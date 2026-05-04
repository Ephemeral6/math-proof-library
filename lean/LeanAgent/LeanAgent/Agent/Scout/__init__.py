"""Scout Mode — low-cost batch tractability scanning.

Spec: workspace/agents_spec/scout_mode.md.

Public API:
  scout_one(problem, config) -> TractabilityReport
  scout_batch(problems, config) -> dict (batch report)
  ScoutConfig
"""

from .orchestrator import ScoutConfig, scout_batch, scout_one
from .scope_judge import ScopeVerdict, run_scope_judge
from .strategy_proposer import StrategyProposal, run_strategy_proposer

__all__ = [
    "scout_one", "scout_batch", "ScoutConfig",
    "run_strategy_proposer", "StrategyProposal",
    "run_scope_judge", "ScopeVerdict",
]
