function START_C1_extractTS_AL
% extracts spike rates for each channel, ignore the events 
% 
% last modified: 2026.01.07

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

unitsORchanStrs                             = {'channels'}; % or units
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
                                                    
                [spikeRaster, chanLinearInds] = extractTS_AL(filespecs); 

                spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).spikeRaster           = spikeRaster;
                % spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).firingRateRaster      = firingRateRaster;
                spikeTuningResults.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).chanLinearInds        = chanLinearInds;                
            end % sessI
        end % arrayI        
        save(MAT_spikeTuningResults, 'spikeTuningResults', '-v7.3');
    end % subjectI
end % unitsORchanI

end % START_C1_extractTS_AL
