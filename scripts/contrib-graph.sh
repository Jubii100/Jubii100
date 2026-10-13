#!/usr/bin/env bash
# Renders the profile's contribution calendar (last 12 months) as two SVGs, light and dark,
# so the README can show it at the top: GitHub always places its own graph below the README.
#
# Data: the GraphQL contributionCalendar, the same per-day counts and levels the public
# profile shows (private contributions appear as counts only, when the profile shares them).
# Any token works, including the Actions GITHUB_TOKEN.
#
# Needs: gh, jq. Usage: scripts/contrib-graph.sh [LOGIN]   (default: Jubii100)
set -euo pipefail

cd "$(dirname "$0")/.."
LOGIN=${1:-Jubii100}
OUT=assets
mkdir -p "$OUT"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

gh api graphql -f login="$LOGIN" -f query='
  query($login: String!) { user(login: $login) { contributionsCollection { contributionCalendar {
    totalContributions weeks { contributionDays { date contributionCount contributionLevel weekday } } } } } }' \
  --jq '.data.user.contributionsCollection.contributionCalendar' > "$tmp/cal.json"
[ "$(jq '.weeks | length' "$tmp/cal.json")" -gt 0 ] || { echo "contrib-graph: no calendar returned" >&2; exit 3; }

# $1: light | dark. Writes $tmp/$1.svg.
render() {
  jq -r --arg theme "$1" --arg login "$LOGIN" '
    ({ light: { c: ["#ebedf0","#9be9a8","#40c463","#30a14e","#216e39"], t: "#57606a" },
       dark:  { c: ["#161b22","#0e4429","#006d32","#26a641","#39d353"], t: "#8b949e" } }[$theme]) as $p
    | {"NONE":0,"FIRST_QUARTILE":1,"SECOND_QUARTILE":2,"THIRD_QUARTILE":3,"FOURTH_QUARTILE":4} as $lv
    | ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"] as $mon
    | 13 as $s | 32 as $x0 | 20 as $y0
    | (.weeks | length) as $nw
    | ($x0 + $nw * $s) as $w
    | ($y0 + 7 * $s + 24) as $h
    | "font-family=\"-apple-system,BlinkMacSystemFont,Segoe UI,Helvetica,Arial,sans-serif\" font-size=\"10\" fill=\"\($p.t)\"" as $font
    | [
        "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 \($w) \($h)\" width=\"\($w)\" height=\"\($h)\" role=\"img\" aria-labelledby=\"t\">",
        "<title id=\"t\">\(.totalContributions) contributions by \($login) in the last year, private repositories included as counts</title>",
        "<g \($font)>",
        # month labels where a week starts a new month (none in the last two columns)
        ( [ .weeks | to_entries[] | {i: .key, m: (.value.contributionDays[0].date[5:7] | tonumber)} ]
          | . as $ws
          | range(0; length) as $k
          | select($k > 0 and $ws[$k].m != $ws[$k - 1].m and $k < $nw - 2)
          | "<text x=\"\($x0 + $ws[$k].i * $s)\" y=\"12\">\($mon[$ws[$k].m - 1])</text>" ),
        "<text x=\"0\" y=\"\($y0 + 1 * $s + 9)\">Mon</text>",
        "<text x=\"0\" y=\"\($y0 + 3 * $s + 9)\">Wed</text>",
        "<text x=\"0\" y=\"\($y0 + 5 * $s + 9)\">Fri</text>",
        "<text x=\"\($x0)\" y=\"\($h - 6)\">\(.totalContributions | tostring | if length > 3 then .[:-3] + "," + .[-3:] else . end) contributions in the last year · private work counted, code not shown</text>",
        "<text x=\"\($w - 5 * $s - 34)\" y=\"\($h - 6)\" text-anchor=\"end\">Less</text>",
        ( range(0; 5) as $l
          | "<rect x=\"\($w - (5 - $l) * $s - 28)\" y=\"\($h - 15)\" width=\"10\" height=\"10\" rx=\"2\" fill=\"\($p.c[$l])\"/>" ),
        "<text x=\"\($w - 26)\" y=\"\($h - 6)\">More</text>",
        "</g>",
        ( .weeks | to_entries[] | .key as $i | .value.contributionDays[]
          | "<rect x=\"\($x0 + $i * $s)\" y=\"\($y0 + .weekday * $s)\" width=\"10\" height=\"10\" rx=\"2\" fill=\"\($p.c[$lv[.contributionLevel]])\"><title>\(.date): \(.contributionCount)</title></rect>" ),
        "</svg>"
      ] | .[]
  ' "$tmp/cal.json" > "$tmp/$1.svg"
}

# Render both first (set -e stops on any failure), then replace only what differs.
render light
render dark
changed=unchanged
for t in light dark; do
  grep -q '</svg>' "$tmp/$t.svg" || { echo "contrib-graph: $t.svg incomplete" >&2; exit 4; }
  cmp -s "$tmp/$t.svg" "$OUT/contrib-$t.svg" || { cp "$tmp/$t.svg" "$OUT/contrib-$t.svg"; changed=updated; }
done
echo "contrib-graph: $(jq .totalContributions "$tmp/cal.json") contributions; $changed"
