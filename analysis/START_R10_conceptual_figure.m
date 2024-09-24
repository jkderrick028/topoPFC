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


[X1, X2] = meshgrid(-3:0.2:3); 

% z1 = 3 * (1-X1).^2 .* exp(-X1.^2-(X2+1).^2) - 10*(X1/5 - X1.^3 - X2.^5)
% .* exp(-X1.^2-X2.^2) - 1/3*exp(-(X1+1).^2-X2.^2); % original definition
z1 = 3 * (1-X1).^2 .* exp(-X1.^2-(X2+1).^2) - 10*(- X1.^3 - X2.^5) .* exp(-X1.^2-X2.^2) - 1/3*exp(-(X1+1).^2-X2.^2); 
z2 = 3 * (1-X1).^2 .* exp(-X1.^2-(X2).^2) - 10*(X1/5 - X1.^3 - X2.^5) .* exp(-X1.^2-X2.^2) - 1/3*exp(-(X1+1).^2-X2.^2); 
z3 = 2 * (1-X1).^2 .* exp(-X1.^2-(X2).^2) - 4*(X1/5 - X1.^3 - X2.^5) .* exp(-X1.^2-X2.^2) - 1/3*exp(-(X1+1).^2-X2.^2); 


figI_response = 10;


figure(figI_response); clf(figI_response); 

surf(X1,X2,z1); 
colormap bone; 
box off;
set(gca,'XTick',[]);
set(gca,'YTick',[]);
set(gca,'ZTick',[]);
title('cell 1'); 



figure(figI_response); clf(figI_response); 

surf(X1,X2,z2); 
colormap bone; 
box off;
set(gca,'XTick',[]);
set(gca,'YTick',[]);
set(gca,'ZTick',[]);
title('cell 2'); 


figure(figI_response); clf(figI_response); 

surf(X1,X2,z3); 
colormap bone; 
box off;
set(gca,'XTick',[]);
set(gca,'YTick',[]);
set(gca,'ZTick',[]);
title('cell 3'); 


close all;

end % function START_R10_conceptual_figure
