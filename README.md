# Task-specific topographical maps of neural activity in the primate lateral prefrontal cortex 

This repository contains code in support of the paper "Task-specific topographical maps of neural activity in the primate lateral prefrontal cortex" 

## Publications

Preprint: ["Task-specific topographical maps of neural activity in the primate lateral prefrontal cortex](https://www.biorxiv.org/content/10.1101/2024.05.10.591729v1)

## Prerequisites

MATLAB 2023a with the following libraries: 
- Curve Fitting Toolbox version 3.9
- Image Processing Toolbox version 11.7
- Statistics and Machine Learning Toolbox version 12.5


Python 3.10 with the following libraries
- torchvision version 0.15.2
- torch version 2.0.1
- numpy version 1.24.2
- matplotlib version 3.7.0

The analysis code was tested on MacOS 10.15.7 with 32G RAM. The expected run time of the pipeline using simulated data on a normal desktop computer should be under 10 minutes. 



## Data

Simulated data can be found in `results/spikeTuningVectors/`, which can also be generated by running the script `analysis/START_R1_simulate_data.m`.

The reconstructed cortical patch from existing histology work can be found in `results/goldman_rakic/` 

## Code

### Simulating data

`START_R1_simulate_data.m` This function simulates data for the analysis pipeline. Data will be drawn from a normal distribution with some degrees of spatial autocorrelation imposed. In the simulation, there are 3 tasks, 2 subjects, each having 2 arrays. Three measurement sessions will be generated for each subject in each task. 

### Visualizing tuning similarity on the array

`START_B2_spikesMDS.m` This function visualizes tuning similarity of channels on the array using multi-dimensional scaling. 

Example usage: `START_B2_spikesMDS('taskStr', 'KM')`

### Estimating the spatial autocorrelation function of tuning profiles

`START_B3_donutACF.m` and `START_B3_donutACF_fitting_summary.m`. The first function estimates the spatial autocorrelation of tuning profiles for each array in each session in each task. The second function fits a Laplacian to the spatial autocorrelation function. 

Example usage: `START_B3_donutACF('taskStr', 'KM')` then `START_B3_donutACF_fitting_summary('taskStr', 'KM')`

### Smoothing the array maps with a 2D kernel whose FWHM matches the fitted Laplacian

`START_B4_figure_procrustes.m` This function smoothes the array maps with 2D kernels whose FWHM matches the fitted Laplacian. 

### Testing for the consistency of functional topography across time within a task and across tasks

`START_B5_daysAcrossTasks.m` computes the interval between measurement sessions. 
`START_B6_topoInference_generation.m` splits the signal into task related and residuals and computes the correlation matrices (functional topography) for each component for each array in each session in each task. 
`START_B6_topoInference_t_test.m` computes the consistency of functional topography and performs statistical inference. 

Worth mentioning, in the simple simulation script `START_R1_simulate_data.m`, the signal is generated at random, without modeling task effects. As a consequence, the results for the inference performed on simulated data are likely to be different from actual findings in the manuscript. 

Symbols in the inference results figure: 
- light blue dots indicate that the consistency of topography for task related signal is significantly different from that for residuals. 
- magenta dots indicate that the consistency of topography is higher than chance under channel permutation tests. 
- horizontal lines and error bars in cyan show the mean and standard error of the permutation distribution. 
- blue horizontal lines show the noise ceiling for between-task comparisons. 
- red dots show that the between-task consistency is significantly lower than noise ceiling. 

### Random sampling from existing histology work

`results/goldman_rakic/START_A1_generate_dataset.py` generates random samples of 4 mm x 4 mm structural maps from existing histology work.
`analysis/START_B7_Goldman_Rakic_donutACF.m` down-samples the structural maps to 10 x 10, and estimates the spatial autocorrelation function for these maps.
`analysis/START_B8_all_donutACF_curves.m` summarizes all the spatial autocorrelation functions for both simulated data and sampled structural maps. 
