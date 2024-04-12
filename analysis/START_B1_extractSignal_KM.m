function START_B1_extractSignal_KM
% extracts spike tuning, mcTuning, residuals, first dimensions are all 100,
% nan for reference channels
% 
% spikeTuningResults.(channels or units).(taskVariable)
%   mcTuning        (100 x conditions, double array)
%   tuning          (100 x conditions, double array)
%   chanLinearInds  (nChannels x 1)
%   raster          (100 x time x trials)
%   
% 
% last modified: 2023.10.20


import spikes.*;


projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'spikeTuningVectors';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

[sessionStrsB, sessionStrsT]        = getSessInfo('KM');
excludedSessionStrs                 = get_excludedSessionStrs(); 
subjectStrs                         = {'Buzz', 'Theo'};
arrayStrs                           = {'NSP0', 'NSP1'};
unitsORchanStrs                     = {'channels', 'units'};
taskVariables                       = {'nineLocations', 'lr'};

filespecs.cueDelayOnly              = 0;
filespecs.trialOutcome              = 'correctOnly';
filespecs.method                    = 'phase_cdr';                      % entire cue (3000 ms), entire delay (2000 ms), first 500 ms into response

for unitsORchanI=1:numel(unitsORchanStrs)
    switch unitsORchanStrs{unitsORchanI}
        case 'units'
            filespecs.collapseUnits = 0;
        case 'channels'
            filespecs.collapseUnits = 1;
    end

    for subjectI=1:numel(subjectStrs)
        filespecs.subjectStr        = subjectStrs{subjectI};
        MAT_spikeTuningResults      = fullfile(resultsPath, sprintf('%s_%s_%s_results.mat', currfilename, subjectStrs{subjectI}, unitsORchanStrs{unitsORchanI}));
        spikeTuningResults          = [];
        
        switch subjectStrs{subjectI}
            case 'Buzz'
                sessionStrs         = sessionStrsB;
            case 'Theo'
                sessionStrs         = sessionStrsT;
        end
        sessionStrs                 = setdiff(sessionStrs, excludedSessionStrs); 
                   
        for arrayI = 1:numel(arrayStrs)
            filespecs.arrayStr      = arrayStrs{arrayI};           
            
            for sessI=1:numel(sessionStrs)
                filespecs.sessionStr            = sessionStrs{sessI};    
                fprintf('processing %s %s %s %s\n', subjectStrs{subjectI}, sessionStrs{sessI}, arrayStrs{arrayI}, unitsORchanStrs{unitsORchanI});
                
                for taskVarI=1:numel(taskVariables)
                    filespecs.tuningTaskVar     = taskVariables{taskVarI}; 
                    [tuningProfile, mcTuningProfile, residualRaster, spikeRaster, firingRateRaster, conditionInfo, uniqueConditions, chanLinearInds, tuningEventStrs] = extractSignals_KM(filespecs); 

                    spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).(taskVariables{taskVarI}).tuningProfile         = tuningProfile;
                    spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).(taskVariables{taskVarI}).mcTuningProfile       = mcTuningProfile;
                    spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).(taskVariables{taskVarI}).residualRaster        = residualRaster;
                    spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).(taskVariables{taskVarI}).spikeRaster           = spikeRaster;
                    spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).(taskVariables{taskVarI}).firingRateRaster      = firingRateRaster;
                    spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).(taskVariables{taskVarI}).conditionInfo         = conditionInfo;
                    spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).(taskVariables{taskVarI}).uniqueConditions      = uniqueConditions;
                    spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).(taskVariables{taskVarI}).chanLinearInds        = chanLinearInds;
                    spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).(taskVariables{taskVarI}).tuningEventStrs       = tuningEventStrs;                                        
                end % taskVarI                
            end % sessI
        end % arrayI
        save(MAT_spikeTuningResults, 'spikeTuningResults', '-v7.3');
    end % subjectI
end % unitsORchanI

end % START_B1_extractSignal_KM
