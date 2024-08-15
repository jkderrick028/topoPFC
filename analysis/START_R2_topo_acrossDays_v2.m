function START_R3_topo_acrossDays(varargin)
% This script focuses on discontinuity. 
% 
% last modified: 2024.07.31

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

for subjectI=1:numel(subjectStrs)    
    daysDiff                        = daysAcrossTasks.(subjectStrs{subjectI}).daysDiff; 
    tasks_thisSubject               = daysAcrossTasks.(subjectStrs{subjectI}).tasks_thisSubject; 
    sessions_thisSubject            = daysAcrossTasks.(subjectStrs{subjectI}).sessions_thisSubject; 

    output.(subjectStrs{subjectI}).daysDiff             = daysDiff; 
    output.(subjectStrs{subjectI}).tasks_thisSubject    = tasks_thisSubject; 
    output.(subjectStrs{subjectI}).sessions_thisSubject = sessions_thisSubject; 


    n_sessions                      = numel(sessions_thisSubject);
    
    for arrayI=1:numel(arrayStrs)
        topo_corrs                  = zeros(n_sessions, n_sessions); 
        
        for sessI = 1:(n_sessions-1)
            for sessJ = (sessI+1):n_sessions
                signal_types        = {'whole', 'task', 'residuals'};
                typeI               = find(strcmp(signal_types, signalType)); 
                
                topo_1              = output_simmats.(tasks_thisSubject{sessI}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sessions_thisSubject{sessI}))(typeI).signal_corrmat;
                topo_2              = output_simmats.(tasks_thisSubject{sessJ}).(subjectStrs{subjectI}).(arrayStrs{arrayI}).(sprintf('sess_%s', sessions_thisSubject{sessJ}))(typeI).signal_corrmat;

                topo_1              = sqmat2vec(topo_1);
                topo_2              = sqmat2vec(topo_2);

                topo_corrs(sessI, sessJ) = corr(topo_1, topo_2, 'type', 'Pearson', 'rows', 'complete');
            end % sessJ 
        end % sessI
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).topo_corrs = topo_corrs; 
    end % arrayI
end % subjectI 

PS_results                          = fullfile(resultsPath, sprintf('%s_%s.ps', currfilename, signalType));
if exist(PS_results, 'file')
    system(['rm ' PS_results]); 
end

figI                                = 10; 
figure(figI); clf(figI); 
nHors                               = numel(subjectStrs);
nVers                               = numel(arrayStrs);
currSubplotI                        = 1;

% for monkey B, KM-KM -> KM-AL
for arrayI = 1:numel(arrayStrs)
    corrs       = output.Buzz.(arrayStrs{arrayI}).topo_corrs(5, 6:end);
    tasks       = output.Buzz.tasks_thisSubject(5:end);
    daysDiff    = abs(output.Buzz.daysDiff(5, 6:end));
    sessions    = output.Buzz.sessions_thisSubject(5:end);

    taskPairs = {};
    for sessJ=2:numel(sessions)
        taskPairs{sessJ-1} = sprintf('%s_%s', tasks{1}, tasks{sessJ});
    end % sessJ
    keepInds    = find(daysDiff <= 20);
    corrs       = corrs(keepInds);
    taskPairs   = taskPairs(keepInds); 
    daysDiff    = daysDiff(keepInds);

    subplot(nHors, nVers, currSubplotI);
    % within-task: blue
    % between-task: cyan
    hold on; 
    for pairI=1:numel(taskPairs)
        if strcmp(taskPairs{pairI}, 'KM_KM') || strcmp(taskPairs{pairI}, 'AL_AL')
            scatter(daysDiff(pairI), corrs(pairI), [], str2rgb('toronto_blue'), 'filled'); 
        else
            scatter(daysDiff(pairI), corrs(pairI), [], str2rgb('cyan'), 'filled');
        end
        % text(daysDiff(pairI), corrs(pairI), strrep(taskPairs{pairI}, '_', '\_')); 
    end % pairI
    title(sprintf('Buzz %s', arrayStrs{arrayI})); 
    xlabel('days');
    ylabel('corr');
    xlim([0, 20]);
    ylim([-0.1, 1]);
    box off; 
    currSubplotI = currSubplotI + 1; 
end % arrayI 

% for monkey T, KM-KM -> KM-ODR
for arrayI = 1:numel(arrayStrs)
    % corrs       = output.Theo.(arrayStrs{arrayI}).topo_corrs(1, 2:11);
    % tasks       = output.Theo.tasks_thisSubject(1:11);
    % daysDiff    = abs(output.Theo.daysDiff(1, 2:11));
    % sessions    = output.Theo.sessions_thisSubject(1:11);

    corrs       = output.Theo.(arrayStrs{arrayI}).topo_corrs + output.Theo.(arrayStrs{arrayI}).topo_corrs';
    corrs       = corrs(11, 1:10);
    tasks       = output.Theo.tasks_thisSubject(1:11);
    tasks       = [tasks{11}; tasks(1:10)]; 
    daysDiff    = abs(output.Theo.daysDiff(11, 1:10));
    sessions    = output.Theo.sessions_thisSubject(1:11);
    sessions    = [sessions{11}; sessions(1:10)]; 

    taskPairs = {};
    for sessJ=2:numel(sessions)
        taskPairs{sessJ-1} = sprintf('%s_%s', tasks{1}, tasks{sessJ});
    end % sessJ
    keepInds    = find(daysDiff <= 20);
    corrs       = corrs(keepInds);
    taskPairs   = taskPairs(keepInds); 
    daysDiff    = daysDiff(keepInds);

    subplot(nHors, nVers, currSubplotI);
    % within-task: blue
    % between-task: cyan
    hold on; 
    for pairI=1:numel(taskPairs)
        if strcmp(taskPairs{pairI}, 'KM_KM')
            scatter(daysDiff(pairI), corrs(pairI), [], str2rgb('toronto_blue'), 'filled'); 
        else
            scatter(daysDiff(pairI), corrs(pairI), [], str2rgb('cyan'), 'filled');
        end
        % text(daysDiff(pairI), corrs(pairI), strrep(taskPairs{pairI}, '_', '\_')); 
    end % pairI
    title(sprintf('Theo %s', arrayStrs{arrayI})); 
    xlabel('days');
    ylabel('corr');
    xlim([0, 20]);
    ylim([-0.1, 1]);
    box off; 
    currSubplotI = currSubplotI + 1; 
end % arrayI 

pageHeadings                                = [];
pageHeadings{1}                             = sprintf('%s topo corrs across days', signalType);
addHeadingAndPrint(pageHeadings, PS_results, figI);

save(MAT_output, 'output', '-v7.3');
close all;

end % START_R3_topo_acrossDays
