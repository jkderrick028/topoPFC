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

signalType = 'mcTuning'; 

arrayColors = {
    [255, 204, 229]/255,    % Theo, NSP0
    [19, 74, 142]/255,      % Buzz, NSP1
    [0.3010 0.7450 0.9330]  % Buzz, NSP0            
};

%% preparation
projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'goldman_rakic';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

n_tasks = numel(taskStrs);

task_mean_monkeyB_NSP1      = []; 

for taskI = 1:n_tasks
    MAT_donutACF            = fullfile(resultsPath, sprintf('START_B3_donutACF_fitting_summary_%s_%s.mat', taskStrs{taskI}, signalType));
    donutACF_output         = load(MAT_donutACF).output; 

    for subjectI = 1:numel(subjectStrs)
        for arrayI = 1:numel(arrayStrs)
            if strcmp(subjectStrs{subjectI}, 'Theo') && strcmp(arrayStrs{arrayI}, 'NSP1')
                continue;                 
            end
            I_real_combine  = donutACF_output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).fitting.X;            

            if strcmp(subjectStrs{subjectI}, 'Buzz') && strcmp(arrayStrs{arrayI}, 'NSP1')
                task_mean_monkeyB_NSP1 = [task_mean_monkeyB_NSP1; mean(I_real_combine, 1)]; 
            end
        end % arrayI
    end % subjectI
end % taskI 

resizes = [0.4, 0.5, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0]; 

nHors = 3;
nVers = 3;

figI_acf = 10; 
figure(figI_acf); clf(figI_acf); 

for sizeI=1:numel(resizes)
    MAT_siulation               = fullfile(projectPath, 'results', ANALYSIS, 'START_R6_rescale_structural_maps', sprintf('resize_%.1f', resizes(sizeI)), sprintf('output_%.1f.mat', resizes(sizeI))); 
    simulation_results          = load(MAT_siulation).output.moranIs; 
    distances                   = [0, simulation_results{1}.uniqueDists]; 
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
    a = plot(distances, I_real_combine', 'Color', [200, 200, 200]/255, 'LineWidth', 0.3);
    alpha(a, 0.5)
    plot(distances, mean(I_real_combine, 1, 'omitnan'), 'Color', 'k', 'LineWidth', 2); 

    plot(distances, task_mean_monkeyB_NSP1(1, :), 'Color', [0.9290 0.6940 0.1250], 'LineStyle', '-', 'LineWidth', 2);   % ODR, yellow
    plot(distances, task_mean_monkeyB_NSP1(2, :), 'Color', [0.4660 0.6740 0.1880], 'LineStyle', '-', 'LineWidth', 2);   % VWM, green
    plot(distances, task_mean_monkeyB_NSP1(3, :), 'Color', [0.4940 0.1840 0.5560], 'LineStyle', '-', 'LineWidth', 2);   % CDM, purple

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
