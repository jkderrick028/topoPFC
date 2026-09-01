function spikeData = loadTS_ODR(filespecs)
% loads ODR spike data. 
% 
% INPUT
%   filespecs fields
%       subjectStr:         'Buzz' OR 'Theo'
%       arrayStr:           'NSP0' OR 'NSP1'
%       sessionStr:          e.g. '20180307'
%       trialOutcome:       'correctOnly' OR 'incorrectOnly' OR 'correctANDincorrect'
% 
% OUTPUT
%   spikeData fields 
%       raster              (100 x time points x trials)
%       trialOutcome        (nTrials x 1)
%       chanLinearInds      (nActiveChannels x 1)
%           ...
% 
% 
% 
% USAGE
% 
% filespecs.subjectStr      = 'Buzz';
% filespecs.arrayStr        = 'NSP0';
% filespecs.sessionStr      = '20180307'; 
% filespecs.collapseUnits   =  1;
% filespecs.trialOutcome    = 'correctOnly'; 
% 
% spikeData = loadTS_ODR(filespecs); 
% 
% last modified: 2026.01.07

import spikes.*;
import utils_dx.*;


if ~isfield(filespecs, 'collapseUnits'),    filespecs.collapseUnits = 1; end        % by default, we will collapse the units within the same channel.

projectPath         = setProjectPath(); 
data                = load(fullfile(projectPath, 'data', 'ODR', filespecs.subjectStr, sprintf('%s_%s_ODR_NeuralData.mat', filespecs.subjectStr(1), filespecs.sessionStr))).dataODRStruct;

switch filespecs.arrayStr
    case 'NSP0'
        aliasName   = 'Ventral';
    case 'NSP1'
        aliasName   = 'Dorsal';
end
raster              = permute(data.Rasters.(aliasName), [3, 2, 1]); 

switch filespecs.arrayStr
    case {'NSP0', 'Ventral'}
        channelInfo = cellstr(num2str(data.SpkSort.Ventral(:, 2), '%03.f'));
    case {'NSP1', 'Dorsal'}
        channelInfo = cellstr(num2str(data.SpkSort.Dorsal(:, 2), '%03.f'));
end % switch

arrayMap                                = loadArrayMap(filespecs.subjectStr, filespecs.arrayStr);

[raster, channelInfo]                   = selectUnits(raster, channelInfo);
trialOutcome                            = data.TrialOutcome;

switch filespecs.trialOutcome
    case 'correctOnly'
        includedTrialInds               = find(logical(trialOutcome));
    case 'incorrectOnly'
        includedTrialInds               = find(~logical(trialOutcome));
    case 'correctANDincorrect'
        includedTrialInds               = 1:numel(trialOutcome);
end

raster                                  = raster(:, :, includedTrialInds);
trialOutcome                            = trialOutcome(includedTrialInds);

isElecNum = 0; 
if filespecs.collapseUnits
    [raster, channelInfo]               = channelCollapse(raster, channelInfo);  
    [raster, chanLinearInds]            = getLinearOrderChanRaster(raster, channelInfo, arrayMap, isElecNum);    
else
    chanLinearInds                      = getChanLinearInds(arrayMap, channelInfo, isElecNum); 
    [B, I]                              = sort(chanLinearInds);
    raster                              = raster(I, :, :);
    chanLinearInds                      = B; 
end

spikeData.raster                        = raster;
spikeData.chanLinearInds                = chanLinearInds;
spikeData.trialOutcome                  = trialOutcome;
spikeData.arrayStr                      = filespecs.arrayStr;
spikeData.channelInfo                   = reshape(channelInfo, [], 1);
spikeData.collapseUnits                 = filespecs.collapseUnits;
spikeData.arrayMap                      = arrayMap;

end % function loadSpikes_ODR
