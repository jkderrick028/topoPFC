function R2 = computeR2(y_true, y_predicted)
% input:
%   y_true      (channels x conds)
%   y_predicted (channels x conds)
% 
% last modified: 2022.04.21

SSTO    = sum((y_true - mean(y_true, 2)).^2, 2);
SSE     = sum((y_true - y_predicted).^2, 2);
R2      = 1 - SSE./SSTO;

end