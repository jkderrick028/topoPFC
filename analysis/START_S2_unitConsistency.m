function START_S2_unitConsistency
% the consistency of tuning profiles of units measured by the same channel.  
% 
% last modified: 2024.04.27

import utils_dx.*;
import spikes.*;

close all;

projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'supplemental';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

subjectStrs                         = {'Buzz', 'Theo'};
arrayStrs                           = {'NSP0', 'NSP1'};
taskStrs                            = {'ODR', 'KM', 'AL'};
plotTaskStrs                        = {'ODR', 'VWM', 'CDM'}; 
nRows                               = 10;
nCols                               = 10; 
nChannelsTotal                      = nRows * nCols; 
excludedSessionStrs                 = get_excludedSessionStrs(); 
output                              = [];
MAT_output                          = fullfile(resultsPath, sprintf('%s_output.mat', currfilename)); 
figI_consistency                    = 10; 

for subjectI=1:numel(subjectStrs)
    for taskI=1:numel(taskStrs)
        resultsPath_taskTuning      = fullfile(projectPath, 'results', 'spikeTuningVectors', sprintf('START_B1_extractSignal_%s', taskStrs{taskI}));
        MAT_tuningResults           = fullfile(resultsPath_taskTuning, sprintf('START_B1_extractSignal_%s_%s_units_results.mat', taskStrs{taskI}, subjectStrs{subjectI}));
        spikeTuningResults          = load(MAT_tuningResults).spikeTuningResults; 

        for arrayI=1:numel(arrayStrs)
            sessionStrs             = fieldnames(spikeTuningResults.(arrayStrs{arrayI}));
            sessionStrs             = strrep(sessionStrs, 'sess_', '');
            sessionStrs             = setdiff(sessionStrs, excludedSessionStrs); 
            nSessions               = numel(sessionStrs);
            meanCorr_acrossSessions                 = []; 
            nUnitsPerChannel_acrossSessions         = []; 
            for sessI=1:nSessions
                fprintf('Processing %s %s %s %s\n', subjectStrs{subjectI}, taskStrs{taskI}, arrayStrs{arrayI}, sessionStrs{sessI}); 
                meanCorr_eachChannel_thisSession    = nan(nChannelsTotal, 1); 
                nUnitsPerChannel_thisSession        = nan(nChannelsTotal, 1); 
                switch taskStrs{taskI}
                    case 'KM'
                        mcTuningProfile = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.mcTuningProfile;
                        chanLinearInds  = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.chanLinearInds;
                    case 'AL'
                        mcTuningProfile = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.mcTuningProfile;
                        chanLinearInds  = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.chanLinearInds;
                    case 'ODR'
                        mcTuningProfile = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.mcTuningProfile;
                        chanLinearInds  = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.chanLinearInds;             
                end
                mcTuningProfile         = reshape(mcTuningProfile, size(mcTuningProfile, 1), []);
                [meanCorr_eachChannel, uniqueChannelLinearInds, nUnitsPerChannel]   = unitConsistency(mcTuningProfile, chanLinearInds); 
                meanCorr_eachChannel_thisSession(uniqueChannelLinearInds)           = meanCorr_eachChannel;
                nUnitsPerChannel_thisSession(uniqueChannelLinearInds)               = nUnitsPerChannel;
                meanCorr_acrossSessions                                             = cat(2, meanCorr_acrossSessions, meanCorr_eachChannel_thisSession);
                nUnitsPerChannel_acrossSessions                                     = cat(2, nUnitsPerChannel_acrossSessions, nUnitsPerChannel_thisSession);                               
    
                output.(subjectStrs{subjectI}).(taskStrs{taskI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).chanLinearInds    = uniqueChannelLinearInds; 
            end % sessI
            output.(subjectStrs{subjectI}).(taskStrs{taskI}).(arrayStrs{arrayI}).meanCorr_acrossSessions                                        = meanCorr_acrossSessions; 
            output.(subjectStrs{subjectI}).(taskStrs{taskI}).(arrayStrs{arrayI}).nUnitsPerChannel_acrossSessions                                = nUnitsPerChannel_acrossSessions; 
        end % arrayI        
    end % taskI 
end % subjectI 

PS_unitsConsistency_summary     = fullfile(resultsPath, sprintf('%s_summary.ps', currfilename));    
if exist(PS_unitsConsistency_summary, 'file'), system(['rm ' PS_unitsConsistency_summary]); end

nHors           = 3 * 2;                        % number of arrays x 2 distributions
nVers           = numel(taskStrs); 
figure(figI_consistency); clf(figI_consistency);
for subjectI=1:numel(subjectStrs)
    for arrayI=1:numel(arrayStrs)
        if strcmp(subjectStrs{subjectI}, 'Theo') && strcmp(arrayStrs{arrayI}, 'NSP1')
            continue;
        end
        for taskI=1:numel(taskStrs)
            nUnitsPerChannel_acrossSessions = output.(subjectStrs{subjectI}).(taskStrs{taskI}).(arrayStrs{arrayI}).nUnitsPerChannel_acrossSessions; 
            meanCorr_acrossSessions         = output.(subjectStrs{subjectI}).(taskStrs{taskI}).(arrayStrs{arrayI}).meanCorr_acrossSessions; 
            
            nUnitsPerChannel_acrossSessions = reshape(nUnitsPerChannel_acrossSessions, [], 1);
            nUnitsPerChannel_acrossSessions = nUnitsPerChannel_acrossSessions(~isnan(nUnitsPerChannel_acrossSessions));

            meanCorr_acrossSessions         = reshape(meanCorr_acrossSessions, [], 1);
            meanCorr_acrossSessions         = meanCorr_acrossSessions(~isnan(meanCorr_acrossSessions)); 

            arrayIndex      = (subjectI - 1)*numel(arrayStrs) + arrayI;     % 1: B_NSP0, 2: B_NSP1, 3: T_NSP0
            
            % top, nUnits distribution
            currSubplotI    = (arrayIndex - 1) * 2 * nVers + taskI; 
            subplot(nHors, nVers, currSubplotI);
            histogram_nUnitsPerChan(nUnitsPerChannel_acrossSessions);
            % title(sprintf('%s %s %s nUnits dist.', subjectStrs{subjectI}, arrayStrs{arrayI}, plotTaskStrs{taskI}));

            % bottom, corr distribution
            currSubplotI    = currSubplotI + nVers;
            subplot(nHors, nVers, currSubplotI);
            histogram_tuningSimilarity(meanCorr_acrossSessions);
            % title(sprintf('%s %s %s tuning sim. dist.', subjectStrs{subjectI}, arrayStrs{arrayI}, plotTaskStrs{taskI}));
        end % taskI 
    end % arrayI
end % subjectI 

pageHeading                 = []; 
pageHeading{1}              = sprintf('tuning similarity of units within a same channel');
addHeadingAndPrint(pageHeading, PS_unitsConsistency_summary, figI_consistency);

save(MAT_output, 'output', '-v7.3');

close all;
end % function START_S2_unitConsistency


function histogram_tuningSimilarity(meanCorr_eachChannel)
% 
% last modified: 2023.06.07

import utils_dx.*; 

histogram(meanCorr_eachChannel, -1:0.1:1);
box off; 
xlabel('Pearson correlation');
ylabel('# channels');
hold on;
medianCorr = median(meanCorr_eachChannel, 'omitnan'); 
xline(medianCorr, '--', sprintf('median=%.2f', medianCorr), 'LineWidth', 2, 'Color', [100, 100, 100]/255); 

end % function histogram_tuningSimilarity


function histogram_nUnitsPerChan(nUnitsPerChannel)
histogram(nUnitsPerChannel, 'BinMethod', 'integers'); 
xlim([0, 7]);
xticks(1:7);
xticklabels(1:7); 
box off;
xlabel('# units');
ylabel('# channels'); 
end

function [meanCorr_eachChannel, uniqueChannelLinearInds, nUnitsPerChannel] = unitConsistency(tuningProfiles, chanLinearInds)
% 1. the frequency of a channel measuring 1, 2, 3, 4, 5, 6 and more units
% at the same time. 
% 2. the mean correlation of tuning profiles of units within the same
% channel
% 
% last modified: 2023.06.05

import utils_dx.*; 

chanLinearInds_categorical      = categorical(chanLinearInds);
chanLinearInds_categories       = categories(chanLinearInds_categorical); 
nUnitsPerChannel                = countcats(chanLinearInds_categorical);

uniqueChannelLinearInds         = str2double(chanLinearInds_categories); 
nChannels                       = numel(uniqueChannelLinearInds); 
meanCorr_eachChannel            = nan(nChannels, 1);                        % nan for channels with only 1 unit

for chanI = 1:nChannels
    nUnits_thisChannel          = nUnitsPerChannel(chanI);
    if nUnits_thisChannel == 1
        continue;
    end
    unitInds_thisChan           = find(ismember(chanLinearInds, uniqueChannelLinearInds(chanI))); 
    tuningProfiles_thisChan     = tuningProfiles(unitInds_thisChan, :); 
    corrmat                     = corr(tuningProfiles_thisChan', 'type', 'Pearson', 'rows', 'complete'); 
    meanCorr_eachChannel(chanI) = fisherMean(sqmat2vec(corrmat));
end % chanI 

end % function unitConsistency