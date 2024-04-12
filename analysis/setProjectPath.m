function projectPath = setProjectPath()
% function setProjectPath() sets the root path of the topoPFC project
% 
% USAGE:
% 
% projectPath = setProjectPath(); 
% 
% last modified: 2023.02.27


[currpath,currname,currext] = fileparts(mfilename('fullpath')); 
projectPath                 = fullfile(currpath, '..');

