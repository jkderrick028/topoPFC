function conditionInfo = conditionInfoSortingOut_KM(spikeData)
% function conditionInfoSortingOut prepares trial condition info for
% decoding. 
% 
% last modified: 2024.04.12

import spikes.*;

conditionInfo       = spikeData.conditionInfo;
conditionInfo       = reshape(conditionInfo, [], 1); 

end
