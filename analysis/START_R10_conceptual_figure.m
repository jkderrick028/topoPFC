function START_R10_conceptual_figure
% response manifolds for 3 cells
% 
% last modified: 2024.09.24


import mds.*;
import utils_dx.*;
import topography.*;

close all;

projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'topography';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

output                              = [];
MAT_output                          = fullfile(resultsPath, sprintf('%s.mat', currfilename)); 

task_colours                        = {
   [0.9290 0.6940 0.1250], ...  % ODR, yellow
   [0.4660 0.6740 0.1880], ...  % VWM, green
   [0.4940 0.1840 0.5560]       % CDM, purple
};

[X1, X2] = meshgrid(-3:0.2:3); 

% z1 = 3 * (1-X1).^2 .* exp(-X1.^2-(X2+1).^2) - 10*(X1/5 - X1.^3 - X2.^5)
% .* exp(-X1.^2-X2.^2) - 1/3*exp(-(X1+1).^2-X2.^2); % original definition
% z1 = 3 * (1-X1).^2 .* exp(-X1.^2-(X2+1).^2) - 10*(- X1.^3 - X2.^5) .* exp(-X1.^2-X2.^2) - 1/3*exp(-(X1+1).^2-X2.^2); 
% z1 = exp(-(X1-1).^2-(X2+1).^2) + 2 * exp((-X1.^2-(X2-1).^2)/1.2) - 1.5*exp(-(X1+1).^2-X2.^2); 
z1 = 0.8 * exp((-(X1+0.5).^2-(X2-0.5).^2)/1.2) - 0.5*exp(-(X1-1.2).^2-(X2+1.2).^2); 

z2 = 3 * (1-X1).^2 .* exp(-X1.^2-(X2).^2) - 10*(X1/5 - X1.^3 - X2.^5) .* exp(-X1.^2-X2.^2) - 1/3*exp(-(X1+1).^2-X2.^2); 
z3 = 2 * (1-X1).^2 .* exp(-X1.^2-(X2).^2) - 4*(X1/5 - X1.^3 - X2.^5) .* exp(-X1.^2-X2.^2) - 1/3*exp(-(X1+1).^2-X2.^2); 


tuningProfiles_task1 = [];
tuningProfiles_task2 = [];
tuningProfiles_task3 = [];

figI_response = 10;
figure(figI_response); clf(figI_response); 

%% cell 1
surf(X1,X2,z1, 'EdgeColor', 'none'); 
colormap bone; 
box off;
set(gca,'XTick',[]);
set(gca,'YTick',[]);
set(gca,'ZTick',[]);

hold on; 
%% cell 1, task 1
select_1 = 16:3:28; 
select_2 = 13:3:23;
x_task1 = X1(select_1, select_2);
y_task1 = X2(select_1, select_2);
z_task1 = z1(select_1, select_2); 
tuningProfiles_task1 = [tuningProfiles_task1; reshape(z_task1, 1, [])]; 

% mesh(x_task1, y_task1, z_task1, 'EdgeColor', task_colours{1}, 'FaceColor', 'none', 'LineWidth', 1.5); 
% mesh(X1(select_1(1):select_1(end), select_2(1):select_2(end)), X2(select_1(1):select_1(end), select_2(1):select_2(end)), z1(select_1(1):select_1(end), select_2(1):select_2(end)), 'EdgeColor', task_colours{1}, 'FaceColor', 'none', 'LineWidth', 1); 
scatter3(x_task1, y_task1, z_task1, 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', task_colours{1}, 'SizeData', 100);

%% cell 1, task 2
select_1 = 9:3:20; 
select_2 = 15:3:26; 
x_task2 = X1(select_1, select_2);
y_task2 = X2(select_1, select_2);
z_task2 = z1(select_1, select_2);
tuningProfiles_task2 = [tuningProfiles_task2; reshape(z_task2, 1, [])]; 

% mesh(x_task2, y_task2, z_task2, 'EdgeColor', task_colours{2}, 'FaceColor', 'none', 'LineWidth', 1.5); 
scatter3(x_task2, y_task2, z_task2, 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', task_colours{2}, 'SizeData', 100);

%% cell 1, task 3
select_1 = 6:3:16; 
select_2 = 8:3:20; 
x_task3 = X1(select_1, select_2);
y_task3 = X2(select_1, select_2);
z_task3 = z1(select_1, select_2); 
tuningProfiles_task3 = [tuningProfiles_task3; reshape(z_task3, 1, [])]; 

% mesh(x_task3, y_task3, z_task3, 'EdgeColor', task_colours{3}, 'FaceColor', 'none', 'LineWidth', 1.5); 
scatter3(x_task3, y_task3, z_task3, 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', task_colours{3}, 'SizeData', 100);

hold off; 


figure(figI_response); clf(figI_response); 
%% cell 2
surf(X1,X2,z2, 'EdgeColor', 'none'); 
colormap bone; 
box off;
set(gca,'XTick',[]);
set(gca,'YTick',[]);
set(gca,'ZTick',[]);

hold on; 

%% cell 2, task 1
select_1 = 16:3:28; 
select_2 = 13:3:23;
x_task1 = X1(select_1, select_2);
y_task1 = X2(select_1, select_2);
z_task1 = z2(select_1, select_2);
tuningProfiles_task1 = [tuningProfiles_task1; reshape(z_task1, 1, [])]; 

% mesh(x_task1, y_task1, z_task1, 'EdgeColor', task_colours{1}, 'FaceColor', 'none', 'LineWidth', 1.5); 
scatter3(x_task1, y_task1, z_task1, 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', task_colours{1}, 'SizeData', 100);

%% cell 2, task 2
select_1 = 9:3:20; 
select_2 = 15:3:26; 
x_task2 = X1(select_1, select_2);
y_task2 = X2(select_1, select_2);
z_task2 = z2(select_1, select_2); 
tuningProfiles_task2 = [tuningProfiles_task2; reshape(z_task2, 1, [])]; 

% mesh(x_task2, y_task2, z_task2, 'EdgeColor', task_colours{2}, 'FaceColor', 'none', 'LineWidth', 1.5); 
scatter3(x_task2, y_task2, z_task2, 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', task_colours{2}, 'SizeData', 100);

%% cell 2, task 3
% select_1 = 6:3:16; 
% select_2 = 8:3:17;
select_1 = 6:3:16; 
select_2 = 8:3:20; 
x_task3 = X1(select_1, select_2);
y_task3 = X2(select_1, select_2);
z_task3 = z2(select_1, select_2); 
tuningProfiles_task3 = [tuningProfiles_task3; reshape(z_task3, 1, [])]; 

% mesh(x_task3, y_task3, z_task3, 'EdgeColor', task_colours{3}, 'FaceColor', 'none', 'LineWidth', 1.5); 
scatter3(x_task3, y_task3, z_task3, 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', task_colours{3}, 'SizeData', 100);

hold off; 


figure(figI_response); clf(figI_response); 

%% cell 3
surf(X1,X2,z3, 'EdgeColor', 'none'); 
colormap bone; 
box off;
set(gca,'XTick',[]);
set(gca,'YTick',[]);
set(gca,'ZTick',[]);

hold on; 

%% cell 3, task 1
select_1 = 16:3:28; 
select_2 = 13:3:23;
x_task1 = X1(select_1, select_2);
y_task1 = X2(select_1, select_2);
z_task1 = z3(select_1, select_2);
tuningProfiles_task1 = [tuningProfiles_task1; reshape(z_task1, 1, [])]; 

% mesh(x_task1, y_task1, z_task1, 'EdgeColor', task_colours{1}, 'FaceColor', 'none', 'LineWidth', 1.5); 
scatter3(x_task1, y_task1, z_task1, 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', task_colours{1}, 'SizeData', 100);

%% cell 3, task 2
select_1 = 9:3:20; 
select_2 = 15:3:26;
x_task2 = X1(select_1, select_2);
y_task2 = X2(select_1, select_2);
z_task2 = z3(select_1, select_2); 
tuningProfiles_task2 = [tuningProfiles_task2; reshape(z_task2, 1, [])]; 

% mesh(x_task2, y_task2, z_task2, 'EdgeColor', task_colours{2}, 'FaceColor', 'none', 'LineWidth', 1.5); 
scatter3(x_task2, y_task2, z_task2, 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', task_colours{2}, 'SizeData', 100);

%% cell 3, task 3
% select_1 = 6:3:16; 
% select_2 = 8:3:17; 
select_1 = 6:3:16; 
select_2 = 8:3:20; 
x_task3 = X1(select_1, select_2);
y_task3 = X2(select_1, select_2);
z_task3 = z3(select_1, select_2); 
tuningProfiles_task3 = [tuningProfiles_task3; reshape(z_task3, 1, [])]; 

% mesh(x_task3, y_task3, z_task3, 'EdgeColor', task_colours{3}, 'FaceColor', 'none', 'LineWidth', 1.5); 
scatter3(x_task3, y_task3, z_task3, 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', task_colours{3}, 'SizeData', 100);

hold off; 

%% re-arange tuning profiles before plotting, so that they look better
tuningProfiles_task1 = tuningProfiles_task1(:, [16, 20, 19, 18, 17, 15, 14, 13, 12, 7, 2, 1, 3, 6, 8, 4, 9, 11, 5, 10]); 
tuningProfiles_task2 = tuningProfiles_task2(:, [2, 1, 6, 5, 10, 9, 14, 13, 15, 16, 3, 4, 8, 7, 12, 11]); 
tuningProfiles_task3 = tuningProfiles_task3(:, [18, 19, 13, 14, 9, 10, 5, 6, 1, 2, 3, 7, 4, 11, 16, 8, 12, 16, 20, 15]); 

PS_results = fullfile(resultsPath, 'output.ps'); 
if exist(PS_results, 'file')
    system(['rm ' PS_results]);
end

figure(figI_response); clf(figI_response);
nHors               = 3;
nVers               = 3;
currsubplotI        = 1; 

figI_simmat         = 11; 
for taskI=1:3
    eval(sprintf('tuning_profile = tuningProfiles_task%d;', taskI)); 
    for cellI=1:3
        figure(figI_response); 
        subplot(nHors, nVers, currsubplotI);
        hold on; 
        scatter(1:numel(tuning_profile(cellI, :)), tuning_profile(cellI, :), 'filled', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', task_colours{taskI}); 
        plot(tuning_profile(cellI, :), 'LineWidth', 0.5, 'Color', task_colours{taskI}); 
        box off;
        axis off; 
        title(sprintf('task %d, cell %d', taskI, cellI)); 
        hold off;
        currsubplotI= currsubplotI + 1;
    end % cellI

    corrmat         = corr(tuning_profile', 'type', 'Pearson'); 
    figure(figI_simmat);
    subplot(3, 1, taskI); 
    visualizeCorrMat(corrmat, 'axisLabels', 'cells', 'YDir_normal', 0);      
end % taskI
pageHeading         = [];
pageHeading{1}      = 'simulated tuning profiles'; 
addHeadingAndPrint(pageHeading, PS_results, figI_response); 

pageHeading         = [];
pageHeading{1}      = 'tuning corrmats'; 
addHeadingAndPrint(pageHeading, PS_results, figI_simmat); 

close all;

end % function START_R10_conceptual_figure
