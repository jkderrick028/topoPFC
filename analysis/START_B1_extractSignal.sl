#!/bin/bash -l
#SBATCH --job-name=START_B1_extractSignal
#SBATCH --account=def-mmur
#SBATCH --time=0-13:59
#SBATCH --cpus-per-task=3
#SBATCH --mem-per-cpu=32G 
#SBATCH --mail-user=jkderrick.jobscheduler@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --output=slurm_outputs/%x_%A.out

module load matlab

matlab -nodisplay -r "START_B1_extractSignal_AL"
matlab -nodisplay -r "START_B1_extractSignal_KM"

