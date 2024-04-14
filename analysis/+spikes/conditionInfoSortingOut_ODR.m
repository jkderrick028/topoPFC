function conditionInfo = conditionInfoSortingOut_ODR(taskVariableStr, spikeData)
% function conditionInfoSortingOut_ODR prepares trial condition info for
% decoding
% 
% last modified: 2024.04.14

import spikes.*; 

switch taskVariableStr
    case 'quadrants'
        conditionInfo                   = spikeData.conditionInfo;
    case 'trialOutcome'
        conditionInfo                   = spikeData.trialOutcome;
        conditionInfo                   = compose('%d', conditionInfo);     
end % switch

conditionInfo                           = reshape(conditionInfo, [], 1); 

end