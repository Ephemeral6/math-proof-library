# CoE+CTR Accuracy Benchmark

Cross-domain accuracy comparison, subject = `claude-as-test-subject`.

| Domain | N | Baseline | CoT | CoE-R | CoE-RT | CoE-RC | CoE-CTR | Best |
|---|---|---|---|---|---|---|---|---|
| graph_connectivity | 34 | 38.2% | - | - | - | - | 100.0% | CoE-CTR |

| **average** | - | **38.2%** | - | - | - | - | **100.0%** | - |

## Per-condition breakdown

### graph_connectivity

| Condition | Accuracy | Correct/N | Errors |
|---|---|---|---|
| Baseline | 38.2% | 13/34 | 0 |
| CoE-CTR | 100.0% | 34/34 | 0 |
