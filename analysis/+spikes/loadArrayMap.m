function arrayMap = loadArrayMap(subjectStr, arrayStr)
% function loadArrayMap loads the arrayMap for each array, where
% information of channel location can be extracted. 
% 
% USAGE
%   arrayMap = loadArrayMap('Buzz', 'NSP0');
%   arrayMap = loadArrayMap('Buzz', 'ventral');
% 
% last modified: 2023.10.29


projectPath         = setProjectPath(); 

switch upper(arrayStr)
    case {'NSP0', 'VENTRAL'}
        arrayMap    = load(fullfile(projectPath, 'data', sprintf('%sVentralArrayMap.mat',subjectStr))).arrayMap;
    case {'NSP1', 'DORSAL'}
        arrayMap    = load(fullfile(projectPath, 'data', sprintf('%sDorsalArrayMap.mat',subjectStr))).arrayMap;
end % switch
