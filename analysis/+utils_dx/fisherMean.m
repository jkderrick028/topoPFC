function rmean = fisherMean(vec)

import utils_dx.*;

z       = r2z(vec);
zmean   = mean(z, 'omitnan');
rmean   = z2r(zmean); 

end % function fisherMean
