function START_B8_all_donutACF_curves
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
ANALYSIS                            = 'topovis';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

signalType = 'mcTuning'; 

arrayColors = {
    [255, 204, 229]/255,    % Theo, NSP0
    [19, 74, 142]/255,      % Buzz, NSP1
    [0.3010 0.7450 0.9330]  % Buzz, NSP0            
};


nHors = 2;
nVers = 2;

figI_acf = 10; 
figure(figI_acf); clf(figI_acf); 

n_tasks = numel(taskStrs);

task_mean_monkeyB_NSP1      = []; 

for taskI = 1:n_tasks
    MAT_donutACF            = fullfile(resultsPath, sprintf('START_B3_donutACF_fitting_summary_%s_%s.mat', taskStrs{taskI}, signalType));
    donutACF_output         = load(MAT_donutACF).output; 

    subplot(nHors, nVers, taskI);
    patch([0, 0.4, 0.4, 0], [-0.3, -0.3, 1, 1], [220, 220, 220]/255, 'FaceAlpha', .5, 'EdgeColor', 'none'); 
    colorI                  = 1; 
    for subjectI = 1:numel(subjectStrs)
        for arrayI = 1:numel(arrayStrs)
            if strcmp(subjectStrs{subjectI}, 'Theo') && strcmp(arrayStrs{arrayI}, 'NSP1')
                continue;                 
            end
            I_real_combine  = donutACF_output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).fitting.X; 
            distances       = donutACF_output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).fitting.Y; 
            fwhms           = donutACF_output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).fitting.fwhm;
            fwhm_median     = median(fwhms);
            
            hold on; 
            plot(distances, I_real_combine', 'Color', arrayColors{colorI}, 'LineWidth', 1.2); 
            xline(fwhm_median, 'Color', arrayColors{colorI}, 'LineWidth', 0.8, 'LineStyle', '--');            
            colorI          = colorI + 1;

            if strcmp(subjectStrs{subjectI}, 'Buzz') && strcmp(arrayStrs{arrayI}, 'NSP1')
                task_mean_monkeyB_NSP1 = [task_mean_monkeyB_NSP1; mean(I_real_combine, 1)]; 
            end
        end % arrayI
    end % subjectI 
    yline(0, 'LineWidth', 1, 'Color', [120, 120, 120]/255, 'LineStyle', '--'); 
    xlim([0, 3.65]);
    ylim([-0.3, 1]);
    title(taskStrs{taskI}); 
    xlabel('distances (mm)');
    ylabel('donut ACF'); 
end % taskI 

MAT_siulation               = fullfile(resultsPath, 'Goldman_rakic_simulation.mat'); 
simulation_results          = load(MAT_siulation).output.moranIs; 
I_real_combine              = []; 
n_simulations               = numel(simulation_results);

for simI = 1:n_simulations
    I_real_this_sim         = [simulation_results{simI}.I_real]; 
    I_real_this_sim         = [1, I_real_this_sim]; 
    I_real_combine          = [I_real_combine; I_real_this_sim]; 
end % simI

subplot(nHors, nVers, 4); 
hold on;
yline(0, 'LineWidth', 1, 'Color', [120, 120, 120]/255, 'LineStyle', '--'); 
plot(distances, I_real_combine', 'Color', [200, 200, 200]/255, 'LineWidth', 1);
% plot(distances, task_mean_monkeyB_NSP1', 'Color', 'cyan', 'LineStyle', '-.', 'LineWidth', 1.2);
plot(distances, task_mean_monkeyB_NSP1(1, :), 'Color', [0.9290 0.6940 0.1250], 'LineStyle', '-', 'LineWidth', 2);
plot(distances, task_mean_monkeyB_NSP1(2, :), 'Color', [0.4660 0.6740 0.1880], 'LineStyle', '-', 'LineWidth', 2);
plot(distances, task_mean_monkeyB_NSP1(3, :), 'Color', [0.4940 0.1840 0.5560], 'LineStyle', '-', 'LineWidth', 2);
xlim([0, 3.65]);
ylim([-0.3, 1]);
xlabel('distances (mm)');
ylabel('donut ACF'); 
title('goldman-rakic simulations'); 

pageHeadings                = 'donut ACFs';
PS_acfs = fullfile(resultsPath, sprintf('acfs_%s.ps', signalType));
if exist(PS_acfs, 'file')
    system(['rm ' PS_acfs]);
end
addHeadingAndPrint(pageHeadings, PS_acfs, figI_acf); 

close all;

end % START_B8_all_donutACF_curves
