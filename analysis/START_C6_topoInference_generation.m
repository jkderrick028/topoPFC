function START_C6_topoInference_generation
% whole TS, ignoring trial events 
% 
% last modified: 2026.01.07

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
excludedSessionStrs             = get_excludedSessionStrs();

figI                            = 10; 
nHors                           = 1; 
nVers                           = 1; 

for taskI=1:numel(taskStrs)
    for subjectI=1:numel(subjectStrs)
        switch taskStrs{taskI}
            case 'KM'
                MAT_data = fullfile(projectPath, 'results', 'spikeTuningVectors', 'START_B1_extractSignal_KM', ['START_B1_extractSignal_KM_', subjectStrs{subjectI}, '_channels_results.mat']); 
            case 'AL'
                MAT_data = fullfile(projectPath, 'results', 'spikeTuningVectors', 'START_C1_extractTS_AL', ['START_C1_extractTS_AL_', subjectStrs{subjectI}, '_channels_results.mat']); 
            case 'ODR'
                MAT_data = fullfile(projectPath, 'results', 'spikeTuningVectors', 'START_C1_extractTS_ODR', ['START_C1_extractTS_ODR_', subjectStrs{subjectI}, '_channels_results.mat']); 
        end
        
        spikeTuningResults      = load(MAT_data).spikeTuningResults;
        for arrayI=1:numel(arrayStrs)
            sessionStrs         = fieldnames(spikeTuningResults.(arrayStrs{arrayI})); % sess_ format
            sessionStrs         = sessionStrs(~contains(sessionStrs, excludedSessionStrs)); 
            
            PS_corrmats         = fullfile(resultsPath, sprintf('corrmats_%s_%s_%s.pdf', subjectStrs{subjectI}, arrayStrs{arrayI}, taskStrs{taskI}));
            if exist(PS_corrmats, 'file')
                system(['rm ' PS_corrmats]);
            end
            for sessI=1:numel(sessionStrs)
                switch taskStrs{taskI}
                    case 'ODR'
                        spikeRaster             = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).spikeRaster;       
                        spikeRaster             = reshape(spikeRaster, size(spikeRaster, 1), []); 
                        chanLinearInds          = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).chanLinearInds;
                    case 'KM'
                        spikeRaster             = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).nineLocations.spikeRaster;
                        spikeRaster             = reshape(spikeRaster, size(spikeRaster, 1), []); 
                        chanLinearInds          = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).nineLocations.chanLinearInds;
                    case 'AL'
                        spikeRaster             = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).spikeRaster;                             
                        chanLinearInds          = spikeTuningResults.(arrayStrs{arrayI}).(sessionStrs{sessI}).chanLinearInds;
                end % switch
                
                        
                figure(figI); clf(figI);

                spikeRaster                     = smoothdata(spikeRaster, 2, 'movmean', 50, 'omitmissing');                               
                signal_corrmat                  = corr(spikeRaster', 'type', 'Pearson');

                subplot(nHors, nVers, 1);

                visualizeCorrMat(signal_corrmat, 'titleStr', 'time series'); 
      
                % output_simmats.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sessionStrs{sessI}).signal          = spikeRaster;       
                output_simmats.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sessionStrs{sessI}).signal_corrmat  = signal_corrmat;             

                pageHeadings                    = {}; 
                pageHeadings{1}                 = sprintf('corrmats for time series'); 
                pageHeadings{2}                 = sprintf('%s %s %s %s', subjectStrs{subjectI}, arrayStrs{arrayI}, taskStrs{taskI}, strrep(sessionStrs{sessI}, 'sess_', ''));
                addHeadingAndPrint(pageHeadings, PS_corrmats, figI); 
                
                output_simmats.(taskStrs{taskI}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sessionStrs{sessI}).chanLinearInds                 = chanLinearInds;
            end % sessI 
        end % arrayI        
    end % subjectI 
end % taskI 

save(MAT_output, 'output_simmats', '-v7.3'); 

close all; 
end % START_C6_topoInference_generation

