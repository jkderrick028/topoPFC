function START_R4_sim_stripes
% 1.    simulate underlying structural maps (stripes) with varying widths,
% 0.1:0.1:2;
% 2.    downsample the structural maps to electrode array resolution
% 3.    compute spatial ACF
% 
% last modified: 2024.08.14

import spikes.*;
import utils_dx.*;
import moranI.*;

close all;

projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'topography';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

output                              = [];
MAT_output                          = fullfile(resultsPath, sprintf('%s.mat', currfilename)); 

figI_maps                           = 10; 
nHors                               = 3;
nVers                               = 2; 
PS_maps                             = fullfile(resultsPath, sprintf('%s.ps', currfilename)); 
if exist(PS_maps, 'file')
    system(['rm ' PS_maps]); 
end

nRows                               = 10;
nCols                               = 10; 
nChannelsTotal                      = nRows * nCols; 

% Example usage
arraySize = 4; % in mm
stripe_width = 0.4; % in mm
n_periods = 0.5 / (stripe_width*sqrt(2)); 

img1 = generate_stripey_image(n_periods);

imagesc(img1); axis square; colormap gray; 

end % START_R3_feature_maps



function img = generate_stripey_image(n_periods)
    fx          = 1 / n_periods; % 1 / period in x direction
    fy          = 1 / n_periods; % 1 / period in y direction
    Nx          = 400; % image dimension in x direction
    Ny          = 400; % image dimension in y direction
    [xi, yi]    = ndgrid(0:0.01:4, 0:0.01:4);
    img         = sin(2 * pi * (fx * xi  + fy * yi)) > 0;
    imagesc(img); axis square; colormap gray; 
    img         = img(1:Nx, 1:Ny); 
    clf; 
    imagesc(img); axis square; colormap gray; 
end

