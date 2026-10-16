# writing: sources

This is a custom merge of two skills plus an adapted Portuguese port. It is not
tracked against upstream and there is no auto-sync. Update by hand if ever
needed.

## Engines folded in

- **unsloppify** (github.com/woerndl/unsloppify, MIT, Copyright (c) 2026 unsloppify contributors).
  Source of the six failure modes, the context rules, the guards, `references/patterns.md`,
  `references/phrases.txt`, and `scripts/scan.sh`.
- **asd-ste100-skill** (github.com/danyuchn/asd-ste100-skill, MIT, Copyright (c) 2026 Dustin Yuchen Teng).
  Source of the controlled-language structural rules, `references/ste-en.md`, and `scripts/ste-lint.py`.
- **asd-ste100-pt** (written for this config). Portuguese adaptation:
  `references/ste-pt.md`, `scripts/pt-lint.py`, `examples/antes-depois-pt.md`.

`scripts/lint.sh` and `SKILL.md` are new glue.

## Upstream rule sets (not redistributed)

ASD-STE100 (Simplified Technical English) is free to obtain but not to
redistribute. Get it at https://www.asd-ste100.org/STE_downloads.html. The
English rules here apply the underlying principle and do not reproduce the
official ~900-word dictionary. Portuguese has no official approved dictionary.
