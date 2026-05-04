import json
import os

domains = [
    "symmetry", "knot_theory", "graph_connectivity", "boundary_interior",
    "discrete_curvature", "projection", "surface_topology", "surface_topology_s21"
]

case_map = {
    "symmetry": ["same-000", "same-001", "same-002"],
    "knot_theory": ["3_1-r2-0", "3_1-r2-1", "3_1-r2-2"],
    "graph_connectivity": ["R00_n8-t0", "R00_n8-t1", "R00_n8-t2"],
    "boundary_interior": ["unit_square-trans-0", "unit_square-trans-1", "unit_square-trans-2"],
    "discrete_curvature": ["tetrahedron-subdiv-f0-0", "tetrahedron-subdiv-f1-1", "tetrahedron-subdiv-f2-2"],
    "projection": ["self-cube-xy", "self-cube-xz", "self-cube-yz"],
    "surface_topology": ["a3-b1", "a3-b4", "a3-b6"],
    "surface_topology_s21": ["a122-b2", "a122-b6", "a122-b9"]
}

base_path = r"C:\Users\12729\Desktop\Math\SpatialMind\benchmarks"

results = []

for domain in domains:
    for condition in ["000", "RTC"]:
        file_path = os.path.join(base_path, domain, "ablation", f"{condition}.json")
        if not os.path.exists(file_path):
            print(f"Warning: {file_path} not found")
            continue
        
        with open(file_path, "r") as f:
            data = json.load(f)
            case_list = data.get("cases", [])
            cases_to_find = case_map[domain]
            
            found_cases = 0
            for case in case_list:
                if case["case_id"] in cases_to_find:
                    results.append({
                        "domain": domain,
                        "condition": "baseline" if condition == "000" else "rtc",
                        "case_id": case["case_id"],
                        "data": case
                    })
                    found_cases += 1
            
            if found_cases < 3:
                print(f"Warning: Only found {found_cases} cases for {domain} in {condition}")

output_file = r"C:\Users\12729\Desktop\Math\extracted_ablation_data.json"
with open(output_file, "w") as f:
    json.dump(results, f, indent=2)

print(f"Successfully saved {len(results)} cases to {output_file}")
