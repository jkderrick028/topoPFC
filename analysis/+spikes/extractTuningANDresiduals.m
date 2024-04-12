function [tuningProfile, mcTuningProfile, residualRaster] = extractTuningANDresiduals(raster, conditionInfo, uniqueConditions)
% for a give raster (100 x time x trials), extract tuning, mcTuning, and
% residuals
% 
% INPUT
%   raster          (100 x time x trials, double array)
%   conditionInfo   (trials x 1, cell array)
% 
% 
% last modified: 2023.10.29

if ~exist('uniqueConditions', 'var'), uniqueConditions = unique(conditionInfo); end

[nChannelsTotal, nTimePoints, nTrials]  = size(raster);
assert(nTrials==numel(conditionInfo), 'n trials does not match n conditions'); 

nUniqueConditions   = numel(uniqueConditions);

tuningProfile       = zeros(nChannelsTotal, nTimePoints, nUniqueConditions);
residualRaster      = zeros(nChannelsTotal, nTimePoints, nTrials);

for condI=1:nUniqueConditions
    trialInds_thisCond                      = find(ismember(conditionInfo, uniqueConditions(condI)));
    tuningProfile(:, :, condI)              = mean(raster(:, :, trialInds_thisCond), 3);
    residualRaster(:, :, trialInds_thisCond)= raster(:, :, trialInds_thisCond) - tuningProfile(:, :, condI);
end % condI

tuningProfile_reshape   = reshape(tuningProfile, nChannelsTotal, []); 
mcTuningProfile         = tuningProfile_reshape - mean(tuningProfile_reshape, 2);
mcTuningProfile         = reshape(mcTuningProfile, size(tuningProfile)); 

end % function extractTuningANDresiduals
