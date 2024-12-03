#!/bin/bash -l
#SBATCH --job-name=START_R8_simmat_session_splits
#SBATCH --account=def-mmur
#SBATCH --time=0-1:59
#SBATCH --cpus-per-task=3
#SBATCH --mem-per-cpu=32G 
#SBATCH --mail-user=jkderrick.jobscheduler@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --output=slurm_outputs/%x_%A.out

module load matlab

matlab -nodisplay -r "START_R8_simmat_session_splits"

