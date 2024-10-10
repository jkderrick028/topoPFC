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
PS_maps                             = fullfile(resultsPath, sprintf('%s.ps', currfilename)); 
if exist(PS_maps, 'file')
    system(['rm ' PS_maps]); 
end

nRows                               = 10;
nCols                               = 10; 
nChannelsTotal                      = nRows * nCols; 


% Example usage
arraySize       = 4; % in mm
stripe_widths   = 0.1:0.1:2; % in mm
n_maps = numel(stripe_widths); 

nVers                               = 4; 
nHors                               = ceil(n_maps / nVers);

resolution      = 0.01; 
mapSize         = arraySize / resolution; 
maps            = ones(mapSize, mapSize, n_maps);

figure(figI_maps); clf(figI_maps); 
for mapI = 1:n_maps
    f                   = 1/stripe_widths(mapI)/2; 
    maps(:, :, mapI)    = generate_stripes(f);
    subplot(nHors, nVers, mapI); 
    imagesc(maps(:, :, mapI), [0, 1]);
    axis square; 
    colormap gray;
    title(sprintf('%.1f mm', stripe_widths(mapI))); 
end % mapI 

pageHeading = 'high res structural maps'; 
addHeadingAndPrint(pageHeading, PS_maps, figI_maps); 

% downsample each map to 10 x 10

maps_sampled    = zeros(nRows, nCols, n_maps); 
startIs         = 1:40:400; 
endIs           = startIs + 40 - 1;

figure(figI_maps); clf(figI_maps); 
for mapI = 1:n_maps
    for rowI = 1:nRows
        for colI = 1:nCols
            maps_sampled(rowI, colI, mapI) = mean(maps(startIs(rowI):endIs(rowI), startIs(colI):endIs(colI), mapI), 'all');
        end % colI 
    end % rowI
    subplot(nHors, nVers, mapI); 
    imagesc(maps_sampled(:, :, mapI), [0, 1]);
    axis square; 
    colormap gray;
    title(sprintf('%.1f mm', stripe_widths(mapI))); 
end % mapI 

pageHeading = 'low res functional maps'; 
addHeadingAndPrint(pageHeading, PS_maps, figI_maps); 
 

% run spatial ACF
figure(figI_maps); clf(figI_maps); 

for mapI = 1:n_maps
    tuning_profile = reshape(maps_sampled(:, :, mapI), [], 1);
    subplot(nHors, nVers, mapI);
    output(mapI).acf = donutACF_channels(tuning_profile, []); 
    title(sprintf('%.1f mm', stripe_widths(mapI))); 
    box off;
end % mapI 

pageHeading = 'spatial ACFs'; 
addHeadingAndPrint(pageHeading, PS_maps, figI_maps); 

save(MAT_output, 'output', '-v7.3'); 
close all;
end % START_R4_sim_stripes

function out = generate_stripes(f)
% 
% last modified: 2024.08.14

x   = 0:0.01:4;
x   = x(1:400); 
y   = sin(2 * pi * f * x) > 0; 

out = repmat(y, 400, 1); 

end % function generate_stripes
