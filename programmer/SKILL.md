---
name: programmer
description: Guide for agentic programming with terminal agents — command validation, multi-step verification, failure recovery, and tool-aware execution. Based on Terminal-Bench, LiveCodeBench, and SWE-bench findings. Use when writing code, debugging, running shell commands, fixing bugs, or building software with LLM agents.
license: MIT
metadata:
  source: https://github.com/geokkjer/agent-skills
  papers: >
    Terminal-Bench (arXiv:2601.11868, https://arxiv.org/abs/2601.11868);
    LiveCodeBench (arXiv:2403.07974, https://arxiv.org/abs/2403.07974);
    SWE-bench (arXiv:2310.06770, https://arxiv.org/abs/2310.06770)
---

# Programmer Skill

Write code agentically — validate before executing, verify after,
recover from failures, and pick the right tool for the job. This skill is
grounded in findings from Terminal-Bench (Merrill et al., 2026),
LiveCodeBench (Jain et al., 2024), and SWE-bench (Jimenez et al., 2024).

This skill also embodies three virtues:

**Laziness:** Never do work that doesn't need doing. Before acting, ask: is this the minimum effort that solves the problem? Prefer the simplest solution. Avoid over-engineering. If something already exists and works, use it — don't rebuild it. Document your reasoning so you don't have to explain yourself twice.

**Impatience:** Respect the user's time above all. Respond with what they need, not everything you know. Anticipate what they'll ask next and address it now. If a task can be done in parallel, do it in parallel. If a shorter answer suffices, give the shorter answer. Never make the user wait for information they didn't ask for.

**Hubris:** Take responsibility for quality. Every output you produce should be correct, tested, and something you'd stand behind. If you're unsure, say so — silence about uncertainty is worse than admitting it. Don't produce code you wouldn't want your name on. When you make a mistake, fix it thoroughly, not patch it minimally.

When these virtues conflict:
- Laziness says "do less" — Hubris says "do it right". Choose right.
- Impatience says "be fast" — Hubris says "be correct". Choose correct.
- Laziness says "skip it" — Impatience says "they need this now". Choose action.

The hierarchy is: correctness first, speed second, brevity third.

## The Evidence Base

Across three major coding benchmarks evaluating dozens of frontier models:

### Terminal-Bench 2.0 (89 hard terminal tasks, 21 models)

1. **Command failures are not random — they're systematic.** Calling executables
   that aren't installed or not in PATH accounts for 24.1% of all command
   failures. Failures when running executables add another 9.6%. Together,
   environment mismatch is the #1 failure (both figures measured on Terminus 2
   trajectories).

2. **Strong and weak models fail differently.** Frontier models' errors
   are dominated by execution mistakes. Weaker models show a more balanced
   pattern — they also fail at coherence (bad planning) and verification
   (not checking their work).

3. **Model selection matters more than agent scaffold.** Upgrading from
   GPT-5-Nano to GPT-5.2 with the same scaffold improved resolution by
   +52 percentage points; switching scaffolds with the same model yielded
   only +17 points (Gemini-2.5-Pro, OpenHands → Terminus 2).

4. **More turns ≠ better results.** No correlation between turn count,
   token count, and task success. Efficiency matters more than volume.

5. **State-of-the-art is 63%.** The best configuration (Codex CLI + GPT-5.2)
   resolves 63% of tasks (leaderboard computed over 74 of the 89 tasks).
   The best open-weight model (Kimi K2 Thinking + Terminus 2) resolves ~36%.

### LiveCodeBench (511 programming problems, 52 models)

6. **Contamination is real.** Models show sharp performance drops on
   problems released after their training cutoff (e.g., DeepSeek-33B drops
   from ~60% to ~0% Pass@1 on post-cutoff LeetCode problems).

7. **Models overfit to HumanEval.** Fine-tuned open models score high on
   HumanEval but fail LiveCodeBench. Closed models maintain consistent
   performance across both.

8. **Holistic capability gaps exist.** Model rankings shift across code
   generation, self-repair, execution, and test output prediction —
   GPT-4-Turbo and Claude-3-Opus rank at the top across all scenarios,
   with the lead varying by sub-task.

### SWE-bench (2,294 real GitHub issues)

9. **Real-world bug fixing tests the full stack.** SWE-bench tasks require
   repository understanding, test-driven validation, and patch generation
   — not just isolated function writing.

---

## The Four Capability Framework

Agentic programming draws on four distinct capabilities. Every task touches
most or all of them. Your approach should demonstrate proficiency in each:

### Execution (the bottleneck)
**Run the right command the right way.** Terminal-Bench found this
dominates all failure categories.

- Check the environment before acting: what's installed? what's the working
  directory? what are the permissions?
- Error mode: *Executable not found* (24.1%) — calling a tool that isn't
  installed or not in PATH
- Error mode: *Execution failure* (9.6%) — calling the right tool with
  wrong arguments or in the wrong context
- **Countermeasure:** Always verify tool availability before calling it.
  `which <tool>` or `command -v <tool>` before first use. Use `--help`
  to confirm flags exist.

### Coherence (the plan)
**Make a plan that makes sense.** Multi-step reasoning before action.

- Think through the full sequence before executing. One wrong step in a
  pipeline corrupts downstream results.
- Error mode: *Disobey task specification* — doing something related but
  not what was asked
- Error mode: *Step repetition* — looping on the same action expecting
  different results
- Error mode: *Reasoning-action mismatch* — describing one plan but
  executing a different one
- **Countermeasure:** Write the plan as comments before code. Then
  execute exactly what the plan says. When you deviate, update the plan.

### Verification (the check)
**Verify your work.** Strong models do this better than weak ones —
Terminal-Bench shows this is a key differentiator.

- After every significant action, check the result. Did the file write?
  Did the test pass? Did the output match expectations?
- Error mode: *No/irrelevant verification* — completing the task without
  checking if it worked
- Error mode: *Weak verification* — running a test but ignoring the
  failure, or checking the wrong property
- Error mode: *Unaware of termination conditions* — the task is done but
  the agent keeps going, or the task isn't done but the agent stops
- **Countermeasure:** For every action, state what success looks like
  before executing, then verify against that definition after.

### Tool Selection (the toolkit)
**Pick the right tool for the job.** Different tasks need different
approaches — file editing, shell commands, script writing, or library calls.

- Know your tool inventory. Don't write 50 lines of Python when `jq`
  would do it in one. Don't use `sed` when a proper parser exists.
- Error mode: *Wrong tool for the job* — using a text editor when a
  compiler flag would work, or writing a script for a built-in command
- Error mode: *Over-engineering* — building a complex solution for a
  simple problem
- **Countermeasure:** Before writing code, ask: "Is there an existing
  tool, built-in command, or library function that already does this?"

---

## Failure Modes to Avoid

Based on Terminal-Bench's trajectory and command-level failure taxonomies:

### Command-Level Failures (what breaks at execution time)

| Failure | Frequency | Prevention |
|---|---|---|
| **Executable not found / not in PATH** | 24.1% | `command -v <tool>` before first use |
| **Execution failure** | 9.6% | Check flags with `--help`; validate inputs |
| **Wrong working directory** | Common | `pwd` at start; use absolute paths |
| **Permission denied** | Common | `ls -la` to check permissions first |
| **Syntax error in command** | Common | Read the command before hitting enter |

### Trajectory-Level Failures (why the whole task fails)

| Failure mode | Strong models | Weak models | Prevention |
|---|---|---|---|
| **Execution errors** | Dominate | Moderate | Pre-flight checks before every command |
| **Coherence failures** | Low | Higher | Plan first, execute second, update plan |
| **Verification failures** | Low | Higher | Verify after every action; define success criteria upfront |
| **Premature termination** | Occasional | Common | Check termination condition explicitly |
| **Context loss** | Rare | Common | Summarize state periodically; re-read task spec |

---

## Workflow: Agentic Programming Loop

```
┌─────────────────────────────────────────────────────┐
│  1. UNDERSTAND the task                              │
│     • What's the goal? What defines "done"?          │
│     • What's the environment? What tools exist?      │
├─────────────────────────────────────────────────────┤
│  2. PLAN the approach                                │
│     • Write the plan as comments                     │
│     • Identify each step's inputs and expected output │
├─────────────────────────────────────────────────────┤
│  3. CHECK environment before acting                  │
│     • pwd, ls, command -v, python --version, etc.    │
│     • Read existing code before editing              │
├─────────────────────────────────────────────────────┤
│  4. EXECUTE one action                               │
│     • Run the command / write the code                │
│     • Capture output and exit code                    │
├─────────────────────────────────────────────────────┤
│  5. VERIFY the result                                │
│     • Did it do what we expected?                    │
│     • If not: diagnose, adjust, retry ONCE           │
│     • If still failing: re-plan, don't loop          │
├─────────────────────────────────────────────────────┤
│  6. CHECK termination                                │
│     • Is the task complete by its own definition?     │
│     • If yes: clean up and stop                      │
│     • If no: return to step 2 for next sub-goal      │
└─────────────────────────────────────────────────────┘
```

### Phase 1 — Understand & Plan (Coherence)

1. **Read the task specification carefully.** Re-read it. What exactly is
   being asked? What files exist? What's the expected output?
2. **Survey the environment.** `ls -la`, `tree`, `pwd`, `git status`,
   `python --version`, `node --version`, whatever's relevant.
3. **Read existing code** before touching it. `cat`, `rg`, `grep` to
   understand structure. Don't edit blind.
4. **Write a plan as comments.** Each step: what tool, what input, what
   expected output, how to verify.

### Phase 2 — Execute & Verify (Execution + Verification)

5. **Check tool availability.** `command -v <tool>` or `which <tool>`.
   If missing, install it or find an alternative.
6. **Validate command syntax.** Use `--help` to confirm flags. Quote
   arguments properly. Handle spaces and special characters.
7. **Execute one action at a time.** Don't chain 5 commands with `&&`
   unless you've tested each individually.
8. **Verify immediately.** Check exit codes. Compare output to expected.
   If the action failed, diagnose from the error message — don't just
   re-run the same command.

### Phase 3 — Recover (Don't Loop)

9. **On failure, change something.** A different flag, a different tool,
   a different approach. Never repeat the same failing command more than
   once without modification.
10. **If stuck, re-read the plan.** Did you skip a step? Did the
    environment change? Are you solving the wrong problem?
11. **Know when to stop.** If the task is complete, stop. If the task
    is impossible in this environment, say so and explain why.

---

## Language-Specific Patterns

### Shell scripting (bash)

```bash
# Always: start with shebang and error handling
#!/usr/bin/env bash
set -euo pipefail

# Check if required tools exist
for cmd in jq curl git; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed" >&2
    exit 1
  fi
done
```

### Python

```python
# Always: check Python version and availability
import sys
assert sys.version_info >= (3, 9), "Python 3.9+ required"

# Verify imports before use
try:
    import requests
except ImportError:
    print("requests not installed. Run: pip install requests")
    sys.exit(1)
```

### Node.js / TypeScript

```bash
# Check node and package manager
node --version
npm --version  # or pnpm --version
# Check if node_modules exists before running
ls node_modules/.package-lock.json 2>/dev/null || npm install
```

### Git operations

```bash
# Always check state before mutating
git status --short
git branch --show-current
# Verify what you're about to change
git diff --stat
```

---

## Anti-Patterns

| ❌ Don't | ✅ Do |
|---|---|
| Run `npm install` without checking Node version | `node --version && npm --version` first |
| Edit a file without reading it first | `cat` or `read` before `edit` or `write` |
| Chain 5 untested commands with `&&` | Test each command individually |
| Loop on the same failing command | Change the approach after one retry |
| Assume a tool is installed | `command -v <tool>` before first use |
| Write 50 lines of Python when `jq` does it | Check tool inventory before writing code |
| Skip verification after editing | Run tests, check output, compare to expected |
| Keep going after the task is done | Check termination condition explicitly |
| Write code without understanding the codebase | `rg`/`grep` to find patterns, read adjacent files |

---

## When to Use This Skill

- Writing, editing, or debugging code
- Running shell commands and pipelines
- Fixing bugs in an existing codebase
- Setting up development environments
- Building software with command-line tools
- Repository-level tasks (multi-file changes, refactoring)

## When NOT to Use This Skill

- Simple single-question lookups — just answer directly
- Creative writing or content generation — use a writing skill
- Web research for factual answers — use the deep-research skill
- Anything without a code or terminal component

---

## Style Summary

| Do | Don't |
|---|---|
| Check environment before executing | Assume tools are installed |
| Write the plan as comments first | Start coding without a plan |
| Verify after every significant action | Trust that it "probably worked" |
| Change approach after one failed retry | Loop on the same failing command |
| Read existing code before editing | Modify files you haven't read |
| Use absolute paths when uncertain | Assume `$PWD` is correct |
| Check exit codes and error messages | Ignore `stderr` output |
| Stop when the task is complete | Keep optimizing a finished task |
