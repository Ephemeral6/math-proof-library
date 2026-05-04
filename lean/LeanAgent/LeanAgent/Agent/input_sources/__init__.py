"""Input source adapters for the End-to-End runner.

Each adapter parses a different problem source into the unified shape:

  {
    "problem_id"          : "...",
    "goal"                : "<NL description>",
    "domain"              : "<AMS bucket>",
    "lean_statement"      : "<Lean 4 code, optional>",
    "source"              : "ranked_problems | formal_conjectures",
    "literature_in_scope" : []
  }
"""
