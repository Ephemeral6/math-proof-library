# Decomposition Templates

Each subdirectory holds one named decomposition template that the
Decomposer can match against. Layout:

```
templates/
  <template_name>/
    template.json    # {"name", "param_slots": [...], "steps": [...], "match_patterns": [...]}
```

A template hits when one of its `match_patterns` (substring or regex,
case-insensitive) appears in the lemma's NL statement or `reuse_reason`. On a
hit the Decomposer skips the LLM call and uses the template's `steps`
verbatim, leaving the `param_slots` for the LLM/Aligner to substitute later.

MVP ships empty — templates accumulate as the Persistence layer learns from
real proofs. To add one by hand, drop a directory matching the schema above;
the Decomposer auto-discovers them on each run.
