function START_R2_topo_acrossDays_v3(varargin)
% build a regression model - the correlation of topography as a function of
% within-/between-task (X1, X2, indicator variables) and days in between
% (X3, continuous variable). More specifically, if within task1, X1=1,
% X2=0; if within task2, X1=0, X2=1; if between task1 and task2, X1=0,
% X2=0;
% 
% We will compute the adjusted R2 for when including X1, X2 only and when
% including both X1, X2 and X3.
% 
% The expectation is that the adjusted R2 when including X1, X2 and X3 will
% be not much higher or even lower than when including only X1 and X2.
% 
% last modified: 2024.08.05

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
excludedSessionStrs                 = get_excludedSessionStrs(); 
excludedSessionStrs{end+1}          = '20170614';
excludedSessionStrs{end+1}          = '20170616';

MAT_simmats                         = fullfile(projectPath, 'results', ANALYSIS, 'START_B6_topoInference_generation', 'output_simmats.mat'); 
output_simmats                      = load(MAT_simmats).output_simmats; 

MAT_daysAcrossTasks                 = fullfile(projectPath, 'results', ANALYSIS, 'START_B5_daysAcrossTasks', 'START_B5_daysAcrossTasks_output.mat'); 
daysAcrossTasks                     = load(MAT_daysAcrossTasks).output; 

PS_corrmats                         = fullfile(resultsPath, sprintf('corrmats_%s.ps', signalType)); 
if exist(PS_corrmats, 'file')
    system(['rm ' PS_corrmats]);
end

figI                                = 10; 

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
        
        for sessI = 1:n_sessions
            for sessJ = 1:n_sessions
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

        figure(figI); clf(figI);
        visualizeCorrMat(topo_corrs, 'axisLabels', 'sessions'); 
        ticklabels                  = cellfun(@(x,y) [x, '\_', y], tasks_thisSubject, sessions_thisSubject, 'UniformOutput', false); 
        xticks(1:n_sessions);
        xticklabels(ticklabels);
        yticks(1:n_sessions); 
        yticklabels(ticklabels);

        pageHeading                 = sprintf('%s %s', subjectStrs{subjectI}, arrayStrs{arrayI}); 
        addHeadingAndPrint(pageHeading, PS_corrmats, figI); 
    end % arrayI
end % subjectI 

PS_results                          = fullfile(resultsPath, sprintf('%s_%s.ps', currfilename, signalType));
if exist(PS_results, 'file')
    system(['rm ' PS_results]); 
end

figure(figI); clf(figI); 
nHors                               = numel(subjectStrs);
nVers                               = numel(arrayStrs);
currSubplotI                        = 1;

color_ODR       = [0.9290 0.6940 0.1250]; 
color_KM        = [0.4660 0.6740 0.1880];
color_AL        = [0.4940 0.1840 0.5560]; 


for subjectI = 1:numel(subjectStrs)
    if strcmp(subjectStrs{subjectI}, 'Buzz')
        interested_tasks= {'KM', 'AL'}; 
    else
        interested_tasks= {'ODR', 'KM'}; 
    end
    for arrayI = 1:numel(arrayStrs)
        corrs       = output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).topo_corrs;
        tasks       = output.(subjectStrs{subjectI}).tasks_thisSubject;
        daysDiff    = abs(output.(subjectStrs{subjectI}).daysDiff);
        sessions    = output.(subjectStrs{subjectI}).sessions_thisSubject;
    
        % X1=1, X2=0 if KM-KM; 
        % X1=0, X2=1 if AL-AL; 
        % X1=0, X2=0 if KM-AL
        X1          = [];
        X2          = [];
        X3          = [];    % days in between 
        Y           = [];    % correlations we are trying to predict 
    
        n_sessions  = numel(sessions); 
        taskPairs = {};
        for sessI = 1:(n_sessions-1)
            for sessJ = (sessI+1):n_sessions
                fprintf('%s %s %s %s\n', tasks{sessI}, sessions{sessI}, tasks{sessJ}, sessions{sessJ}); 
                if daysDiff(sessI, sessJ) > 20
                    continue; 
                end
                if ismember(sessions{sessI}, excludedSessionStrs) || ismember(sessions{sessJ}, excludedSessionStrs)
                    continue;
                end
                % if (strcmp(tasks{sessI}, 'AL') && ismember(sessions(sessI), {'20171121', '20171123'})) || (strcmp(tasks{sessJ}, 'AL') && ismember(sessions(sessJ), {'20171121', '20171123'}))
                %     continue; 
                % end
                if strcmp(tasks{sessI}, interested_tasks{1}) && strcmp(tasks{sessJ}, interested_tasks{1})                
                    X1(end+1)   = 1;
                    X2(end+1)   = 0;                 
                elseif strcmp(tasks{sessI}, interested_tasks{1}) && strcmp(tasks{sessJ}, interested_tasks{2})               
                    X1(end+1)   = 0;
                    X2(end+1)   = 0; 
                elseif strcmp(tasks{sessI}, interested_tasks{2}) && strcmp(tasks{sessJ}, interested_tasks{2})
                    X1(end+1)   = 0;
                    X2(end+1)   = 1;                
                else
                    continue; 
                end
                X3(end+1)       = daysDiff(sessI, sessJ); 
                Y(end+1)        = corrs(sessI, sessJ); 
                taskPairs{end+1}= sprintf('%s_%s', tasks{sessI}, tasks{sessJ}); 
            end % sessJ 
        end % sessI
        
        n       = numel(Y);
        Y       = reshape(Y, n, 1);
        X1      = reshape(X1, n, 1);
        X2      = reshape(X2, n, 1);
        X3      = reshape(X3, n, 1);

        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression.n     = n;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression.Y     = Y;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression.X1    = X1;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression.X2    = X2;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression.X3    = X3;
    
        % regression model for including only X1 and X2
        % yi = b0 + b1 * x1 + b2 * x2 + e
        X       = [ones(n, 1), X1, X2];
        b       = compute_OLS_coeff(X, Y);
        Y_hat   = X * b;
        R2_adj  = compute_R2_adj(Y_hat, Y, size(X, 2)); 
        R2      = compute_R2(Y_hat, Y); 

        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression.model_X12.b         = b;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression.model_X12.R2_adj    = R2_adj;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression.model_X12.R2        = R2;
    
    
        % regression model for including X1, X2 and X3
        % yi = b0 + b1 * x1 + b2 * x2 + b3 * x3 + e
        X       = [ones(n, 1), X1, X2, X3];
        b       = compute_OLS_coeff(X, Y);
        Y_hat   = X * b;
        R2_adj  = compute_R2_adj(Y_hat, Y, size(X, 2));
        R2      = compute_R2(Y_hat, Y); 

        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression.model_X123.b        = b;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression.model_X123.R2_adj   = R2_adj;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression.model_X123.R2       = R2;    


        % regression model for including only X3
        % yi = b0 + b1 * x3 + e
        X       = [ones(n, 1), X3];
        b       = compute_OLS_coeff(X, Y);
        Y_hat   = X * b;
        R2_adj  = compute_R2_adj(Y_hat, Y, size(X, 2));
        R2      = compute_R2(Y_hat, Y); 

        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression.model_X3.b        = b;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression.model_X3.R2_adj   = R2_adj;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression.model_X3.R2       = R2;    
    
        subplot(nHors, nVers, currSubplotI);
        % between-task: cyan
        hold on; 
        % within-task1
        selectedInds = find(strcmp(taskPairs, sprintf('%s_%s', interested_tasks{1}, interested_tasks{1})));
        eval(sprintf("scatter(X3(selectedInds), Y(selectedInds), [], color_%s, 'filled');", interested_tasks{1})); 
        % within-task2
        selectedInds = find(strcmp(taskPairs, sprintf('%s_%s', interested_tasks{2}, interested_tasks{2})));
        eval(sprintf("scatter(X3(selectedInds), Y(selectedInds), [], color_%s, 'filled');", interested_tasks{2}));
        % between-task1_task2
        selectedInds = find(strcmp(taskPairs, sprintf('%s_%s', interested_tasks{1}, interested_tasks{2})));
        scatter(X3(selectedInds), Y(selectedInds), [], str2rgb('cyan'), 'filled');
        
        title(sprintf('%s %s', subjectStrs{subjectI}, arrayStrs{arrayI})); 
        xlabel('days');
        ylabel('corr');
        xlim([0, 20]);
        ylim([-0.1, 1]);
        box off; 
        currSubplotI = currSubplotI + 1; 
    end % arrayI 
end % subjectI

pageHeadings                                = [];
pageHeadings{1}                             = sprintf('%s topo corrs across days', signalType);
addHeadingAndPrint(pageHeadings, PS_results, figI);

save(MAT_output, 'output', '-v7.3');
close all;

end % START_R2_topo_acrossDays_v3


function R2_adj = compute_R2_adj(y_hat, y, p)
% computing adjusted R2
% 
% y_hat, y are of shape (n, 1)
% 
% p is an integer, specifying the number of predictors in the regression
% model
% 
% last modified: 2024.08.05

n       = numel(y_hat);

SSE     = compute_SSE(y_hat, y); 
SSTO    = compute_SSTO(y); 
R2_adj  = 1 - (n-1)/(n-p)*SSE/SSTO; 

end % function compute_R2_adj

function R2 = compute_R2(y_hat, y)
% computing R2
% 
% last modified: 2024.08.05

SSE     = compute_SSE(y_hat, y); 
SSTO    = compute_SSTO(y);
R2      = 1 - SSE / SSTO; 

end % function compute_R2


function SSE = compute_SSE(y_hat, y)
% SSE: sum of squared error
% 
% y_hat and y are of shape (n, 1)
% 
% last modified: 2024.08.05

residual    = y_hat - y; 
SSE         = residual' * residual; 

end % function compute_SSE


function SSTO = compute_SSTO(y)
% y is of shape (n, 1)
% 
% last modified: 2024.08.05

y_bar       = mean(y); 
SSTO        = (y - y_bar)' * (y - y_bar); 
end % function compute_SSTO

function b = compute_OLS_coeff(X, y)
% for the function y = Xb, compute b
% 
% last modified: 2024.08.05

b           = pinv(X' * X) * X' * y; 
b           = reshape(b, [], 1);

end % function compute_OLS_coeff
