function spikeData = loadTS_AL(filespecs)
% function loadTS_AL loads spike data for AL task, no events or conditions concerned.
% 
% INPUT 
%   filespecs.subjectStr    = 'Buzz' OR 'Theo'
%   filespecs.sessionStr    = '20171109'
%   filespecs.blockStr      = 'ALFixedStart', 'ALNovel', 'ALNovel2', 'ALFixedEnd', 'allBlocks', 'fixed', 'novel'
%   filespecs.arrayStr      = 'NSP0' OR 'NSP1'   
%   filespecs.trialOutcome  = 'correctOnly', 'incorrectOnly', 'correctANDincorrect'
%   filespecs.collapseUnits = 0 OR 1 
%   filespecs.eventStrs       (4 x 1 cell array)      {'contextOnset', 'goalsOnset', 'decisionOnset', 'trialEnd'}
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
% filespecs.trialOutcome    = 'correctOnly'; 
% filespecs.collapseUnits   = 1;  
%  
% spikeData                 = loadTS_AL(filespecs); 
% 
% 
% 
% last modified: 2026.01.07

import spikes.*;


spikeData               = [];
spikeData.blockStr      = filespecs.blockStr;

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

arrayMap                = loadArrayMap(filespecs.subjectStr, filespecs.arrayStr);

for blockI=1:numel(blockStrs)
    filespecs.blockStr  = blockStrs{blockI}; 
    data                = makeTS_AL(filespecs);
    channelInfo         = data.chan; 
    
    raster_thisBlock    = data.raster; 

    [raster_thisBlock, channelInfo]   = selectUnits(raster_thisBlock, channelInfo); 
    
    isElecNum   = data.isElecNum; 
    if filespecs.collapseUnits
        [raster_thisBlock, channelInfo]           = channelCollapse(raster_thisBlock, channelInfo);  
        [raster_thisBlock, chanLinearInds]        = getLinearOrderChanRaster(raster_thisBlock, channelInfo, arrayMap, isElecNum);    
    else
        chanLinearInds                  = getChanLinearInds(arrayMap, channelInfo, isElecNum); 
        [B, I]                          = sort(chanLinearInds);
        raster_thisBlock                = raster_thisBlock(I, :, :);
        chanLinearInds                  = B; 
    end
    
    raster_thisBlock    = reshape(raster_thisBlock, size(raster_thisBlock, 1), []); 
    raster              = cat(2, raster, raster_thisBlock);
end % blockI


spikeData.raster                    = raster;
spikeData.subjectStr                = filespecs.subjectStr;
spikeData.sessionStr                = filespecs.sessionStr;
spikeData.arrayStr                  = filespecs.arrayStr;
spikeData.arrayMap                  = arrayMap;
spikeData.chanLinearInds            = chanLinearInds;
spikeData.collapseUnits             = filespecs.collapseUnits;
