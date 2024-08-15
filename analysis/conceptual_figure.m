function conceptual_figure
% response manifolds for 2 cells
% 
% last modified: 2024.08.08


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


rng('default');

% generating response manifold for cell 1
% x1 = 0:0.5:10; 
% x2 = 0:0.5:10; 
% fr1 = zeros(numel(x1), numel(x2)); 

% mu = [2, 3]; 
% sigma = [1, 0.5; 0.5, 1.5]; 
% [X1,X2] = meshgrid(x1,x2);
% X = [X1(:) X2(:)];
% y = mvnpdf(X,mu,sigma);
% y = reshape(y,length(x2),length(x1));
% fr1 = fr1 + 0.8 * y; 
% 
% mu = [7, 8]; 
% sigma = [2, 1.5; 1.5, 1.5]; 
% [X1,X2] = meshgrid(x1,x2);
% X = [X1(:) X2(:)];
% y = mvnpdf(X,mu,sigma);
% y = reshape(y,length(x2),length(x1));
% fr1 = fr1 + 1.5 * y; 
% 
% mu = [3, 6]; 
% sigma = [0.5, 0.8; 0.8, 1.5]; 
% [X1,X2] = meshgrid(x1,x2);
% X = [X1(:) X2(:)];
% y = mvnpdf(X,mu,sigma);
% y = reshape(y,length(x2),length(x1));
% fr1 = fr1 + 2 * y; 
% 
% mu = [7, 1]; 
% sigma = [1.5, 0.5; 0.5, 0.5]; 
% [X1,X2] = meshgrid(x1,x2);
% X = [X1(:) X2(:)];
% y = mvnpdf(X,mu,sigma);
% y = reshape(y,length(x2),length(x1));
% fr1 = fr1 + 1.2 * y; 
% 
% mu = [8, 4]; 
% sigma = [0.8, 0.5; 0.5, 1.6]; 
% [X1,X2] = meshgrid(x1,x2);
% X = [X1(:) X2(:)];
% y = mvnpdf(X,mu,sigma);
% y = reshape(y,length(x2),length(x1));
% fr1 = fr1 + 1.8 * y; 
% 
% mu = [4, 5]; 
% sigma = [2, 0.5; 0.5, 0.8]; 
% [X1,X2] = meshgrid(x1,x2);
% X = [X1(:) X2(:)];
% y = mvnpdf(X,mu,sigma);
% y = reshape(y,length(x2),length(x1));
% fr1 = fr1 + 1.8 * y; 
% 
% y = randn(numel(x1), numel(x2)); 
% fr1 = fr1 + 0.05 * y; 


x_ori = -5:0.5:5; 
y_ori = -5:0.5:5; 
[X,Y] = meshgrid(-5:.5:5);
fr1 = Y.*sin(X) - X.*cos(Y);
task1_sampling_range = [2, 6; 10, 15];
task2_sampling_range = [3, 7; 2, 6];
task3_sampling_range = [12, 16; 3, 6];

% fr1 = fr1 / sum(fr1, 'all'); 

figure(1); 
surf(fr1, 'FaceAlpha', 0.5, 'EdgeColor', 'none'); 
colormap bone;
box off; 
set(gca,'XTick',[]);
set(gca,'YTick',[]);
set(gca,'ZTick',[]);
x1 = x_ori(task1_sampling_range(1, 1));
x2 = x_ori(task1_sampling_range(1, 2));
y1 = x_ori(task1_sampling_range(2, 1));
y2 = x_ori(task1_sampling_range(2, 2));
x_task1 = [x1, x2, x2, x1, x1];
y_task1 = [y1, y2, y2, y1, y1]; 
color_task1 = [0, 1, 0];
hold on;
% plot3(x_task1, y_task1, zeros(size(x_task1)), 'Color', color_task1, 'LineWidth', 2); 

figure(2); 
fr2 = Y.*sin(X) - X.*cos(0.5*Y);
surf(fr2, 'FaceAlpha', 0.5, 'EdgeColor', 'none'); 
colormap bone;
box off; 
set(gca,'XTick',[]);
set(gca,'YTick',[]);
set(gca,'ZTick',[]);


% tuning_cell1_task1 = reshape(fr1(task1_sampling_range(1, 1):task1_sampling_range(1, 2), task1_sampling_range(2, 1): task1_sampling_range(2, 2)), [], 1); 
% tuning_cell2_task1 = reshape(fr2(task1_sampling_range(1, 1):task1_sampling_range(1, 2), task1_sampling_range(2, 1): task1_sampling_range(2, 2)), [], 1); 
% 
% tuning_cell1_task2 = reshape(fr1(task2_sampling_range(1, 1):task2_sampling_range(1, 2), task2_sampling_range(2, 1): task2_sampling_range(2, 2)), [], 1); 
% tuning_cell2_task2 = reshape(fr2(task2_sampling_range(1, 1):task2_sampling_range(1, 2), task2_sampling_range(2, 1): task2_sampling_range(2, 2)), [], 1); 
% 
% tuning_cell1_task3 = reshape(fr1(task3_sampling_range(1, 1):task3_sampling_range(1, 2), task3_sampling_range(2, 1): task3_sampling_range(2, 2)), [], 1); 
% tuning_cell2_task3 = reshape(fr2(task3_sampling_range(1, 1):task3_sampling_range(1, 2), task3_sampling_range(2, 1): task3_sampling_range(2, 2)), [], 1); 


% generating tuning profiles
figure(3); 

% task 1
x = -4:0.5:3; 
tuning_cell1_task1 = sin(x) + cos(x); 
tuning_cell2_task1 = sin(x) + 1.01 * cos(2*x);
tuning_cell3_task1 = sin(x + 0.5) + 1.1 * cos(x); 
tuning_cell4_task1 = sin(x - 0.5) + 1.1 * cos(x); 

% hold on; 
plot(tuning_cell1_task1, 'LineWidth', 3, 'Color', 'k'); 
plot(tuning_cell2_task1, 'LineWidth', 3, 'Color', 'k');
% plot(tuning_cell3_task1, 'LineWidth', 3, 'Color', 'k');
corr(tuning_cell1_task1', tuning_cell2_task1')

% task 2
x = -3:0.5:4;
tuning_cell1_task2 = sin(2 * x) + cos(x); 
tuning_cell2_task2 = 1.1 * sin(2 * x) + cos(x + 0.5);
tuning_cell3_task2 = sin(2 * x + 0.8) + cos(x); 
tuning_cell4_task2 = sin(2 * x - 0.4) + cos(x + 0.2); 

clf(3); 
% hold on;
plot(tuning_cell1_task2, 'LineWidth', 3, 'Color', 'k'); 
plot(tuning_cell2_task2, 'LineWidth', 3, 'Color', 'k');
corr(tuning_cell1_task2', tuning_cell2_task2')

% task 3
x = -5:0.5:2;
tuning_cell1_task3 = sin(3 * x) + cos(1.5 * x); 
tuning_cell2_task3 = 1.1 * sin(3 * x) + cos(1.5 * x + 0.5);
tuning_cell3_task3 = 1.1 * sin(3 * x - 0.8) + cos(1.5 * x + 0.2);
tuning_cell4_task3 = 1.1 * sin(3 * x + 0.6) + 1.1 * cos(1.5 * x + 0.5);

clf(3); 
% hold on;
plot(tuning_cell1_task3, 'LineWidth', 3, 'Color', 'k'); 
plot(tuning_cell2_task3, 'LineWidth', 3, 'Color', 'k');
corr(tuning_cell1_task3', tuning_cell2_task3')

% compute similarity matrices
% task1
tuningProfiles  = [tuning_cell1_task1; tuning_cell2_task1; tuning_cell3_task1; tuning_cell4_task1]; 
simmat1         = corr(tuningProfiles', 'type', 'Pearson', 'rows', 'complete');

tuningProfiles  = [tuning_cell1_task2; tuning_cell2_task2; tuning_cell3_task2; tuning_cell4_task2]; 
simmat2         = corr(tuningProfiles', 'type', 'Pearson', 'rows', 'complete'); 

tuningProfiles  = [tuning_cell1_task3; tuning_cell2_task3; tuning_cell3_task3; tuning_cell4_task3]; 
simmat3         = corr(tuningProfiles', 'type', 'Pearson', 'rows', 'complete'); 

figI            = 4;
figure(figI); clf(figI); 

nHors           = 2;
nVers           = 2;

PS_corrmats     = fullfile(resultsPath, sprintf('corrmats.ps'));
if exist(PS_corrmats, 'file')
    system(['rm ' PS_corrmats]); 
end

subplot(nHors, nVers, 1);
visualizeCorrMat(simmat1, 'axisLabels', 'cells'); 
title('task 1');

subplot(nHors, nVers, 2);
visualizeCorrMat(simmat2, 'axisLabels', 'cells'); 
title('task 2');

subplot(nHors, nVers, 3);
visualizeCorrMat(simmat3, 'axisLabels', 'cells'); 
title('task 3');

pageHeading     = 'conceptual figure simmats'; 

addHeadingAndPrint(pageHeading, PS_corrmats, figI); 

% mds plots
PS_mds     = fullfile(resultsPath, sprintf('mds.ps'));
if exist(PS_mds, 'file')
    system(['rm ' PS_mds]); 
end

% task 1
figure(figI); clf(figI); 
[colours_rgb, unexplainedVariance, coords_2D] = mds_channels(simmat1, 1:4, 2, 2); 

pageHeading = 'mds task 1'; 
addHeadingAndPrint(pageHeading, PS_mds, figI); 

% task 2
figure(figI); clf(figI); 
[colours_rgb, unexplainedVariance, coords_2D] = mds_channels(simmat2, 1:4, 2, 2); 

pageHeading = 'mds task 2'; 
addHeadingAndPrint(pageHeading, PS_mds, figI); 

% task 3
figure(figI); clf(figI); 
[colours_rgb, unexplainedVariance, coords_2D] = mds_channels(simmat3, 1:4, 2, 2); 

pageHeading = 'mds task 3'; 
addHeadingAndPrint(pageHeading, PS_mds, figI); 

close all;

end % function conceptual_figure
