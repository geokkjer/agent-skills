# agent-skills

A collection of agent skills for Pi (and any other Agent Skills-compatible harness).

## Skills

| Skill | Install | Description |
|---|---|---|
| [elisp-functional](elisp-functional/) | `npx skills add geokkjer/agent-skills@elisp-functional` | Write Emacs Lisp with functional programming idioms — `seq-map` over `dolist`, `thread-last` over nesting, `pcase` over `car`/`cdr` |
| [deep-research](deep-research/) | `npx skills add geokkjer/agent-skills@deep-research` | Conduct deep quantitative research with source provenance tracking, cross-source reconciliation, derivation chains, and calibrated uncertainty — based on DeepWeb-Bench findings |
| [programmer](programmer/) | `npx skills add geokkjer/agent-skills@programmer` | Agentic programming with command validation, multi-step verification, failure recovery, and tool-aware execution — based on Terminal-Bench, LiveCodeBench, and SWE-bench findings |
| [unslop](unslop/) | `npx skills add geokkjer/agent-skills@unslop` | Cut AI tells from prose and add human voice — concrete anti-patterns plus "adding soul" guidance (adapted from [backnotprop/pstack](https://github.com/backnotprop/pstack)) |

## Usage

Install all skills:
```sh
npx skills add geokkjer/agent-skills        # interactive: select skills to install
npx skills add geokkjer/agent-skills --all  # or -y: install everything unattended
```

Install a single skill:
```sh
npx skills add geokkjer/agent-skills@elisp-functional
```

## Roles

Pre-configured system prompts with model recommendations:

| Role | File |
|---|---|
| [Deep Research Analyst](roles/deep-research-analyst.md) | Multi-source quantitative research with provenance tracking |
| [Programmer](roles/programmer.md) | Agentic coding, debugging, and shipping with validation and verification |

See [roles/README.md](roles/README.md) for model selection guide.

## License

[MIT](LICENSE)
