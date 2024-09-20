function START_R7_active_channels
% count the number of active channels for each array in each session in
% each task
% 
% last modified: 2024.09.06


close all; 

% data
subjectStrs = {'Buzz', 'Theo'};
arrayStrs   = {'NSP1','NSP0'};
taskStrs    = {'ODR', 'KM', 'AL'}; 

%% preparation
projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'supplemental';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

output                              = []; 
MAT_output                          = fullfile(resultsPath, sprintf('%s_output.mat', currfilename)); 

for taskI = 1:numel(taskStrs)
    for subjectI = 1:numel(subjectStrs)
        MAT_spikeTuningVectors      = fullfile(projectPath, 'results', 'spikeTuningVectors', sprintf('START_B1_extractSignal_%s', taskStrs{taskI}), sprintf('START_B1_extractSignal_%s_%s_channels_results.mat', taskStrs{taskI}, subjectStrs{subjectI})); 
        spikeTuningResults          = load(MAT_spikeTuningVectors).spikeTuningResults; 
        
        for arrayI = 1:numel(arrayStrs)
            if strcmp(subjectStrs{subjectI}, 'Theo') && strcmp(arrayStrs{arrayI}, 'NSP1')
                continue;                 
            end
            
            nActiveChannels         = [];
            input                   = spikeTuningResults.(arrayStrs{arrayI}); 
            sessions                = fieldnames(input); 

            for sessI=1:numel(sessions)
                switch taskStrs{taskI}
                    case 'ODR'
                        nChannels   = numel(input.(sessions{sessI}).quadrants.chanLinearInds); 
                    case 'KM'
                        nChannels   = numel(input.(sessions{sessI}).nineLocations.chanLinearInds); 
                    case 'AL'
                        nChannels   = numel(input.(sessions{sessI}).tuning.chanLinearInds); 
                end
                nActiveChannels(end+1) = nChannels; 
            end % sessI
            output.(sprintf('%s_%s', subjectStrs{subjectI}, taskStrs{taskI})).(arrayStrs{arrayI}).nActiveChannels   = nActiveChannels;
            output.(sprintf('%s_%s', subjectStrs{subjectI}, taskStrs{taskI})).(arrayStrs{arrayI}).mean              = mean(nActiveChannels);
            output.(sprintf('%s_%s', subjectStrs{subjectI}, taskStrs{taskI})).(arrayStrs{arrayI}).std               = std(nActiveChannels);
        end % arrayI
    end % subjectI
end % taskI 

save(MAT_output, 'output', '-v7.3');

end % START_R7_active_channels
