function output = donutACF_channels_cv(tuningProfile_1, tuningProfile_2, excludedChanLI, varargin)
% cross-validated spatial autocorrelation analysis. 
% 
% last modified: 2024.09.20

import utils_dx.*; 

p                   = inputParser;

addParameter(p, 'monitor', 1);
addParameter(p, 'nPermutations', 1000); 

parse(p, varargin{:}); 

monitor             = p.Results.monitor; 
nPermutations       = p.Results.nPermutations; 

rng('default');

nChannelsTotal      = size(tuningProfile_1, 1); 
nRows               = 10;
nCols               = 10;
sz                  = [nRows, nCols]; 
[X, Y]              = ind2sub(sz, 1:nChannelsTotal); 

distmat             = squareform(pdist([X', Y'], 'euclidean'));

uniqueDists         = 0:9; 

output              = []; 
upperCI             = [];
lowerCI             = [];

%% for the actual donut ACF
for distI=1:numel(uniqueDists)
    if uniqueDists(distI)==0
        weightMatrix    = (distmat == 0); 
    else
        weightMatrix    = (distmat <= uniqueDists(distI) & distmat > uniqueDists(distI-1)); 
        weightMatrix(logical(eye(size(weightMatrix)))) = 0; 
    end
        
    [output(distI).I_real, output(distI).I_perm, output(distI).pVal, output(distI).sigORnot] = donutACF_shuffle_cv(tuningProfile_1, tuningProfile_2, weightMatrix, excludedChanLI, nPermutations); 
    upperCI         = [upperCI, prctile([output(distI).I_perm], 97.5)];
    lowerCI         = [lowerCI, prctile([output(distI).I_perm], 2.5)]; 
end % distI

%% for sanity check, where I turned the donut into a plate
% uniqueDists         = 0:13; 
% for distI=1:(numel(uniqueDists) - 1)
%     weightMatrix    = (distmat <= uniqueDists(distI+1)); 
%     weightMatrix(logical(eye(size(weightMatrix)))) = 0; 
%     [output(distI).I_real, output(distI).I_perm, output(distI).pVal, output(distI).sigORnot] = donutACF_shuffle(tuningProfile, weightMatrix, excludedChanLI, nPermutations); 
%     upperCI         = [upperCI, prctile([output(distI).I_perm], 97.5)];
%     lowerCI         = [lowerCI, prctile([output(distI).I_perm], 2.5)]; 
% end % distI

output(1).uniqueDists   =uniqueDists*0.4;

% plotting moranI and permutation results
I_real_acrossDist                   = [output.I_real]; 

% fdr correction
pVals                               = [output.pVal]; 

if all(pVals==0)
    sigORnot_corrected              = ones(size(pVals));
    pVals_corrected                 = zeros(size(pVals)); 
elseif all(isnan(pVals))
    sigORnot_corrected              = zeros(size(pVals));
    pVals_corrected                 = pVals; 
else
    [sigORnot_corrected, ~, ~, pVals_corrected] = fdr_bh(pVals, 0.05); 
end

output(1).sigORnot_corrected        = sigORnot_corrected;
output(1).pVals_corrected           = pVals_corrected;

if monitor
    xaxis                           = 0.4 * uniqueDists; 
    ciplot(lowerCI, upperCI, xaxis, [0.75, 0.75, 0.75]); 
    hold on;
    plot(xaxis, I_real_acrossDist, 'LineWidth', 2, 'Color', 'k'); 
    scatter(xaxis(logical(sigORnot_corrected)), 0, 'red', 'filled'); 
    xlim([0, 3.7]); 
    ylim([-1, 1]); 
    title('donutACF'); 
    xlabel('distance (mm)'); 
    ylabel('donutACF'); 
    set(gca, 'TickDir', 'out');
end 

end % function donutACF_channels_cv

function [I_real, I_perm, pVal, sigORnot] = donutACF_shuffle_cv(tuningProfile_1, tuningProfile_2, weightMatrix, excludedChanLI, nPermutations)
% 
% last modified: 2022.09.14

if ~exist('nPermutations', 'var'), nPermutations = 1000; end

sigLevel                            = 0.05; 
tuningProfile_1(excludedChanLI, :)  = 0;
tuningProfile_2(excludedChanLI, :)  = 0;

nChannelsTotal                      = size(tuningProfile_1, 1);

I_perm                              = zeros(nPermutations, 1);
chanLinearInds                      = setdiff(1:nChannelsTotal, excludedChanLI); 

for permI=1:nPermutations
    tuningProfile_1_permed                      = zeros(size(tuningProfile_1)); 
    tuningProfile_2_permed                      = zeros(size(tuningProfile_2)); 
    chanLinearInds_permed                       = randsample(chanLinearInds, numel(chanLinearInds), false); 
    tuningProfile_1_permed(chanLinearInds, :)   = tuningProfile_1(chanLinearInds_permed, :); 
    tuningProfile_2_permed(chanLinearInds, :)   = tuningProfile_2(chanLinearInds_permed, :); 
    I_perm(permI)                               = donutACF_compute_cv(tuningProfile_1_permed, tuningProfile_2_permed, weightMatrix, excludedChanLI); 
end % permI

I_real                              = donutACF_compute_cv(tuningProfile_1, tuningProfile_2, weightMatrix, excludedChanLI); 
tolerance                           = 1e-4;
if all(isnan(I_perm))
    pVal                            = nan;
    sigORnot                        = 0; 
else
    pVal                            =  sum(I_perm > (I_real-tolerance))/nPermutations; 
    sigORnot                        = (pVal<sigLevel); 
end

end % function donutACF_shuffle_cv

function I = donutACF_compute_cv(tuningProfile_1, tuningProfile_2, weightMatrix, excludedChanLI)
% 
% last modified: 2024.09.20

nChannelsTotal                      = size(tuningProfile_1, 1);
tuningProfile_1(excludedChanLI, :)  = 0;
tuningProfile_2(excludedChanLI, :)  = 0;

weightMatrix(excludedChanLI, :)     = 0;
weightMatrix(:, excludedChanLI)     = 0;

chanLinearInds                      = setdiff(1:nChannelsTotal, excludedChanLI); 
tuningProfile_1_mean                = mean(tuningProfile_1(chanLinearInds, :), 1); 
tuningProfile_2_mean                = mean(tuningProfile_2(chanLinearInds, :), 1); 

covarianceMatrix                    = (tuningProfile_1-tuningProfile_1_mean) * (tuningProfile_2-tuningProfile_2_mean)';
covarianceMatrix_weighted           = weightMatrix .* covarianceMatrix; 

numerator   = sum(covarianceMatrix_weighted, 'all') / sum(weightMatrix, 'all'); 

cov_i       = 0;
cov_j       = 0;

for i=1:nChannelsTotal
    n_j     = sum(weightMatrix(i, :)); 
    cov_i   = cov_i + n_j * covarianceMatrix(i, i); 
end % i

cov_i       = cov_i / sum(weightMatrix, 'all'); 

for j=1:nChannelsTotal
    n_i     = sum(weightMatrix(:, j));
    cov_j   = cov_j + n_i * covarianceMatrix(j, j); 
end % j

cov_j       = cov_j / sum(weightMatrix, 'all'); 

denominator = sqrt(cov_i * cov_j); 
I           = numerator / denominator;

end % function donutACF_channels
