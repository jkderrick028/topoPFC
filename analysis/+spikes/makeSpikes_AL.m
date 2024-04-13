function spikeData = makeSpikes_AL(filespecs)
% function makeSpikes_AL aligns trials to events for the AL task. The
% output would be a struct, with spike raster as one field.
% 
% INPUT
%   filespecs.subjectStr    = 'Buzz' OR 'Theo'
%   filespecs.sessionStr    = '20171109'
%   filespecs.blockStr      = 'ALFixedStart', 'ALNovel', 'ALNovel2', 'ALFixedEnd'
%   filespecs.arrayStr      = 'NSP0' OR 'NSP1'   
%   filespecs.trialOutcome  = 'correctOnly', 'incorrectOnly', 'correctANDincorrect'
%   filespecs.periEventTime   (4 x 2 double array)    time before and after these 4 events: {'contextOnset', 'goalsOnset', 'decisionOnset', 'trialEnd'}
% 
% OUTPUT
%   [spikeData.chan, spikeData.isElecNum]   = extractChanInfo(data.(filespecs.blockStr).chan.(filespecs.arrayStr));
%   spikeData.rasters.(eventStrs{eventI})
%   spikeData.cond.wood                     = data.(filespecs.blockStr).cond.Wood;
%   spikeData.cond.color                    = data.(filespecs.blockStr).cond.ChoiceColour;
%   spikeData.cond.choiceLeft               = data.(filespecs.blockStr).cond.ChoiceLeft;
%   spikeData.cond.trialOutcome             = data.(filespecs.blockStr).cond.Correct;
%   spikeData.cond.periEventTime            = periEventTime;
%   spikeData.cond.eventStrs                = eventStrs;
% 
% USAGE
% filespecs.subjectStr      = 'Theo'; 
% filespecs.sessionStr      = '20170405';
% filespecs.blockStr        = 'ALNovel'; 
% filespecs.arrayStr        = 'NSP0'; 
% filespecs.periEventTime   = [400, 500; 500, 600; 600, 700; 700, 500]; 
% filespecs.trialOutcome    = 'correctOnly'; 
% 
% spikeData                 = makeSpikes_AL(filespecs); 
% 
% last modified: 2023.03.06


fprintf('************** making spike raster for AL %s %s %s %s STARTS **************\n', filespecs.subjectStr, filespecs.sessionStr, filespecs.blockStr, filespecs.arrayStr);
disp(filespecs);

eventStrs_full          = {'contextOnset', 'goalsOnset', 'decisionOnset', 'trialEnd'};
eventStrs               = filespecs.eventStrs; 
eventStrsInTable_full   = {'ContextOnInd', 'GoalsOnInd', 'decisionOnset', 'trlEndInd'};
eventStrsInTable        = eventStrsInTable_full(ismember(eventStrs_full, eventStrs)); 

periEventTime       = filespecs.periEventTime;
assert(size(periEventTime, 1) == numel(eventStrs), 'periEventTime missing events'); 

projectPath         = setProjectPath();
MAT_unprocessedData = fullfile(projectPath, 'data', 'AL', filespecs.subjectStr, sprintf('%s%s.mat', filespecs.subjectStr(1), filespecs.sessionStr));
data                = load(MAT_unprocessedData).data;

spikeData           = [];
preContextOnsetTime = data.(filespecs.blockStr).cond.ContextOnInd   - data.(filespecs.blockStr).cond.trlstart;
context2goalTime    = data.(filespecs.blockStr).cond.GoalsOnInd     - data.(filespecs.blockStr).cond.ContextOnInd;
goal2decisionTime   = data.(filespecs.blockStr).cond.decisionOnset  - data.(filespecs.blockStr).cond.GoalsOnInd;
postDecisionTime    = data.(filespecs.blockStr).cond.trlEndInd      - data.(filespecs.blockStr).cond.decisionOnset;
timeErrorTrlInds    = find(preContextOnsetTime<=0 | context2goalTime<=0 | goal2decisionTime<=0 | postDecisionTime<=0 | data.(filespecs.blockStr).cond.ContextOnInd<=0 | data.(filespecs.blockStr).cond.trlstart<=0 | data.(filespecs.blockStr).cond.GoalsOnInd<=0 | data.(filespecs.blockStr).cond.decisionOnset<=0 | data.(filespecs.blockStr).cond.trlEndInd<=0);

switch filespecs.trialOutcome
    case 'correctOnly'
        excludedTrlInds = find(data.(filespecs.blockStr).cond.Correct==0);
    case 'incorrectOnly'
        excludedTrlInds = find(data.(filespecs.blockStr).cond.Correct==1);
    case 'correctANDincorrect'
        excludedTrlInds = find(data.(filespecs.blockStr).cond.Correct~=0 & data.(filespecs.blockStr).cond.Correct~=1);
end
excludedTrlInds         = union(excludedTrlInds, timeErrorTrlInds);

data.(filespecs.blockStr).cond(excludedTrlInds, :) = [];

nTrials                 = size(data.(filespecs.blockStr).cond, 1);
data.(filespecs.blockStr).rasterInds.(filespecs.arrayStr)(excludedTrlInds, :) = [];
[~, nUnits]             = size(data.(filespecs.blockStr).rasterInds.(filespecs.arrayStr));

for eventI=1:numel(eventStrs)
    eventStarts         = max(data.(filespecs.blockStr).cond.(eventStrsInTable{eventI}) - periEventTime(eventI, 1), 1); % in msec
    eventEnds           = data.(filespecs.blockStr).cond.(eventStrsInTable{eventI}) + periEventTime(eventI, 2) - 1; % in msec
    durationThisEvent   = sum(periEventTime(eventI, :));
    raster              = [];
    for trialI=1:nTrials
        spikePattern_thisTrial = zeros(nUnits, durationThisEvent);
        for unitI=1:nUnits
            spikeTimes  = data.(filespecs.blockStr).rasterInds.(filespecs.arrayStr){trialI, unitI};
            spikeTimes  = spikeTimes(spikeTimes<=eventEnds(trialI) & spikeTimes>=eventStarts(trialI)) - eventStarts(trialI) + 1;
    
            if ~isempty(spikeTimes)
                spikePattern_thisTrial(unitI, spikeTimes) = 1;
            end
        end % unitI
        raster = cat(3, raster, spikePattern_thisTrial); 
    end % trialI
    spikeData.rasters.(eventStrs{eventI}) = raster;
end % eventI

[spikeData.chan, spikeData.isElecNum]   = extractChanInfo(data.(filespecs.blockStr).chan.(filespecs.arrayStr));
spikeData.cond.wood             = data.(filespecs.blockStr).cond.Wood;
spikeData.cond.color            = data.(filespecs.blockStr).cond.ChoiceColour;
spikeData.cond.choiceLeft       = data.(filespecs.blockStr).cond.ChoiceLeft;
spikeData.cond.trialOutcome     = data.(filespecs.blockStr).cond.Correct;
spikeData.cond.periEventTime    = periEventTime;
spikeData.cond.eventStrs        = eventStrs;

monitor = 1;
if monitor
    close all;
    figureStrs      = {'preContextOnsetTime', 'context2goalTime', 'goal2decisionTime', 'postDecisionTime'};
    for figI=1:numel(figureStrs)
        eval(sprintf('histogram(%s(%s>0), 50)', figureStrs{figI}, figureStrs{figI}));
        titleStr    = sprintf("%s %s %s %s", filespecs.subjectStr, filespecs.sessionStr, filespecs.blockStr, figureStrs{figI});
        title(titleStr);
        xlabel('time (ms)'); 
        ylabel('count');
        figSavingPath = fullfile(projectPath, 'results', 'sanityCheck_AL', 'periEventTimingDistPlots_AL');
        if ~exist(figSavingPath, 'dir'), mkdir(figSavingPath); end
        saveas(gcf, fullfile(figSavingPath, sprintf('%s.png', strrep(titleStr,' ', '_'))));
    end % figI
    close all;
end

end % funciton makeSpikes_AL


function [channelInfo, isElecNum] = extractChanInfo(chan)
% function extractChanInfo extract electrode number from the chan cell array. chan is like
% {'Velec001', 'Velec 002'}
% In this function, we will extract the number and put it in the format '001', '010' etc.
% 
% last modified: 2022.10.20

if contains(chan{1}, 'elec')
    isElecNum = 1;
elseif contains(chan{1}, 'Chan')
    isElecNum = 0;
else 
    warning('ChanNum or ElecNum unclear'); 
    return; 
end

channelInfo = cell(numel(chan), 1);
for chanI = 1:numel(chan)
    channum             = str2double(regexp(chan{chanI}, '\d*', 'match'));
    channelInfo{chanI}  = num2str(channum, '%03.f');
end % chanI
end
