function START_R2_topo_acrossDays_v4(varargin)
% build a regression model - the correlation of topography as a function of
% within-/between-task (X1 indicator variables) and days in between
% (X2, continuous variable). More specifically, if within a task, X1=1; if
% between tasks, X1=0. 
% 
% We will compute the adjusted R2 for when including X1 only and when
% including both X1 and X2.
% 
% We will estimate the amount of variance explained by those two competing
% models using one session as a reference, and compute the correlation of
% topography with all the other sessions both within and between tasks.
% Essentially we will build regression models for each row of the
% correlation matrix. 
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

        % only keep sessions in interested tasks
        keepInds    = find(ismember(tasks, interested_tasks));
        corrs       = corrs(keepInds, keepInds);
        tasks       = tasks(keepInds);
        daysDiff    = daysDiff(keepInds, keepInds); 
        sessions    = sessions(keepInds);                 
        n_sessions  = numel(sessions); 
        
        figure(figI); clf(figI); 
        nVers                               = 2;
        nHors                               = ceil(n_sessions / nVers); 
        currSubplotI                        = 1;

        var_contributions                   = [];

        for sessI = 1:n_sessions
            % X1=1, if within a task
            % X1=0, if between tasks
            X1          = [];
            X2          = [];   % days in between 
            Y           = [];   % correlations we are trying to predict

            taskPairs   = {};
            sessPairs   = {};

            for sessJ = 1:n_sessions
                fprintf('%s %s %s %s\n', tasks{sessI}, sessions{sessI}, tasks{sessJ}, sessions{sessJ}); 
                if daysDiff(sessI, sessJ) > 20 || (sessI == sessJ)
                    continue; 
                end
               
                if strcmp(tasks{sessI}, tasks{sessJ})             
                    X1(end+1)   = 1;             
                else
                    X1(end+1)   = 0;
                end                
                X2(end+1)       = daysDiff(sessI, sessJ); 
                Y(end+1)        = corrs(sessI, sessJ); 
                taskPairs{end+1}= sprintf('%s_%s', tasks{sessI}, tasks{sessJ}); 
                sessPairs{end+1}= sprintf('%s_%s', sessions{sessI}, sessions{sessJ}); 
            end % sessJ

            n       = numel(Y);
            Y       = reshape(Y, n, 1);
            X1      = reshape(X1, n, 1);
            X2      = reshape(X2, n, 1);

            if all(X1 == 1) || all(X1 == 0)
                continue; 
            end
    
            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression(sessI).n     = n;
            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression(sessI).Y     = Y;
            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression(sessI).X1    = X1;
            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression(sessI).X2    = X2;

            % regression model for including only X1
            % yi = b0 + b1 * x1 + e
            X           = [ones(n, 1), X1];
            b           = compute_OLS_coeff(X, Y);
            Y_hat       = X * b;
            R2_adj_R    = compute_R2_adj(Y_hat, Y, size(X, 2)); 
            R2_R        = compute_R2(Y_hat, Y); 
    
            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression(sessI).Reduced.b      = b;
            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression(sessI).Reduced.R2_adj = R2_adj_R;
            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression(sessI).Reduced.R2     = R2_R;

            % regression model for including X1 and X2
            % yi = b0 + b1 * x1 + b2 * x2 + e
            X           = [ones(n, 1), X1, X2];
            b           = compute_OLS_coeff(X, Y);
            Y_hat       = X * b;
            R2_adj_F    = compute_R2_adj(Y_hat, Y, size(X, 2));
            R2_F        = compute_R2(Y_hat, Y); 
    
            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression(sessI).Full.b         = b;
            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression(sessI).Full.R2_adj    = R2_adj_F;
            output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).regression(sessI).Full.R2        = R2_F;

            var_contributions = [var_contributions; [R2_R, R2_F - R2_R]];

            subplot(nHors, nVers, currSubplotI);
            % between-task: cyan
            hold on; 
            % within tasks
            selectedInds = find(strcmp(taskPairs, sprintf('%s_%s', interested_tasks{1}, interested_tasks{1})) | strcmp(taskPairs, sprintf('%s_%s', interested_tasks{2}, interested_tasks{2})));
            scatter(X2(selectedInds), Y(selectedInds), [], str2rgb('toronto_blue'), 'filled');
    
            % between tasks
            selectedInds = find(strcmp(taskPairs, sprintf('%s_%s', interested_tasks{1}, interested_tasks{2})) | strcmp(taskPairs, sprintf('%s_%s', interested_tasks{2}, interested_tasks{1})));
            scatter(X2(selectedInds), Y(selectedInds), [], str2rgb('cyan'), 'filled');
            
            title(sprintf('(%d) ref: %s %s', currSubplotI, tasks{sessI}, sessions{sessI})); 
            xlabel('days');
            ylabel('corr');
            xlim([0, 20]);
            ylim([-0.1, 1]);
            box off; 
            currSubplotI = currSubplotI + 1;
        end % sessI
        pageHeadings                                = [];
        pageHeadings{1}                             = sprintf('%s %s', subjectStrs{subjectI}, arrayStrs{arrayI}); 
        pageHeadings{2}                             = sprintf('%s topo corrs across days', signalType);
        addHeadingAndPrint(pageHeadings, PS_results, figI);

        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).var_contributions = var_contributions; 
    end % arrayI 
end % subjectI

save(MAT_output, 'output', '-v7.3');
close all;

end % START_R2_topo_acrossDays_v4


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
