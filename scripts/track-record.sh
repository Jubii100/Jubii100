#!/usr/bin/env bash
# Rewrites the block between <!-- TRACK:START --> and <!-- TRACK:END --> in README.md
# from repository METADATA only (counts, languages, dates). Code never leaves the repos.
#
# Privacy model: repos are keyed by numeric id in showcase.json and printed ONLY
# under the public title given there. Every other repo is counted, never named,
# so client names, codenames and interview tasks stay private.
#
# Needs: gh, jq; a token able to read repo metadata (see SETUP.md).
# Usage: scripts/track-record.sh [--check]   (--check: exit 1 if README would change)
set -euo pipefail

cd "$(dirname "$0")/.."
README=README.md
CONFIG=showcase.json
CHECK=${1:-}

[ -f "$README" ] && [ -f "$CONFIG" ] || { echo "track-record: README.md or showcase.json missing" >&2; exit 2; }
grep -q '<!-- TRACK:START -->' "$README" && grep -q '<!-- TRACK:END -->' "$README" \
  || { echo "track-record: markers missing in README.md" >&2; exit 2; }

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

# 1. Every repo the token can see (owned, collaborator, org member). Forks are not track record.
gh api --paginate "/user/repos?affiliation=owner,collaborator,organization_member&per_page=100" \
  --jq '.[] | select(.fork | not) | {id: (.id | tostring), owner: .owner.login, private, language, created_at, pushed_at}' \
  | jq -s '.' > "$tmp/repos.json"
[ "$(jq length "$tmp/repos.json")" -gt 0 ] || { echo "track-record: API returned no repos (token scope?)" >&2; exit 3; }

# 2. Merge in collaborations the token cannot see (fine-grained tokens cover one owner only).
login=$(gh api user --jq .login)
jq --arg me "$login" --slurpfile cfg "$CONFIG" '
  ($cfg[0].external // []) as $ext
  | ($cfg[0].exclude // []) as $drop
  | map(select(.id as $i | $drop | index($i) | not))
  | (map(.id)) as $seen
  | . + [ $ext[] | select((.id | tostring) as $i | $seen | index($i) | not)
          | {id: (.id | tostring), owner: "external", private: true, language,
             created_at: (.since + "-01T00:00:00Z"), pushed_at: ((.until // .since) + "-01T00:00:00Z")} ]
  | map(. + {mine: (.owner == $me), pushed_at: (.pushed_at // .created_at)})
' "$tmp/repos.json" > "$tmp/all.json"

# A showcased repo the token cannot see would silently vanish from the table: fail instead.
missing=$(jq -r --slurpfile cfg "$CONFIG" '(map(.id)) as $have
  | $cfg[0].showcase | keys[] | select(. as $k | $have | index($k) | not)' "$tmp/all.json")
[ -z "$missing" ] || { echo "track-record: showcase ids not visible to the token (add them under external): $missing" >&2; exit 4; }

# 3. Render the block.
jq -r --slurpfile cfg "$CONFIG" '
  ($cfg[0].showcase // {}) as $show
  | length as $n
  | (map(select(.mine)) | length) as $owned
  | (map(select(.private)) | length) as $priv
  | (map(.created_at[:4]) | min) as $since
  | (map(.pushed_at[:7]) | max) as $last
  | ([.[] | .language // empty] | group_by(.) | map({l: .[0], c: length}) | sort_by(-.c) | .[:7]
      | map("`\(.l)` \(.c)") | join(" · ")) as $langs
  | (map(select($show[.id])) | sort_by(.pushed_at) | reverse) as $named
  | ($n - ($named | length)) as $unnamed
  | [
      "**\($n) repositories** · \($owned) owned · \($n - $owned) contributed to · \(if $priv == $n then "all private" else "\($priv) private" end) · active since \($since) · last push \($last)<br>",
      "<sub>By language: \($langs)</sub>",
      "",
      "<details>",
      "<summary><b>\($named | length) named projects</b> · \($unnamed) more counted, not named</summary>",
      "",
      "| Project | What it is | Stack | Period |",
      "|---|---|---|---|",
      ( $named[] | $show[.id] as $s
        | "| **\($s.title)** \(if .private then "🔒" else "" end) | \($s.line) | \($s.stack // .language // "—") | \($s.period // (if .created_at[:7] == .pushed_at[:7] then .created_at[:7] else "\(.created_at[:7]) → \(.pushed_at[:7])" end)) |" ),
      "",
      "<sub>🔒 private: name, description and dates shown; code is not. The \($unnamed) unnamed repositories are client work, research notebooks and experiments. Generated from repository metadata by <code>scripts/track-record.sh</code>.</sub>",
      "</details>"
    ] | .[]
' "$tmp/all.json" > "$tmp/block.md"

# 4. Splice between the markers.
{
  sed '/<!-- TRACK:START -->/q' "$README"
  cat "$tmp/block.md"
  sed -n '/<!-- TRACK:END -->/,$p' "$README"
} > "$tmp/README.new"

if cmp -s "$tmp/README.new" "$README"; then
  echo "track-record: unchanged"
  exit 0
fi
if [ "$CHECK" = "--check" ]; then
  echo "track-record: README.md is stale" >&2
  exit 1
fi
cp "$tmp/README.new" "$README"
echo "track-record: README.md updated ($(jq length "$tmp/all.json") repositories)"
