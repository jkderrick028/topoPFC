function START_B3_donutACF(varargin)
% function START_B3_donutACF computes donut ACF with permutations using
% mcTuning or residuals. In this script, Xi is the mean-centered tuning
% profile vector of the i-th channel
% 
% last modified: 2024.04.14

import spikes.*;
import utils_dx.*;
import moranI.*;
import topography.tile_tuning_profile; 

close all;

p                                   = inputParser;
p.addParameter('taskStr', 'KM');                                % KM, AL, ODR
p.addParameter('signalType', 'mcTuning');                       % or residual or task_evoked

parse(p, varargin{:});
taskStr                             = p.Results.taskStr; 
signalType                          = p.Results.signalType; 

projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'moranI';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

subjectStrs                         = {'Buzz', 'Theo'};
arrayStrs                           = {'NSP0', 'NSP1'};
excludedSessionStrs                 = get_excludedSessionStrs(); 
nRows                               = 10;
nCols                               = 10;
nChannelsTotal                      = nRows*nCols;
figI_acf                            = 10; 

resultsPath_taskTuning              = fullfile(projectPath, 'results', 'spikeTuningVectors', sprintf('START_B1_extractSignal_%s', taskStr));

for subjectI=1:numel(subjectStrs)
    PS_acf                          = fullfile(resultsPath, sprintf('%s_%s_%s_%s.ps', currfilename, taskStr, subjectStrs{subjectI}, signalType));
    if exist(PS_acf, 'file'), system(['rm ' PS_acf]); end

    output                          = [];
    MAT_output                      = fullfile(resultsPath, sprintf('%s_%s_%s_%s.mat', currfilename, subjectStrs{subjectI}, taskStr, signalType)); 
    
    MAT_tuningResults               = fullfile(resultsPath_taskTuning, sprintf('START_B1_extractSignal_%s_%s_channels_results.mat', taskStr, subjectStrs{subjectI}));
    spikeTuningResults              = load(MAT_tuningResults).spikeTuningResults;

    sessionStrs                     = fieldnames(spikeTuningResults.NSP0);
    sessionStrs                     = strrep(sessionStrs, 'sess_', '');
    sessionStrs                     = setdiff(sessionStrs, excludedSessionStrs); 
    nSessions                       = numel(sessionStrs);

    for sessI = 1:nSessions
        figure(figI_acf); clf(figI_acf);
        nHors                       = numel(arrayStrs);
        nVers                       = 1; 
        for arrayI=1:numel(arrayStrs)
            subplot(nHors, nVers, arrayI); 
            fprintf('Processing %s %s %s %s\n', subjectStrs{subjectI}, taskStr, sessionStrs{sessI}, arrayStrs{arrayI}); 
            switch taskStr
                case 'KM'
                    residualRaster          = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.residualRaster;
                    tuningProfile           = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.tuningProfile;
                    mcTuningProfile         = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.mcTuningProfile;
                    conditionInfo           = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.conditionInfo; 
                    uniqueConditions        = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.uniqueConditions; 
                    chanLinearInds          = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.chanLinearInds;
                case 'AL'
                    residualRaster          = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.residualRaster;
                    tuningProfile           = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.tuningProfile;
                    mcTuningProfile         = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.mcTuningProfile;
                    conditionInfo           = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.conditionInfo; 
                    uniqueConditions        = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.uniqueConditions; 
                    chanLinearInds          = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.chanLinearInds;
                case 'ODR'
                    residualRaster          = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.residualRaster;
                    tuningProfile           = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.tuningProfile;
                    mcTuningProfile         = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.mcTuningProfile;
                    conditionInfo           = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.conditionInfo; 
                    uniqueConditions        = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.uniqueConditions; 
                    chanLinearInds          = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.chanLinearInds;              
            end
            
            switch signalType
                case 'mcTuning'
                    signalProfile           = mcTuningProfile; 
                case 'residual'
                    signalProfile           = residualRaster; 
                case 'task_evoked'
                    signalProfile           = tile_tuning_profile(tuningProfile, conditionInfo, uniqueConditions);
            end
            signalProfile                   = reshape(signalProfile, size(signalProfile, 1), []);             
            donutACFresults                 = donutACF_channels(signalProfile, setdiff(1:nChannelsTotal, chanLinearInds));
            titleStr                        = sprintf('%s', arrayStrs{arrayI});
            title(titleStr); 
            ylim([-0.2, 0.6]); 
            box off; 

            output.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).signalProfile           = signalProfile;
            output.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).sessionStrs             = sessionStrs;
            output.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).chanLinearInds          = chanLinearInds;
            output.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).donutACFresults         = donutACFresults;
        end % arrayI 
        pageHeadings                        = [];
        pageHeadings{1}                     = sprintf('donutACF, %s %s', strrep(taskStr, '_', ' '), strrep(signalType, '_', ' '));
        pageHeadings{2}                     = sprintf('%s %s', subjectStrs{subjectI}, sessionStrs{sessI});            
        addHeadingAndPrint(pageHeadings, PS_acf, figI_acf);    
    end % sessI 
    save(MAT_output, 'output', '-v7.3');
end % subjectI

close all;
end % START_B3_donutACF
