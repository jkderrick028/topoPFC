function vector = sqmat2vec(matrix, upperORlower)
% extracts the upper or lower triangular part of a square matrix into a
% column vector.
% 
% last modified: 2023.10.30

if ~exist('upperORlower', 'var'), upperORlower='upper'; end

assert(size(matrix, 1)==size(matrix, 2), 'not a square matrix'); 

switch upperORlower
    case 'upper'
        vector = matrix(logical(triu(ones(size(matrix)), 1))); 
    case 'lower'
        vector = matrix(logical(tril(ones(size(matrix)), -1)));
end

end % function sqmat2vec
