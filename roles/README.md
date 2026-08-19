# Agent Roles

System prompts paired with model recommendations for specific research tasks.

## Roles

| Role | File | Recommended Models |
|---|---|---|
| Deep Research Analyst | [deep-research-analyst.md](deep-research-analyst.md) | GPT-5.5, Claude Opus 4.7 |
| Programmer | [programmer.md](programmer.md) | GPT-5.2 + Codex CLI, Claude Opus 4.5 (Terminus 2 or Claude Code) |

## Model Selection Guide

### Deep Research

Based on DeepWeb-Bench (Xie et al., 2026) evaluation across 9 frontier models
on 100 deep research tasks (6,400 independently scored cells):

### Tier 1 — Best for Deep Research

| Model | Overall | Retrieval | Derivation | Calibration | Reasoning |
|---|---|---|---|---|---|
| **GPT-5.5** | **33.37%** | 37.84% | **32.55%** | **34.16%** | **32.38%** |
| **Claude Opus 4.7** | **31.84%** | **36.52%** | 30.97% | 31.14% | **31.59%** |

Note: the paper's top configuration is **Codex CLI + GPT-5.5** (GPT-5.5
accessed through the Codex CLI harness); bare GPT-5.5 appears only as the
automated rubric grader there.

**Recommendation:** For deep research tasks, prefer **GPT-5.5** when the task is
derivation-heavy (multi-step composition, extrapolation). Prefer **Claude Opus 4.7**
when source discovery is the hardest part (unusual filings, non-standard disclosure).

### Tier 2 — Solid Performers

| Model | Overall | Notes |
|---|---|---|
| DeepSeek V4 Pro | 28.68% | Balanced across families |
| GLM 5.1 | 28.18% | Slightly stronger at Retrieval |
| Claude Sonnet 4.6 | 27.97% | Cost-effective, strong Retrieval |
| DeepSeek V4 Flash | 27.73% | Best latency/performance ratio |
| Qwen 3.6 Plus | 26.54% | Watch for hallucinated precision |

### Tier 3 — Budget / Niche

| Model | Overall | Notes |
|---|---|---|
| MiniMax M2.7 | 24.06% | Verbose answers (avg 32,948 chars) |
| Kimi K2.6 | 16.79% | Not recommended for deep research |

### Programming

Based on Terminal-Bench, LiveCodeBench, and SWE-bench:

#### Tier 1 — Best for Agentic Programming

| Model + Scaffold | Terminal-Bench | Notes | Best for |
|---|---|---|---|
| **GPT-5.2 + Codex CLI** | **63%** | Top overall; leads code generation | Repository-level tasks, complex multi-step |
| **Claude Opus 4.5 + Terminus 2** | **58%** | Strong comprehension; good for debugging & review | Debugging, code review, understanding |
| **Gemini 3 Pro + Terminus 2** | **57%** | Broad capability coverage | General tasks needing wide skillset |

Claude Opus 4.5 + Claude Code resolves 52% on Terminal-Bench — solid, but
Terminus 2 is the stronger scaffold for Opus 4.5.

#### Tier 2 — Solid Performers

| Model + Scaffold | Notes |
|---|---|
| Claude Opus 4.5 + Claude Code | 52% on Terminal-Bench — solid; Terminus 2 is the stronger scaffold for Opus 4.5 |
| Kimi K2 Thinking + Terminus 2 | ~36% — best open-weight configuration in the paper |
| GPT-5.1 + Codex CLI | Not benchmarked in the cited papers; expected good cost-performance within the 5.x family |
| Claude Sonnet 4.6 + Claude Code | Not benchmarked in the cited papers; fast, cost-effective option |

#### Key Insight: Sub-Task Specialization

LiveCodeBench (2024) found model rankings shift across coding sub-tasks:
- **Code generation:** GPT-4-Turbo leads
- **Self-repair (debugging):** GPT-4-Turbo leads
- **Code execution prediction:** Claude-3-Opus and Mistral-L excel
- **Test output prediction:** Claude-3-Opus surpasses GPT-4-Turbo

Terminal-Bench also found that **model choice matters more than scaffold**
(+52 percentage points from a model upgrade vs. +17 from a scaffold change).

#### Key Insight: Domain Specialization

Based on DeepWeb-Bench

Model rankings shift across domains. Cross-model Spearman correlation is
only ρ = 0.61, and per-case model disagreement reaches 18.8 percentage
points. A model strong in one domain can rank near-bottom in another.

- **Hardest domains** (cross-model avg 14-20%): mortgage REITs, insurance —
  non-standardized disclosures, heavy reconciliation required
- **Easiest domains** (cross-model avg 70-83%): luxury goods, consumer
  electronics — abundant T1 filings, uniform reporting standards

Note: the 14-20% / 70-83% figures are per-case (single-task) cross-model
averages. Across the paper's six domain categories the spread is much
tighter: Energy & Materials is hardest (24.6%) and Healthcare easiest
(30.7%).

**For critical research:** consider ensemble (run with top-2 models, flag answers
that disagree) or domain-specific model selection.

### How These Scores Are Computed

Each of 100 tasks is an 8×8 matrix of entities against research dimensions
(64 cells per task, 6,400 cells total). Each cell is scored on a 4-tier
rubric: 1 (full credit), 0.5 (partial), 0.25 (marginal), 0 (wrong or missing).

The benchmark score is the mean cell score across all 100 tasks for that model.

Source: DeepWeb-Bench Table 1. Paper: <https://arxiv.org/abs/2605.21482>

Sources for programming: Terminal-Bench <https://arxiv.org/abs/2601.11868>,
LiveCodeBench <https://arxiv.org/abs/2403.07974>, SWE-bench <https://arxiv.org/abs/2310.06770>
