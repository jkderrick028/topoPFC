function START_R8_simmat_session_splits
% 1. split the tuning profiles within a session into 2 halves with
% non-overlapping conditions.
% 2. compute the similarity matrices for each half.  
% 3. compute the similarity of these two similarity matrices.
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

output                          = []; 
MAT_output                      = fullfile(resultsPath, sprintf('output.mat')); 

subjectStrs                     = {'Buzz', 'Theo'}; 
arrayStrs                       = {'NSP0', 'NSP1'}; 
taskStrs                        = {'ODR', 'KM', 'AL'};
nTasks                          = numel(taskStrs);
nConds_perTask                  = [12, 27, 24]; 
excludedSessionStrs             = get_excludedSessionStrs(); 
nSamples                        = 100; 

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
        MAT_spikeTuningVectors = fullfile(projectPath, 'results', 'spikeTuningVectors', sprintf('START_B1_extractSignal_%s', taskStrs{taskI}), sprintf('START_B1_extractSignal_%s_%s_channels_results.mat', taskStrs{taskI}, subjectStrs{subjectI})); 
        spikeTuningResults = load(MAT_spikeTuningVectors).spikeTuningResults; 

        switch subjectStrs{subjectI}
            case 'Buzz'
                sessionStrs = sessionStrsB; 
            case 'Theo'
                sessionStrs = sessionStrsT; 
        end
        sessionStrs         = setdiff(sessionStrs, excludedSessionStrs);
        
        for arrayI=1:numel(arrayStrs)
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
                    % tuning_1            = tuning_1 - mean(tuning_1, 2); 
                    % tuning_2            = tuning_2 - mean(tuning_2, 2);

                    % corrmats for each half
                    corrmat_1           = corr(tuning_1', 'type', 'Pearson');
                    corrmat_2           = corr(tuning_2', 'type', 'Pearson');

                    sim_corrmats(sampleI)= corr(sqmat2vec(corrmat_1), sqmat2vec(corrmat_2), 'rows', 'complete', 'type', 'Pearson');
                end % sampleI
                output.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI})(sessI).session         = sessionStrs{sessI};
                output.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI})(sessI).sim_corrmats    = sim_corrmats;
            end % sessI 
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

        for taskI=1:numel(taskStrs)
            sim_corrmats        = [output.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).sim_corrmats]; 
            sim_corrmats        = mean(sim_corrmats, 1); 
            mean_tasks(taskI)   = mean(sim_corrmats);
            ste_tasks(taskI)    = std(sim_corrmats)/sqrt(numel(sim_corrmats)); 
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
        currSubplotI            = currSubplotI + 1; 
    end % arrayI
end % subjectI 

pageHeading                     = []; 
pageHeading{1}                  = sprintf('sim of within-session split-half corrmats'); 
addHeadingAndPrint(pageHeading, PS_corr_summary, figI_corr_summary); 
 
save(MAT_output, 'output', '-v7.3'); 

close all; 
end % START_R8_simmat_session_splits

