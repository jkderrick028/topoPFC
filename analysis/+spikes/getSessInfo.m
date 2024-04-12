function [sessionStrsB, sessionStrsT] = getSessInfo(taskStr)
% function getSessInfo returns sessions for both monkeys in specified task
% without excluding any sessions. 
% 
% Sessions that were excluded from all the analyses could be found in
% spikes.get_excludedSessionStrs;
% 
% USAGE
% 
% [sessionStrsB, sessionStrsT] = getSessInfo('KM'); 
% [sessionStrsB, sessionStrsT] = getSessInfo('Saline'); 
% 
% last modified: 2023.10.29


projectPath             = setProjectPath();
dataPath                = fullfile(projectPath, 'data', taskStr); 
subjectStrs             = {'Buzz', 'Theo'}; 

for subjectI=1:numel(subjectStrs)
    sessionStrs         = {dir(fullfile(dataPath, subjectStrs{subjectI})).name}; 
    sessionStrs         = regexp(sessionStrs, '\d{8}', 'match'); 
    sessionStrs         = sessionStrs(~cellfun(@isempty, sessionStrs));
    sessionStrs         = [sessionStrs{:}]'; 
    sessionStrs         = unique(sessionStrs);  % duplicates for Ketamine and Saline 
    eval(sprintf('sessionStrs%s = sessionStrs;', subjectStrs{subjectI}(1))); 
end % subjectI
