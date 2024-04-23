function START_S3_task_session_vis
% visualize the sessions in each task
% 
% last modified: 2024.04.23

import spikes.*;
import utils_dx.*;
import mds.*;

close all;

projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'supplemental';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

taskStrs                            = {'ODR', 'KM', 'AL'};
subjectStrs                         = {'Buzz', 'Theo'};
excludedSessionStrs                 = get_excludedSessionStrs(); 

% color_eachTask                      = { [0.4660 0.6740 0.1880], % green, ODR
%                                         [0 0.4470 0.7410],      % blue, KM
%                                         [0.9290 0.6940 0.1250]  % yellow, AL
%                                         }; 

color_eachTask                      = { [0.9290 0.6940 0.1250], % yellow, ODR
                                        [0.4660 0.6740 0.1880], % green, KM
                                        [0.4940 0.1840 0.5560]  % purple, AL
                                        }; 

MAT_results                         = fullfile(resultsPath, sprintf('%s_results.mat', currfilename)); 
outputs                             = []; 

PS_taskSession_vis = fullfile(resultsPath, sprintf('%s.ps', currfilename)); 
if exist(PS_taskSession_vis, 'file'), system(['rm ' PS_taskSession_vis]); end

nHors                               = 10;
nVers                               = 1; 

figI_taskSessions                   = 10; 
figure(figI_taskSessions); clf(figI_taskSessions);

for subjectI = 1:numel(subjectStrs)
    subplot(nHors, nVers, subjectI); 

    tasks                                       = {}; 
    sessions                                    = {};

    for taskI = 1:numel(taskStrs)
        [sessionStrsB, sessionStrsT]            = getSessInfo(taskStrs{taskI});

        switch subjectStrs{subjectI}
            case 'Buzz'
                sessionStrs                     = sessionStrsB; 
            case 'Theo'
                sessionStrs                     = sessionStrsT;
        end
        sessionStrs                             = setdiff(sessionStrs, excludedSessionStrs);
        sessions                                = [sessions; sessionStrs];
        tasks                                   = [tasks; repmat(taskStrs(taskI), numel(sessionStrs), 1)]; 
    end % taskI
    times                                       = datetime(datestr(datenum(sessions, 'yyyymmdd'), 'yyyy-mm-dd'));

    times_min                                   = min(times);
    times_relative                              = days(times - times_min) + 1;

    [times_relative_sorted, I]                  = sort(times_relative);
    tasks_sorted                                = tasks(I);

    times_relative_max                          = max(times_relative);
    colors                                      = ones(1, times_relative_max, 3); 
    
    for taskI = 1:numel(taskStrs)
        inds_thisTask                           = find(strcmp(tasks_sorted, taskStrs{taskI}));
        colors(1, times_relative_sorted(inds_thisTask), :) = repmat(color_eachTask{taskI}, numel(inds_thisTask), 1); 
    end % taskI

    imagesc(colors);
    xticks(20:20:times_relative_max);
    xlim([0.5, 140.5]);   
    xlabel('days');
    box off; 
    title(subjectStrs{subjectI}); 

    outputs.(subjectStrs{subjectI}).tasks       = tasks; 
    outputs.(subjectStrs{subjectI}).sessions    = sessions;
end % subjectI

pageHeadings                                    = []; 
pageHeadings{1}                                 = sprintf('sessions in each task');
addHeadingAndPrint(pageHeadings, PS_taskSession_vis, figI_taskSessions); 

save(MAT_results, 'outputs', '-v7.3');
close all;
end % START_S3_task_session_vis
