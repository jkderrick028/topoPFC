function START_R2_topo_acrossDays(varargin)
% The correlation of topo maps as a function of days in between
% 
% last modified: 2024.07.30

import spikes.*;
import utils_dx.*;
import topography.*;

close all;

p                                   = inputParser;
p.addParameter('signalType', 'task');   % or residuals

parse(p, varargin{:});
signalType                          = p.Results.signalType; 

projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'topography';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

output                              = [];
MAT_output                          = fullfile(resultsPath, sprintf('%s_%s.mat', currfilename, signalType)); 

subjectStrs                         = {'Buzz', 'Theo'};
arrayStrs                           = {'NSP1', 'NSP0'}; 

MAT_simmats                         = fullfile(projectPath, 'results', ANALYSIS, 'START_B6_topoInference_generation', 'output_simmats.mat'); 
output_simmats                      = load(MAT_simmats).output_simmats; 

MAT_daysAcrossTasks                 = fullfile(projectPath, 'results', ANALYSIS, 'START_B5_daysAcrossTasks', 'START_B5_daysAcrossTasks_output.mat'); 
daysAcrossTasks                     = load(MAT_daysAcrossTasks).output; 

PS_results                          = fullfile(resultsPath, sprintf('%s_%s.ps', currfilename, signalType));
if exist(PS_results, 'file')
    system(['rm ' PS_results]); 
end

figI                                = 10; 
figure(figI); clf(figI); 
nHors                               = numel(subjectStrs);
nVers                               = numel(arrayStrs);
currSubplotI                        = 1;
for subjectI=1:numel(subjectStrs)
    daysDiff                        = daysAcrossTasks.(subjectStrs{subjectI}).daysDiff; 
    tasks_thisSubject               = daysAcrossTasks.(subjectStrs{subjectI}).tasks_thisSubject; 
    sessions_thisSubject            = daysAcrossTasks.(subjectStrs{subjectI}).sessions_thisSubject; 

    n_sessions                      = numel(sessions_thisSubject);
    
    for arrayI=1:numel(arrayStrs)
        topo_corrs                  = zeros(n_sessions, n_sessions); 
        ODR_task_corrs              = [];
        ODR_task_days               = []; 
        KM_task_corrs               = [];
        KM_task_days                = []; 
        AL_task_corrs               = [];
        AL_task_days                = []; 
        between_task_corrs          = []; 
        between_task_days           = []; 

        for sessI = 1:(n_sessions-1)
            for sessJ = (sessI+1):n_sessions
                signal_types        = {'whole', 'task', 'residuals'};
                typeI               = find(strcmp(signal_types, signalType)); 
                
                topo_1              = output_simmats.(tasks_thisSubject{sessI}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sessions_thisSubject{sessI}))(typeI).signal_corrmat;
                topo_2              = output_simmats.(tasks_thisSubject{sessJ}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sessions_thisSubject{sessJ}))(typeI).signal_corrmat;

                topo_1              = sqmat2vec(topo_1);
                topo_2              = sqmat2vec(topo_2);

                topo_corrs(sessI, sessJ) = corr(topo_1, topo_2, 'type', 'Pearson', 'rows', 'complete'); 

                if abs(daysDiff(sessI, sessJ))<=20
                    if strcmp(tasks_thisSubject{sessI}, tasks_thisSubject{sessJ})
                        eval(sprintf('%s_task_corrs = [%s_task_corrs, topo_corrs(sessI, sessJ)];', tasks_thisSubject{sessI}, tasks_thisSubject{sessI})); 
                        eval(sprintf('%s_task_days = [%s_task_days, abs(daysDiff(sessI, sessJ))];', tasks_thisSubject{sessI}, tasks_thisSubject{sessI}));                        
                    else
                        between_task_corrs  = [between_task_corrs, topo_corrs(sessI, sessJ)]; 
                        between_task_days   = [between_task_days, abs(daysDiff(sessI, sessJ))];
                    end
                end
            end % sessJ 
        end % sessI

        subplot(nHors, nVers, currSubplotI);
        ODR_color                           = [0.9290 0.6940 0.1250];
        KM_color                            = [0.4660 0.6740 0.1880];
        AL_color                            = [0.4940 0.1840 0.5560];

        between_color                       = str2rgb('cyan'); 

        hold on;
        
        if ~isempty(ODR_task_days) && ~strcmp(subjectStrs{subjectI}, 'Buzz')
            scatter(ODR_task_days, ODR_task_corrs, [], ODR_color, 'filled'); 
        end

        if ~isempty(KM_task_days)
            scatter(KM_task_days, KM_task_corrs, [], KM_color, 'filled'); 
        end

        if ~isempty(AL_task_days) && ~strcmp(subjectStrs{subjectI}, 'Theo')
            scatter(AL_task_days, AL_task_corrs, [], AL_color, 'filled'); 
        end

        scatter(between_task_days, between_task_corrs, [], between_color, 'filled');
        title(sprintf('%s %s', subjectStrs{subjectI}, arrayStrs{arrayI})); 
        xlabel('days');
        ylabel('corr');
        xlim([0, 20]);
        ylim([-0.1, 1]); 
        box off; 

        currSubplotI                        = currSubplotI + 1; 
    end % arrayI
end % subjectI 

pageHeadings                                = [];
pageHeadings{1}                             = sprintf('%s topo corrs across days', signalType);
addHeadingAndPrint(pageHeadings, PS_results, figI);

save(MAT_output, 'output', '-v7.3');
close all;

end % START_R2_topo_acrossDays
