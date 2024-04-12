function [raster_extended, chanLinearInds] = getLinearOrderChanRaster(raster, channelInfo, arrayMap, isElecNum)
% function getLinearOrderChanRaster extends a raster (nUniqueChannels x
% nTime x nTrials) to 100 x nTime x nTrials and arrage channels based on
% their linear indices on the array.
% 
% For channels without signal, nan's will serve as a place holder.
% 
% last modified: 2023.10.29

import spikes.getChanLinearInds; 


nRows           = 10;
nCols           = 10;
nChannelsTotal  = nRows * nCols;

[nChannels, nTimePoints, nTrials] = size(raster);

raster_extended = nan(nChannelsTotal, nTimePoints, nTrials);
chanLinearInds  = getChanLinearInds(arrayMap, channelInfo, isElecNum); 

raster_extended(chanLinearInds, :, :)   = raster; 
chanLinearInds                          = sort(chanLinearInds);

end % getLinearOrderChanRaster
