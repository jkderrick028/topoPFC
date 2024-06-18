function START_R1_simulate_data(varargin)
% this function computes chan x chan tuning correlation matrix and conducts
% multi-dimensional scaling on it, then project channels from 2D MDS space
% back to the array. 
% 
% This script works for both mcTuning and residual. 
% 
% last modified: 2024.04.12

import spikes.*;
import utils_dx.*;
import mds.*;

close all;

p                                   = inputParser;
p.addParameter('taskStr', 'KM');                            % KM, AL, ODR
p.addParameter('signalType', 'mcTuning');

parse(p, varargin{:});
taskStr                             = p.Results.taskStr; 
signalType                          = p.Results.signalType; 

projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'topovis';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

subjectStrs                         = {'Buzz', 'Theo'};
arrayStrs                           = {'NSP1', 'NSP0'};
excludedSessionStrs                 = get_excludedSessionStrs(); 
pDims                               = 1:10;

resultsPath_taskTuning              = fullfile(projectPath, 'results', 'spikeTuningVectors', sprintf('START_B1_extractSignal_%s', taskStr));

output                              = [];
MAT_output                          = fullfile(resultsPath, sprintf('%s_%s_%s.mat', currfilename, taskStr, signalType)); 

figI_mds                            = 10; 
figI_unexplVar                      = 15; 

for subjectI=1:numel(subjectStrs)
    PS_mds                          = fullfile(resultsPath, sprintf('%s_%s_%s_%s.ps', currfilename, taskStr, subjectStrs{subjectI}, signalType));
    if exist(PS_mds, 'file'), system(['rm ' PS_mds]); end
    PS_mds_unexplVar                = fullfile(resultsPath, sprintf('%s_%s_%s_unexplVar_%s.ps', currfilename, taskStr, subjectStrs{subjectI}, signalType));
    if exist(PS_mds_unexplVar, 'file'), system(['rm ' PS_mds_unexplVar]); end
    
    MAT_tuningResults               = fullfile(resultsPath_taskTuning, sprintf('START_B1_extractSignal_%s_%s_channels_results.mat', taskStr, subjectStrs{subjectI}));    
    spikeTuningResults              = load(MAT_tuningResults).spikeTuningResults;

    for arrayI = 1:numel(arrayStrs)  
        sessionStrs                     = fieldnames(spikeTuningResults.(arrayStrs{arrayI}));
        sessionStrs                     = strrep(sessionStrs, 'sess_', '');
        sessionStrs                     = setdiff(sessionStrs, excludedSessionStrs); 
        nSessions                       = numel(sessionStrs);        
        mdsUnexplainedVarianceSummary   = []; 
        for sessI = 1:nSessions
            fprintf('Processing %s %s %s %s\n', subjectStrs{subjectI}, taskStr, arrayStrs{arrayI}, sessionStrs{sessI}); 
            switch taskStr
                case 'KM'
                    switch signalType
                        case 'mcTuning'
                            signalProfile_thisSession       = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.mcTuningProfile;
                        case 'residual'
                            signalProfile_thisSession       = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.residualRaster;
                    end
                    chanLinearInds_thisSession              = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).nineLocations.chanLinearInds;
                case 'AL'
                    switch signalType
                        case 'mcTuning'
                            signalProfile_thisSession       = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.mcTuningProfile;
                        case 'residual'
                            signalProfile_thisSession       = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.residualRaster;
                    end
                    chanLinearInds_thisSession              = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).tuning.chanLinearInds;
                case 'ODR'
                    switch signalType
                        case 'mcTuning'
                            signalProfile_thisSession       = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.mcTuningProfile;
                        case 'residual'
                            signalProfile_thisSession       = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.residualRaster;
                    end
                    chanLinearInds_thisSession              = spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).quadrants.chanLinearInds;                
            end         
            
            signalProfile_thisSession                       = reshape(signalProfile_thisSession, size(signalProfile_thisSession, 1), []);
            corrmat                                         = corr(signalProfile_thisSession', 'type', 'Pearson'); 
            
            figure(figI_mds); clf(figI_mds);
            [colours_rgb, unexplainedVariance, coords_2D]   = mds_channels(signalProfile_thisSession, chanLinearInds_thisSession); 
            
            mdsUnexplainedVarianceSummary                   = cat(2, mdsUnexplainedVarianceSummary, unexplainedVariance); 

            pageHeadings                                    = [];
            pageHeadings{1}                                 = sprintf('tuning similarity, %s %s', strrep(taskStr, '_', ' '), signalType);
            pageHeadings{2}                                 = sprintf('%s %s %s', subjectStrs{subjectI}, sessionStrs{sessI}, arrayStrs{arrayI});
            addHeadingAndPrint(pageHeadings, PS_mds, figI_mds);

            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).colours_rgb         = colours_rgb;
            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).unexplainedVariance = unexplainedVariance;
            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).coords_2D           = coords_2D;
            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).chanLinearInds      = chanLinearInds_thisSession;
            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).corrmat             = corrmat;
        end % sessI        
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).mdsUnexplainedVarianceSummary                                    = mdsUnexplainedVarianceSummary; 
    end % arrayI
    
    figure(figI_unexplVar); clf(figI_unexplVar);
    for arrayI = 1:numel(arrayStrs)
        mdsUnexplainedVarianceSummary                       = output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).mdsUnexplainedVarianceSummary; 
        subplot(numel(arrayStrs), 1, arrayI);        
        hold on;
        plot(pDims, mdsUnexplainedVarianceSummary, 'Color', str2rgb('light_grey'), 'LineWidth', 0.8);
        plot(pDims, squeeze(mean(mdsUnexplainedVarianceSummary, 2)), 'k-', 'LineWidth', 1.2);
        titleStr                                            = sprintf('%s', arrayStrs{arrayI});
        title(titleStr);
        ylim([0, 1]);
        xlim([0, pDims(end)]); 
        yticks(0:0.2:1);
        yticklabels(0:0.2:1);
        xticks(pDims);
        xlabel('nDim mds');
        ylabel('unexplained variance');
        box off; 
    end % arrayI
    pageHeadings                                            = [];
    pageHeadings{1}                                         = sprintf('unexplained variance, %s %s', strrep(taskStr, '_', ' '), signalType);
    pageHeadings{2}                                         = sprintf('%s', subjectStrs{subjectI});
    addHeadingAndPrint(pageHeadings, PS_mds_unexplVar, figI_unexplVar);
end % subjectI

save(MAT_output, 'output', '-v7.3');
close all;

end % START_B2_spikesMDS
