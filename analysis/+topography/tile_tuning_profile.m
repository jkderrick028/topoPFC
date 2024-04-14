function task_signal = tile_tuning_profile(tuningProfile, conditionInfo, uniqueConditions)
% extend tuningProfile (nChannels x nEpochs x nConditions) into (nChannels
% x nEpochs x nTrials)
% 
% last modified: 2024.03.04


nTrials                 = numel(conditionInfo);
[nChannels, nEpochs, ~] = size(tuningProfile);

task_signal             = nan(nChannels, nEpochs, nTrials);
nUniqueConditions       = numel(uniqueConditions);

for condI=1:nUniqueConditions
    trialInds                       = find(ismember(conditionInfo, uniqueConditions(condI)));
    task_signal(:, :, trialInds)    = repmat(tuningProfile(:, :, condI), 1, 1, numel(trialInds));
end % condI 

end % function tile_tuning_profile
