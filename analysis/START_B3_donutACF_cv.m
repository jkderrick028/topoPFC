function START_B3_donutACF_cv(varargin)
% function START_B3_donutACF_cv computes donut ACF with permutations with
% cross-validation. 
% 
% In this script, Xi is the mean-centered tuning profile vector of the i-th
% channel
% 
% last modified: 2024.09.20

import spikes.*;
import utils_dx.*;
import moranI.*;

rng('default');

close all;

p                                   = inputParser;
p.addParameter('taskStr', 'KM');                                % KM, AL, ODR
p.addParameter('signalType', 'mcTuning');                       % doesn't work for residuals because the number of trials differs across partitions

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
                    firingRateRaster        = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.firingRateRaster;                     
                    conditionInfo           = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.conditionInfo; 
                    uniqueConditions        = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.uniqueConditions; 
                    chanLinearInds          = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.chanLinearInds;
                case 'AL'
                    firingRateRaster        = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.firingRateRaster;                  
                    conditionInfo           = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.conditionInfo; 
                    uniqueConditions        = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.uniqueConditions; 
                    chanLinearInds          = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.chanLinearInds;
                case 'ODR'
                    firingRateRaster        = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.firingRateRaster;  
                    conditionInfo           = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.conditionInfo; 
                    uniqueConditions        = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.uniqueConditions; 
                    chanLinearInds          = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.chanLinearInds;              
            end
                        
            [tuningProfile_1, mcTuningProfile_1, residualRaster_1, tuningProfile_2, mcTuningProfile_2, residualRaster_2] = split_session_2halves(firingRateRaster, conditionInfo, uniqueConditions); 

            switch signalType
                case 'mcTuning'
                    signalProfile_1         = mcTuningProfile_1; 
                    signalProfile_2         = mcTuningProfile_2;                  
            end

            signalProfile_1                 = reshape(signalProfile_1, size(signalProfile_1, 1), []);
            signalProfile_2                 = reshape(signalProfile_2, size(signalProfile_2, 1), []);
            
            %% to add some noise to one half of the data
            % signalProfile_2                 = signalProfile_2 + randn(size(signalProfile_2));
            % signalProfile_2                 = signalProfile_2 - mean(signalProfile_2, 2);

            donutACFresults                 = donutACF_channels_cv(signalProfile_1, signalProfile_2, setdiff(1:nChannelsTotal, chanLinearInds));
            titleStr                        = sprintf('%s', arrayStrs{arrayI});
            title(titleStr); 
            ylim([-0.3, 1.1]); 
            box off; 

            output.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).signalProfile_1         = signalProfile_1;
            output.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).signalProfile_2         = signalProfile_2;
            output.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).sessionStrs             = sessionStrs;
            output.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).chanLinearInds          = chanLinearInds;
            output.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).donutACFresults         = donutACFresults;
        end % arrayI 
        pageHeadings                        = [];
        pageHeadings{1}                     = sprintf('donutACF cv, %s %s', strrep(taskStr, '_', ' '), strrep(signalType, '_', ' '));
        pageHeadings{2}                     = sprintf('%s %s', subjectStrs{subjectI}, sessionStrs{sessI});            
        addHeadingAndPrint(pageHeadings, PS_acf, figI_acf);    
    end % sessI 
    save(MAT_output, 'output', '-v7.3');
end % subjectI

close all;
end % START_B3_donutACF_cv

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
