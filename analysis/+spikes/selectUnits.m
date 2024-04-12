function [raster, channelInfo] = selectUnits(raster, channelInfo)
% function selectUnits makes sure that we only use units with mean
% firing rate (across all trials) greater than 1 Hz (averaged across the
% whole raster time period). 
%  
% last modified: 2023.03.03

assert(size(raster, 1)==numel(channelInfo), 'size does not match'); 

firingRate      = 1000 * mean(mean(raster, 3), 2);
unitInds_gt1Hz  = find(firingRate>=1);
raster          = raster(unitInds_gt1Hz, :, :);
channelInfo     = channelInfo(unitInds_gt1Hz);

end % function selectUnits