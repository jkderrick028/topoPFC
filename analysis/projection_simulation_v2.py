import numpy as np
import matplotlib.pyplot as plt
import scipy


def sqmat2vec(sqmat, upperORlower='upper'):
    """
    extracts the upper or lower triangular part of a square matrix and return as a vector

    """

    if upperORlower == 'upper':
        coords = np.where(np.triu(np.ones(sqmat.shape), k=1) > 0)
    else:
        coords = np.where(np.tril(np.ones(sqmat.shape), k=1) > 0)

    vec = sqmat[coords]
    return vec


def r2z(r):
    z = np.log(np.divide(1+r, 1-r)) / 2
    return z


def z2r(z):
    r = np.divide(np.exp(2*z)-1, np.exp(2*z)+1)
    return r

K1 = 50     # conditions for projection 1
K2 = 50     # conditions for projection 2
N = 300     # number of time points
P = 100     # number of channels
R = 20      # number of runs

n_simulations = 1000

np.random.seed(0)

# spatial structure
sigma = 10 * np.random.randn(P, P)
sigma = sigma ** 2
sigma = scipy.ndimage.gaussian_filter(sigma, 2)
sigma = (sigma + sigma.T) / 2
M = np.real(scipy.linalg.sqrtm(sigma))

Y = np.random.randn(R, N, P) @ M

corrs = []
uppers = []
lowers = []

for simI in np.arange(n_simulations):
    inds_Y1 = np.random.choice(N, K1, False)
    inds_Y2 = np.random.choice([x for x in np.arange(N) if x not in inds_Y1], K2, False)

    Y1 = Y[:, inds_Y1]
    Y2 = Y[:, inds_Y2]

    topo1 = np.array([sqmat2vec(np.corrcoef(y.T)) for y in Y1])
    topo2 = np.array([sqmat2vec(np.corrcoef(y.T)) for y in Y2])

    # for runI in np.arange(R):
    #     corrs.append(np.corrcoef(topo1[runI], topo2[runI])[0, 1])

    corrs.append(np.mean([np.corrcoef(topo1[runI], topo2[runI])[0, 1] for runI in np.arange(R)]))

    # upper bound
    upper_bound = []
    topo1_r2z = r2z(topo1)
    mean_topo1 = topo1_r2z.mean(axis=0)
    mean_topo1 = z2r(mean_topo1)
    for run in np.arange(R):
        upper_bound.append(np.corrcoef(mean_topo1, topo2[run])[0, 1])
    upper_bound = np.mean(upper_bound)

    # lower bound
    lower_bound = []
    for run in np.arange(R):
        mean_topo1 = np.mean([topo1_r2z[j] for j in np.arange(R) if j != run], axis=0)
        mean_topo1 = z2r(mean_topo1)
        lower_bound.append(np.corrcoef(mean_topo1, topo2[run])[0, 1])
    lower_bound = np.mean(lower_bound)

    # print(f'ub: {upper_bound}, lb: {lower_bound}, corr: {corrs[-1]}')
    uppers.append(upper_bound)
    lowers.append(lower_bound)


corrs = np.array(corrs)
uppers = np.array(uppers)
lowers = np.array(lowers)

print(f'corrs: mean={corrs.mean()}, std={corrs.std()}')
print(f'uppers: mean={uppers.mean()}, std={uppers.std()}')
print(f'lowers: mean={lowers.mean()}, std={lowers.std()}')

scipy.stats.ttest_ind(corrs, lowers, alternative='less')

pass
