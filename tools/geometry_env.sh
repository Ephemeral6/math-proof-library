#!/bin/bash
# Activate the conda `geometry` environment.
# Usage: source scripts/geometry_env.sh
#
# Provides: snappy, curver, flipper, spherogram, plink (Python 3.11.15).
# Regina and SageMath are NOT in this env — neither has Windows conda builds.

export PATH="/c/Users/12729/miniconda3/Scripts:/c/Users/12729/miniconda3:$PATH"

# Initialize conda for this shell, then activate the env.
eval "$(conda shell.bash hook 2>/dev/null)"
conda activate geometry

echo "Geometry environment activated:"
echo "  python: $(python --version 2>&1)"
echo "  which : $(which python)"
echo "  env   : ${CONDA_DEFAULT_ENV:-unknown}"
