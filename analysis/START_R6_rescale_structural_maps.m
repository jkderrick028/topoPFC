function START_R6_rescale_structural_maps
% this function rescales the structural map from Goldman-Rakic 1984 and
% runs spatial ACF analysis on the rescaled map. 
% 
% last modified: 2024.08.30

import moranI.donutACF_channels; 
import utils_dx.*; 

close all;

projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'goldman_rakic';

resizes = [0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0]; 

for sizeI = 1:numel(resizes)
    resultsPath                     = fullfile(projectPath, 'results', ANALYSIS, currfilename, sprintf('resize_%.1f', resizes(sizeI)));
    if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end
    
    PS_simulations                  = fullfile(resultsPath, sprintf('simulations_%.1f.ps', resizes(sizeI)));
    if exist(PS_simulations, 'file')
        system(['rm ' PS_simulations]);
    end

    output                              = [];
    MAT_output                          = fullfile(resultsPath, sprintf('output_%.1f.mat', resizes(sizeI))); 

    image_dir                           = fullfile(projectPath, 'results', ANALYSIS, sprintf('generated_dataset_%.1f', resizes(sizeI))); 
    image_files                         = {dir(image_dir).name};
    image_files                         = setdiff(image_files, {'.', '..', '.DS_Store'}); 
    
    n_images                            = numel(image_files); 

    figI_1                              = 10;
    figI_2                              = 11; 
    monitor                             = 1; 
    
    moranIs                             = cell(n_images, 1); 
    figI_moranI                         = 13; 

    for imageI = 1:n_images
        image                           = imread(fullfile(image_dir, image_files{imageI})); 
        
        image                           = rgb2gray(image);
        
        image_binary                    = ones(size(image));
        
        if monitor
            figure(figI_1); 
            clf(figI_1); 
            imagesc(image_binary, [0, 1]);
            colormap('gray');
            colorbar;
            axis square; 
        end
        
        image_binary(image ==0)         = 0;
        if monitor
            imagesc(image_binary, [0, 1]);
            colormap('gray');
            colorbar;
            axis square; 
        end
        
        sampled                         = ones(10, 10);
        stride                          = ceil(size(image_binary, 1) / 10); 
        starting_points                 = 1:stride:size(image_binary, 1); 
        end_points                      = min(starting_points + stride -1, size(image_binary, 1));
        
        n_bins                          = 10;
        for i = 1:n_bins
            for j = 1:n_bins 
                sampled(i, j)           = mean(image_binary(starting_points(i):end_points(i), starting_points(j):end_points(j)), 'all');
            end
        end
        
        if monitor
            figure(figI_2); 
            clf(figI_2); 
            imagesc(sampled, [0, 1]); 
            colormap('gray');
            colorbar;
            axis square;
        end
        figure(figI_moranI); 
        clf(figI_moranI); 
        moranIs{imageI}                 = donutACF_channels(reshape(sampled, [], 1), []);
    end % imageI

    I_reals                             = [];

    for imageI = 1:n_images
        I_real                          = [1, moranIs{imageI}.I_real]; 
        I_reals                         = [I_reals; I_real]; 
    end % imageI 
    
    distances                           = [0, moranIs{1}(1).uniqueDists]; 
    figI_summary                        = 12;
    figure(figI_summary); clf(figI_summary);
    subplot(2, 1, 1); 
    hold on;
    yline(0, 'LineStyle', '--', 'Color', str2rgb('dark_grey'), 'LineWidth', 1.2)
    plot(distances, I_reals', 'Color', str2rgb('light_grey'), 'LineWidth', 0.7); 
    plot(distances, mean(I_reals, 1), 'Color', 'k', 'LineWidth', 2); 
    xlabel('distances (mm)');
    ylabel('ACF');
    ylim([-0.4, 1]);
    xlim([0, 4]); 
    xticks(0:1:4); 
    title('goldman-rakic ACF');
    box('off');
    
    pageHeadings                        = sprintf('%d simulations, %.1f', n_images, resizes(sizeI));
    addHeadingAndPrint(pageHeadings, PS_simulations, figI_summary);
    
    output.moranIs                      = moranIs;
    save(MAT_output, 'output', '-v7.3'); 
end % sizeI 

close all;

end % START_R6_rescale_structural_maps
