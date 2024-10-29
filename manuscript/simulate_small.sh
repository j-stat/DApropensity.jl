#!/bin/bash
#SBATCH --account=cbc-condo
#SBATCH -c 8
#SBATCH -t 6-0 --mem=512G
#SBATCH -J dapropensity
#SBATCH -e /gpfs/data/cbc/aguang/DApropensity.jl/manuscript/logs/%J.err
#SBATCH -o /gpfs/data/cbc/aguang/DApropensity.jl/manuscript/logs/%J.out

WORKDIR=/gpfs/data/cbc/aguang/DApropensity.jl

module load julia/1.9.3s-i3zndt3
julia --project=. simulate_small.jl --threads=auto
