function START_B3_donutACF_fitting_summary(varargin)
% summarizes donut ACF results using saturation dots and testing 95% of
% the null distribution against 0
% 
% last modified: 2024.04.15

import spikes.*;
import utils_dx.*;
import moranI.*;

close all;

p                                           = inputParser;
p.addParameter('taskStr', 'KM');                                            % KM, AL, ODR, Ketamine_KeyMapWM2, Saline_KeyMapWM3
p.addParameter('signalType', 'mcTuning');                                   % or residual, or task_evoked
p.addParameter('func', 'laplacian');                                        % or gaussian 

parse(p, varargin{:});
taskStr                                     = p.Results.taskStr; 
signalType                                  = p.Results.signalType; 
func                                        = p.Results.func; 

projectPath                                 = setProjectPath();
[currPath, currfilename, currext]           = fileparts(mfilename('fullpath'));
ANALYSIS                                    = 'moranI';
resultsPath                                 = fullfile(projectPath, 'results', ANALYSIS, currfilename, func);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

subjectStrs                                 = {'Buzz', 'Theo'};
arrayStrs                                   = {'NSP0', 'NSP1'};
excludedSessionStrs                         = get_excludedSessionStrs(); 
significanceLevel                           = 0.05; 

figI_acf                                    = 10;
output                                      = []; 
MAT_output                                  = fullfile(resultsPath, sprintf('%s_%s_%s.mat', currfilename, taskStr, signalType)); 

PS_summary                                  = fullfile(resultsPath, sprintf('%s_%s_%s.ps', currfilename, taskStr, signalType));
if exist(PS_summary, 'file'), system(['rm ' PS_summary]); end

PS_fitting                                  = fullfile(resultsPath, sprintf('%s_%s_%s_fitting.ps', currfilename, taskStr, signalType));
if exist(PS_fitting, 'file'), system(['rm ' PS_fitting]); end

for subjectI = 1:numel(subjectStrs)
    MAT_donutACF                            = fullfile(projectPath, 'results', 'moranI', 'START_B3_donutACF', sprintf('START_B3_donutACF_%s_%s_%s.mat', subjectStrs{subjectI}, taskStr, signalType)); 
    donutACF_results                        = load(MAT_donutACF).output; 
    for arrayI=1:numel(arrayStrs)
        sessionStrs                         = fieldnames(donutACF_results.(arrayStrs{arrayI})); 
        sessionStrs                         = strrep(sessionStrs, 'sess_', '');
        sessionStrs                         = setdiff(sessionStrs, excludedSessionStrs);
        nSessions                           = numel(sessionStrs); 
        I_real_combine                      = []; 
        I_perm_95_combine                   = []; 
        I_real_perm95_diff_combine          = []; 
        sigORnot_combine                    = []; 
        for sessI=1:nSessions
            uniqueDists                     = donutACF_results.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).donutACFresults(1).uniqueDists; 
            % uniqueDists                     = (1:13) * 0.4; 
            nUniqueDists                    = numel(uniqueDists); 
            I_real_thisSession              = [donutACF_results.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).donutACFresults.I_real]; 
            I_real_combine                  = cat(1, I_real_combine, I_real_thisSession); 
            I_perm_95_thisSession           = nan(1, nUniqueDists); 
            I_real_perm95_diff_thisSession  = nan(1, nUniqueDists); 
            for distI=1:nUniqueDists
                I_perm                      = donutACF_results.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).donutACFresults(distI).I_perm;
                I_perm_95_thisSession(distI)= prctile(I_perm, (1-significanceLevel)*100); 
                I_real_perm95_diff_thisSession(distI) = I_real_thisSession(distI)-I_perm_95_thisSession(distI); 
            end % distI 
            I_perm_95_combine               = cat(1, I_perm_95_combine, I_perm_95_thisSession); 
            I_real_perm95_diff_combine      = cat(1, I_real_perm95_diff_combine, I_real_perm95_diff_thisSession); 
            sigORnot_thisSession            = donutACF_results.(arrayStrs{arrayI}).(sprintf('sess_%s', sessionStrs{sessI})).donutACFresults(1).sigORnot_corrected; 
            sigORnot_combine                = cat(1, sigORnot_combine, sigORnot_thisSession); 
        end % sessI 
        output.(subjectStrs{subjectI}).sessionStrs                                          = sessionStrs;
        output.(subjectStrs{subjectI}).uniqueDists                                          = uniqueDists;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).I_real_combine                   = I_real_combine; 
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).I_perm_95_combine                = I_perm_95_combine; 
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).I_real_perm95_diff_combine       = I_real_perm95_diff_combine;    
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).sigORnot_combine                 = sigORnot_combine;
    end % arrayI 
end % subjectI 

nHors                                       = numel(subjectStrs);
nVers                                       = 2; 
for subjectI=1:numel(subjectStrs)
    sessionStrs                             = output.(subjectStrs{subjectI}).sessionStrs; 
    nSessions                               = numel(sessionStrs); 
    uniqueDists                             = output.(subjectStrs{subjectI}).uniqueDists';
    % uniqueDists                             = (1:13) * 0.4; 
    nUniqueDists                            = numel(uniqueDists); 
    arrayColors                             = {[0 1 1], [0 0.4470 0.7410]};                 % cyan and dark blue, for ventral and dorsal arrays

    figure(figI_acf); clf(figI_acf); 
    % figure for dots with saturation 
        
    for arrayI=1:numel(arrayStrs)
        currSubplotI                        = arrayI; 
        subplot(nHors, nVers, currSubplotI); 
        hold on; 
        I_real_combine                      = output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).I_real_combine;        
        p1                                  = plot(uniqueDists, I_real_combine', 'Color', [200, 200, 200]/255, 'LineWidth', 1.2);

        I_real_mean                         = mean(I_real_combine, 1);        
        p2                                  = plot(uniqueDists, I_real_mean, 'Color', arrayColors{arrayI}, 'LineWidth', 1.8); 

        legend([p1(1), p2], {'session', 'mean'}, 'Box', 'off'); 

        sigORnot_combine                    = output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).sigORnot_combine;
        sigDistInds                         = find(any(sigORnot_combine, 1)); 
        saturation                          = sum(sigORnot_combine, 1)/nSessions; 
        saturation                          = saturation(sigDistInds); 
        nSigDistInds                        = numel(sigDistInds); 
        scatter(uniqueDists(sigDistInds), zeros(1, nSigDistInds), 22, 'red', 'filled', 'AlphaData', saturation, 'MarkerFaceAlpha', 'flat', 'AlphaDataMapping', 'none', 'HandleVisibility', 'off');
        box off; 
        xlim([0.3, 3.7]); 
        minMoranI = -0.2; 
        maxMoranI = 0.3; 
        ylim([minMoranI, maxMoranI]); 
        yticks(minMoranI:0.1:maxMoranI);
        yticklabels(minMoranI:0.1:maxMoranI);
        xticks(0.4:0.2:3.7);
        xticklabels(0.4:0.2:3.7); 
        xlabel('distance (mm)');
        ylabel('correlation'); 
        title(sprintf('donutACF %s', arrayStrs{arrayI})); 
        hold off; 
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).saturation   = saturation;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).sigDistInds  = sigDistInds;
    end % arrayI 
    
    % figure for testing the difference between real MoranI and 95% null
    % distribution against 0    
    for arrayI=1:numel(arrayStrs)
        currSubplotI                        = arrayI + numel(arrayStrs); 
        subplot(nHors, nVers, currSubplotI); 
        hold on;
        I_real_perm95_diff_combine          = output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).I_real_perm95_diff_combine;  
        plot(uniqueDists, I_real_perm95_diff_combine', 'Color', [200, 200, 200]/255, 'LineWidth', 1.2);

        I_real_perm95_diff_mean             = mean(I_real_perm95_diff_combine, 1);        
        plot(uniqueDists, I_real_perm95_diff_mean, 'Color', arrayColors{arrayI}, 'LineWidth', 1.8); 

        pVal_nullDist                       = zeros(1, nUniqueDists); 
        for distI = 1:nUniqueDists
            pVal_nullDist(distI)            = sum(I_real_perm95_diff_combine(:, distI)<=0)/nSessions; 
        end % distI 
        if all(pVal_nullDist==0)
            sigORnot_corrected              = zeros(size(pVal_nullDist));
            pVals_corrected                 = zeros(size(pVal_nullDist)); 
        else
            [sigORnot_corrected, ~, ~, pVals_corrected] = fdr_bh(pVal_nullDist, significanceLevel); 
        end
        sigDistInds                         = find(sigORnot_corrected); 
        nSigDistInds                        = numel(sigDistInds); 
        scatter(uniqueDists(sigDistInds), zeros(1, nSigDistInds), 22, 'red', 'filled'); 
        box off;
        xlim([0.3, 3.7]);
        minMoranI = -0.3; 
        maxMoranI = 0.3; 
        ylim([minMoranI, maxMoranI]); 
        yticks(minMoranI:0.1:maxMoranI);
        yticklabels(minMoranI:0.1:maxMoranI);
        xticks(0.4:0.2:3.7);
        xticklabels(0.4:0.2:3.7);
        xlabel('distance (mm)');
        ylabel('correlation'); 
        title(sprintf('against .95 null %s', arrayStrs{arrayI}));
        hold off; 
    end % arrayI    
    pageHeading                             = [];
    pageHeading{1}                          = sprintf('donutACF summary figure %s %s %s', subjectStrs{subjectI}, strrep(taskStr, '_', ' '), signalType); 
    pageHeading{2}                          = 'avg autoCorr and difference against 95% null'; 
    addHeadingAndPrint(pageHeading, PS_summary, figI_acf); 
end % subjectI 

%% fitting functions
figure(figI_acf); clf(figI_acf);
nHors                                       = numel(subjectStrs);
nVers                                       = numel(arrayStrs);
currsubplotI                                = 1;

for subjectI = 1:numel(subjectStrs)
    uniqueDists                             = output.(subjectStrs{subjectI}).uniqueDists;
    % uniqueDists                             = (1:13) * 0.4; 
    select_DistInds                         = find(uniqueDists<=3.7);
    % select_DistInds                         = find(uniqueDists<=5.2);
    for arrayI = 1:numel(arrayStrs)
        I_real_combine                      = output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).I_real_combine;
        nSessions                           = size(I_real_combine, 1); 
        X                                   = [ones(nSessions, 1), I_real_combine(:, select_DistInds)];
        Y                                   = [0, uniqueDists(select_DistInds)];
        
        subplot(nHors, nVers, currsubplotI);
        hold on;
        p1 = plot(Y, X', 'Color', str2rgb('light_grey'), 'LineWidth', 1.3); 

        [curves_fitted, s_fitted, R2, fwhm] = fitting(X, Y, func); 
        
        p2 = plot(Y, curves_fitted', 'Color', str2rgb('cyan'), 'LineWidth', 1.3);

        yline(0, 'LineStyle', '--', 'LineWidth', 1.2, 'Color', str2rgb('dark_grey'), 'HandleVisibility', 'off'); 
        
        legend([p1(1), p2(1)], {'real', 'fitted'}, 'Box', 'off'); 
        title(sprintf('%s %s, R^2=%.2f', subjectStrs{subjectI}, arrayStrs{arrayI}, mean(R2))); 
        xlabel('distance (mm)');
        ylabel('correlation');
        ylim([-0.2, 1]); 

        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).fitting.X                = X;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).fitting.Y                = Y;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).fitting.curves_fitted    = curves_fitted;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).fitting.s_fitted         = s_fitted;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).fitting.R2               = R2;
        output.(subjectStrs{subjectI}).(arrayStrs{arrayI}).fitting.fwhm             = fwhm;

        currsubplotI                        = currsubplotI + 1; 
    end % arrayI 
end % subjectI 

pageHeading                                 = [];
pageHeading{1}                              = sprintf('donutACF fitting summary %s %s %s', taskStr, signalType, func); 
addHeadingAndPrint(pageHeading, PS_fitting, figI_acf); 

save(MAT_output, 'output', '-v7.3');
close all; 
end % function START_B7_acf_fitting_summary

function [curves_fitted, s_fitted, R2, fwhm]  = fitting(corrs, dists, func)
% 
% last modified: 2023.09.11

import utils_dx.*; 

rng('default'); 

switch func
    case 'gaussian'
        equation                    = '1.01*exp(-d^2/(2*s^2))-0.01';    % gaussian 
    case 'laplacian'
        equation                    = '1.02*exp(-d/s)-0.02';            % laplacian
end

myfittype                   = fittype(equation,...
    'independent',{'d'},...
    'coefficients',{'s'}); 

nSessions                   = size(corrs, 1); 

curves_fitted               = nan(nSessions, numel(dists)); 
s_fitted                    = nan(nSessions, 1);

for sessI = 1:nSessions
    myfit                   = fit(dists', corrs(sessI, :)', myfittype);
    s                       = myfit.s;
    s_fitted(sessI)         = s;
    switch func
        case 'gaussian'
            curves_fitted(sessI, :) = 1.01*exp(-dists.^2/(2*s^2))-0.01;     % gaussian
        case 'laplacian'
            curves_fitted(sessI, :) = 1.02*exp(-dists./s)-0.02;             % laplacian
    end
end % sessI 

% R2                          = computeR2(corrs(:, 2:end), curves_fitted(:, 2:end));
R2                          = computeR2(corrs, curves_fitted);
fwhm                        = computeFWHM(s_fitted, func); 

end 


function fwhm = computeFWHM(s, func)
% compute fwhm for gaussian and laplacian
% 
% last modified: 2023.09.14

switch func
    case 'gaussian'
        fwhm = 2 * abs(s) * sqrt(2 * log(2));
    case 'laplacian'
        fwhm = 2 * s * log(2); 
end

end