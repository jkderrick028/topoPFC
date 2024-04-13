function spikeData = loadSpikes_AL(filespecs)
% function loadSpikes_AL loads spike data for AL task.
% 
% INPUT 
%   filespecs.subjectStr    = 'Buzz' OR 'Theo'
%   filespecs.sessionStr    = '20171109'
%   filespecs.blockStr      = 'ALFixedStart', 'ALNovel', 'ALNovel2', 'ALFixedEnd', 'allBlocks', 'fixed', 'novel'
%   filespecs.arrayStr      = 'NSP0' OR 'NSP1'   
%   filespecs.trialOutcome  = 'correctOnly', 'incorrectOnly', 'correctANDincorrect'
%   filespecs.periEventTime   (4 x 2 double array)    time before and after these 4 events: {'contextOnset', 'goalsOnset', 'decisionOnset', 'trialEnd'}
%   filespecs.collapseUnits = 0 OR 1 
%   filespecs.eventStrs       (4 x 1 cell array)      {'contextOnset', 'goalsOnset', 'decisionOnset', 'trialEnd'}
%   filespecs.conditionSort = 'lr', 'clr_ctx', 'trialOutcome', 'context', 'tuning' (which is the product of context and color_context configuration)
% 
% OUTPUT
%   spikeData.raster            (nUnits OR 100 x nTimePoints x nTrials)
%   spikeData.chanLinearInds
%   spikeData.trialOutcome
%   spikeData.conditionInfo
%   spikeData.collapseUnits
%   spikeData.arrayMap
%   spikeData.eventStrs
%   spikeData.periEventTime
% 
% USAGE
% filespecs.subjectStr      = 'Theo'; 
% filespecs.sessionStr      = '20170405';
% filespecs.blockStr        = 'fixed'; 
% filespecs.arrayStr        = 'NSP0'; 
% filespecs.periEventTime   = [400, 500; 500, 600; 600, 700; 700, 500]; 
% filespecs.trialOutcome    = 'correctOnly'; 
% filespecs.conditionSort   = 'lr'; 
% filespecs.collapseUnits   = 1;  
% filespecs.eventStrs       = {'contextOnset', 'goalsOnset', 'decisionOnset', 'trialEnd'}; 
%  
% spikeData                 = loadSpikes_AL(filespecs); 
% 
% 
% 
% last modified: 2023.03.06

import spikes.*;


spikeData               = [];
spikeData.blockStr      = filespecs.blockStr;

eventStrs               = filespecs.eventStrs;
projectPath             = setProjectPath();
MAT_unprocessedData     = fullfile(projectPath, 'data', 'AL', filespecs.subjectStr, sprintf('%s%s.mat', filespecs.subjectStr(1), filespecs.sessionStr));
data_unprocessed        = load(MAT_unprocessedData).data;
blockStrs               = fieldnames(data_unprocessed);

if strcmp(filespecs.blockStr, 'allBlocks')
     
elseif strcmpi(filespecs.blockStr, 'fixed')
    blockStrs           = blockStrs(contains(lower(blockStrs), 'fixed')); 
elseif strcmpi(filespecs.blockStr, 'novel')
    blockStrs           = blockStrs(contains(lower(blockStrs), 'novel'));
else
    blockStrs           = {filespecs.blockStr}; 
end

raster                  = [];
condStruct              = []; 
condStrs                = {'wood', 'color', 'choiceLeft', 'trialOutcome'};
for condI=1:numel(condStrs)
    condStruct.(condStrs{condI})    = []; 
end % condI

for blockI=1:numel(blockStrs)
    filespecs.blockStr  = blockStrs{blockI}; 
    data                = makeSpikes_AL(filespecs);
    
    raster_thisBlock    = []; 
    for eventI=1:numel(eventStrs)
        raster_thisBlock= cat(2, raster_thisBlock, data.rasters.(eventStrs{eventI}));
    end % eventI
    raster              = cat(3, raster, raster_thisBlock);
    
    for condI=1:numel(condStrs)
        condStruct.(condStrs{condI}) = [condStruct.(condStrs{condI}); data.cond.(condStrs{condI})]; 
    end % condI
end % blockI

channelInfo             = data.chan;
[raster, channelInfo]   = selectUnits(raster, channelInfo); 
arrayMap                = loadArrayMap(filespecs.subjectStr, filespecs.arrayStr);

isElecNum   = data.isElecNum; 
if filespecs.collapseUnits
    [raster, channelInfo]           = channelCollapse(raster, channelInfo);  
    [raster, chanLinearInds]        = getLinearOrderChanRaster(raster, channelInfo, arrayMap, isElecNum);    
else
    chanLinearInds                  = getChanLinearInds(arrayMap, channelInfo, isElecNum); 
    [B, I]                          = sort(chanLinearInds);
    raster                          = raster(I, :, :);
    chanLinearInds                  = B; 
end

% sorting out conditionInfo
if isfield(filespecs, 'conditionSort') && ~strcmp(filespecs.conditionSort, 'events')
    conditionInfo                   = conditionInfoSortingOut_AL(filespecs.conditionSort, condStruct); 
else
    conditionInfo                   = []; 
end

spikeData.raster                    = raster;
spikeData.subjectStr                = filespecs.subjectStr;
spikeData.sessionStr                = filespecs.sessionStr;
spikeData.arrayStr                  = filespecs.arrayStr;
spikeData.arrayMap                  = arrayMap;
spikeData.chanLinearInds            = chanLinearInds;
spikeData.conditionInfo             = conditionInfo;
spikeData.eventStrs                 = filespecs.eventStrs;
spikeData.periEventTime             = filespecs.periEventTime;
spikeData.condStruct                = condStruct;
spikeData.trialOutcome              = condStruct.trialOutcome;
spikeData.collapseUnits             = filespecs.collapseUnits;
