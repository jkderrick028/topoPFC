function [spikeRaster, chanLinearInds] = extractTS_ODR(filespecs)
% function extractTS_ODR extracts the spike rates for each channel in the
% ODR task                
% 
% last modified: 2026.01.07

import spikes.*; 


spikeData                           = loadTS_ODR(filespecs);

chanLinearInds                      = spikeData.chanLinearInds;

spikeRaster                         = spikeData.raster;

end % function extractSignals_ODR
