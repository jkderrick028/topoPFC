#!/bin/bash -l
#SBATCH --job-name=run_entire_pipeline
#SBATCH --account=def-mmur
#SBATCH --time=0-3:59
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=32G 
#SBATCH --mail-user=jkderrick.jobscheduler@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --output=slurm_outputs/%x_%A.out

module load matlab

# matlab -nodisplay -r "START_B1_extractSignal_AL"
# matlab -nodisplay -r "START_B1_extractSignal_KM"
# matlab -nodisplay -r "START_B1_extractSignal_ODR"

matlab -nodisplay -r "START_B2_spikesMDS('taskStr', 'ODR')"
matlab -nodisplay -r "START_B2_spikesMDS('taskStr', 'KM')"
matlab -nodisplay -r "START_B2_spikesMDS('taskStr', 'AL')"

matlab -nodisplay -r "START_B3_donutACF('taskStr', 'ODR', 'signalType', 'mcTuning')"
matlab -nodisplay -r "START_B3_donutACF('taskStr', 'KM', 'signalType', 'mcTuning')"
matlab -nodisplay -r "START_B3_donutACF('taskStr', 'AL', 'signalType', 'mcTuning')"

matlab -nodisplay -r "START_B3_donutACF_fitting_summary('taskStr', 'ODR', 'signalType', 'mcTuning')"
matlab -nodisplay -r "START_B3_donutACF_fitting_summary('taskStr', 'KM', 'signalType', 'mcTuning')"
matlab -nodisplay -r "START_B3_donutACF_fitting_summary('taskStr', 'AL', 'signalType', 'mcTuning')"

matlab -nodisplay -r "START_B4_figure_procrustes"

# matlab -nodisplay -r "START_B3_donutACF_cv('taskStr', 'ODR', 'signalType', 'mcTuning')"
# matlab -nodisplay -r "START_B3_donutACF_cv('taskStr', 'KM', 'signalType', 'mcTuning')"
# matlab -nodisplay -r "START_B3_donutACF_cv('taskStr', 'AL', 'signalType', 'mcTuning')"

# matlab -nodisplay -r "START_B3_donutACF_fitting_summary_cv('taskStr', 'ODR', 'signalType', 'mcTuning')"
# matlab -nodisplay -r "START_B3_donutACF_fitting_summary_cv('taskStr', 'KM', 'signalType', 'mcTuning')"
# matlab -nodisplay -r "START_B3_donutACF_fitting_summary_cv('taskStr', 'AL', 'signalType', 'mcTuning')"

# matlab -nodisplay -r "START_B4_figure_procrustes_cv"

# matlab -nodisplay -r "START_B5_daysAcrossTasks"
# matlab -nodisplay -r "START_B6_topoInference_generation"
# matlab -nodisplay -r "START_B6_topoInference_t_test"

# matlab -nodisplay -r "START_R2_topo_acrossDays_v3"

# matlab -nodisplay -r "START_R5_behavioural_performance"

# matlab -nodisplay -r "START_S2_unitConsistency"

# matlab -nodisplay -r "START_S3_task_session_vis"


