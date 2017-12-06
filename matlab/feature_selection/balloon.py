import sys
import re
import os

import numpy as np

### KDE using a balloon estimator

# Number of NNs to use (this may be less than the number available in the NN file)
k = 512

# Class priors
wt_prior = 0.1
no_prior = 1.0 - 0.1

# Index of NN that determines the balloon radius
balloon_rank = 30

# Scaling factor used to compute balloon radius
# For gabor features, 0.1 is too small, and anything >= 1.0 is all the same
balloon_scale = 1.0

# Read command line args
assert(len(sys.argv) == 4)
nn_file = sys.argv[1]
label_file = sys.argv[2]
n_ref = int(sys.argv[3])

# Parse filename for metadata
data_dir, nn_file_basename = os.path.split(nn_file)
pattern = '(?P<brain>\w+)\.N\.(?P<N>\d+)\.testnn\.(?P<k_max>\d+)\.(?P<feature>\w+)\.bin'
metadata = re.match(pattern, nn_file_basename).groupdict()
brain_name = metadata['brain']
N = int(metadata['N'])
feature = metadata['feature']

# Read NN file
with open(nn_file, 'rb') as f:
    k_max = np.fromfile(f, dtype=np.int32, count=1)[0]
    assert(k <= k_max)
    nn_pair_dt = np.dtype([('nn_dist', np.float64), ('nn_gid', np.float64)])
    nn_list_dt = np.dtype([('gid', np.float64), ('nn_pairs', nn_pair_dt, k_max)])
    nn_lists = np.fromfile(f, dtype=nn_list_dt)

# Read label file
ref_labels = np.fromfile(label_file, dtype=np.float32, count=n_ref)

# WT probabilities
wt_probs = np.zeros(N)

for nn_list in nn_lists:
    # Read target gid, NN gids, and NN distances
    gid = int(nn_list['gid'])
    nn_gids = nn_list['nn_pairs']['nn_gid'][:k].astype(np.int32)
    nn_dists = nn_list['nn_pairs']['nn_dist'][:k]

    if (gid % 10000 == 0):
        print "Processing gid {}".format(gid)

    # Calculate potentials using the balloon radius
    balloon_radius = balloon_scale * nn_dists[balloon_rank]
    potentials = np.exp(-0.5 * (nn_dists / balloon_radius) ** 2)

    # Compute densities for each class
    no_density = np.sum(potentials[ref_labels[nn_gids] == 0])
    wt_density = np.sum(potentials[ref_labels[nn_gids] != 0])

    # Compute probabilities for WT class
    try:
        wt_probs[gid] = wt_prior * wt_density / (wt_prior * wt_density + no_prior * no_density)
    except ZeroDivisionError:
        wt_probs[gid] = wt_prior

# Write output file
wt_probs_file = "{}/{}.{}.probs.WT.bin".format(data_dir, brain_name, feature)
with open(wt_probs_file, 'wb') as f:
    wt_probs.tofile(f)

