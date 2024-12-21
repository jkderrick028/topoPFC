function START_B8_all_donutACF_curves_cv
% plot the cross-validated donutACFs for 1. ODR, 2. KM, and 3. AL tasks,
% then 4. the mean on top of goldman-rakic simulations.
% 
% to run this script, copy START_B3_donutACF_fitting_summary .mat files and
% goldman-rakic simulation results (renaming to
% Goldman_rakic_simulation.mat) to 'START_B8_all_donutACF_curves' directory
% 
% compute FWHMs for structural ACFs
% 
% last modified: 2024.11.14


import utils_dx.*; 

close all; 

% data
subjectStrs                         = {'Theo', 'Buzz'};
arrayStrs                           = {'NSP1','NSP0'};
taskStrs                            = {'ODR', 'KM', 'AL'}; 

%% preparation
projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'topovis';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

signalType                          = 'mcTuning'; 

arrayColors = {
    [255, 204, 229]/255,    % Theo, NSP0
    [19, 74, 142]/255,      % Buzz, NSP1
    [0.3010 0.7450 0.9330]  % Buzz, NSP0            
};


nHors                       = 2;
nVers                       = 2;

figI_acf                    = 10; 
figure(figI_acf); clf(figI_acf); 

n_tasks                     = numel(taskStrs);

task_mean_ACFs_monkeyB_NSP1 = [];
task_mean_FWHMs_monkeyB_NSP1= []; 

for taskI = 1:n_tasks
    MAT_donutACF            = fullfile(projectPath, 'results', 'moranI', 'START_B3_donutACF_fitting_summary_cv', 'laplacian', sprintf('START_B3_donutACF_fitting_summary_cv_%s_%s.mat', taskStrs{taskI}, signalType));
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
                task_mean_ACFs_monkeyB_NSP1     = [task_mean_ACFs_monkeyB_NSP1; mean(I_real_combine, 1)]; 
                task_mean_FWHMs_monkeyB_NSP1    = [task_mean_FWHMs_monkeyB_NSP1; mean(fwhms)]; 
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

FWHMs_structural            = nan(n_simulations, 1); 
for simI = 1:n_simulations
    I_real_this_sim         = [simulation_results{simI}.I_real]; 
    I_real_this_sim         = [1, I_real_this_sim]; 
    I_real_combine          = [I_real_combine; I_real_this_sim]; 
    [curves_fitted, s_fitted, R2, fwhm]  = fitting(I_real_this_sim, distances, 'laplacian');
    FWHMs_structural(simI)  = fwhm; 
end % simI


color_ODR                   = [0.9290 0.6940 0.1250];   % ODR, yellow
color_KM                    = [0.4660 0.6740 0.1880];   % VWM, green
color_AL                    = [0.4940 0.1840 0.5560];   % CDM, purple
color_structural            = [150, 150, 150]/255;      % grey

subplot(nHors, nVers, 4); 
hold on;
yline(0, 'LineWidth', 1, 'Color', [120, 120, 120]/255, 'LineStyle', '--'); 

% plotting the individual structural ACFs
plot(distances, I_real_combine', 'Color', [200, 200, 200]/255, 'LineWidth', 1);

% plotting the mean and std of structual ACFs
ACFs_structural_mean        = mean(I_real_combine, 1); 
% ACFs_structural_std         = std(I_real_combine, 0, 1); 
% plot(distances, ACFs_structural_mean, 'Color', color_structural, 'LineWidth', 2); 

% lower_bound                 = ACFs_structural_mean - ACFs_structural_std; 
% upper_bound                 = ACFs_structural_mean + ACFs_structural_std; 

lower_bound                 = prctile(I_real_combine, 2.5, 1); 
upper_bound                 = prctile(I_real_combine, 97.5, 1); 

plot(distances, lower_bound, 'Color', color_structural, 'LineWidth', 1.5, 'LineStyle', '--'); 
plot(distances, upper_bound, 'Color', color_structural, 'LineWidth', 1.5, 'LineStyle', '--'); 
% errorbar(distances, ACFs_structural_mean, ACFs_structural_std, 'Color', 'k', 'LineWidth', 1); 

% plotting the mean FWHM of structural ACFs
FWHM_structural_mean        = mean(FWHMs_structural); 
% FWHM_structural_std         = std(FWHMs_structural); 
% xline(FWHM_structural_mean, 'Color', color_structural, 'LineStyle', '--', 'LineWidth', 0.8);
% errorbar(FWHM_structural_mean, 0, FWHM_structural_std, 'horizontal', 'Color', [120, 120, 120]/255);

FWHM_structural_pct_lower   = prctile(FWHMs_structural, 2.5);
FWHM_structural_pct_upper   = prctile(FWHMs_structural, 97.5);

scatter([FWHM_structural_pct_lower, FWHM_structural_pct_upper], [0, 0], 15, 'filled', 'o', 'MarkerFaceColor', color_structural);

% plotting the mean ACFs for each task
plot(distances, task_mean_ACFs_monkeyB_NSP1(1, :), 'Color', color_ODR, 'LineStyle', '-', 'LineWidth', 2);  % ODR, yellow
plot(distances, task_mean_ACFs_monkeyB_NSP1(2, :), 'Color', color_KM, 'LineStyle', '-', 'LineWidth', 2);   % VWM, green
plot(distances, task_mean_ACFs_monkeyB_NSP1(3, :), 'Color', color_AL, 'LineStyle', '-', 'LineWidth', 2);   % CDM, purple

% plotting the mean FWHM of functional ACFs for each task
xline(task_mean_FWHMs_monkeyB_NSP1(1), 'Color', color_ODR, 'LineStyle', '--', 'LineWidth', 0.8); 
xline(task_mean_FWHMs_monkeyB_NSP1(2), 'Color', color_KM, 'LineStyle', '--', 'LineWidth', 0.8); 
xline(task_mean_FWHMs_monkeyB_NSP1(3), 'Color', color_AL, 'LineStyle', '--', 'LineWidth', 0.8); 

xlim([0, 3.65]);
ylim([-0.3, 1]);
xlabel('distances (mm)');
ylabel('donut ACF'); 
title('goldman-rakic simulations'); 

pageHeadings                = 'cv donut ACFs';
PS_acfs = fullfile(resultsPath, sprintf('acfs_%s.ps', signalType));
if exist(PS_acfs, 'file')
    system(['rm ' PS_acfs]);
end
addHeadingAndPrint(pageHeadings, PS_acfs, figI_acf); 

close all;

end % START_B8_all_donutACF_curves_cv


function [curves_fitted, s_fitted, R2, fwhm]  = fitting(corrs, dists, func)
% 
% last modified: 2023.09.11

import utils_dx.*; 

rng('default'); 

switch func
    case 'gaussian'
        equation            = '1.01*exp(-d^2/(2*s^2))-0.01';    % gaussian 
    case 'laplacian'
        equation            = '1.02*exp(-d/s)-0.02';            % laplacian
end

myfittype                   = fittype(equation,...
    'independent',{'d'},...
    'coefficients',{'s'}); 

nSessions                   = size(corrs, 1); 

curves_fitted               = nan(nSessions, numel(dists)); 
s_fitted                    = nan(nSessions, 1);

for sessI = 1:nSessions
    myfit                   = fit(dists', corrs(sessI, :)', myfittype);
    s                       = myfit.s;
    s_fitted(sessI)         = s;
    switch func
        case 'gaussian'
            curves_fitted(sessI, :) = 1.01*exp(-dists.^2/(2*s^2))-0.01;     % gaussian
        case 'laplacian'
            curves_fitted(sessI, :) = 1.02*exp(-dists./s)-0.02;             % laplacian
    end
end % sessI 

% R2                          = computeR2(corrs(:, 2:end), curves_fitted(:, 2:end));
R2                          = computeR2(corrs, curves_fitted);
fwhm                        = computeFWHM(s_fitted, func); 

end 


function fwhm = computeFWHM(s, func)
% compute fwhm for gaussian and laplacian
% 
% last modified: 2023.09.14

switch func
    case 'gaussian'
        fwhm = 2 * abs(s) * sqrt(2 * log(2));
    case 'laplacian'
        fwhm = 2 * s * log(2); 
end

end