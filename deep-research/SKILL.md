---
name: deep-research
description: Guide for conducting deep research with web search agents. Based on DeepWeb-Bench findings — retrieval is not the bottleneck; derivation, cross-source reconciliation, and calibrated abstention dominate errors. Use when doing multi-source quantitative research, cross-referencing financial/industry data, or composing answers from multiple authoritative documents.
license: MIT
metadata:
  source: https://github.com/geokkjer/agent-skills
  paper: https://arxiv.org/abs/2605.21482
  paper_title: "DeepWeb-Bench: A Deep Research Benchmark Demanding Massive Cross-Source Evidence and Long-Horizon Derivation"
---

# Deep Research Skill

Conduct deep research the way frontier agents should: evidence-first, cross-source auditable, derivation-explicit, and calibrated against uncertainty. This skill is grounded in the findings of DeepWeb-Bench (Xie et al., 2026), which found that `retrieval is not the bottleneck` in deep research — it's what happens `after` retrieval that determines answer quality.

## The DeepWeb-Bench Findings (Evidence Base)

Across 100 tasks (6,400 cells per model) evaluated on 9 frontier models (874 of 900 model-task pairs scored):

1. **Retrieval failures account for only 12–14% of errors** (from a 500-cell human-labeled failure sample). Derivation and Calibration failures exceed 70%.
2. **Strong and weak models fail differently.** Top models suffer from *incomplete derivation* (31%); weaker models from *hallucinated precision* (38%).
3. **Models exhibit genuine domain specialization.** Cross-model Spearman ρ = 0.61; per-case disagreement reaches 18.8 percentage points.
4. **Frontier models score 16–33% on the benchmark.** The best model (Codex CLI + GPT-5.5) reaches 33.37%; there is substantial headroom.

The implication: improving deep research requires targeted interventions in **derivation accuracy** and **calibration behavior**, not further scaling of retrieval.

## Core Methodology

### 1. Every Answer Has Three Acceptable Types

When producing a quantitative research answer, choose exactly one:

| Type | When to use | Scoring weight |
|---|---|---|
| **Precise value** | Authoritative source(s) agree on a precise number | Full credit if within tolerance + derivation shown |
| **Range estimate** | Sources disagree, or you must compose/estimate | Partial credit (0.5) with stated method |
| **"Not available"** | No authoritative source supports a precise value | Full credit with justification |

**Never fabricate precision.** If you cannot verify a number from an authoritative source, say so explicitly. A precise-but-wrong number scores 0; a justified "not available" scores 1. This is the single most important calibration rule.

### 2. Every Answer Cites Sources With Provenance

For every value you produce, attach:

- **Source URLs** — the specific pages/documents you used
- **Source-provenance level** — classify each source into one of four tiers:

| Level | Description | Examples |
|---|---|---|
| **T1** | Primary filings, official disclosures, final regulatory rules | SEC 10-K, EU tariff regulation, central bank release |
| **T2** | Methodology-published research, formal statistical datasets | Bureau of Statistics, peer-reviewed datasets |
| **T3** | Reputable media and sell-side research | Bloomberg, Reuters, industry analyst reports |
| **T4** | Informal or unverified sources | Blog posts, forum posts, company marketing pages |

- **Cross-source agreement marker** — one of: `consistent`, `divergent`, or `single` (only one independent source found)

Prefer T1 and T2 sources. When multiple authoritative sources disagree (divergent), acknowledge the divergence and use a range estimate with explicit reconciliation notes.

### 3. Show Your Derivation — Always

For any value that requires computation, composition, or synthesis, include the full derivation chain. This is not optional.

```
Derivation: BYD per-vehicle gross profit
  1. Automotive segment revenue: CNY 602B (source: BYD 2024 annual report, p. 45)
  2. Segment gross margin: 20.2% (source: BYD 2024 annual report, p. 47)
  3. Passenger-vehicle deliveries: 4.27M (source: BYD 2024 production & sales volume announcement)
  4. Gross profit = 602B × 20.2% = CNY 121.6B
  5. Per-vehicle = 121.6B ÷ 4.27M ≈ CNY 28,500
```

**Why this matters:** The DeepWeb-Bench paper's #1 error mode for strong models is *incomplete derivation* — retrieving correct intermediate values but misapplying them in the composition step (e.g., applying a gross-margin rate to total revenue instead of segment revenue). An explicit derivation chain makes this error detectable and correctable.

## The Four Capability Framework

Deep research draws on four distinct capabilities. Every task touches most or all of them. Your answers should demonstrate proficiency in each:

### Retrieval (baseline)
**Find the authoritative source.** Locate primary documents, extract the relevant number, and cite it.

- Only ~12.5% of cells in a deep research task are pure retrieval
- Retrieval is necessary but not sufficient — it's table stakes
- Error mode: *Retrieval gap* — failing to locate an indexable authoritative source

### Derivation (the bottleneck)
**Compose an answer from multiple disclosed numbers through multi-step computation.** The majority of errors originate here.

- Sub-types: Chain derivation, cross-column comparison, sum-of-the-parts decomposition
- Error mode: *Incomplete derivation* — correct inputs, wrong composition step
- Pattern: "Retrieved revenue and margin correctly, applied margin to wrong base"
- **Countermeasure:** Write the derivation first, then compute. Scope-check every intermediate: "Am I applying this rate to the right quantity?"

### Reasoning
**Produce a quantitative answer under a counterfactual or forward trajectory.** Model-based, not extraction-based.

- Sub-types: Scenario reasoning, quantitative extrapolation
- Requires stating assumptions explicitly
- Error mode: *Scope drift* — answering a related but different question

### Calibration
**Know when to abstain and when to acknowledge uncertainty.** This is where models most consistently fail.

- Sub-types: Cross-source conflict resolution, hallucination resistance
- Error mode: *Hallucinated precision* — committing to a number when no authoritative source exists
- Error mode: *Silent source choice* — picking one source's value without acknowledging a conflicting source
- **Countermeasure:** Check cross-source agreement before finalizing. If sources disagree, state the disagreement and provide a range.

## Failure Modes to Avoid

These are the five failure modes identified in DeepWeb-Bench human annotation of 500 failing cells:

| Failure mode | Frequency (top models) | Frequency (other models) | Description |
|---|---|---|---|
| **Incomplete derivation** | 31% | 24% | Correctly retrieves inputs, misapplies a composition step |
| **Hallucinated precision** | 22% | 38% | Commits to precise value when ground truth is "not available" or a range |
| **Silent source choice** | 18% | 14% | Picks one source's value without acknowledging a conflicting source |
| **Scope drift** | 15% | 12% | Answers a related but different question than what was asked |
| **Retrieval gap** | 14% | 12% | Fails to locate a publicly indexable authoritative source |

### How to prevent each failure mode

**Incomplete derivation →** Always write the derivation chain with intermediate quantities labeled. Check that every rate/tax/margin is applied to the correct base. "Gross margin × segment revenue" — verify both are scoped to the same segment.

**Hallucinated precision →** Before submitting a precise number, ask: "Can I cite an authoritative source for this exact value?" If not, produce a range or "not available" with justification. A precise number costs you when wrong but gains nothing over a range when right.

**Silent source choice →** When you find two authoritative sources with different values, state both, explain why they differ (different methodology, reporting period, segment definition), and give a range. Never just pick one.

**Scope drift →** Re-read the question after forming your answer. Check that the entity, the metric, the time period, and the unit match exactly.

**Retrieval gap →** Search with multiple query formulations. Try the entity's official name, ticker, and common aliases. Check regulatory databases (SEC EDGAR, CSRC), not just web search.

## Answer Structure Template

For each research cell (entity × dimension), produce:

```json
{
  "entity": "BYD",
  "dimension": "D2 — Per-vehicle gross profit",
  "value": 28500,
  "unit": "CNY",
  "type": "precise",
  "range_low": null,
  "range_high": null,
  "derivation": "1. Segment revenue: CNY 602B (source: BYD 2024 annual report). 2. Segment gross margin: 20.2% (source: ibid). 3. Gross profit = 602B × 20.2% = CNY 121.6B. 4. Deliveries: 4.27M (source: BYD production report Dec 2024). 5. Per-vehicle = 121.6B / 4.27M ≈ CNY 28,500.",
  "source_urls": [
    "https://www.byd.com/.../annual-report-2024.pdf",
    "https://www.byd.com/.../dec-2024-production-sales.pdf"
  ],
  "source_provenance": {
    "primary": "T1",
    "cross_source": "consistent"
  }
}
```

For a range answer:

```json
{
  "entity": "XPeng",
  "dimension": "D3 — YoY ASP change",
  "value": null,
  "unit": "percent change",
  "type": "range",
  "range_low": -8.0,
  "range_high": -3.0,
  "derivation": "Two authoritative sources disagree due to different segment definitions. Source A (T1, annual filing) implies -3%; Source B (T2, industry data) implies -8%. Reported as range.",
  "source_urls": ["..."],
  "source_provenance": {
    "primary": "T1",
    "cross_source": "divergent",
    "divergence_note": "Segment composition differs: Source A includes only passenger EVs; Source B includes all NEV segments."
  }
}
```

For a "not available" answer:

```json
{
  "entity": "Qualcomm (Cloud AI 100)",
  "dimension": "D6 — Product-line gross margin",
  "value": null,
  "unit": null,
  "type": "not_available",
  "range_low": null,
  "range_high": null,
  "derivation": "Qualcomm does not disclose product-level gross margin for the Cloud AI 100 in any filing (reviewed: 10-K 2024, 10-Q Q1-Q3 2025). No independent research firm publishes a credible estimate.",
  "source_urls": [
    "https://www.sec.gov/.../qualcomm-10k-2024.pdf"
  ],
  "source_provenance": {
    "primary": "T1",
    "cross_source": "single",
    "justification": "Absence of disclosure verified across three quarterly filings and one annual filing."
  }
}
```

## Tool Usage Pattern

When conducting deep research, follow this workflow:

### Phase 1: Evidence Collection

1. **Search for primary sources first** — regulatory filings, official statistics, official announcements. Use `web_search` with entity name + source type keywords.
2. **Read, don't scan** — use `page_visit` to fetch full page content. Search snippets are not evidence.
3. **Fetch PDFs** — annual reports, regulatory filings, and statistics are often PDFs. Use `pdf_fetch` to extract text layers.
4. **Track sources** — maintain a running list of URLs visited, tagged by provenance tier and support verdict.
5. **Search for contradictions** — deliberately query for alternative numbers or conflicting analyses before finalizing.

### Phase 2: Composition and Derivation

6. **Write derivation chains** — for each computed value, list every intermediate with its source.
7. **Scope-check** — verify rates/margins/taxes apply to the correct base; check segment vs. total.
8. **Cross-check** — when multiple sources are available, compare values. If they diverge, document the divergence.
9. **Calibrate** — for each cell, decide: precise, range, or not available? Err toward range when sources disagree, toward "not available" when no credible source exists.

### Phase 3: Verification

10. **Re-read the question** — check entity, metric, period, and unit.
11. **Check source tiers** — prefer T1/T2 sources; flag T4 sources in your provenance record.
12. **Audit your derivations** — verify each arithmetic step before submitting.
13. **Submit only verified answers** — leave cells unanswered (score 0) rather than fabricating.

## Domain Specialization Awareness

DeepWeb-Bench found that models have genuine domain-specific strengths (ρ = 0.61 cross-model agreement). When researching:

- **Know your domain blind spots.** If you lack familiarity with a domain's disclosure conventions (e.g., how REITs report FFO vs. AFFO, how insurance companies report combined ratios), acknowledge this and search for the relevant accounting or reporting standard first.
- **Hardest domains** involve reconciliation of non-standardized disclosures. The lowest single-task cross-model average is mortgage REITs (14.67%); across the six domain categories, Energy & Materials is hardest (24.6%).
- **Easiest domains** are those with abundant, uniform primary filings. The highest single-task average is luxury goods (83.07%); across categories, Healthcare is easiest (30.7%).
- **Strategy for unfamiliar domains:** start by understanding the reporting framework, not by searching for individual numbers.

## When NOT to Use This Skill

- Simple single-fact lookups — use standard web search, not deep research methodology
- Creative or subjective analysis — this skill is for quantitative, source-backed research
- Code or software engineering — use a coding-specific skill instead
- Tasks where a quick estimate is acceptable without source auditing

## Style Summary

| Do | Don't |
|---|---|
| Cite T1/T2 sources with provenance tags | Accept T4 sources without disclosure |
| Show derivation chains for every computed value | Report a final number without intermediate steps |
| Return "not available" when evidence is absent | Fabricate precision to fill every cell |
| Use ranges when sources disagree | Silently pick one source over another |
| Scope-check every intermediate computation | Apply rates/margins to wrong bases |
| Search for contradictions before finalizing | Accept the first number you find |
| Track cross-source agreement (consistent/divergent/single) | Present a single-source answer as definitive |
| Read full pages via page_visit | Rely on search snippets only |
