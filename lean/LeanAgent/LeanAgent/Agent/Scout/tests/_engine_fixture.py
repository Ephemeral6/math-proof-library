"""Test-only engine fixture for verifier engine_call dispatch."""

from __future__ import annotations


def echo(value: str = "ok") -> str:
    return value


def boom() -> None:
    raise RuntimeError("intentional failure")


def add(a: int, b: int) -> int:
    return a + b
