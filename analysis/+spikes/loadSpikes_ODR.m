function spikeData = loadSpikes_ODR(filespecs)
% loads ODR spike data. 
% 
% INPUT
%   filespecs fields
%       subjectStr:         'Buzz' OR 'Theo'
%       arrayStr:           'NSP0' OR 'NSP1'
%       sessionStr:          e.g. '20180307'
%       trialOutcome:       'correctOnly' OR 'incorrectOnly' OR 'correctANDincorrect'
%       alignEvents:        0 or 1. if 0, load raw raster, if 1, align trials to events, keep certain time before and after each event and form a new raster
%       periEventTime:      (5 x 2 double array)
%       eventStrs:          (5 x 1 cell array)      {'fixationOn', 'targetOn', 'targetOff', 'fixationOff', 'response'}
% 
% OUTPUT
%   spikeData fields 
%       raster              (100 x time points x trials)
%       conditionInfo       (nTrials x 1 cell array)        4 quadrants, retinotopic space
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
% filespecs.alignEvents     =  0;
% filespecs.collapseUnits   =  1;
% filespecs.trialOutcome    = 'correctOnly'; 
% filespecs.periEventTime   =  [  450, 300;
%                                 250, 750;
%                                 250, 2000;
%                                 2000, 200;
%                                 200, 150];
% filespecs.eventStrs       = {'fixationOn', 'targetOn', 'targetOff', 'fixationOff', 'response'}; 
% 
% spikeData = loadSpikes_ODR(filespecs); 
% 
% last modified: 2023.10.29

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
eventStrs           = filespecs.eventStrs;
nEvents             = numel(eventStrs);

switch filespecs.arrayStr
    case {'NSP0', 'Ventral'}
        channelInfo = cellstr(num2str(data.SpkSort.Ventral(:, 2), '%03.f'));
    case {'NSP1', 'Dorsal'}
        channelInfo = cellstr(num2str(data.SpkSort.Dorsal(:, 2), '%03.f'));
end % switch

eventTiming                             = data.EvTiming;
arrayMap                                = loadArrayMap(filespecs.subjectStr, filespecs.arrayStr);

[raster, channelInfo]                   = selectUnits(raster, channelInfo);
conditionInfo                           = compose('%d', data.QuadCond);
trialOutcome                            = data.TrialOutcome;

switch filespecs.trialOutcome
    case 'correctOnly'
        includedTrialInds               = find(logical(trialOutcome));
    case 'incorrectOnly'
        includedTrialInds               = find(~logical(trialOutcome));
    case 'correctANDincorrect'
        includedTrialInds               = 1:numel(trialOutcome);
end

conditionInfo                           = conditionInfo(includedTrialInds);
raster                                  = raster(:, :, includedTrialInds);
trialOutcome                            = trialOutcome(includedTrialInds);

if ~filespecs.alignEvents
    eventInds                           = [];
    for eventI=1:nEvents
        inds_thisEvent                  = ceil(1000*eventTiming.(capitalize_str(eventStrs{eventI}))) + 1001; 
        inds_thisEvent                  = inds_thisEvent(includedTrialInds); 
        eventInds                       = cat(2, eventInds, inds_thisEvent); 
    end % eventI
    spikeData.eventInds                 = eventInds;
end

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
spikeData.conditionInfo                 = conditionInfo;
spikeData.chanLinearInds                = chanLinearInds;
spikeData.trialOutcome                  = trialOutcome;
spikeData.arrayStr                      = filespecs.arrayStr;
spikeData.channelInfo                   = reshape(channelInfo, [], 1);
spikeData.collapseUnits                 = filespecs.collapseUnits;
spikeData.arrayMap                      = arrayMap;
spikeData.eventStrs                     = eventStrs;
spikeData.eventTiming                   = eventTiming;
spikeData.alignEvents                   = filespecs.alignEvents;

end % function loadSpikes_ODR
