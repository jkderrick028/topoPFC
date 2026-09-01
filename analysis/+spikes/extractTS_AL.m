function [spikeRaster, chanLinearInds] = extractTS_AL(filespecs)
% function extractTS_AL extracts the spike rates for each channel in the AL
% task, no events needed
% 
% INPUT
%   'method'                   
%               'epoch'             some time relative to an event, but not including the event itself
%               'window'            some time around each event
%               'around_response'   a few hundred ms before and after response
% 
% last modified: 2026.01.07

import spikes.*; 

if ~isfield(filespecs, 'blockStr'), filespecs.blockStr = 'allBlocks'; end

spikeData                                       = loadTS_AL(filespecs);

% firingRateRaster                                = smoothdata(spikeData.raster, 2, 'movmean', 50, 'omitmissing'); 

chanLinearInds                                  = spikeData.chanLinearInds;

spikeRaster                                     = spikeData.raster;


end % function extractSignals_AL
