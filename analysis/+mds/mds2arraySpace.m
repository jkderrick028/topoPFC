function chanColours = mds2arraySpace(chanColours_rgb, chanLinearInds)
% this function arranges 3d colors according to channel linear index into a
% 10 x 10 x 3 matrix
% 
% last modified: 2022.07.10

nRows                           = 10;
nCols                           = 10;
nColourChannels                 = 3;            % r, g, b
chanColours                     = ones(nRows, nCols, nColourChannels);
sz                              = [nRows, nCols];
nChannles                       = numel(chanLinearInds);

for chanI=1:nChannles
    [rowI, colI]                = ind2sub(sz, chanLinearInds(chanI));
    chanColours(rowI, colI, :)  = chanColours_rgb(chanI, :);
end % chanI

end % function mds2arraySpace
