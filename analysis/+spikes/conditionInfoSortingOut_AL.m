function conditionInfo = conditionInfoSortingOut_AL(taskVariableStr, condStruct, spikeData)
% function conditionInfoSortingOut prepares trial condition info for decoding
% 
% the logic for determining configuration 1 vs configuration 2:
% definition: 
%   configuration 1: (color_W, color_S) 
%   configuration 2: (color_S, color_W)
% 
% implementation: 
%   if trial correct:
%       if wood:
%           if choice left
%               config_1
%           if choice right
%               config_2
%       if steel:
%           if choice left
%               config_2
%           if choice right
%               config_1 
%   if trial incorrect: 
%       if wood:
%           if choice left
%               config_2
%           if choice right
%               config_1
%       if steel:
%           if choice left
%               config_1
%           if choice right
%               config_2
% 
% last modified: 2023.11.06

import spikes.*; 

nTrials = numel(condStruct.trialOutcome);

switch taskVariableStr
    case 'context'
        conditionInfo                                   = cell(nTrials, 1); 
        conditionInfo(logical(condStruct.wood))         = {'W'};
        conditionInfo(~logical(condStruct.wood))        = {'S'};
    case 'lr'
        conditionInfo                                   = cell(nTrials, 1); 
        conditionInfo(logical(condStruct.choiceLeft))   = {'L'};
        conditionInfo(~logical(condStruct.choiceLeft))  = {'R'};
    case 'trialOutcome'
        conditionInfo = compose('%d', condStruct.trialOutcome);
    case 'clr_ctx'
        conditionInfo = cell(nTrials, 1);
        % configuration 1: color associated with wood on the left
        % configuration 2: color associated with wood on the right
        for trialI = 1:nTrials
            if condStruct.trialOutcome(trialI)
                if condStruct.wood(trialI)
                    if condStruct.choiceLeft(trialI)
                        conditionInfo{trialI} = 'config_1';
                    else % choice right
                        conditionInfo{trialI} = 'config_2';
                    end
                else % steel
                    if condStruct.choiceLeft(trialI)
                        conditionInfo{trialI} = 'config_2';
                    else % choice right
                        conditionInfo{trialI} = 'config_1';
                    end
                end
            else % incorrect trial
                if condStruct.wood(trialI)
                    if condStruct.choiceLeft(trialI)
                        conditionInfo{trialI} = 'config_2';
                    else % choice right
                        conditionInfo{trialI} = 'config_1';
                    end
                else % steel
                    if condStruct.choiceLeft(trialI)
                        conditionInfo{trialI} = 'config_1';
                    else % choice right
                        conditionInfo{trialI} = 'config_2';
                    end
                end
            end 
        end % trialI
    case 'tuning'
        conditionInfo_ctx   = conditionInfoSortingOut_AL('context', condStruct); 
        conditionInfo_cfg   = conditionInfoSortingOut_AL('clr_ctx', condStruct);
        ctx_id              = strcmp(conditionInfo_ctx, 'W'); 
        ctx_id              = double(ctx_id); 
        ctx_id              = 2-ctx_id;                                     % 1: wood; 2: steel
        cfg_id              = strcmp(conditionInfo_cfg, 'config_1');
        cfg_id              = double(cfg_id); 
        cfg_id              = 2-cfg_id;                                     % 1: cfg1; 2: cfg2
        tuning_id           = (ctx_id - 1) * 2 + cfg_id;                    % 1: W cfg1; 2: W cfg2; 3: S cfg1; 4: S cfg2
        conditionInfo       = compose('%d', tuning_id);          
    case 'events'
        eventStrs           = spikeData.eventStrs; 
        eventStartEndBinInds= spikeData.eventStartEndBinInds;
        nTimePoints         = spikeData.nTimePoints; 
        conditionInfo       = eventAsCond(eventStrs, eventStartEndBinInds, nTimePoints);
end % switch
end
