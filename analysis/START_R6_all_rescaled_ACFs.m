function START_R6_all_rescaled_ACFs
% plot the donutACFs for 1. ODR, 2. KM, and 3. AL tasks, then 4. the mean
% on top of goldman-rakic simulations. 
% 
% to run this script, copy START_B3_donutACF_fitting_summary_cv.mat files and
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

output                      = [];
MAT_output                  = fullfile(resultsPath, sprintf('%s_output.mat', currfilename)); 

n_tasks = numel(taskStrs);

task_mean_monkeyB_NSP1      = []; 

for taskI = 1:n_tasks
    MAT_donutACF            = fullfile(resultsPath, sprintf('START_B3_donutACF_fitting_summary_cv_%s_%s.mat', taskStrs{taskI}, signalType));
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

resizes = [0.4, 0.8, 1.0, 1.2, 1.6, 2.0]; 

nHors = 3;
nVers = 2;

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

    % compute the confidence interval for each distance
    lbs                         = [1];
    ubs                         = [1]; 
    for distI = 2:size(I_real_combine, 2)
        % [lb, ub]                = compute_95_CI(I_real_combine(:, distI)); 
        [lb, ub]                = compute_95_percentil(I_real_combine(:, distI)); 
        % [lb, ub]                = compute_90_percentil(I_real_combine(:, distI));
        
        if  all(task_mean_monkeyB_NSP1(:, distI) >= lb) && all(task_mean_monkeyB_NSP1(:, distI) <= ub)
            is_significant_distance = 1; 
        else
            is_significant_distance = 0; 
        end
        output.(sprintf('resize_%d', sizeI))(distI).lb      = lb;
        output.(sprintf('resize_%d', sizeI))(distI).ub      = ub;
        output.(sprintf('resize_%d', sizeI))(distI).data    = I_real_combine(:, distI);
        output.(sprintf('resize_%d', sizeI))(distI).is_significant_distance = is_significant_distance;
        lbs(end+1)              = lb;
        ubs(end+1)              = ub; 
    end % distI 

    subplot(nHors, nVers, sizeI); 
    hold on;
    yline(0, 'LineWidth', 1, 'Color', [120, 120, 120]/255, 'LineStyle', '--'); 
    a = plot(distances, I_real_combine', 'Color', [200, 200, 200]/255, 'LineWidth', 0.3);
    alpha(a, 0.5)
    plot(distances, mean(I_real_combine, 1, 'omitnan'), 'Color', 'k', 'LineWidth', 2); 

    plot(distances, task_mean_monkeyB_NSP1(1, :), 'Color', [0.9290 0.6940 0.1250], 'LineStyle', '-', 'LineWidth', 2);   % ODR, yellow
    plot(distances, task_mean_monkeyB_NSP1(2, :), 'Color', [0.4660 0.6740 0.1880], 'LineStyle', '-', 'LineWidth', 2);   % VWM, green
    plot(distances, task_mean_monkeyB_NSP1(3, :), 'Color', [0.4940 0.1840 0.5560], 'LineStyle', '-', 'LineWidth', 2);   % CDM, purple

    % plot(distances, lbs, 'Color', 'r', 'LineWidth', 1, 'LineStyle', '--');
    % plot(distances, ubs, 'Color', 'r', 'LineWidth', 1, 'LineStyle', '--');

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

save(MAT_output, 'output', '-v7.3'); 

close all;

end % START_R6_all_rescaled_ACFs


function [lb, ub] = compute_95_CI(data)
% compute 95% confidence interval
% 
% last modified: 2024.09.06

mean_data   = mean(data);
n           = numel(data);
sigma       = std(data);

lb          = mean_data - 1.96 * sigma / sqrt(n);
ub          = mean_data + 1.96 * sigma / sqrt(n);

end % function compute_95_CI

function [lb, ub] = compute_95_percentil(data)
% compute 95% confidence interval
% 
% last modified: 2024.09.06

lb          = prctile(data, 2.5);
ub          = prctile(data, 97.5);

end % function compute_95_percentil

function [lb, ub] = compute_90_percentil(data)
% compute 95% confidence interval
% 
% last modified: 2024.09.06

lb          = prctile(data, 5);
ub          = prctile(data, 95);

end % function compute_90_percentil
