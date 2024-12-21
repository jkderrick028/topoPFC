function START_R13_throwOutSharedSpikes_AL
% Check the number of shared spikes between each pair of channels. If a
% channel pair shares more than 10% of the spikes, removed shared spikes
% from both channels.
% 
% last modified: 2024.12.20

import spikes.*;


projectPath                                 = setProjectPath();
[currPath, currfilename, currext]           = fileparts(mfilename('fullpath'));

dataPath_original                           = fullfile(projectPath, 'data', 'AL_untouched', 'Buzz'); 


resultsPath                                 = fullfile(projectPath, 'data', 'AL', 'Buzz');
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

sessionStrs                                 = {'20171109', '20171110', '20171111', '20171112'}; 
subjectStr                                  = 'Buzz';
arrayStr                                    = 'NSP1'; 
% threshold                                   = 0.1; 
threshold                                   = 0.2; 

for sessI = 1:numel(sessionStrs)
    MAT_original                            = fullfile(dataPath_original, sprintf('%s%s.mat', subjectStr(1), sessionStrs{sessI})); 
    data                                    = load(MAT_original).data;
    
    blockStrs                               = fieldnames(data); 
    for blockI = 1:numel(blockStrs)
        chan                                = data.(blockStrs{blockI}).chan.(arrayStr); 
        rasterInds                          = data.(blockStrs{blockI}).rasterInds.(arrayStr);

        unique_chan                         = unique(chan);
        n_unique_chan                       = numel(unique_chan);
        n_trials                            = size(rasterInds, 1); 

        for chanI = 1:(n_unique_chan - 1)
            units_chanI                     = find(strcmp(chan, unique_chan{chanI})); 
            for chanJ = (chanI + 1):n_unique_chan
                units_chanJ                                     = find(strcmp(chan, unique_chan{chanJ})); 

                spike_times_each_trial_chanI                    = cell(n_trials, 1); 
                spike_times_each_trial_chanJ                    = cell(n_trials, 1);
                spike_times_each_trial_unique_combo             = cell(n_trials, 1);
                spike_times_each_trial_throw_out                = cell(n_trials, 1);

                for trlI = 1:n_trials
                    temp                                        = rasterInds(trlI, units_chanI); 
                    spike_times_each_trial_chanI{trlI}          = vertcat(temp{:});

                    temp                                        = rasterInds(trlI, units_chanJ); 
                    spike_times_each_trial_chanJ{trlI}          = vertcat(temp{:});

                    combo                                       = [spike_times_each_trial_chanI{trlI}; spike_times_each_trial_chanJ{trlI}]; 
                    [unique_vals, ~, ic]                        = unique(combo);
                    spike_times_each_trial_unique_combo{trlI}   = unique_vals;
                    counts                                      = accumarray(ic, 1);
                    spike_times_each_trial_throw_out{trlI}      = unique_vals(counts > 1);
                end % trlI 

                % compute the amount of shared spikes
                n_spikes_total                                  = 0;
                n_unique_spikes                                 = 0; 
                for trlI = 1:n_trials
                    n_spikes_total                              = n_spikes_total + numel(spike_times_each_trial_chanI{trlI}) + numel(spike_times_each_trial_chanJ{trlI}); 
                    n_unique_spikes                             = n_unique_spikes + numel(spike_times_each_trial_unique_combo{trlI});                    
                end % trlI 
                
                prop_shared_spikes                              = 1 - n_unique_spikes / n_spikes_total;
                if prop_shared_spikes > threshold
                    for trlI = 1:n_trials
                        for unitI =1:numel(units_chanI)                                                        
                            rasterInds{trlI, units_chanI(unitI)}= rasterInds{trlI, units_chanI(unitI)}(~ismember(rasterInds{trlI, units_chanI(unitI)}, spike_times_each_trial_throw_out{trlI}));  
                        end % unitI

                        for unitJ =1:numel(units_chanJ)
                            rasterInds{trlI, units_chanJ(unitJ)}= rasterInds{trlI, units_chanJ(unitJ)}(~ismember(rasterInds{trlI, units_chanJ(unitJ)}, spike_times_each_trial_throw_out{trlI}));  
                        end % unitJ
                    end % trlI 
                end 
            end % chanJ 
        end % chanI
        data.(blockStrs{blockI}).rasterInds.(arrayStr)          = rasterInds;
    end % blockI
    MAT_modified = fullfile(resultsPath, sprintf('%s%s.mat', subjectStr(1), sessionStrs{sessI})); 
    save(MAT_modified, 'data', '-v7.3'); 
end % sessI 



end % START_R13_throwOutSharedSpikes_AL
