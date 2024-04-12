function meanCorrelation = visualizeCorrMat(corrMat, varargin)
% function visualizeCorrMat visualizes the correlation matrix (square
% format) 
% 
% last modified: 2023.04.22

import utils_dx.*;

p = inputParser;

addRequired(p,  'corrMat');
addParameter(p, 'axisLabels', 'channels');
addParameter(p, 'titleStr', 'corr mat');
addParameter(p, 'textStr', []);
addParameter(p, 'cbrStr', []);
addParameter(p, 'range', [-1, 1]);
addParameter(p, 'isSignificant', 0);
addParameter(p, 'elements', 'upper');       % which elements of the correlation matrix to include when computing avg correlation. 'upper', 'full'
addParameter(p, 'nanColor', 'light_grey');

parse(p, corrMat, varargin{:});

axisLabels              = p.Results.axisLabels;
titleStr                = p.Results.titleStr;
textStr                 = p.Results.textStr;
cbrStr                  = p.Results.cbrStr;
range                   = p.Results.range; 
isSignificant           = p.Results.isSignificant;
elements                = p.Results.elements;
nanColor                = p.Results.nanColor;

h                       = imagesc(corrMat, range);
axis square;
cmap                    = redblue(512);
colormap(cmap);
cbr                     = colorbar;
% clim(range);
set(gca, 'clim', range); 

if any(isnan(corrMat), 'all')
    imAlpha                 = ones(size(corrMat));
    imAlpha(isnan(corrMat)) = 0; 
    set(h, 'AlphaData', imAlpha); 
    set(gca, 'Color', str2rgb(nanColor));    
end

if ~isempty(cbrStr)
    cbr.Label.String    = cbrStr;
else
    cbr.Label.String    = {'[Pearson r]'};
end

set(cbr, 'YTick', range(1):((abs(range(1))+abs(range(2)))/2):range(2), 'FontSize', 10);
xlabel(axisLabels, 'FontSize', 10);
ylabel(axisLabels, 'FontSize', 10);
side                    = size(corrMat, 1);
switch elements
    case 'upper'
        meanCorrelation = fisherMean(sqmat2vec(corrMat, 'upper'));
    case 'full'
        meanCorrelation = fisherMean(reshape(corrMat, [], 1));
end

if isempty(textStr)
    if isSignificant
        text(side*0.5, side*0.7, sprintf('\\fontsize{12}r_{avg}^*=%.2f', meanCorrelation));
    else
        text(side*0.5, side*0.7, sprintf('\\fontsize{12}r_{avg}=%.2f', meanCorrelation));
    end
else
%     text(side*0.7, side*0.7, textStr);
    text(side*0.7, side*0.7, sprintf('\\fontsize{12}%s', textStr));
end
    
set(gca, 'YDir', 'normal');

if exist('titleStr', 'var')
    title(strrep(titleStr, '_', ' '), 'FontSize', 12);
end

end % function visualizeCorrMat
