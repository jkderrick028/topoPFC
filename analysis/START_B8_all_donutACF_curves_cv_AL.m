function START_B8_all_donutACF_curves_cv_AL
% plot the spatial ACFs for AL monkey B dorsal array pre- and post-spike
% removal
% 
% last modified: 2024.12.28


import utils_dx.*; 

close all; 

% data
subjectStrs                         = {'Buzz'};
arrayStrs                           = {'NSP1'};
taskStrs                            = {'AL'}; 

%% preparation
projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'topovis';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

signalType                          = 'mcTuning'; 

arrayColors = {
    [19, 74, 142]/255,      % Buzz, NSP1            
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