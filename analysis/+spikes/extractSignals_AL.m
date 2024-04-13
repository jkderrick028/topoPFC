function [tuningProfile, mcTuningProfile, residualRaster, spikeRaster, firingRateRaster, conditionInfo, uniqueConditions, chanLinearInds, tuningEventStrs] = extractSignals_AL(filespecs)
% function extractSignals_AL extracts tuningProfile, mcTuningProfile and
% residualRaster for AL task. 
% 
% NOTE
%   in the original data, these are the events: {'contextOnset', 'goalsOnset', 'decisionOnset', 'trialEnd'}
% 
% INPUT
%   'method'                   
%               'epoch'             some time relative to an event, but not including the event itself
%               'window'            some time around each event
%               'around_response'   a few hundred ms before and after response
% 
% last modified: 2023.05.08

import spikes.*; 

if ~isfield(filespecs, 'blockStr'), filespecs.blockStr = 'allBlocks'; end

eventStrs                                       = {'contextOnset', 'goalsOnset', 'decisionOnset'};
periEventTime                                   = [ 50,  600;
                                                    500, 300;
                                                    500, 500];
eventStartEndTiming                             = periEventTiming2eventStartEndTiming(periEventTime);
eventInds                                       = eventStartEndTiming(:, 1) + periEventTime(:, 1); 
filespecs.periEventTime                         = periEventTime;
filespecs.eventStrs                             = eventStrs;

tuningEventStrs                         = {'pre_contextOnset', 'post_contextOnset', 'pre_goalsOnset', 'post_goalsOnset', 'pre_decisionOnset', 'post_decisionOnset'};
nEvents                                 = numel(tuningEventStrs);
tuningEventStartEndTiming               = zeros(nEvents, 2); 

for eventI = 1:numel(eventStrs)
    rowI                                = 2*(eventI-1) + 1; 
    tuningEventStartEndTiming(rowI, 1)  = eventInds(eventI) - periEventTime(eventI, 1);
    tuningEventStartEndTiming(rowI, 2)  = eventInds(eventI) - 1; 

    rowI                                = 2*(eventI-1) + 2; 
    tuningEventStartEndTiming(rowI, 1)  = eventInds(eventI);
    tuningEventStartEndTiming(rowI, 2)  = eventInds(eventI) + periEventTime(eventI, 2) - 1;
end % eventI

spikeData                                       = loadSpikes_AL(filespecs);

firingRateRaster                                = estimateFiringRates_phase(spikeData.raster, tuningEventStartEndTiming);      
firingRateRaster                                = sqrt(firingRateRaster);

chanLinearInds                                  = spikeData.chanLinearInds;

conditionInfo                                   = conditionInfoSortingOut_AL(filespecs.tuningTaskVar, spikeData.condStruct, spikeData);
spikeRaster                                     = spikeData.raster;

uniqueConditions                        = {'1', '2', '3', '4'}; 

[tuningProfile, mcTuningProfile, residualRaster]= extractTuningANDresiduals(firingRateRaster, conditionInfo, uniqueConditions); 

end % function extractSignals_AL
