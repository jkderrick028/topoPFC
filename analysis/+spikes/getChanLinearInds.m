function chanLinearInds = getChanLinearInds(arrayMap, channelInfo, isElecNum)
% function getChanLinearInds returns the linear indices of channels
% specified in channelInfo for the given subject and array.
% 
% INPUT
%   arrayMap
%   channelInfo     (nChannels x 1 or nUnits x 1), e.g. {'001'; '002'; '002'; '003'}...
%   isElecNum       (boolean) 1 if is ElecNum, 0 if is ChanNum 
% 
% OUTPUT
%   chanLinearInds  (nChannels x 1 or nUnits x 1), the linear indices of specified channels
% 
% last modified: 2023.10.29


nRows           = 10;
nCols           = 10;
sz              = [nRows, nCols];                       % the shank arrangement of the utah arrays that we are using

nChannels       = numel(channelInfo);
chanLinearInds  = nan(nChannels, 1);

for chanI = 1:nChannels
    chanNum     = str2double(channelInfo{chanI});
    
    if isElecNum
        row     = arrayMap.Row(arrayMap.ElecNum == chanNum) + 1;
        col     = arrayMap.Column(arrayMap.ElecNum == chanNum) + 1;
    else % i.e., ChanNum        
        row     = arrayMap.Row(arrayMap.ChanNum == chanNum) + 1;
        col     = arrayMap.Column(arrayMap.ChanNum == chanNum) + 1;
    end

    chanLinearInds(chanI) = sub2ind(sz, row, col);
end % chanI

