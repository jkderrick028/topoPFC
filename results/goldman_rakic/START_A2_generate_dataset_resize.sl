#!/bin/bash -l
#SBATCH --job-name=START_A2_generate_dataset_resize
#SBATCH --account=def-mmur
#SBATCH --time=0-15:59
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=16G 
#SBATCH --mail-user=jkderrick.jobscheduler@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --output=slurm_outputs/%x_%A.out

module load StdEnv/2020  gcc/9.3.0
module load fsl/6.0.4
module load gcc opencv python scipy-stack

source ~/tcompo/bin/activate

python START_A2_generate_dataset_resize.py
