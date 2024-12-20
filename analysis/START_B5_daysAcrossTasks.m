function START_B5_daysAcrossTasks
% 
% last modified: 2024.04.16

import utils_dx.*; 
import spikes.*;

close all;

projectPath                 = setProjectPath();
[currPath, currfilename, currext] = fileparts(mfilename('fullpath'));
ANALYSIS                    = 'topography';
resultsPath                 = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

subjectStrs                 = {'Buzz', 'Theo'};
taskStrs                    = {'ODR', 'KM', 'AL'};
excludedSessionStrs         = get_excludedSessionStrs(); 

% %% control analysis, removing 4 sessions for AL
% excludedSessionStrs         = [excludedSessionStrs, {'20171109', '20171110', '20171111', '20171112'}]; 
% 
% %%

output                      = []; 
MAT_output                  = fullfile(resultsPath, sprintf('%s_output.mat', currfilename));
output.excludedSessionStrs  = excludedSessionStrs; 

figI_datediff               = 10;
PS_datediff                 = fullfile(resultsPath, sprintf('%s_datediff.ps', currfilename));
if exist(PS_datediff, 'file'), system(['rm ' PS_datediff]); end

figure(figI_datediff); clf(figI_datediff); 
for subjectI=1:numel(subjectStrs)    
    output.(subjectStrs{subjectI}).sessions_thisSubject     = []; 
    output.(subjectStrs{subjectI}).tasks_thisSubject        = []; 

    for taskI=1:numel(taskStrs)
        [sessionStrsB, sessionStrsT]                        = getSessInfo(taskStrs{taskI});
        switch subjectStrs{subjectI}
            case 'Buzz'
                sessions_thisTask                           = sessionStrsB; 
            case 'Theo'
                sessions_thisTask                           = sessionStrsT; 
        end        
        sessions_thisTask                                   = setdiff(sessions_thisTask, excludedSessionStrs); 
        taskStrs_thisTask                                   = repmat(taskStrs(taskI), numel(sessions_thisTask), 1); 

        output.(subjectStrs{subjectI}).sessions_thisSubject = cat(1, output.(subjectStrs{subjectI}).sessions_thisSubject, sessions_thisTask);
        output.(subjectStrs{subjectI}).tasks_thisSubject    = cat(1, output.(subjectStrs{subjectI}).tasks_thisSubject, taskStrs_thisTask); 
    end % taskI

    times           = datetime(datestr(datenum(output.(subjectStrs{subjectI}).sessions_thisSubject, 'yyyymmdd'), 'yyyy-mm-dd')); 
    nSessionsTotal  = numel(times); 
    
    clear daysDiff; 

    for sessI=1:nSessionsTotal
        for sessJ=1:nSessionsTotal
            daysDiff(sessI, sessJ)          = times(sessI) - times(sessJ); 
        end % sessJ
    end % sessI
    daysDiff        = days(daysDiff); 
    
    ax              = subplot(numel(subjectStrs), 1, subjectI);
    cmap            = redblue(256);     
    imagesc(daysDiff, [-30, 30]); 
    colormap(cmap); 
    axis square; 
    colorbar; 
    title(subjectStrs{subjectI}); 
    xticks(1:size(daysDiff, 1));
    xticklabels(strcat(output.(subjectStrs{subjectI}).sessions_thisSubject, output.(subjectStrs{subjectI}).tasks_thisSubject));
    yticks(1:size(daysDiff, 1));
    yticklabels(strcat(output.(subjectStrs{subjectI}).sessions_thisSubject, output.(subjectStrs{subjectI}).tasks_thisSubject));
    set(gca, 'YDir', 'normal'); 

    output.(subjectStrs{subjectI}).daysDiff = daysDiff;     
end % subjectI

pageHeadings                                = [];
pageHeadings{1}                             = 'ODR, KM, AL data session diff'; 
addHeadingAndPrint(pageHeadings, PS_datediff, figI_datediff); 

save(MAT_output, 'output'); 

close all;

end % function START_B5_daysAcrossTasks
