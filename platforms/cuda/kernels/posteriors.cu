/*****************************************************************/
/*    Copyright (c) 2013, Stanford University and the Authors    */
/*    Author: Robert McGibbon <rmcgibbo@gmail.com>               */
/*    Contributors:                                              */
/*                                                               */
/*****************************************************************/

#include "logsumexp.cu"
#include <stdlib.h>


template<unsigned int n_states>
__global__ void posteriors(
const mixed* __restrict__ fwdlattice,
const mixed* __restrict__ bwdlattice,
const int n_trajs,
const int* __restrict__ sequence_lengths,
const int* __restrict__ cum_sequence_lengths,
float* __restrict__ posteriors)
{
    const int N = cum_sequence_lengths[n_trajs-1] + sequence_lengths[n_trajs-1];
    unsigned int gid = blockIdx.x*blockDim.x+threadIdx.x;
    mixed work_buffer, normalizer;

    while (gid < n_states*N) {
        const unsigned int t = gid / n_states;
        const unsigned int lid = gid % n_states;
        work_buffer = fwdlattice[t*n_states + lid] + bwdlattice[t*n_states + lid];
        normalizer = logsumexp<mixed, n_states>(work_buffer);
        posteriors[t*n_states + lid] = expf(work_buffer - normalizer);

        gid += gridDim.x*blockDim.x;
    }
}
