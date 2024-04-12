function [collapsedRaster, channels] = channelCollapse(raster, channelInfo)
% function channelCollapse sums units' activity within the same channel.
%  
% INPUT
%   raster:         (nUnits x nTime x nTrials)
%   channelInfo:    (nUnits x 1)    e.g. {'001', '001', '002', '002', '002', '003'}
% 
% OUTPUT
%   collapsedRaster (nUniqueChannels x nTime x nTrials)
%   channels        (nUniqueChannels x 1)
% 
% USAGE
%   [collapsedRaster, channels] = channelCollapse(raster, channelInfo)
% 
% last modified: 2023.10.29


[nUnits, nTrialTimePoints, nTrials] = size(raster);
assert(nUnits == numel(channelInfo), 'size does not match'); 

channels        = unique(channelInfo);
nChannels       = numel(channels); % nChannels: the number of unique channels
collapsedRaster = zeros(nChannels, nTrialTimePoints, nTrials);

for chanI = 1:nChannels
    collapsedRaster(chanI, :, :) = sum(raster(ismember(channelInfo, channels(chanI)), :, :), 1);
end % chanI
