function [tuningProfile, mcTuningProfile, residualRaster, spikeRaster, firingRateRaster, conditionInfo, uniqueConditions, chanLinearInds, tuningEventStrs] = extractSignals_KM(filespecs)
% function extractSignals_KM extracts tuningProfile, mcTuningProfile and
% residualRaster for KM task. 
% 
% INPUT
%   'method'    
%               'phase_cd'          average spike rate across the entire trial phase (cue and delay only)
%               'phase_cdr'         average spike rate across the entire trial phase (cue, delay, and 500 ms into response)
%               'around_response'   some time before and after response
% 
% USAGE
% filespecs.subjectStr      = 'Buzz'; 
% filespecs.sessionStr      = '20171201';
% filespecs.arrayStr        = 'NSP1';
% filespecs.trialOutcome    = 'correctOnly';
% filespecs.collapseUnits   = 1;
% filespecs.tuningTaskVar   = 'nineLocations';
% 
% last modified: 2024.04.12

import spikes.*; 


filespecs.cueDelayOnly              = 0; 

tuningEventStartEndTiming           = [ 1,     3000;
                                        3001,  5000;
                                        5001,  5500]; 
tuningEventStrs                     = {'cue', 'delay', 'response'};

spikeData                           = loadSpikes_KM(filespecs);
firingRateRaster                    = estimateFiringRates_phase(spikeData.raster, tuningEventStartEndTiming);      
firingRateRaster                    = sqrt(firingRateRaster);
chanLinearInds                      = spikeData.chanLinearInds;

conditionInfo                       = conditionInfoSortingOut_KM(spikeData);
spikeRaster                         = spikeData.raster;
uniqueConditions                    = {'8', '3', '10', '9', '1', '11', '12', '7', '6'}; 


[tuningProfile, mcTuningProfile, residualRaster] = extractTuningANDresiduals(firingRateRaster, conditionInfo, uniqueConditions); 

end % function extractSignals_KM
