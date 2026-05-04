"""Split sonnet_prompts.json into individual files so agents can read by path."""
import json
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
src = os.path.join(ROOT, "sonnet_prompts.json")
out_dir = os.path.join(ROOT, "sonnet_prompt_files")
os.makedirs(out_dir, exist_ok=True)

with open(src, "r", encoding="utf-8") as f:
    prompts = json.load(f)

manifest = []
for idx, item in enumerate(prompts):
    fname = f"{idx:02d}_{item['domain']}__{item['case_id']}__{item['condition']}.md"
    fpath = os.path.join(out_dir, fname)
    with open(fpath, "w", encoding="utf-8") as f:
        f.write(item["prompt"])
    manifest.append({
        "idx": idx,
        "file": fname,
        "domain": item["domain"],
        "case_id": item["case_id"],
        "condition": item["condition"],
    })

with open(os.path.join(out_dir, "manifest.json"), "w", encoding="utf-8") as f:
    json.dump(manifest, f, ensure_ascii=False, indent=2)

print(f"Wrote {len(manifest)} prompt files to {out_dir}")
