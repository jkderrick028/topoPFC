function START_R6_all_rescaled_ACFs
% plot the donutACFs for 1. ODR, 2. KM, and 3. AL tasks, then 4. the mean
% on top of goldman-rakic simulations. 
% 
% to run this script, copy START_B3_donutACF_fitting_summary .mat files and
% goldman-rakic simulation results (renaming to
% Goldman_rakic_simulation.mat) to 'START_B8_all_donutACF_curves' directory
% 
% last modified: 2024.04.18


import utils_dx.*; 

close all; 

% data
subjectStrs = {'Theo', 'Buzz'};
arrayStrs = {'NSP1','NSP0'};
taskStrs = {'ODR', 'KM', 'AL'}; 

%% preparation
projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'goldman_rakic';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

resizes = [0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0]; 

nHors = 3;
nVers = 3;

figI_acf = 10; 
figure(figI_acf); clf(figI_acf); 

for sizeI=1:numel(resizes)
    MAT_siulation               = fullfile(projectPath, 'results', ANALYSIS, 'START_R6_rescale_structural_maps', sprintf('output_%.1f.mat', resizes(sizeI))); 
    simulation_results          = load(MAT_siulation).output.moranIs; 
    I_real_combine              = []; 
    n_simulations               = numel(simulation_results);

    for simI = 1:n_simulations
        I_real_this_sim         = [simulation_results{simI}.I_real]; 
        I_real_this_sim         = [1, I_real_this_sim]; 
        I_real_combine          = [I_real_combine; I_real_this_sim]; 
    end % simI

    subplot(nHors, nVers, sizeI); 
    hold on;
    yline(0, 'LineWidth', 1, 'Color', [120, 120, 120]/255, 'LineStyle', '--'); 
    plot(distances, I_real_combine', 'Color', [200, 200, 200]/255, 'LineWidth', 1);
    plot(distances, mean(I_real_combine, 1), 'Color', 'k', 'LineWidth', 1.5); 
    xlim([0, 3.65]);
    ylim([-0.3, 1]);
    xlabel('distances (mm)');
    ylabel('donut ACF'); 
    title(sprintf('resize %.1f', resizes(sizeI))); 
end % sizeI 

PS_acfs = fullfile(resultsPath, sprintf('acfs_rescaled_structural_maps.ps'));
if exist(PS_acfs, 'file')
    system(['rm ' PS_acfs]);
end

pageHeadings                = 'ACFs for rescaled structural maps';
addHeadingAndPrint(pageHeadings, PS_acfs, figI_acf); 

close all;

end % START_R6_all_rescaled_ACFs
