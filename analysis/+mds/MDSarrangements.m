function MDSarrangements(coords_2D, dotColours, figInfo)

import mds.*;

nChannels = size(coords_2D,1);
subplot(figInfo.nVerPan,figInfo.nHorPan,figInfo.subplotI);
plotDots(coords_2D,eye(nChannels,nChannels),dotColours);
title(figInfo.title, 'FontSize', 12);

if var(dotColours(:))
    axis equal off
end

end