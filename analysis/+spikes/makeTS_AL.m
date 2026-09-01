function spikeData = makeTS_AL(filespecs)
% function makeTS_AL loads the spikes for channels while ignoring events 
% 
% INPUT
%   filespecs.subjectStr    = 'Buzz' OR 'Theo'
%   filespecs.sessionStr    = '20171109'
%   filespecs.blockStr      = 'ALFixedStart', 'ALNovel', 'ALNovel2', 'ALFixedEnd'
%   filespecs.arrayStr      = 'NSP0' OR 'NSP1'   
%   filespecs.trialOutcome  = 'correctOnly', 'incorrectOnly', 'correctANDincorrect'
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
% last modified: 2026.01.07

fprintf('************** making spike raster for AL %s %s %s %s STARTS **************\n', filespecs.subjectStr, filespecs.sessionStr, filespecs.blockStr, filespecs.arrayStr);
disp(filespecs);

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

eventStarts         = 0; % in msec
eventEnds           = ceil((data.(filespecs.blockStr).cond.end - data.(filespecs.blockStr).cond.start) * 1000); % in msec
duration            = max(eventEnds - eventStarts)+1;
raster              = [];
for trialI=1:nTrials
    spikePattern_thisTrial = zeros(nUnits, duration);
    for unitI=1:nUnits
        spikeTimes  = data.(filespecs.blockStr).rasterInds.(filespecs.arrayStr){trialI, unitI};
        spikeTimes  = spikeTimes(spikeTimes<=eventEnds(trialI) & spikeTimes>=eventStarts) + 1;

        if ~isempty(spikeTimes)
            spikePattern_thisTrial(unitI, spikeTimes) = 1;
        end
    end % unitI
    raster = cat(3, raster, spikePattern_thisTrial); 
end % trialI
spikeData.raster = raster;


[spikeData.chan, spikeData.isElecNum]   = extractChanInfo(data.(filespecs.blockStr).chan.(filespecs.arrayStr));



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