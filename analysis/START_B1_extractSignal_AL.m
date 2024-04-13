function START_B1_extractSignal_AL
% extracts spike tuning, mcTuning, residuals, first dimensions are all 100
% 
% contexts, configurations (config1: color associated with wood on the
% left, config2: color associated with wood on the right), and events 
% 
% last modified: 2024.04.13

import spikes.*;


projectPath                                 = setProjectPath();
[currPath, currfilename, currext]           = fileparts(mfilename('fullpath'));
ANALYSIS                                    = 'spikeTuningVectors';
resultsPath                                 = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

[sessionStrsB, sessionStrsT]                = getSessInfo('AL');
excludedSessionStrs                         = get_excludedSessionStrs(); 
subjectStrs                                 = {'Buzz', 'Theo'};
arrayStrs                                   = {'NSP0', 'NSP1'};
taskVariables                               = {'tuning'};

unitsORchanStrs                             = {'channels', 'units'}; % or units
filespecs.trialOutcome                      = 'correctOnly';
filespecs.blockStr                          = 'allBlocks'; 

for unitsORchanI=1:numel(unitsORchanStrs)
    switch unitsORchanStrs{unitsORchanI}
        case 'units'
            filespecs.collapseUnits         = 0;
        case 'channels'
            filespecs.collapseUnits         = 1;
    end
    for subjectI=1:numel(subjectStrs)
        filespecs.subjectStr                = subjectStrs{subjectI};
        MAT_spikeTuningResults              = fullfile(resultsPath, sprintf('%s_%s_%s_results.mat', currfilename, subjectStrs{subjectI}, unitsORchanStrs{unitsORchanI}));
        spikeTuningResults                  = [];
        switch subjectStrs{subjectI}
            case 'Buzz'
                sessionStrs                 = sessionStrsB;
            case 'Theo'
                sessionStrs                 = sessionStrsT;
        end
        sessionStrs                         = setdiff(sessionStrs, excludedSessionStrs); 
                
        for arrayI=1:numel(arrayStrs)
            filespecs.arrayStr              = arrayStrs{arrayI};
            for sessI=1:numel(sessionStrs)
                filespecs.sessionStr        = sessionStrs{sessI};   
                
                for taskVarI=1:numel(taskVariables)
                    filespecs.tuningTaskVar = taskVariables{taskVarI}; 
                    
                    [tuningProfile, mcTuningProfile, residualRaster, spikeRaster, firingRateRaster, conditionInfo, uniqueConditions, chanLinearInds, tuningEventStrs] = extractSignals_AL(filespecs); 

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

end % START_B1_extractSignal_AL
