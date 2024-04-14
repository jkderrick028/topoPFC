function [tuningProfile, mcTuningProfile, residualRaster, spikeRaster, firingRateRaster, conditionInfo, uniqueConditions, chanLinearInds, tuningEventStrs] = extractSignals_ODR(filespecs)
% function extractSignals_ODR extracts tuningProfile, mcTuningProfile and
% residualRaster for ODR task. 
% 
% NOTE
%   in the original data, these are the events: 'fixationOn', 'targetOn', 'targetOff', 'fixationOff', 'response'
% 
% INPUT
%   'method'                   
%               'phase_cd'          using entire trial phase, cue and delay only                                    [cue: targetOn to targetOff; delay: targetOff to response]; 
%               'phase_cdr'         using entire trial phase, cue, delay and 500 ms into response                   [cue: targetOn to targetOff; delay: targetOff to response; response: response starts to 500ms into reponse];
%               'around_response'   a few hundred ms before and after response                                      [response-500+1, response+500-1]; 
%               'epoch'             pre-define some time windows that are in between events (not including events)
%               'window'            some time around each event (events themselves are included as well)
% 
% last modified: 2023.05.08

import spikes.*; 


filespecs.alignEvents               =  0;

tuningEventStrs                     = {'cue', 'delay', 'response'};        
filespecs.eventStrs                 = {'targetOn', 'targetOff', 'response'}; 

spikeData                           = loadSpikes_ODR(filespecs);
eventInds                           = spikeData.eventInds;
eventInds                           = [eventInds, min(eventInds(:, end)+500, 5001)]; 

nEvents                             = size(eventInds, 2) - 1; 
nTrials                             = size(eventInds, 1); 
firingRateRaster                    = zeros(size(spikeData.raster, 1), nEvents, nTrials); 

for trialI = 1:nTrials
    for eventI = 1:nEvents
        firingRateRaster(:, eventI, trialI) = 1000 * mean(spikeData.raster(:, eventInds(trialI, eventI):eventInds(trialI, eventI+1)-1, trialI), 2); 
    end % eventI 
end % trialI 

firingRateRaster                    = sqrt(firingRateRaster);
chanLinearInds                      = spikeData.chanLinearInds;

conditionInfo                       = conditionInfoSortingOut_ODR(filespecs.tuningTaskVar, spikeData);
spikeRaster                         = spikeData.raster;

switch filespecs.tuningTaskVar
    case 'quadrants'
        uniqueConditions            = {'1', '2', '3', '4'};  
    case 'lr'
        uniqueConditions            = {'L', 'R'}; 
end

[tuningProfile, mcTuningProfile, residualRaster] = extractTuningANDresiduals(firingRateRaster, conditionInfo, uniqueConditions); 

end % function extractSignals_ODR
