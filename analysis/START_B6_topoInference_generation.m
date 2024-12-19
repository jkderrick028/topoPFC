function START_B6_topoInference_generation
% signal = task + residuals.
% the replicability of correlation matrices (signal, task, residuals)
% within and across tasks. 
% 
% last modified: 2024.04.16

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

output_simmats                  = [];
MAT_output                      = fullfile(resultsPath, sprintf('output_simmats.mat')); 

subjectStrs                     = {'Buzz', 'Theo'}; 
taskStrs                        = {'ODR', 'KM', 'AL'}; 
arrayStrs                       = {'NSP0', 'NSP1'}; 
signal_types                    = {'whole', 'task', 'residuals'}; 
excludedSessionStrs             = get_excludedSessionStrs();

%% control analysis, removing 4 sessions for AL
excludedSessionStrs             = [excludedSessionStrs, {'20171109', '20171110', '20171111', '20171112'}]; 

%%

figI                            = 10; 
nHors                           = 2; 
nVers                           = 2; 

for taskI=1:numel(taskStrs)
    for subjectI=1:numel(subjectStrs)
        MAT_data = fullfile(projectPath, 'results', 'spikeTuningVectors', ['START_B1_extractSignal_', taskStrs{taskI}], ['START_B1_extractSignal_', taskStrs{taskI}, '_', subjectStrs{subjectI}, '_channels_results.mat']); 
        spikeTuningResults      = load(MAT_data).spikeTuningResults;
        for arrayI=1:numel(arrayStrs)
            sessionStrs         = fieldnames(spikeTuningResults.(arrayStrs{arrayI})); % sess_ format
            sessionStrs         = sessionStrs(~contains(sessionStrs, excludedSessionStrs)); 
            
            PS_corrmats         = fullfile(resultsPath, sprintf('corrmats_%s_%s_%s.ps', subjectStrs{subjectI}, arrayStrs{arrayI}, taskStrs{taskI}));
            if exist(PS_corrmats, 'file')
                system(['rm ' PS_corrmats]);
            end
            for sessI=1:numel(sessionStrs)
                switch taskStrs{taskI}
                    case 'ODR'
                        residualRaster          = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).quadrants.residualRaster;
                        tuningProfile           = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).quadrants.tuningProfile;
                        firingRateRaster        = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).quadrants.firingRateRaster;
                        conditionInfo           = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).quadrants.conditionInfo; 
                        uniqueConditions        = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).quadrants.uniqueConditions; 
                        chanLinearInds          = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).quadrants.chanLinearInds;
                    case 'KM'
                        residualRaster          = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).nineLocations.residualRaster;
                        tuningProfile           = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).nineLocations.tuningProfile;
                        firingRateRaster        = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).nineLocations.firingRateRaster;
                        conditionInfo           = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).nineLocations.conditionInfo; 
                        uniqueConditions        = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).nineLocations.uniqueConditions; 
                        chanLinearInds          = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).nineLocations.chanLinearInds;
                    case 'AL'
                        residualRaster          = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).tuning.residualRaster;
                        tuningProfile           = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).tuning.tuningProfile;
                        firingRateRaster        = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).tuning.firingRateRaster;
                        conditionInfo           = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).tuning.conditionInfo; 
                        uniqueConditions        = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).tuning.uniqueConditions; 
                        chanLinearInds          = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).tuning.chanLinearInds;
                end % switch
                task_signal                     = tile_tuning_profile(tuningProfile, conditionInfo, uniqueConditions);           
                
                figure(figI); clf(figI);
                
                for signal_typeI=1:numel(signal_types)
                    switch signal_types{signal_typeI}
                        case 'whole'
                            signal              = firingRateRaster; 
                        case 'task'
                            signal              = task_signal; 
                        case 'residuals'
                            signal              = residualRaster; 
                    end
                    signal                      = reshape(signal, size(signal, 1), []); 
                    signal_corrmat              = corr(signal', 'type', 'Pearson');

                    subplot(nHors, nVers, signal_typeI);

                    visualizeCorrMat(signal_corrmat, 'titleStr', signal_types{signal_typeI}); 

                    output_simmats.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sessionStrs{sessI})(signal_typeI).signal_type     = signal_types{signal_typeI};
                    output_simmats.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sessionStrs{sessI})(signal_typeI).signal          = signal;       
                    output_simmats.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sessionStrs{sessI})(signal_typeI).signal_corrmat  = signal_corrmat;                                        
                end % signal_typeI

                pageHeadings                    = {}; 
                pageHeadings{1}                 = sprintf('corrmats for whole, task and residuals'); 
                pageHeadings{2}                 = sprintf('%s %s %s %s', subjectStrs{subjectI}, arrayStrs{arrayI}, taskStrs{taskI}, strrep(sessionStrs{sessI}, 'sess_', ''));
                addHeadingAndPrint(pageHeadings, PS_corrmats, figI); 

                output_simmats.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sessionStrs{sessI})(1).conditionInfo                  = conditionInfo;
                output_simmats.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sessionStrs{sessI})(1).uniqueConditions               = uniqueConditions;
                output_simmats.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sessionStrs{sessI})(1).chanLinearInds                 = chanLinearInds;
            end % sessI 
        end % arrayI        
    end % subjectI 
end % taskI 

save(MAT_output, 'output_simmats', '-v7.3'); 

close all; 
end % START_B6_topoInference_generation

