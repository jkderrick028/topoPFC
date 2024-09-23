function START_R9_topoInference_t_test_independent
% signal = task + residuals.
% the replicability of correlation matrices (signal, task, residuals)
% within and across tasks. 
% 
% we only include session pairs that are independent - meaning a session
% cannot participate in 2 session pairs. 
% 
% last modified: 2024.09.23

import topography.*; 
import spikes.*;
import utils_dx.*; 

rng('default'); 

close all;

projectPath = setProjectPath();
[currPath, currfilename, currext] = fileparts(mfilename('fullpath'));
ANALYSIS    = 'topography';
resultsPath = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

output_inference                = []; 
MAT_output_inference            = fullfile(resultsPath, sprintf('output_inference.mat')); 

MAT_output_simmats              = fullfile(resultsPath, '..', 'START_B6_topoInference_generation', sprintf('output_simmats.mat')); 
output_simmats                  = load(MAT_output_simmats).output_simmats; 

subjectStrs                     = {'Buzz', 'Theo'}; 
arrayStrs                       = {'NSP0', 'NSP1'}; 
signal_types                    = {'whole', 'task', 'residuals'}; 

MAT_daysAcrossTasks             = fullfile(resultsPath, '..', 'START_B5_daysAcrossTasks', 'START_B5_daysAcrossTasks_output.mat'); 
if ~exist(MAT_daysAcrossTasks, 'file')
    START_B5_daysAcrossTasks; 
end
daysAcrossTasks_output          = load(MAT_daysAcrossTasks).output;

sessionPairs                    = generate_sessionPairs(daysAcrossTasks_output);

task_combinations               = { {'ODR', 'ODR'};
                                    {'ODR', 'KM'};
                                    {'ODR', 'AL'};
                                    {'KM', 'KM'};
                                    {'KM', 'AL'};
                                    {'AL', 'AL'}};
n_task_combinations             = numel(task_combinations); 
nPermutations                   = 1000; 

significance_level              = 0.05; 
figI_corr_summary               = 10;
PS_corr_summary                 = fullfile(resultsPath, sprintf('%s_corr_summary.ps', currfilename));
if exist(PS_corr_summary, 'file')
    system(['rm ' PS_corr_summary]); 
end

%% dealing with real data
nVers                           = 2; 
nHors                           = ceil(n_task_combinations / nVers);

for subjectI = 1:numel(subjectStrs)
    sessionPairs_thisSubject    = sessionPairs.(subjectStrs{subjectI}); 
    n_sessionPairs_thisSubject  = numel(sessionPairs_thisSubject); 

    for arrayI = 1:numel(arrayStrs)        
        simmat_corrs        = nan(numel(signal_types), n_sessionPairs_thisSubject);
        simmat_corrs_perm   = nan(numel(signal_types), n_sessionPairs_thisSubject, nPermutations); 
        
        for signal_typeI = 1:numel(signal_types)
            for sess_pairI = 1:n_sessionPairs_thisSubject
                task1       = sessionPairs_thisSubject(sess_pairI).task1; 
                task2       = sessionPairs_thisSubject(sess_pairI).task2;
                sess1       = sessionPairs_thisSubject(sess_pairI).sess1; 
                sess2       = sessionPairs_thisSubject(sess_pairI).sess2;

                row_index1  = find(strcmp({output_simmats.(task1).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sess1)).signal_type}, signal_types{signal_typeI})); 
                simmat1     = output_simmats.(task1).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sess1))(row_index1).signal_corrmat;

                row_index2  = find(strcmp({output_simmats.(task2).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sess2)).signal_type}, signal_types{signal_typeI})); 
                simmat2     = output_simmats.(task2).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sess2))(row_index2).signal_corrmat;               
                chanLinearInds2     = output_simmats.(task2).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sess2))(1).chanLinearInds;
                
                simmat_corrs_perm(signal_typeI, sess_pairI, :) = corrmat_corrs_permutation(simmat1, simmat2, chanLinearInds2);

                simmat1     = sqmat2vec(simmat1); 
                simmat2     = sqmat2vec(simmat2); 

                simmat_corrs(signal_typeI, sess_pairI) = corr(simmat1, simmat2, 'type', 'Pearson', 'rows', 'complete');
            end % sess_pairI
        end % signal_typeI
        output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).simmat_corrs       = simmat_corrs;
        output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).simmat_corrs_perm  = simmat_corrs_perm; 
        
        task1s_this_subject = {sessionPairs_thisSubject.task1}; 
        task2s_this_subject = {sessionPairs_thisSubject.task2}; 

        actual_mean_task_combs  = nan(numel(signal_types), n_task_combinations);
        perm_results_task_combs = nan(numel(signal_types), n_task_combinations, nPermutations);

        figure(figI_corr_summary); clf(figI_corr_summary);

        for combI=1:n_task_combinations
            subplot(nHors, nVers, combI); 
            hold on; 
            inds_combI          = find(strcmp(task1s_this_subject, task_combinations{combI}{1}) & strcmp(task2s_this_subject, task_combinations{combI}{2})); 
            n_task_pairs_combI  = numel(inds_combI);

            actual_r_this_comb  = simmat_corrs(:, inds_combI);
            
            output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).actual_r(combI).r      = actual_r_this_comb;
            output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).actual_r(combI).n      = n_task_pairs_combI;
            output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).actual_r(combI).tasks  = strjoin(task_combinations{combI}, '_');

            actual_mean_task_combs(:, combI) = mean(actual_r_this_comb, 2); 
            errorbar(1:numel(signal_types), actual_mean_task_combs(:, combI)', std(actual_r_this_comb, 0, 2)/sqrt(n_task_pairs_combI)', '.', 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1);
            xlim([0, numel(signal_types)+1]);
            xticks(1:numel(signal_types));
            xticklabels(signal_types);
            xlabel('signal types'); 
            ylim([-0.17, 0.8]); 
            yticks(0:0.2:0.8);
            ylabel('Pearson r');
            title(sprintf('%s %s (%d)', task_combinations{combI}{1}, task_combinations{combI}{2}, n_task_pairs_combI));
            box off;            

            % plot the mean and ste of permutations
            perm_results        = squeeze(mean(simmat_corrs_perm(:, inds_combI, :), 2)); % 3 x 1000
            perm_mean           = mean(perm_results, 2); 
            perm_ste            = std(perm_results, 0, 2);
            perm_results_task_combs(:, combI, :) = perm_results; 
            errorbar(1:numel(signal_types), perm_mean, perm_ste, '.', 'LineStyle', 'none', 'Color', [0 1 1]) % cyan
        end % combI
        output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).perm_results_task_combs  = perm_results_task_combs; 

        % within each task combination, test whether whole is significantly
        % higher than residuals
        for combI=1:n_task_combinations
            inds_combI              = find(strcmp(task1s_this_subject, task_combinations{combI}{1}) & strcmp(task2s_this_subject, task_combinations{combI}{2})); 
           
            rs_whole                = squeeze(simmat_corrs(1, inds_combI));
            rs_residuals            = squeeze(simmat_corrs(3, inds_combI));

            % [h, p_vals, ci, stats]  = ttest(rs_whole, rs_residuals, 'Tail', 'right');
            [h, p_vals, ci, stats]  = ttest(rs_whole, rs_residuals);
            
            if p_vals < significance_level
                subplot(nHors, nVers, combI);
                scatter(1, -0.05, 'filled', 'MarkerFaceColor', [0.4660 0.6740 0.1880]); % green 
            end
            output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).actual_r(combI).p_whole_gt_residuals       = p_vals;
            output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).actual_r(combI).stats_whole_gt_residuals   = stats;
        end % combI 

        % within each task combination, test whether task is significantly
        % higher than residuals
        for combI=1:n_task_combinations
            inds_combI              = find(strcmp(task1s_this_subject, task_combinations{combI}{1}) & strcmp(task2s_this_subject, task_combinations{combI}{2})); 
           
            rs_task                 = squeeze(simmat_corrs(2, inds_combI));
            rs_residuals            = squeeze(simmat_corrs(3, inds_combI));

            % [h, p_vals, ci, stats]  = ttest(rs_task, rs_residuals, 'Tail', 'right'); 
            [h, p_vals, ci, stats]  = ttest(rs_task, rs_residuals); 
            
            if p_vals < significance_level
                subplot(nHors, nVers, combI);
                scatter(2, -0.05, 'filled', 'MarkerFaceColor', [0.3010 0.7450 0.9330]); % light blue 
            end
            output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).actual_r(combI).p_task_gt_residuals        = p_vals;
            output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).actual_r(combI).stats_task_gt_residuals    = stats;
        end % combI

        % within each task combination, test whether residuals is
        % significantly higher than task
        for combI=1:n_task_combinations
            inds_combI              = find(strcmp(task1s_this_subject, task_combinations{combI}{1}) & strcmp(task2s_this_subject, task_combinations{combI}{2})); 
           
            rs_task                 = squeeze(simmat_corrs(2, inds_combI));
            rs_residuals            = squeeze(simmat_corrs(3, inds_combI));

            % [h, p_vals, ci, stats]  = ttest(rs_residuals, rs_task, 'Tail', 'right'); 
            [h, p_vals, ci, stats]  = ttest(rs_residuals, rs_task); 
            if p_vals < significance_level
                subplot(nHors, nVers, combI);
                scatter(3, -0.05, 'filled', 'MarkerFaceColor', [0.8500 0.3250 0.0980]); % orange
            end
            output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).actual_r(combI).p_residuals_gt_task        = p_vals;
            output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).actual_r(combI).stats_residuals_gt_task    = stats;
        end % combI      

        % within each task combination, test whether replicability is
        % significantly higher than permutation null distribution
        for combI=1:n_task_combinations
            perm_results        = squeeze(perm_results_task_combs(:, combI, :)); 
            p_vals = perm_results >= repmat(actual_mean_task_combs(:, combI), 1, nPermutations); 
            p_vals = sum(p_vals, 2) / nPermutations;
            p_significant = find(p_vals < significance_level);

            if ~isempty(p_significant)
                subplot(nHors, nVers, combI);
                scatter(p_significant, -0.15*ones(1, numel(p_significant)), 'filled', 'MarkerFaceColor', [1 0 1]); % magenta 
            end
            output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).actual_r(combI).perm_results   = perm_results;
            output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).actual_r(combI).p_perm         = p_vals;
        end % combI

        % for between-task combinations, plot the noise ceiling, estimated
        % using the sqrt of average within-task replicability
        for combI=1:n_task_combinations   
            inds_combI          = find(strcmp(task1s_this_subject, task_combinations{combI}{1}) & strcmp(task2s_this_subject, task_combinations{combI}{2}));            
            n_task_pairs_combI  = numel(inds_combI);
            
            if ~strcmp(task_combinations{combI}{1}, task_combinations{combI}{2})
                for combJ=1:n_task_combinations
                    if strcmp(task_combinations{combJ}{1}, task_combinations{combJ}{2}) && strcmp(task_combinations{combJ}{1}, task_combinations{combI}{1})
                        combJ_task1_task1 = combJ;
                    end
                    if strcmp(task_combinations{combJ}{1}, task_combinations{combJ}{2}) && strcmp(task_combinations{combJ}{1}, task_combinations{combI}{2})
                        combJ_task2_task2 = combJ;
                    end
                end % combJ
                actual_mean_task1   = actual_mean_task_combs(:, combJ_task1_task1); 
                actual_mean_task2   = actual_mean_task_combs(:, combJ_task2_task2);
                actual_mean_dot_product = actual_mean_task1 .* actual_mean_task2; 
                noise_ceiling       = sqrt(actual_mean_dot_product); 
                
                % t test see if between task reliability is significantly
                % lower than noise ceiling
                rs                      = simmat_corrs(:, inds_combI);
                [h, p_vals, ci, stats]  = ttest(rs', repmat(noise_ceiling, 1, n_task_pairs_combI)', 'Tail', 'left'); 
                                
                p_significant           = find(p_vals < significance_level);
                
                subplot(nHors, nVers, combI);
                errorbar(1:numel(signal_types), noise_ceiling, 0, '.', 'LineStyle', 'none', 'Color', [0 0.4470 0.7410]); % blue
                
                if ~isempty(p_significant)
                    scatter(p_significant, -0.1*ones(1, numel(p_significant)), 'filled', 'MarkerFaceColor', [0.6350 0.0780 0.1840]); % red 
                end 
                output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).actual_r(combI).noise_ceiling          = noise_ceiling;
                output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).actual_r(combI).p_lt_noise_ceiling     = p_vals;
                output_inference.(subjectStrs{subjectI}).(arrayStrs{arrayI}).actual_r(combI).stats_lt_noise_ceiling = stats;
            end 
        end % combI 
        
        pageHeading{1}          = sprintf('simmat corrmat replicability for whole, task and residuals'); 
        pageHeading{2}          = sprintf('%s %s', subjectStrs{subjectI}, arrayStrs{arrayI}); 
        addHeadingAndPrint(pageHeading, PS_corr_summary, figI_corr_summary); 
    end % arrayI 
end % subjectI 

save(MAT_output_inference, 'output_inference', '-v7.3'); 

close all; 
end % START_R9_topoInference_t_test_independent


function output = generate_sessionPairs(daysAcrossTasks_output, varargin)
% generating task session pairs no more than certain days apart. 
% 
% last modified: 2024.02.19

p               = inputParser; 
p.addParameter('maxDays', 20);

parse(p, varargin{:});
maxDays         = p.Results.maxDays; 

subjectStrs     = {'Buzz', 'Theo'};
output          = []; 

for subjectI=1:numel(subjectStrs)
    sessions    = daysAcrossTasks_output.(subjectStrs{subjectI}).sessions_thisSubject; 
    tasks       = daysAcrossTasks_output.(subjectStrs{subjectI}).tasks_thisSubject;
    daysDiff    = daysAcrossTasks_output.(subjectStrs{subjectI}).daysDiff; 

    daysDiff    = triu(daysDiff, 1); 

    for dayI=1:(numel(sessions)-1)
        found_first = 0;
        for dayJ=(dayI+1):numel(sessions)
            if strcmp(tasks{dayI}, tasks{dayJ})
                continue;
            end
            if abs(daysDiff(dayI, dayJ)) <= maxDays && abs(daysDiff(dayI, dayJ)) > 0 && found_first==0 
                found_first = 1;
                continue; 
            end
            if found_first
                daysDiff(dayI, dayJ) = 0;  
            end
        end % dayJ 
    end % dayI

    for dayJ=2:numel(sessions)
        found_first = 0;
        for dayI=1:(dayJ-1)
            if strcmp(tasks{dayI}, tasks{dayJ})
                continue;
            end
            if abs(daysDiff(dayI, dayJ)) <= maxDays && abs(daysDiff(dayI, dayJ)) > 0 && found_first==0 
                found_first = 1;
                continue; 
            end
            if found_first
                daysDiff(dayI, dayJ) = 0;  
            end
        end % dayI 
    end % dayJ 

    sessPairInds= find(abs(daysDiff) <= maxDays & abs(daysDiff) > 0); 
    sz          = size(daysDiff); 
    [X, Y]      = ind2sub(sz, sessPairInds); 

    for indx=1:numel(X)
        output.(subjectStrs{subjectI})(indx).task1      = tasks{X(indx)}; 
        output.(subjectStrs{subjectI})(indx).task2      = tasks{Y(indx)};
        output.(subjectStrs{subjectI})(indx).sess1      = sessions{X(indx)};
        output.(subjectStrs{subjectI})(indx).sess2      = sessions{Y(indx)};
        output.(subjectStrs{subjectI})(indx).daysDiff   = daysDiff(X(indx), Y(indx)); 
    end % indx
end % subjectI 

end % function generate_sessionPairs

function corrs_permutation = corrmat_corrs_permutation(corrmat1, corrmat2, chanLinearInds2, varargin)
% permute channel locations and compute correlations
% 
% corrmat of shape nChannelsTotal x nChannelsTotal
% chanLinearInds of shape nChannels_active x 1
% 
% last modified: 2024.03.12

import utils_dx.sqmat2vec; 

p                   = inputParser; 
p.addParameter('nPermutations', 1000); 

parse(p, varargin{:});
nPermutations       = p.Results.nPermutations; 

corrs_permutation   = nan(nPermutations, 1); 

nChannelsTotal      = size(corrmat1, 1); 
corrmat1_vec        = sqmat2vec(corrmat1); 

for permI=1:nPermutations
    chanLinearInds2_permed                          = randsample(chanLinearInds2, numel(chanLinearInds2), false); 
    corrmat2_perm                                   = nan(nChannelsTotal, nChannelsTotal);
    corrmat2_perm(chanLinearInds2, chanLinearInds2) = corrmat2(chanLinearInds2_permed, chanLinearInds2_permed); 
    corrmat2_perm_vec                               = sqmat2vec(corrmat2_perm); 
    corrs_permutation(permI)                        = corr(corrmat1_vec, corrmat2_perm_vec, 'type', 'Pearson', 'rows', 'complete'); 
end % permI 

end % function corrmat_corrs_permutation
