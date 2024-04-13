function eventStartEndTiming = periEventTiming2eventStartEndTiming(periEventTiming)
% function periEventTiming2eventStartEndTiming converts perievent time to
% event time index in the newly constructed raster (we concatenate the
% raster for difference events together as if the raster's from a
% continuous recording period)
% 
% USAGE
% 
% eventStartEndTiming = periEventTiming2eventStartEndTiming([300, 400; 200, 100]); 
% [1, 700; 701, 1000]
% 
% last modified: 2023.10.29

eventStartEndTiming = ones(size(periEventTiming));
nEvents             = size(periEventTiming, 1);
for eventI = 1:nEvents
    eventStartEndTiming(eventI, 2)          = eventStartEndTiming(eventI, 1) + sum(periEventTiming(eventI, :)) - 1;
    if eventI<nEvents
        eventStartEndTiming(eventI+1, 1)    = sum(sum(periEventTiming(1:eventI, :))) + 1;
    end
end % eventI
