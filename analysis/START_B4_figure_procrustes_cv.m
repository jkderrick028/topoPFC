function START_B4_figure_procrustes_cv(varargin)
% generates raw figures for the manuscript.
% 1.    pick out the 2 sessions in each task for visualization (Buzz, NSP1)
% 
% 2.    align channels with signals across sessions and tasks and estimate
%       the transformations
% 
% 3.    apply the same transformations to channels that sometimes have
%       signal while sometimes not
% 
% 4.    smooth all the maps
% 
% last modified: 2024.09.20


import mds.*;
import utils_dx.*;

close all;

p                                               = inputParser;
p.addParameter('signalType', 'mcTuning');                                   % or residual
parse(p, varargin{:});
signalType                                      = p.Results.signalType;

projectPath                                     = setProjectPath();
[currPath, currfilename, currext]               = fileparts(mfilename('fullpath'));
ANALYSIS                                        = 'topovis';
resultsPath                                     = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

taskStrs                                        = {'ODR', 'KM', 'AL'}; 
subjectStr                                      = 'Buzz'; 
arrayStr                                        = 'NSP1'; 
nRows                                           = 10;
nCols                                           = 10;
nChannelsTotal                                  = nRows * nCols; 

MAT_procrustesOutput                            = fullfile(resultsPath, sprintf('%s_output_%s.mat', currfilename, signalType));
output                                          = []; 
output.taskStrs                                 = taskStrs; 
output.subjectStr                               = subjectStr; 
output.arrayStr                                 = arrayStr; 

PS_mdsProcrustes                                = fullfile(resultsPath, sprintf('%s_results_%s.ps', currfilename, signalType));
if exist(PS_mdsProcrustes, 'file'), system(['rm ' PS_mdsProcrustes]); end
figI_mdsProcrustes                              = 10; 

mds_resultsPath = fullfile(projectPath, 'results', 'topovis', 'START_B2_spikesMDS');
sessions        = {
                   {'20180307', '20180305'}, ...    % ODR
                   {'20171128', '20171127'}, ...    % KM
                   {'20171111', '20171110'}  ...    % AL
                    }; 

data                                            = [];
index                                           = 1; 
for taskI = 1:numel(taskStrs)
    MAT_mds_output                              = fullfile(mds_resultsPath, sprintf('START_B2_spikesMDS_%s_%s.mat', taskStrs{taskI}, signalType)); 
    output_this_task                            = load(MAT_mds_output).output.(subjectStr).(arrayStr); 
    
    for sessI = 1: 2
        data(index).task                        = taskStrs{taskI};
        data(index).session                     = sessions{taskI}{sessI};
        data(index).coords_2D                   = output_this_task.(sprintf('sess_%s', sessions{taskI}{sessI})).coords_2D; 
        data(index).chanLinearInds              = output_this_task.(sprintf('sess_%s', sessions{taskI}{sessI})).chanLinearInds;
        index                                   = index + 1; 
    end % sessI 
end % taskI 

% now visualize the maps without any processing
figure(figI_mdsProcrustes); clf(figI_mdsProcrustes); 
nHors                                           = 3; 
nVers                                           = 2;
figInfo.nHors                                   = nHors;
figInfo.nVers                                   = nVers; 

for dataI = 1:numel(data)
    figInfo.subplotI                            = dataI; 
    figInfo.title                               = sprintf('%s %s', data(dataI).task, data(dataI).session); 
    coords2maps(data(dataI).coords_2D, data(dataI).chanLinearInds, figInfo);    
end % dataI

pageHeadings                                    = 'original mds maps';
addHeadingAndPrint(pageHeadings, PS_mdsProcrustes, figI_mdsProcrustes); 


% now locate the channels that have signals at all times
chanLinearInds_with_signals                     = []; 
for dataI = 1:numel(data)
    if isempty(chanLinearInds_with_signals)
        chanLinearInds_with_signals             = union(chanLinearInds_with_signals, data(dataI).chanLinearInds);
    else
        chanLinearInds_with_signals             = intersect(chanLinearInds_with_signals, data(dataI).chanLinearInds);
    end
end % dataI 

coords_2D_combine                               = nan(numel(chanLinearInds_with_signals), 2, numel(data)); 
for dataI = 1:numel(data)
    data(dataI).extra_chanLinearInds            = setdiff(data(dataI).chanLinearInds, chanLinearInds_with_signals); 
    data(dataI).included_chanIndices            = find(ismember(data(dataI).chanLinearInds, chanLinearInds_with_signals));
    data(dataI).excluded_chanIndices            = find(~ismember(data(dataI).chanLinearInds, chanLinearInds_with_signals));
    coords_2D_combine(:, :, dataI)              = data(dataI).coords_2D(data(dataI).included_chanIndices, :);
end % dataI

% now do procrustes and align all the maps to the mean
target_coords_2D                                = mean(coords_2D_combine, 3); 

for dataI = 1:numel(data)
    [d,Z,transform]                             = procrustes(target_coords_2D, coords_2D_combine(:, :, dataI));
    chanLinearInds_this_data                    = data(dataI).chanLinearInds; 
    coords_2D_full_aligned                      = nan(numel(chanLinearInds_this_data), 2); 
    coords_2D_full_aligned(data(dataI).included_chanIndices, :)     = Z;
    if ~isempty(data(dataI).excluded_chanIndices)
        coords_2D_excluded                      = data(dataI).coords_2D(data(dataI).excluded_chanIndices, :); 
        coords_2D_excluded                      = transform.b * coords_2D_excluded * transform.T + transform.c(1,:);
        coords_2D_full_aligned(data(dataI).excluded_chanIndices, :) = coords_2D_excluded;         
    end
    data(dataI).coords_2D_aligned               = coords_2D_full_aligned; 
end % dataI 

% now visualize procrustes results
figure(figI_mdsProcrustes); clf(figI_mdsProcrustes); 
nHors                                           = 3; 
nVers                                           = 2;
figInfo.nHors                                   = nHors;
figInfo.nVers                                   = nVers; 

for dataI = 1:numel(data)
    figInfo.subplotI                            = dataI; 
    figInfo.title                               = sprintf('%s %s', data(dataI).task, data(dataI).session); 
    colours_rgb                                 = coords2maps(data(dataI).coords_2D_aligned, data(dataI).chanLinearInds, figInfo);
    data(dataI).colours_aligned                 = colours_rgb; 
end % dataI

pageHeadings                                    = 'aligned mds maps';
addHeadingAndPrint(pageHeadings, PS_mdsProcrustes, figI_mdsProcrustes); 


% now smooth the aligned maps
nColourChannels                                 = 3; % rgb channels
fitting_resultsPath                             = fullfile(projectPath, 'results', 'moranI', 'START_B3_donutACF_fitting_summary_cv', 'laplacian'); 

dataI = 1; 
for taskI = 1:numel(taskStrs)
    MAT_fitting_output                          = fullfile(fitting_resultsPath, sprintf('START_B3_donutACF_fitting_summary_cv_%s_%s.mat', taskStrs{taskI}, signalType)); 
    fitting_output                              = load(MAT_fitting_output).output.(subjectStr);
    sessionStrs_this_task                       = fitting_output.sessionStrs; 
    for sessI = 1:2
        sess_index                              = find(strcmp(sessionStrs_this_task, sessions{taskI}{sessI})); 
        data(dataI).fwhm                        = fitting_output.(arrayStr).fitting.fwhm(sess_index); 
        dataI                                   = dataI + 1; 
    end % sessI
    if ~exist('distances', 'var')
        distances                               = fitting_output.uniqueDists; 
    end
end % taskI 


figure(figI_mdsProcrustes); clf(figI_mdsProcrustes); 
nHors                                           = 3; 
nVers                                           = 2;
for dataI = 1:numel(data)
    colours_rgb                                 = data(dataI).colours_aligned; 
    chanLinearInds                              = data(dataI).chanLinearInds; 
    
    fwhm_mm                                     = data(dataI).fwhm; 
    fwhm                                        = fwhm_mm/0.4;
    
    % smooth the map using the fitted Laplacians
    s                                           = fwhm/sqrt(log(2))/2;
    b                                           = fwhm/log(2)/2; 
    kernel_1D                                   = exp(-abs(distances)/b);
    kernel_2D                                   = min(repmat(kernel_1D, [numel(kernel_1D) 1]), repmat(kernel_1D', [1 numel(kernel_1D)]));
    chanColours_sm                              = nan(size(colours_rgb));
    for colourChanI = 1:nColourChannels
        chanColours_sm(:,:,colourChanI)         = imgaussfilt(colours_rgb(:,:,colourChanI), s);                    
    end % colourChanI

    chanColours_sm                              = reshape(chanColours_sm, nChannelsTotal, 3);
    chanColours_sm(setdiff(1:100, chanLinearInds), :) = 1; 
    chanColours_sm                              = reshape(chanColours_sm, nRows, nCols, nColourChannels); 
    
    subplot(nHors, nVers, dataI);
    imagesc(chanColours_sm);
    axis square;
    axis off; 
    xlabel('channels'); ylabel('channels');
    set(gca, 'xtick', 2:2:size(chanColours_sm, 1));
    set(gca, 'ytick', 2:2:size(chanColours_sm, 1));
    set(gca, 'YDir', 'normal');
    title(sprintf('%s %s', data(dataI).task, data(dataI).session), 'FontSize', 12);
end % dataI

pageHeadings                                    = 'smoothed mds maps';
addHeadingAndPrint(pageHeadings, PS_mdsProcrustes, figI_mdsProcrustes); 


output.data                                     = data; 
save(MAT_procrustesOutput, 'output', '-v7.3');
close all;
end % function START_B4_figure_procrustes_cv

function arraySpaceColour = coords2maps(coords_2D, chanLinearInds, figInfo)
% 
% last modified: 2023.05.09

import mds.*;

[theta, rho]                        = cart2pol(coords_2D(:,1), coords_2D(:,2));
hues                                = (rad2deg(theta) + 180) ./ 360;
saturations                         = rho/max(rho);
brightness                          = 0.8*ones(size(hues)); 
colours_hsv                         = [hues, saturations, brightness];
colours_rgb                         = hsv2rgb(colours_hsv);

subplot(figInfo.nHors, figInfo.nVers, figInfo.subplotI);
arraySpaceColour                    = mds2arraySpace(colours_rgb, chanLinearInds);
imagesc(arraySpaceColour);
axis square;
axis off; 
xlabel('channels'); ylabel('channels');
set(gca, 'xtick', 2:2:size(arraySpaceColour, 1));
set(gca, 'ytick', 2:2:size(arraySpaceColour, 1));
set(gca, 'YDir', 'normal');
title(figInfo.title, 'FontSize', 12);

end % function coords2maps
