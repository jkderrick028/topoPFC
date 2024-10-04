function [colours_rgb, unexplainedVariance, coords_2D] = mds_channels(signal, chanLinearInds, nRows, nCols)
% function mds_channels computes channel x channel correlation distance (1
% - correlation) matrix, conduct MDS, color code each channel based on
% their distance in the mds splace, project channels back to the 10 x 10
% array space
% 
% INPUT
%   signal being tuningProfile
%   chanLinearInds
% 
% last modified: 2024.04.12

import utils_dx.visualizeCorrMat;
import utils_dx.sqmat2vec;
import mds.*;


if ~exist('nRows', 'var'), nRows = 10; end
if ~exist('nCols', 'var'), nCols = 10; end

nDims                                                   = 2;
criterion                                               = 'metricstress';
figInfo.nVerPan                                         = 2;
figInfo.nHorPan                                         = 2;
[nChannelsTotal, ~]                                     = size(signal);

% correlation matrix using original high-dimensional data
corrmat                                         = zeros(nChannelsTotal, nChannelsTotal);        
corrmat(chanLinearInds, chanLinearInds)         = corr(signal(chanLinearInds, :)', 'type', 'Pearson', 'rows', 'complete');

subplot(figInfo.nVerPan, figInfo.nHorPan, 1);
visualizeCorrMat(corrmat, 'axisLabels', 'channels', 'titleStr', 'signal corrmat');

% mds reducing dimensionanlity
% use correlation distance matrix in the original space and euclidean distance matrix in
% the reduced mds space
figInfo.subplotI                                = 2;
distmat_orig                                    = zeros(nChannelsTotal, nChannelsTotal);      
pdist_orig                                      = pdist(signal(chanLinearInds, :), 'correlation'); 
distmat_orig(chanLinearInds, chanLinearInds)    = squareform(pdist_orig);

[coords_2D, stress, disparities]                = mdscale(distmat_orig(chanLinearInds, chanLinearInds), nDims, 'criterion', criterion); 

[theta, rho]                                    = cart2pol(coords_2D(:,1), coords_2D(:,2));
hues                                            = (rad2deg(theta) + 180) ./ 360;
saturations                                     = rho/max(rho);
brightness                                      = 0.8*ones(size(hues)); 
colours_hsv                                     = [hues, saturations, brightness];
colours_rgb                                     = hsv2rgb(colours_hsv);

figInfo.title                                   = sprintf('2D MDS %s', criterion);
MDSarrangements(coords_2D, colours_rgb, figInfo);

% project back to array space
subplot(figInfo.nVerPan, figInfo.nHorPan, 3);
arraySpaceColour                                = mds2arraySpace(colours_rgb, chanLinearInds, nRows, nCols);
imagesc(arraySpaceColour);
axis square;
axis off; 
xlabel('channels'); ylabel('channels');
set(gca, 'xtick', 2:2:size(arraySpaceColour, 1));
set(gca, 'ytick', 2:2:size(arraySpaceColour, 1));
set(gca, 'YDir', 'normal');
title('array maps', 'FontSize', 12);

% scree plot
pDims                                   = 1:10;
unexplainedVariance                     = nan(numel(pDims), 1);
for pdistI=1:numel(pDims)
    [coords, stress, disparities]       = mdscale(distmat_orig(chanLinearInds, chanLinearInds), pDims(pdistI), 'criterion', criterion); 
    pdist_mds                           = pdist(coords, 'euclidean');    
    unexplainedVariance(pdistI)         = 1 - corr(pdist_orig', pdist_mds', 'type', 'Pearson')^2;
end % pdistI

subplot(figInfo.nVerPan, figInfo.nHorPan, 4);
plot(pDims, unexplainedVariance, 'k');
axis square;
box off; 
ylim([0, 1]);
yticks(0:0.2:1);
yticklabels(0:0.2:1);
xticks(pDims);  
xlabel('nDim mds');
ylabel('unexplained variance');
title('unexplained var', 'FontSize', 12);

end % function mds_channels
