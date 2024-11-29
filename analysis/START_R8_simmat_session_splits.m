function START_R8_simmat_session_splits
% 1. split the tuning profiles within a session into 2 halves with
% non-overlapping conditions.
% 2. compute the similarity matrices for each half.  
% 3. compute the similarity of these two similarity matrices.
% 
% last modified: 2024.10.01

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

output                          = []; 
MAT_output                      = fullfile(resultsPath, sprintf('output.mat')); 

subjectStrs                     = {'Buzz', 'Theo'}; 
arrayStrs                       = {'NSP0', 'NSP1'}; 
taskStrs                        = {'ODR', 'KM', 'AL'};
nTasks                          = numel(taskStrs);
nConds_perTask                  = [12, 27, 24]; 
excludedSessionStrs             = get_excludedSessionStrs(); 
nSamples                        = 100;
nChannelsTotal                  = 100; 

% split conditions into 2 halves
for taskI=1:nTasks
    [sessionStrsB, sessionStrsT] = getSessInfo(taskStrs{taskI}); 

    nConds_split1               = ceil(nConds_perTask(taskI)/2); 
    cond_inds_split1            = zeros(nSamples, nConds_split1);
    cond_inds_split2            = zeros(nSamples, nConds_perTask(taskI)-nConds_split1); 
    
    for sampleI = 1:nSamples
        cond_inds_split1(sampleI, :) = randsample(nConds_perTask(taskI), nConds_split1);
        cond_inds_split2(sampleI, :) = setdiff(1:nConds_perTask(taskI), cond_inds_split1(sampleI, :));        
    end % sampleI

    output.(taskStrs{taskI}).cond_inds_split1 = cond_inds_split1;
    output.(taskStrs{taskI}).cond_inds_split2 = cond_inds_split2;

    for subjectI=1:numel(subjectStrs)
        MAT_spikeTuningVectors  = fullfile(projectPath, 'results', 'spikeTuningVectors', sprintf('START_B1_extractSignal_%s', taskStrs{taskI}), sprintf('START_B1_extractSignal_%s_%s_channels_results.mat', taskStrs{taskI}, subjectStrs{subjectI})); 
        spikeTuningResults      = load(MAT_spikeTuningVectors).spikeTuningResults; 

        switch subjectStrs{subjectI}
            case 'Buzz'
                sessionStrs     = sessionStrsB; 
            case 'Theo'
                sessionStrs     = sessionStrsT; 
        end
        sessionStrs             = setdiff(sessionStrs, excludedSessionStrs);
        
        for arrayI=1:numel(arrayStrs)
            %% only save simmats for half 1
            simmats                     = nan(numel(sessionStrs), nSamples, nChannelsTotal*(nChannelsTotal-1)/2); 
            for sessI=1:numel(sessionStrs)
                switch taskStrs{taskI}
                    case 'ODR'
                        tuningProfile   = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.tuningProfile; 
                    case 'KM'
                        tuningProfile   = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.tuningProfile; 
                    case 'AL'
                        tuningProfile   = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.tuningProfile; 
                end
                tuningProfile           = reshape(tuningProfile, size(tuningProfile, 1), []); 

                sim_corrmats            = nan(nSamples, 1); 
                for sampleI=1:nSamples
                    tuning_1            = tuningProfile(:, cond_inds_split1(sampleI, :)); 
                    tuning_2            = tuningProfile(:, cond_inds_split2(sampleI, :)); 

                    % % mean-centering
                    tuning_1            = tuning_1 - mean(tuning_1, 2); 
                    tuning_2            = tuning_2 - mean(tuning_2, 2);

                    % corrmats for each half
                    corrmat_1           = corr(tuning_1', 'type', 'Pearson');
                    corrmat_2           = corr(tuning_2', 'type', 'Pearson');

                    % sqmat2vec
                    corrmat_1           = sqmat2vec(corrmat_1);
                    corrmat_2           = sqmat2vec(corrmat_2);

                    sim_corrmats(sampleI)       = corr(corrmat_1, corrmat_2, 'rows', 'complete', 'type', 'Pearson');
                    simmats(sessI, sampleI, :)  = corrmat_1;
                end % sampleI
                output.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI})(sessI).session         = sessionStrs{sessI};
                output.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI})(sessI).sim_corrmats    = sim_corrmats;
            end % sessI 
            output.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI})(1).simmats                 = simmats;
        end % arrayI 
    end % subjectI 
end % taskI

save(MAT_output, 'output', '-v7.3'); 

% computing the upper bound by splitting the spikeRateRasters into two
% halves at the trial level, estimating tuning profiles for each half,
% computing tuning similarity matrices for each half, and correlating the
% simmilarity matrices. 

n_repetitions                   = nSamples; 

for taskI=1:nTasks
    [sessionStrsB, sessionStrsT] = getSessInfo(taskStrs{taskI}); 

    for subjectI = 1:numel(subjectStrs)
        MAT_spikeTuningVectors  = fullfile(projectPath, 'results', 'spikeTuningVectors', sprintf('START_B1_extractSignal_%s', taskStrs{taskI}), sprintf('START_B1_extractSignal_%s_%s_channels_results.mat', taskStrs{taskI}, subjectStrs{subjectI})); 
        spikeTuningResults      = load(MAT_spikeTuningVectors).spikeTuningResults; 

        switch subjectStrs{subjectI}
            case 'Buzz'
                sessionStrs     = sessionStrsB; 
            case 'Theo'
                sessionStrs     = sessionStrsT; 
        end
        sessionStrs             = setdiff(sessionStrs, excludedSessionStrs);

        n_sessions              = numel(sessionStrs);
        
        for arrayI = 1:numel(arrayStrs)
            simmat_corrs        = nan(n_sessions, n_repetitions);
    
            for sessI = 1:n_sessions
                switch taskStrs{taskI}
                    case 'ODR'
                        firingRateRaster    = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.firingRateRaster; 
                        uniqueConditions    = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.uniqueConditions;
                        conditionInfo       = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.conditionInfo;
                    case 'KM'
                        firingRateRaster    = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.firingRateRaster; 
                        uniqueConditions    = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.uniqueConditions;
                        conditionInfo       = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.conditionInfo;
                    case 'AL'
                        firingRateRaster    = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.firingRateRaster; 
                        uniqueConditions    = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.uniqueConditions;
                        conditionInfo       = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.conditionInfo;
                end

                for repeatI = 1:n_repetitions
                    [tuningProfile_1, mcTuningProfile_1, residualRaster_1, tuningProfile_2, mcTuningProfile_2, residualRaster_2] = split_session_2halves(firingRateRaster, conditionInfo, uniqueConditions); 
                    
                    mcTuningProfile_1       = reshape(mcTuningProfile_1, size(mcTuningProfile_1, 1), []);
                    mcTuningProfile_2       = reshape(mcTuningProfile_2, size(mcTuningProfile_2, 1), []);

                    simmat_1                = corr(mcTuningProfile_1', 'Type', 'Pearson');
                    simmat_2                = corr(mcTuningProfile_2', 'Type', 'Pearson');
        
                    simmat_1                = sqmat2vec(simmat_1);
                    simmat_2                = sqmat2vec(simmat_2);
                    simmat_corrs(sessI, repeatI) = corr(simmat_1, simmat_2, 'Type', 'Pearson', 'Rows', 'complete'); 
                end % repeatI
            end % sessI
            output.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI})(1).simmat_corrs    = simmat_corrs;
        end % arrayI
    end % subjectI
end % taskI 


figI_corr_summary               = 10;
PS_corr_summary                 = fullfile(resultsPath, sprintf('%s_corr_session_splits.ps', currfilename));
if exist(PS_corr_summary, 'file')
    system(['rm ' PS_corr_summary]); 
end

figure(figI_corr_summary); clf(figI_corr_summary); 
nHors                           = numel(subjectStrs);
nVers                           = numel(arrayStrs); 
currSubplotI                    = 1; 
for subjectI=1:numel(subjectStrs)
    for arrayI=1:numel(arrayStrs)
        mean_tasks              = nan(1, numel(taskStrs));        
        ste_tasks               = nan(1, numel(taskStrs));
        upper_bound_tasks       = nan(1, numel(taskStrs)); 

        for taskI=1:numel(taskStrs)
            sim_corrmats        = [output.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).sim_corrmats]; 
            sim_corrmats        = mean(sim_corrmats, 1); 
            
            % t-test against 0
            [h, p]              = ttest(sim_corrmats);
            output.(taskStrs{taskI}).ttest.(subjectStrs{subjectI}).(arrayStrs{arrayI}).h = h;
            output.(taskStrs{taskI}).ttest.(subjectStrs{subjectI}).(arrayStrs{arrayI}).p = p;
            
            mean_tasks(taskI)   = mean(sim_corrmats);
            ste_tasks(taskI)    = std(sim_corrmats)/sqrt(numel(sim_corrmats));

            % upper bound
            simmat_corrs        = output.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI})(1).simmat_corrs; 
            upper_bound_tasks(taskI) = mean(simmat_corrs, 'all'); 
        end % taskI
        
        subplot(nHors, nVers, currSubplotI);
        bar(1:numel(taskStrs), mean_tasks);
        hold on;
        errorbar(1:numel(taskStrs), mean_tasks, ste_tasks, 'LineStyle', 'none', 'Color', 'k');
        box off;
        xlabel('tasks');
        ylabel('Pearson r');
        xticks(1:numel(taskStrs));
        xticklabels({'ODR', 'VWM', 'CDM'});
        yticks(0:0.2:1);
        yticklabels(0:0.2:1); 
        ylim([0, 1]); 
        title(sprintf('%s %s', subjectStrs{subjectI}, arrayStrs{arrayI})); 

        % plotting the upper bound
        errorbar(1:numel(taskStrs), upper_bound_tasks, 0, '.', 'LineStyle', 'none', 'Color', [120, 120, 120]/255);

        currSubplotI            = currSubplotI + 1; 
    end % arrayI
end % subjectI 

pageHeading                     = []; 
pageHeading{1}                  = sprintf('sim of within-session split-half corrmats'); 
addHeadingAndPrint(pageHeading, PS_corr_summary, figI_corr_summary); 
 

% computing the betwee-task consistency and noise ceiling
figure(figI_corr_summary); clf(figI_corr_summary); 
nHors                           = numel(subjectStrs);
nVers                           = numel(arrayStrs); 
currSubplotI                    = 1; 

MAT_daysAcrossTasks             = fullfile(projectPath, 'results', 'topography', 'START_B5_daysAcrossTasks', 'START_B5_daysAcrossTasks_output.mat'); 
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

for subjectI = 1:numel(subjectStrs)
    sessionPairs_thisSubject    = sessionPairs.(subjectStrs{subjectI}); 
    n_sessionPairs_thisSubject  = numel(sessionPairs_thisSubject); 

    for arrayI = 1:numel(arrayStrs)
        simmat_corrs            = nan(n_sessionPairs_thisSubject, nSamples); 
        for sess_pairI = 1:n_sessionPairs_thisSubject
            task1               = sessionPairs_thisSubject(sess_pairI).task1; 
            task2               = sessionPairs_thisSubject(sess_pairI).task2;
            sess1               = sessionPairs_thisSubject(sess_pairI).sess1; 
            sess2               = sessionPairs_thisSubject(sess_pairI).sess2;

            sessions_1          = {output.(task1).(subjectStrs{subjectI}).(arrayStrs{arrayI}).session};
            indx_1              = find(strcmp(sessions_1, sess1)); 
            sessions_2          = {output.(task2).(subjectStrs{subjectI}).(arrayStrs{arrayI}).session};
            indx_2              = find(strcmp(sessions_2, sess2));

            simmats_1           = squeeze(output.(task1).(subjectStrs{subjectI}).(arrayStrs{arrayI})(1).simmats(indx_1, :, :));
            simmats_2           = squeeze(output.(task2).(subjectStrs{subjectI}).(arrayStrs{arrayI})(1).simmats(indx_2, :, :)); 

            for repI = 1:nSamples
                simmat_corrs(sess_pairI, repI) = corr(reshape(simmats_1(repI, :), [], 1), reshape(simmats_2(repI, :), [], 1), 'rows', 'complete', 'type', 'Pearson'); 
            end % repI             
        end % sess_pairI 

        task1s_this_subject     = {sessionPairs_thisSubject.task1}; 
        task2s_this_subject     = {sessionPairs_thisSubject.task2};

        mean_task_combs         = nan(n_task_combinations, nSamples);
        ste_task_combs          = nan(n_task_combinations, nSamples);
        for combI = 1:n_task_combinations
            inds_combI                  = find(strcmp(task1s_this_subject, task_combinations{combI}{1}) & strcmp(task2s_this_subject, task_combinations{combI}{2})); 
            n_task_pairs_combI          = numel(inds_combI);

            actual_r_this_comb          = simmat_corrs(inds_combI, :); 
            mean_task_combs(combI, :)   = mean(actual_r_this_comb, 1); 
            ste_task_combs(combI, :)    = std(actual_r_this_comb, 0, 1)/sqrt(n_task_pairs_combI); 
        end % combI 
        
        subplot(nHors, nVers, currSubplotI);
        hold on; 
        errorbar(1:n_task_combinations, mean(mean_task_combs, 2), mean(ste_task_combs, 2), '.', 'LineStyle', 'none', 'Color', 'k', 'LineWidth', 1);
        box off;
        xticks(1:n_task_combinations);
        xticklabels(cellfun(@(x) strjoin(x, '\\_'), task_combinations, 'UniformOutput', false));
        xlim([0, n_task_combinations]);
        ylim([-0.17, 0.8]);
        yticks(0:0.2:0.8);
        title(sprintf('%s %s', subjectStrs{subjectI}, arrayStrs{arrayI})); 
        ylabel('Pearson r'); 
        xlabel('task combs');

        % noise ceiling
        noise_ceilings          = nan(n_task_combinations, 1); 
        for combI=1:n_task_combinations   
            inds_combI          = find(strcmp(task1s_this_subject, task_combinations{combI}{1}) & strcmp(task2s_this_subject, task_combinations{combI}{2}));      
            
            if ~strcmp(task_combinations{combI}{1}, task_combinations{combI}{2})
                for combJ=1:n_task_combinations
                    if strcmp(task_combinations{combJ}{1}, task_combinations{combJ}{2}) && strcmp(task_combinations{combJ}{1}, task_combinations{combI}{1})
                        combJ_task1_task1 = combJ;
                    end
                    if strcmp(task_combinations{combJ}{1}, task_combinations{combJ}{2}) && strcmp(task_combinations{combJ}{1}, task_combinations{combI}{2})
                        combJ_task2_task2 = combJ;
                    end
                end % combJ
                actual_mean_task1       = mean(mean_task_combs(combJ_task1_task1, :)); 
                actual_mean_task2       = mean(mean_task_combs(combJ_task2_task2, :));
                actual_mean_dot_product = actual_mean_task1 .* actual_mean_task2; 
                noise_ceiling           = sqrt(actual_mean_dot_product);
                noise_ceilings(combI)   = noise_ceiling; 
                
                % t test see if between task reliability is significantly
                % lower than noise ceiling
                rs                      = mean(simmat_corrs(inds_combI, :), 2);
                [h, p_vals, ci, stats]  = ttest(rs, noise_ceiling, 'Tail', 'left'); 
                                
                p_significant           = (p_vals < 0.05);
                                
                errorbar(combI, noise_ceiling, 0, '.', 'LineStyle', 'none', 'Color', [150, 150, 150]/255); % grey
                
                if p_significant
                    scatter(combI, -0.1, 'filled', 'MarkerFaceColor', [150, 150, 150]/255); 
                end                 
            end 
        end % combI 
        output.between_tasks.(subjectStrs{subjectI}).(arrayStrs{arrayI}).simmat_corrs           = simmat_corrs; 
        output.between_tasks.(subjectStrs{subjectI}).(arrayStrs{arrayI}).task1s_this_subject    = task1s_this_subject; 
        output.between_tasks.(subjectStrs{subjectI}).(arrayStrs{arrayI}).task2s_this_subject    = task2s_this_subject; 
        output.between_tasks.(subjectStrs{subjectI}).(arrayStrs{arrayI}).mean_task_combs        = mean_task_combs; 
        output.between_tasks.(subjectStrs{subjectI}).(arrayStrs{arrayI}).ste_task_combs         = ste_task_combs; 
        output.between_tasks.(subjectStrs{subjectI}).(arrayStrs{arrayI}).noise_ceilings         = noise_ceilings; 
    end % arrayI 
end % subjectI

pageHeading                     = []; 
pageHeading{1}                  = sprintf('between tasks'); 
addHeadingAndPrint(pageHeading, PS_corr_summary, figI_corr_summary); 


save(MAT_output, 'output', '-v7.3'); 

close all; 
end % START_R8_simmat_session_splits



function [tuningProfile_1, mcTuningProfile_1, residualRaster_1, tuningProfile_2, mcTuningProfile_2, residualRaster_2] = split_session_2halves(firingRateRaster, conditionInfo, uniqueConditions)
% 
% last modified: 2024.09.20

import spikes.extractTuningANDresiduals; 

half1_cond_inds         = [];
half2_cond_inds         = []; 

for condI = 1:numel(uniqueConditions)
    trl_inds_this_cond  = find(strcmp(conditionInfo, uniqueConditions{condI})); 
    half1_this_cond     = randsample(trl_inds_this_cond, ceil(numel(trl_inds_this_cond)/2));
    half2_this_cond     = setdiff(trl_inds_this_cond, half1_this_cond); 

    half1_cond_inds     = [half1_cond_inds; half1_this_cond];
    half2_cond_inds     = [half2_cond_inds; half2_this_cond]; 
end % condI

firingRateRaster1       = firingRateRaster(:, :, half1_cond_inds);
firingRateRaster2       = firingRateRaster(:, :, half2_cond_inds);

conditionInfo_1         = conditionInfo(half1_cond_inds);
conditionInfo_2         = conditionInfo(half2_cond_inds);

[tuningProfile_1, mcTuningProfile_1, residualRaster_1] = extractTuningANDresiduals(firingRateRaster1, conditionInfo_1, uniqueConditions); 
[tuningProfile_2, mcTuningProfile_2, residualRaster_2] = extractTuningANDresiduals(firingRateRaster2, conditionInfo_2, uniqueConditions); 

end % function split_session_2halves


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
