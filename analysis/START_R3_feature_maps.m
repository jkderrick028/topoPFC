function START_R3_feature_maps
% visualize 3 types of maps, based an example session in KM task, monkey B
% dorsal array
% 
% 1. selectivity to 9 target locations
% 2. selectivity to 3 trial epochs (cue, delay, response)
% 3. selectivity to 9 target during cue, delay, response respectively
% 4. selectivity to 9 target x 3 epochs
% 
% last modified: 2024.08.26

import spikes.*;
import utils_dx.*;
import mds.*;

close all;

projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'topovis';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

subjectStr                          = 'Buzz';
arrayStr                            = 'NSP1';

output                              = [];
MAT_output                          = fullfile(resultsPath, sprintf('%s.mat', currfilename)); 

figI_maps                           = 10; 
nHors                               = 3;
nVers                               = 2; 
PS_maps                             = fullfile(resultsPath, sprintf('%s.ps', currfilename)); 
if exist(PS_maps, 'file')
    system(['rm ' PS_maps]); 
end

nRows                               = 10;
nCols                               = 10; 
nChannelsTotal                      = nRows * nCols; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% feature maps KM
taskStr                             = 'KM'; 
sessionStr                          = '20171201'; 
resultsPath_taskTuning              = fullfile(projectPath, 'results', 'spikeTuningVectors', sprintf('START_B1_extractSignal_%s', taskStr));
MAT_tuningResults                   = fullfile(resultsPath_taskTuning, sprintf('START_B1_extractSignal_%s_%s_channels_results.mat', taskStr, subjectStr));    
spikeTuningResults                  = load(MAT_tuningResults).spikeTuningResults.(arrayStr).(sprintf('sess_%s', sessionStr)).nineLocations;

chanLinearInds                      = spikeTuningResults.chanLinearInds; 
conditionInfo                       = spikeTuningResults.conditionInfo; 
uniqueConditions                    = spikeTuningResults.uniqueConditions; 
tuningProfile                       = spikeTuningResults.tuningProfile; 
excluded_chanLinearInds             = setdiff(1:nChannelsTotal, chanLinearInds); 

target_colors                       = {
    [107, 207, 54]/255, [50, 168, 109]/255, [38, 140, 67]/255;
    [89, 229, 242]/255, [76, 146, 184]/255, [11, 67, 122]/255;
    [227, 232, 88]/255, [232, 179, 88]/255, [186, 89, 74]/255
};

target_by_epoch_colors              = {
    [157, 124, 204]/255, [165, 86, 204]/255, [151, 10, 204]/255, ...
    [204, 176, 175]/255, [204, 102, 100]/255, [204, 9, 23]/255, ...
    [204, 149, 167]/255, [204, 159, 191]/255, [204, 77, 141]/255, ...
    [109, 219, 210]/255, [123, 204, 198]/255, [12, 187, 199]/255, ...
    [89, 229, 242]/255, [66, 138, 204]/255, [6, 90, 204]/255, ...
    [155, 180, 204]/255, [4, 117, 232]/255, [9, 33, 242]/255, ....
    [107, 207, 54]/255, [50, 168, 109]/255, [38, 140, 67]/255, ...
    [140, 204, 182]/255, [74, 200, 113]/255, [14, 180, 55]/255, ...
    [227, 232, 88]/255, [232, 179, 88]/255, [204, 103, 10]/255
}; 

% map 1, selectivity to 9 targets
spikes_map1                         = squeeze(sum(tuningProfile, 2)); % shape of 100 x 9 
[M, I]                              = max(spikes_map1, [], 2); 
feature_map1                        = ones(nChannelsTotal, 3); 

currCondI = 1;
for i=1:3
    for j=1:3
        chanInds                    = find(I == currCondI);
        feature_map1(chanInds, :)   = repmat(target_colors{i, j}, numel(chanInds), 1); 

        currCondI                   = currCondI + 1; 
    end % j
end % i

feature_map1(excluded_chanLinearInds, :) = 1; 
feature_map1                        = reshape(feature_map1, 10, 10, 3); 

figure(figI_maps); clf(figI_maps);

subplot(nHors, nVers, 1);
imagesc(feature_map1); 
axis square;
set(gca, 'YDir', 'normal'); 
xlabel('channels');
ylabel('channels'); 
title('selectivity to targets'); 

% map 2, selectivity to 3 trial epochs
trial_epoch_colors = {
   % [207, 75, 54]/255, [38, 49, 140]/255, [168, 50, 156]/255 
   [207, 75, 54]/255, [38, 49, 140]/255, [38, 140, 67]/255 
}; 
spikes_map2                         = squeeze(sum(tuningProfile, 3)); % shape of 100 x 3
[M, I]                              = max(spikes_map2, [], 2); 
feature_map2                        = ones(nChannelsTotal, 3); 

n_epochs = 3; 

for i = 1:n_epochs
    chanInds                        = find(I == i); 
    feature_map2(chanInds, :)       = repmat(trial_epoch_colors{i}, numel(chanInds), 1); 
end % i
feature_map2(excluded_chanLinearInds, :) = 1; 
feature_map2 = reshape(feature_map2, 10, 10, 3);

subplot(nHors, nVers, 2);
imagesc(feature_map2);
axis square;
set(gca, 'YDir', 'normal');
xlabel('channels');
ylabel('channels'); 
title('selectivity to trial epochs'); 


% map 3, selectivity to 9 targets during cue
spikes_map3 = squeeze(tuningProfile(:, 1, :)); % shape of 100 x 9
[M, I]                              = max(spikes_map3, [], 2); 
feature_map3                        = ones(nChannelsTotal, 3); 

currCondI = 1;
for i=1:3
    for j=1:3
        chanInds                    = find(I == currCondI);
        feature_map3(chanInds, :)   = repmat(target_colors{i, j}, numel(chanInds), 1); 

        currCondI                   = currCondI + 1; 
    end % j
end % i

feature_map3(excluded_chanLinearInds, :) = 1; 
feature_map3                        = reshape(feature_map3, 10, 10, 3); 

subplot(nHors, nVers, 3);
imagesc(feature_map3); 
axis square;
set(gca, 'YDir', 'normal'); 
xlabel('channels');
ylabel('channels'); 
title('selectivity to targets during cue'); 


% map 4, selectivity to 9 targets during delay
spikes_map4 = squeeze(tuningProfile(:, 2, :)); % shape of 100 x 9
[M, I]                              = max(spikes_map4, [], 2); 
feature_map4                        = ones(nChannelsTotal, 3); 

currCondI = 1;
for i=1:3
    for j=1:3
        chanInds                    = find(I == currCondI);
        feature_map4(chanInds, :)   = repmat(target_colors{i, j}, numel(chanInds), 1); 

        currCondI                   = currCondI + 1; 
    end % j
end % i

feature_map4(excluded_chanLinearInds, :) = 1; 
feature_map4                        = reshape(feature_map4, 10, 10, 3); 

subplot(nHors, nVers, 4);
imagesc(feature_map4); 
axis square;
set(gca, 'YDir', 'normal'); 
xlabel('channels');
ylabel('channels'); 
title('selectivity to targets during delay'); 


% map 5, selectivity to 9 targets during response
spikes_map5 = squeeze(tuningProfile(:, 3, :)); % shape of 100 x 9
[M, I]                              = max(spikes_map5, [], 2); 
feature_map5                        = ones(nChannelsTotal, 3); 

currCondI = 1;
for i=1:3
    for j=1:3
        chanInds                    = find(I == currCondI);
        feature_map5(chanInds, :)   = repmat(target_colors{i, j}, numel(chanInds), 1); 

        currCondI                   = currCondI + 1; 
    end % j
end % i

feature_map5(excluded_chanLinearInds, :) = 1; 
feature_map5                        = reshape(feature_map5, 10, 10, 3); 

subplot(nHors, nVers, 5);
imagesc(feature_map5); 
axis square;
set(gca, 'YDir', 'normal'); 
xlabel('channels');
ylabel('channels'); 
title('selectivity to targets during response'); 


% map 6, selectivity to 9 target locations x 3 trial epochs
spikes_map6                         = permute(tuningProfile, [1, 3, 2]); 
spikes_map6                         = reshape(spikes_map6, nChannelsTotal, []); 
[M, I]                              = max(spikes_map6, [], 2); 
feature_map6 = ones(nChannelsTotal, 3);

currCondI = 1;
for i = 1:27
    chanInds = find(I == currCondI);
    feature_map6(chanInds, :) = repmat(target_by_epoch_colors{i}, numel(chanInds), 1);
    currCondI = currCondI + 1; 
end % i
feature_map6(excluded_chanLinearInds, :) = 1;
feature_map6 = reshape(feature_map6, 10, 10, 3); 

subplot(nHors, nVers, 6);
imagesc(feature_map6); 
axis square;
set(gca, 'YDir', 'normal'); 
xlabel('channels');
ylabel('channels'); 
title('selectivity to targets by epochs'); 


pageHeading                         = 'feature maps KM'; 
addHeadingAndPrint(pageHeading, PS_maps, figI_maps); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% feature maps ODR

taskStr                             = 'ODR'; 
sessionStr                          = '20180307'; 
resultsPath_taskTuning              = fullfile(projectPath, 'results', 'spikeTuningVectors', sprintf('START_B1_extractSignal_%s', taskStr));
MAT_tuningResults                   = fullfile(resultsPath_taskTuning, sprintf('START_B1_extractSignal_%s_%s_channels_results.mat', taskStr, subjectStr));    
spikeTuningResults                  = load(MAT_tuningResults).spikeTuningResults.(arrayStr).(sprintf('sess_%s', sessionStr)).quadrants;

chanLinearInds                      = spikeTuningResults.chanLinearInds; 
conditionInfo                       = spikeTuningResults.conditionInfo; 
uniqueConditions                    = spikeTuningResults.uniqueConditions; 
tuningProfile                       = spikeTuningResults.tuningProfile; 
excluded_chanLinearInds             = setdiff(1:nChannelsTotal, chanLinearInds); 

target_colors                       = {
    [89, 229, 242]/255, [107, 207, 54]/255; 
    [50, 168, 109]/255, [76, 146, 184]/255
};

target_by_epoch_colors              = {
    [204, 102, 100]/255, [204, 176, 175]/255, [165, 86, 204]/255, [204, 9, 23]/255, ...
    [66, 138, 204]/255, [123, 204, 198]/255, [89, 229, 242]/255, [6, 90, 204]/255, ...
    [140, 204, 182]/255, [107, 207, 54]/255, [50, 168, 109]/255, [38, 140, 67]/255
}; 

% map 1, selectivity to 4 quadrants
spikes_map1                         = squeeze(sum(tuningProfile, 2)); % shape of 100 x 4
[M, I]                              = max(spikes_map1, [], 2); 
feature_map1                        = ones(nChannelsTotal, 3); 

currCondI = 1;
for i=1:2
    for j=1:2
        chanInds                    = find(I == currCondI);
        feature_map1(chanInds, :)   = repmat(target_colors{i, j}, numel(chanInds), 1); 

        currCondI                   = currCondI + 1;    
    end % j
end % i

feature_map1(excluded_chanLinearInds, :) = 1; 
feature_map1                        = reshape(feature_map1, 10, 10, 3); 

figure(figI_maps); clf(figI_maps);

subplot(nHors, nVers, 1);
imagesc(feature_map1); 
axis square;
set(gca, 'YDir', 'normal'); 
xlabel('channels');
ylabel('channels'); 
title('selectivity to quadrants'); 


% map 2, selectivity to 3 trial epochs
spikes_map2                         = squeeze(sum(tuningProfile, 3)); % shape of 100 x 3
[M, I]                              = max(spikes_map2, [], 2); 
feature_map2                        = ones(nChannelsTotal, 3); 

n_epochs = 3; 

for i = 1:n_epochs
    chanInds                        = find(I == i); 
    feature_map2(chanInds, :)       = repmat(trial_epoch_colors{i}, numel(chanInds), 1); 
end % i
feature_map2(excluded_chanLinearInds, :) = 1; 
feature_map2 = reshape(feature_map2, 10, 10, 3);

subplot(nHors, nVers, 2);
imagesc(feature_map2);
axis square;
set(gca, 'YDir', 'normal');
xlabel('channels');
ylabel('channels'); 
title('selectivity to trial epochs'); 


% map 3, selectivity to 4 quadrants x 3 trial epochs
spikes_map3                         = permute(tuningProfile, [1, 3, 2]); 
spikes_map3                         = reshape(spikes_map3, nChannelsTotal, []); 
[M, I]                              = max(spikes_map3, [], 2); 
feature_map3 = ones(nChannelsTotal, 3);

currCondI = 1;
for i = 1:12
    chanInds = find(I == currCondI);
    feature_map3(chanInds, :) = repmat(target_by_epoch_colors{i}, numel(chanInds), 1);
    currCondI = currCondI + 1; 
end % i
feature_map3(excluded_chanLinearInds, :) = 1;
feature_map3 = reshape(feature_map3, 10, 10, 3); 

subplot(nHors, nVers, 3);
imagesc(feature_map3); 
axis square;
set(gca, 'YDir', 'normal'); 
xlabel('channels');
ylabel('channels'); 
title('selectivity to quadrants by epochs'); 


pageHeading                         = 'feature maps ODR'; 
addHeadingAndPrint(pageHeading, PS_maps, figI_maps); 

save(MAT_output, 'output', '-v7.3');
close all;

end % START_R3_feature_maps
