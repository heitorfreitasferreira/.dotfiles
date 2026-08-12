# Tiger Style

Apply these as global coding defaults when the current repo does not define a stronger local rule.

## Priority Order

1. Safety.
2. Performance.
3. Developer experience.

## Defaults

- Prefer the smallest correct change.
- Keep control flow explicit and bounded.
- Handle expected errors explicitly.
- Assert non-trivial invariants close to where they matter.
- Avoid unnecessary dependencies and abstractions.
- Use precise names and keep units explicit.
- Prefer stable, boring code over clever code.

## Review Checklist

- Is work bounded?
- Are invariants obvious or asserted?
- Are errors handled instead of ignored?
- Is there duplicated state or needless indirection?
- Is there a smaller correct change?
