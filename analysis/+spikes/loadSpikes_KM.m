function spikeData = loadSpikes_KM(filespecs)
% function loadSpikes_KM loads KM data with noise channels. 
%  
% INPUT
%   filespecs fields
%       subjectStr:         'Buzz' OR 'Theo'
%       arrayStr:           'NSP0' OR 'NSP1'
%       sessionStr:          e.g. '20171205'
%       trialOutcome:       'correctOnly' OR 'incorrectOnly' OR 'correctANDincorrect'
%           
% OUTPUT
%   spikeData fileds 
%       raster              [100 x time points x trials]
%       conditionInfo       [nTrials x 1]                   9 target locations, we do not group conditions into 3 columns at this stage
%       trialOutcome        [nTrials x 1]
%       chanLinearInds      [nActiveChannels x 1]
%           ...
% conditionInfo will be in cell array format, each element will be a
% string, e.g., {'9', '2', '5', ...}
% 
% 
% USAGE
% 
% filespecs.subjectStr    = 'Buzz';
% filespecs.arrayStr      = 'NSP0';
% filespecs.sessionStr    = '20171201'; 
% filespecs.cueDelayOnly  =  0;
% filespecs.collapseUnits =  1;
% filespecs.trialOutcome  = 'correctOnly'; 
% 
% spikeData = loadSpikes_KM(filespecs); 
% 
% 
% last modified: 2023.03.04


import spikes.*;


if ~isfield(filespecs, 'collapseUnits'),    filespecs.collapseUnits = 1; end % by default, we will collapse the units within the same channel. 
if ~isfield(filespecs, 'cueDelayOnly'),     filespecs.cueDelayOnly  = 1; end

projectPath             = setProjectPath(); 

data                    = load(fullfile(projectPath, 'data', 'KM', filespecs.subjectStr, sprintf('includeNoiseChannels_KM_%s_%s.mat', filespecs.subjectStr, filespecs.sessionStr))).data;            
raster                  = data.WM.rasters.(filespecs.arrayStr); 
if filespecs.cueDelayOnly
    raster              = raster(:, 1:5000, :);
else
    raster              = raster(:, 1:7000, :); 
end

channelInfo             = cellfun(@(x) x(1:3), data.WM.chan.(filespecs.arrayStr), 'UniformOutput', false);
[raster, channelInfo]   = selectUnits(raster, channelInfo);

conditionInfo           = compose('%d', data.WM.cond);
trialOutcome            = data.WM.trialOutcome;

switch filespecs.trialOutcome
    case 'correctOnly'
        includedTrialInds       = find(logical(trialOutcome));
    case 'incorrectOnly'
        includedTrialInds       = find(~logical(trialOutcome));
    case 'correctANDincorrect'
        includedTrialInds       = 1:numel(trialOutcome);
end

conditionInfo                   = reshape(conditionInfo(includedTrialInds), [], 1);
raster                          = raster(:, :, includedTrialInds);
trialOutcome                    = reshape(trialOutcome(includedTrialInds), [], 1);
arrayMap                        = loadArrayMap(filespecs.subjectStr, filespecs.arrayStr);

isElecNum                       = 0; 
if filespecs.collapseUnits
    [raster, channelInfo]       = channelCollapse(raster, channelInfo);  
    [raster, chanLinearInds]    = getLinearOrderChanRaster(raster, channelInfo, arrayMap, isElecNum);    
else
    chanLinearInds              = getChanLinearInds(arrayMap, channelInfo, isElecNum); 
    [B, I]                      = sort(chanLinearInds);
    raster                      = raster(I, :, :);
    chanLinearInds              = B; 
end

spikeData.raster                = raster;
spikeData.conditionInfo         = conditionInfo;
spikeData.chanLinearInds        = chanLinearInds;
spikeData.trialOutcome          = trialOutcome;
spikeData.arrayStr              = filespecs.arrayStr;
spikeData.collapseUnits         = filespecs.collapseUnits;
spikeData.arrayMap              = arrayMap;
spikeData.includeNoiseChannels  = 1;
