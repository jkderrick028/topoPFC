function START_R5_behavioural_performance
% accuracy for each session in ODR, KM and AL task
% 
% last modified: 2024.08.15

import spikes.*;

close all;

projectPath                         = setProjectPath();
[currPath, currfilename, currext]   = fileparts(mfilename('fullpath'));
ANALYSIS                            = 'behaviour';
resultsPath                         = fullfile(projectPath, 'results', ANALYSIS, currfilename);
if ~exist(resultsPath, 'dir'), mkdir(resultsPath); end

output                              = [];
MAT_output                          = fullfile(resultsPath, sprintf('%s.mat', currfilename)); 

figI_maps                           = 10; 
PS_maps                             = fullfile(resultsPath, sprintf('%s.ps', currfilename)); 
if exist(PS_maps, 'file')
    system(['rm ' PS_maps]); 
end

taskStrs                            = {'ODR', 'KM', 'AL'};
subjectStrs                         = {'Buzz', 'Theo'}; 

for taskI = 1:numel(taskStrs)
    [sessionStrsB, sessionStrsT]    = getSessInfo(taskStrs{taskI});
    excludedSessionStrs             = get_excludedSessionStrs();
    
    for subjectI = 1:numel(subjectStrs)
        dataPath = fullfile(projectPath, 'data', taskStrs{taskI}, subjectStrs{subjectI}); 

        switch subjectStrs{subjectI}
            case 'Buzz'
                sessionStrs         = sessionStrsB;
            case 'Theo'
                sessionStrs         = sessionStrsT;
        end
        sessionStrs                 = setdiff(sessionStrs, excludedSessionStrs); 

        for sessI = 1:numel(sessionStrs)
            switch taskStrs{taskI}
                case 'ODR'
                    MAT_data        = fullfile(dataPath, sprintf('%s_%s_%s_NeuralData.mat', subjectStrs{subjectI}(1), sessionStrs{sessI}, taskStrs{taskI}));
                    data            = load(MAT_data).dataODRStruct;
                    trialOutcome    = data.TrialOutcome;   
                    conditionInfo   = compose('%d', data.QuadCond);
                    output.(taskStrs{taskI}).(subjectStrs{subjectI})(sessI).conditionInfo   = conditionInfo;
                case 'KM'
                    MAT_data        = fullfile(dataPath, sprintf('includeNoiseChannels_%s_%s_%s.mat', taskStrs{taskI}, subjectStrs{subjectI}, sessionStrs{sessI}));
                    data            = load(MAT_data).data;
                    trialOutcome    = data.WM.trialOutcome;
                    conditionInfo   = compose('%d', data.WM.cond'); 
                    output.(taskStrs{taskI}).(subjectStrs{subjectI})(sessI).conditionInfo   = conditionInfo;
                case 'AL'
                    MAT_data        = fullfile(dataPath, sprintf('%s%s.mat', subjectStrs{subjectI}(1), sessionStrs{sessI}));
                    data            = load(MAT_data).data;
                    blocks          = fieldnames(data);
                    trialOutcome    = []; 
                    for blockI = 1:numel(blocks)
                        trialOutcome= [trialOutcome; data.(blocks{blockI}).cond.Correct]; 
                    end % blockI
            end
            accuracy                = sum(trialOutcome) / numel(trialOutcome);
            output.(taskStrs{taskI}).(subjectStrs{subjectI})(sessI).session         = sessionStrs{sessI};
            output.(taskStrs{taskI}).(subjectStrs{subjectI})(sessI).accuracy        = accuracy;
            output.(taskStrs{taskI}).(subjectStrs{subjectI})(sessI).trialOutcome    = trialOutcome;
        end % sessI
    end % subjectI 
end % taskI 

save(MAT_output, 'output', '-v7.3'); 
close all;
end % START_R5_behavioural_performance

