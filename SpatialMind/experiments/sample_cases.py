"""
Sample 5 cases per domain (seed=42) and extract per-case data for each ablation condition.
Output: experiments/sampled/{domain}/{case_id}__{condition}.json
"""
import json
import os
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]  # SpatialMind/
BENCH = ROOT / "benchmarks"
OUT = ROOT / "experiments" / "sampled"

DOMAINS = [
    "symmetry",
    "knot_theory",
    "boundary_interior",
    "discrete_curvature",
    "graph_connectivity",
    "projection",
    "surface_topology",
    "surface_topology_s21",
]

CONDITIONS = ["000", "00C", "0T0", "0TC", "R00", "R0C", "RT0", "RTC"]

# Pick the level file to sample from. Default level_4; fall back to level_5 if missing.
def pick_level_file(domain_dir: Path) -> Path:
    for lvl in ["level_4.json", "level_5.json", "level_3.json"]:
        p = domain_dir / lvl
        if p.exists():
            return p
    raise FileNotFoundError(f"no level file found in {domain_dir}")


def load_condition(domain_dir: Path, cond: str):
    p = domain_dir / "ablation" / f"{cond}.json"
    if not p.exists():
        return None
    with open(p, "r", encoding="utf-8") as f:
        return json.load(f)


def main():
    summary = {}
    for domain in DOMAINS:
        domain_dir = BENCH / domain
        if not domain_dir.exists():
            print(f"[skip] {domain}: not found")
            continue

        # 1. Sample 5 case_ids deterministically.
        lvl_file = pick_level_file(domain_dir)
        with open(lvl_file, "r", encoding="utf-8") as f:
            lvl = json.load(f)
        cases = lvl["cases"]
        case_ids = [c["case_id"] for c in cases]

        rng = random.Random(42)
        sampled_ids = rng.sample(case_ids, 5)
        summary[domain] = {"level_file": lvl_file.name, "sampled": sampled_ids}

        # 2. For each condition, extract those 5 cases and the global counterfactual block.
        for cond in CONDITIONS:
            data = load_condition(domain_dir, cond)
            if data is None:
                print(f"[warn] {domain}/{cond}: missing")
                continue
            id_to_case = {c["case_id"]: c for c in data["cases"]}
            cf_block = data.get("counterfactual")  # only present in *C conditions

            out_dir = OUT / domain
            out_dir.mkdir(parents=True, exist_ok=True)
            for cid in sampled_ids:
                if cid not in id_to_case:
                    print(f"[warn] {domain}/{cond}/{cid}: case missing in condition file")
                    continue
                payload = {
                    "domain": data.get("domain", domain),
                    "condition": cond,
                    "primitives": data["primitives"],
                    "case_id": cid,
                    "case_data": id_to_case[cid],
                }
                if cf_block is not None and "C" in cond:
                    payload["counterfactual"] = cf_block
                out_path = out_dir / f"{cid}__{cond}.json"
                with open(out_path, "w", encoding="utf-8") as f:
                    json.dump(payload, f, ensure_ascii=False, indent=1)

        print(f"[ok] {domain}: sampled 5 cases x 8 conditions -> {OUT / domain}")

    # Save summary of which case_ids were sampled per domain.
    with open(OUT / "sampling_manifest.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, ensure_ascii=False, indent=2)
    print(f"\nManifest: {OUT / 'sampling_manifest.json'}")


if __name__ == "__main__":
    main()
