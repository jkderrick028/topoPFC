function firingRateRaster = estimateFiringRates_phase(raster, eventStartEndTiming)
% function estimateFiringRates_phase estimates firing rates using by
% averaging spike count over the whole trial phase. Can be used for both
% single units and channels.
% 
% INPUT
%       raster                  (units x time x trials)
%       eventStartEndTiming     (events x 2) e.g. [1, 3000; 3001, 5000];
% 
% OUTPUT
%       firingRateRaster        (units x events x trials) spikes/second
% 
% last modified: 2023.10.29


nEvents                 = size(eventStartEndTiming, 1);
[nUnits, ~, nTrials]    = size(raster);
firingRateRaster        = zeros(nUnits, nEvents, nTrials);

for eventI=1:nEvents
    firingRateRaster(:, eventI, :) = mean(raster(:, eventStartEndTiming(eventI, 1):eventStartEndTiming(eventI, 2), :), 2);
end % eventI

firingRateRaster        = 1000*firingRateRaster; % spikes/second

end % function estimateFiringRates_phase
