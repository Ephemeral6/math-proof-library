"""
LLM interface for the Lean Formalization Agent.

Two providers:

  * `anthropic` — calls the Anthropic API via the `anthropic` Python SDK.
                  Requires `ANTHROPIC_API_KEY` env var and the SDK installed.
  * `stub`      — reads canned responses from a JSON file. Used for offline
                  end-to-end testing and as a fallback when the API is
                  unavailable.

Usage:

    llm = LLM(provider="auto", stub_path=Path("Tests/stubs/descent_lemma.json"))
    response = llm.ask(stage="aligner", task="signature", context={...})

Each `ask` call is keyed by (stage, task) so the stub registry can return
the right response. If a key is missing in stub mode, an exception is raised
to make the gap explicit.
"""

from __future__ import annotations

import json
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass
class LLMResponse:
    text: str
    provider: str
    stage: str
    task: str


class LLM:
    """Thin wrapper around an LLM (real or canned)."""

    def __init__(
        self,
        *,
        provider: str = "auto",
        stub_path: Path | str | None = None,
        model: str = "claude-opus-4-7",
    ):
        self.provider_pref = provider
        self.stub_path = Path(stub_path) if stub_path else None
        self.model = model
        self._stubs: dict[str, str] = {}
        self._stub_used: dict[str, int] = {}
        self._client = None
        self._init_provider()

    def _init_provider(self):
        if self.provider_pref == "stub":
            self._load_stubs()
            self.provider = "stub"
            return
        if self.provider_pref == "anthropic":
            self._init_anthropic(strict=True)
            self.provider = "anthropic"
            return
        # auto: try anthropic, fall back to stub
        if self._init_anthropic(strict=False):
            self.provider = "anthropic"
        else:
            self._load_stubs()
            self.provider = "stub"

    def _init_anthropic(self, *, strict: bool) -> bool:
        api_key = os.environ.get("ANTHROPIC_API_KEY")
        if not api_key:
            if strict:
                raise RuntimeError("ANTHROPIC_API_KEY not set")
            return False
        try:
            import anthropic  # type: ignore
        except ImportError:
            if strict:
                raise RuntimeError("anthropic SDK not installed; pip install anthropic")
            return False
        self._client = anthropic.Anthropic(api_key=api_key)
        return True

    def _load_stubs(self):
        if not self.stub_path or not self.stub_path.exists():
            self._stubs = {}
            return
        data = json.loads(self.stub_path.read_text(encoding="utf-8"))
        # Stub schema: {(stage, task): text} — but JSON keys must be strings.
        # We store with key f"{stage}::{task}".
        if isinstance(data, dict):
            self._stubs = {k: v for k, v in data.items()}

    # ------------------------------------------------------------------ #
    # Public API
    # ------------------------------------------------------------------ #

    def _resolve_stub(self, stage: str, task: str, attempt: int) -> tuple[str, str] | None:
        """Try (key, text) in priority order.

        Order:
          1. exact          stage::task#attempt   (only if attempt > 0)
          2. exact          stage::task
          3. wildcard       stage::any_<suffix>   (e.g. line12_fill -> any_fill)
          4. wildcard       stage::any
        Returns (resolved_key, text) or None.
        """
        keys: list[str] = []
        if attempt > 0:
            keys.append(f"{stage}::{task}#{attempt}")
        keys.append(f"{stage}::{task}")
        import re as _re
        m = _re.match(r".*?_(.+)$", task)
        if m:
            keys.append(f"{stage}::any_{m.group(1)}")
        keys.append(f"{stage}::any")
        for k in keys:
            if k in self._stubs:
                return k, self._stubs[k]
        return None

    def ask(
        self,
        *,
        stage: str,
        task: str,
        prompt: str,
        system: str | None = None,
        max_tokens: int = 2048,
        temperature: float = 0.0,
        attempt: int = 0,
    ) -> LLMResponse:
        """Ask the LLM. `stage` and `task` are used to key into stubs."""
        primary_key = f"{stage}::{task}" if attempt == 0 else f"{stage}::{task}#{attempt}"
        if self.provider == "stub":
            resolved = self._resolve_stub(stage, task, attempt)
            if resolved is None:
                raise KeyError(
                    f"stub LLM has no response for key '{primary_key}'. "
                    f"Add an entry to {self.stub_path} or set ANTHROPIC_API_KEY."
                )
            resolved_key, text = resolved
            self._stub_used[resolved_key] = self._stub_used.get(resolved_key, 0) + 1
            return LLMResponse(text=text, provider="stub", stage=stage, task=task)
        # anthropic
        msgs = [{"role": "user", "content": prompt}]
        kwargs: dict[str, Any] = dict(
            model=self.model,
            max_tokens=max_tokens,
            temperature=temperature,
            messages=msgs,
        )
        if system:
            kwargs["system"] = system
        response = self._client.messages.create(**kwargs)
        text = "".join(
            block.text for block in response.content if getattr(block, "type", None) == "text"
        )
        return LLMResponse(text=text, provider="anthropic", stage=stage, task=task)

    # ------------------------------------------------------------------ #
    # Helpers
    # ------------------------------------------------------------------ #

    def has_stub(self, stage: str, task: str) -> bool:
        return f"{stage}::{task}" in self._stubs

    def report(self) -> dict:
        return {
            "provider": self.provider,
            "stub_path": str(self.stub_path) if self.stub_path else None,
            "stub_keys": list(self._stubs.keys()) if self.provider == "stub" else None,
            "stub_used": dict(self._stub_used) if self.provider == "stub" else None,
        }
