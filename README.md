## Mohammed Elsiddig

AI engineer in Dubai. I lead the AI work at Debot Intelligent Automation, part of Royal Furniture Group, mostly on LLM agents for day-to-day operations and some robotics. My repositories are private (employer and client code), so here is a short note on some of the work.

**Royal AI Assistant** · 2026 · TypeScript, PostgreSQL, AWS CDK<br>
A WhatsApp assistant for the group's customers and staff, in English, Arabic and Hindi. It answers from live ERP data and hands anything it can't resolve to the right team as a ticket. It handles about 3,500 messages a day.

<details>
<summary>Notes</summary>

- Access rules live in Postgres (row-level security that fails closed, writes through definer functions), not in the prompt. The ERP is mirrored one way into a scoped replica.
- Changes are tested against ~340 scenarios that send real webhooks to staging and check the reply, the SQL it ran and the rows it left.
- The incoming gate checks signatures, drops duplicates and stays quiet while a person is replying on the same number.
- Fixes to the third-party agent framework are small checked patches, each with a kill switch; rate limits and an egress allowlist keep failures contained.
</details>

**Growbal AI Core** · 2025 · Python, Django, LangGraph, pgvector<br>
Crawlers and a matching agent for a Gulf marketplace of company-formation, tax and visa providers. Building a provider profile cost under $0.10.

<details>
<summary>Notes</summary>

- Page text is line-numbered so a small model returns only the line ranges worth reading; later served from a fine-tuned open-weight model on vLLM.
- Search combines pgvector similarity with a small tag-match boost, and a LangGraph agent searches, checks and summarises.
- Onboarding researches the provider first, so they confirm details instead of typing them.
</details>

**Lernactal-OS** · 2026 · Python, Docker · personal<br>
An experiment in running a few AI agents (Hermes and Claude Code) on one machine, behind a Telegram chat, for job search, news and forecasting. Most of the work goes into keeping them in check.

<details>
<summary>Notes</summary>

- Each agent's prompt, model and settings are versioned and measured, and only a higher-level agent (or I) can change them.
- Checks that need a second look escalate from code to a small model, to an agent, to me.
- Probabilities are computed in code; models only grade single pieces of evidence.
- A change lands only with an end-to-end test and a review by a separate agent; usage budgets stop sessions before limits.
</details>

**Smaller projects**
- Stock-Health Agent: inventory advice where the LLM calls a deterministic stock engine instead of doing the arithmetic.
- Budget Analyst Agent: text-to-SQL that loads only the schema it needs and checks every query is read-only.
- LLM Robot Cell: ROS2 pick-and-place where a deterministic safety check can reject the LLM's plan and ask for another.
- Robotics AI Bench: pose and hand tracking for an industrial arm, with the AI kept advisory.
- Video Engagement Model and Hybrid RAG + SQL Agent; earlier, algal-bloom detection, traffic forecasting and computer vision work.

<!-- TRACK:START -->
<details>
<summary>Project list: 25 repositories since 2021, 23 my own and 2 contributed to, all private</summary>

| Project | What it is | Stack | Period |
|---|---|---|---|
| **Lernactal-OS** | Personal project: a few AI agents for job search, news and forecasting, with tests and budgets around every change | Python · Hermes Agent · Claude Code · Docker | 2026-09 → 2026-10 |
| **Royal AI Assistant** | WhatsApp assistant for the customers and staff of a UAE retail group | TypeScript · PostgreSQL · AWS · OpenClaw | 2026-03 → 2026-09 |
| **Stock-Health Agent** | Inventory advisor: LLM drives a deterministic stock engine and a bounded research sub-agent inside an egress-locked runtime | TypeScript · OpenClaw · AWS CDK | 2026-04 |
| **Robotics AI Bench** | Phase-0 perception bench for an industrial arm: GPU pose workers over ZeroMQ, telemetry, AI kept advisory | Python · Docker · YOLO11 · MediaPipe | 2026-04 |
| **LLM Robot Cell** | ROS2 cell where LLM motion plans pass a deterministic safety gate; rejections feed back into replanning | Python · ROS2 · FastAPI | 2026-02 |
| **Budget Analyst UI** | Streaming chat front end for the budget analyst: tool-call events over the Vercel AI SDK | TypeScript · Next.js · AI SDK | 2026-02 |
| **Budget Analyst Agent** | Text-to-SQL analyst: token-budgeted schema loading, read-only SQL validation, DSPy-compiled modules, calibrated confidence | Python · LangGraph · DSPy · MCP | 2026-01 → 2026-02 |
| **Growbal AI Core** | Agentic crawler, hybrid vector search and onboarding research agent for a B2B services marketplace | Python · Django · LangGraph · pgvector | 2025-06 → 2025-10 |
| **Hybrid RAG + SQL Agent** | Routes questions to documents, SQL or both on a local 3.8B model, with typed repair loops and citations | Python · LangGraph · DSPy · Ollama | 2025-09 |
| **Video Engagement Model** | Multimodal engagement predictor: SigLIP2 frame embeddings through a DeiT encoder, fused with text | PyTorch · Keras · Transformers | 2025-04 |
| **Speaking Coach** | Local reasoning-model coach with a staged assessment dialogue and an embedding-quantised response cache | Python · Ollama · Gradio | 2025-03 |
| **Research Digest Agent** | Scheduled search → relevance filter → summariser–reviewer critique loop → daily e-mail digest | Python · LangGraph | 2025-03 |
| **BirdCLEF 2024** | Audio frames (MFCC + RMS) reshaped by convolution into a pretrained ViT's input space | TensorFlow · Keras | 2024-06 |
| **Harmful Algae Detection** | CNN proof of concept on underwater microscopy for a harmful-algal-bloom early-warning system | TensorFlow · DVC | 2024-01 |
| **Logo Standardizer** | OpenCV pipeline that finds a logo and its background and normalises crop, centring and mask | Python · OpenCV | 2023-04 |
| **Graph Traffic Forecast** | GCN-LSTM spatio-temporal forecasting on a road-sensor graph (MASE 0.69 vs naive) | TensorFlow · StellarGraph | 2021-10 |

<sub>The code is private; only names, descriptions and dates are shown. 9 more (client work and experiments) are not listed. Generated by <code>scripts/track-record.sh</code>.</sub>
</details>
<!-- TRACK:END -->

[LinkedIn](https://www.linkedin.com/in/mohammed-elsiddig-aa3211193) · B.Eng. Electrical & Electronic Engineering, University of Nottingham
