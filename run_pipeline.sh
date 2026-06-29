#!/bin/bash
set -e

# Accept outside parameters or fallback to defaults
# very small step and particle count to keep repo light
#
STEPS=${1:-100}
PARTICLES=${2:-100}
WIND_SPEED=${3:-1}

echo "=========================================="
echo "LAUNCHING PRODUCTION TESTING LOOP"
echo "=========================================="

mkdir -p report/images
julia setup.jl

# Execute the simulation using formal, named parameter arguments
julia -t auto --project=. scripts/run_simulation.jl \
    --steps "$STEPS" \
    --particles "$PARTICLES" \
    --wind "$WIND_SPEED"

julia --project=. test/runtests.jl
julia --project=. scripts/generate_plots.jl
