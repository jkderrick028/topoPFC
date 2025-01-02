% function START_R12_crosstalk_ben
% check the proportion of shared spikes between each pair of channels.
% 
% last modified: 2024.12.18


import spikes.*;
import utils_dx.*; 

% 
% projectPath                         = setProjectPath();
% [currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
% ANALYSIS                            = 'supplemental';
% resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
% if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end
% 

%% AL
%load session data
% session = 'B20171109';
% session = 'B20171110';
% session = 'B20171111';
session = 'B20171112';
% session = 'B20171121';
% session = 'B20171123';
load(['/Users/jkderrick028/Documents/Projects/topoPFC/data/AL_0.1/Buzz/', session, '.mat']); 


%get all thresholdcrossings for each channel
nsp = {'NSP0'}; 
allChans = data.ALNovel.chan.(nsp{1});
uniChans = unique(allChans);
thresholdedAct = cell(length(uniChans),1);
for chan = 1:length(uniChans)
    units = find(contains(allChans,uniChans{chan}));
    temp = [];
    for ii =1:length(units)
        spikeTimes = vertcat(arrayfun(@(x) data.ALNovel.rasterInds.(nsp{1}){x,units(ii)}+(x*30000),...
            1:size(data.ALNovel.rasterInds.(nsp{1}),1),'UniformOutput',0));
        temp = [temp;vertcat(spikeTimes{:})]; 
    end
    thresholdedAct{chan} = sort(temp);
end

combo = [thresholdedAct{3};thresholdedAct{5}];
length(unique(combo))/length(combo);
for ii = 1:length(uniChans)-1
    for jj = ii+1:length(uniChans)
        combo = [thresholdedAct{ii};thresholdedAct{jj}];
        percUni(ii, jj) = 1-(length(unique(combo))/length(combo));


    end
end
max(max(percUni))

figure
hold on
subplot(2,1,1)
hold on
histogram(percUni(percUni~=0),'BinWidth',.01)
legend({'NPS0','NSP1'})
subplot(2,1,2)
hold on
histogram(percUni(percUni~=0),'BinWidth',.01)


nsp = {'NSP1'}
allChans = data.ALNovel.chan.(nsp{1});
uniChans = unique(allChans);
thresholdedAct = cell(length(uniChans),1);
for chan = 1:length(uniChans)
    units = find(contains(allChans,uniChans{chan}));
    temp = [];
    for ii =1:length(units)
        spikeTimes = vertcat(arrayfun(@(x) data.ALNovel.rasterInds.(nsp{1}){x,units(ii)}+(x*30000),...
            1:size(data.ALNovel.rasterInds.(nsp{1}),1),'UniformOutput',0));
        temp = [temp;vertcat(spikeTimes{:})]; 
    end
    thresholdedAct{chan} = sort(temp);
end

combo = [thresholdedAct{3};thresholdedAct{5}];
length(unique(combo))/length(combo);
for ii = 1:length(uniChans)-1
    for jj = ii+1:length(uniChans)
        combo = [thresholdedAct{ii};thresholdedAct{jj}];
        percUni(ii, jj) = 1-(length(unique(combo))/length(combo));
    end
end
max(max(percUni))
subplot(2,1,1)
title(session);
histogram(percUni(percUni~=0),'BinWidth',.01)
legend({'NPS0','NSP1'})
subplot(2,1,2)
histogram(percUni(percUni~=0),'BinWidth',.01)
ylim([0 50])
