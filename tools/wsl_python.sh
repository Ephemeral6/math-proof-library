#!/bin/bash
# Run a Python script inside the WSL Ubuntu geometry environment.
#
# Usage:
#   bash scripts/wsl_python.sh <path/to/script.py> [args...]
#   bash scripts/wsl_python.sh -c "<inline python code>"
#   bash scripts/wsl_python.sh --sage <path/to/script.py> [args...]   # use Sage's Python
#
# The WSL env (Ubuntu 24.04) provides:
#   - Python 3.12.3 system packages: numpy, sympy, mpmath, matplotlib
#   - Topology stack: snappy, regina, curver, flipper, spherogram, plink,
#                     knot_floer_homology, low_index, FXrays, networkx
#   - --sage flag routes to the conda env `sage` (full SageMath via conda-forge)

set -e

# Convert a Windows-style path (C:\Users\... or C:/Users/...) into a WSL path
# (/mnt/c/Users/...). Leaves already-WSL or relative paths alone.
to_wsl_path() {
    local p="$1"
    if [[ "$p" =~ ^[A-Za-z]:[\\/]?(.*)$ ]]; then
        local drive="${p:0:1}"
        local rest="${p:2}"
        rest="${rest//\\//}"
        rest="${rest#/}"
        echo "/mnt/${drive,,}/${rest}"
    else
        echo "$p"
    fi
}

USE_SAGE=0
if [[ "$1" == "--sage" ]]; then
    USE_SAGE=1
    shift
fi

SAGE_ACTIVATE='source ~/miniconda3/etc/profile.d/conda.sh && conda activate sage'

if [[ "$1" == "-c" ]]; then
    shift
    CODE="$1"
    if (( USE_SAGE )); then
        wsl bash -c "$SAGE_ACTIVATE && sage -c \"$CODE\""
    else
        wsl bash -c "python3 -c \"$CODE\""
    fi
    exit $?
fi

SCRIPT_PATH="$1"
shift || true
WSL_PATH=$(to_wsl_path "$SCRIPT_PATH")

if (( USE_SAGE )); then
    if [[ "$WSL_PATH" == *.sage ]]; then
        wsl bash -c "$SAGE_ACTIVATE && sage '$WSL_PATH' $*"
    else
        wsl bash -c "$SAGE_ACTIVATE && sage --python '$WSL_PATH' $*"
    fi
else
    wsl bash -c "python3 '$WSL_PATH' $*"
fi
