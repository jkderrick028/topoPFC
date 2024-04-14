#!/bin/bash -l
#SBATCH --job-name=START_B3_donutACF
#SBATCH --account=def-mmur
#SBATCH --time=0-5:59
#SBATCH --cpus-per-task=3
#SBATCH --mem-per-cpu=32G 
#SBATCH --mail-user=jkderrick.jobscheduler@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --output=slurm_outputs/%x_%A.out

module load matlab

matlab -nodisplay -r "START_B3_donutACF('taskStr', 'ODR', 'signalType', 'mcTuning')"
matlab -nodisplay -r "START_B3_donutACF('taskStr', 'KM', 'signalType', 'mcTuning')"
matlab -nodisplay -r "START_B3_donutACF('taskStr', 'AL', 'signalType', 'mcTuning')"

matlab -nodisplay -r "START_B3_donutACF('taskStr', 'ODR', 'signalType', 'residual')"
matlab -nodisplay -r "START_B3_donutACF('taskStr', 'KM', 'signalType', 'residual')"
matlab -nodisplay -r "START_B3_donutACF('taskStr', 'AL', 'signalType', 'residual')"

matlab -nodisplay -r "START_B3_donutACF('taskStr', 'ODR', 'signalType', 'task_evoked')"
matlab -nodisplay -r "START_B3_donutACF('taskStr', 'KM', 'signalType', 'task_evoked')"
matlab -nodisplay -r "START_B3_donutACF('taskStr', 'AL', 'signalType', 'task_evoked')"