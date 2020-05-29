import numpy as np
import cmath
import scipy.sparse
from scipy.sparse import csr_matrix, diags

"""
Note:
(1) The returned Y is a sparse matrix in scipy. It can be converted to a numpy array
using the Y.toarray() function.
(2) The index is starting from 0 instead 1, in constrast to MATLAB."""

def load_cdf(filename):
    fid = open(filename, 'r')
    line = fid.readline()
    base_mva = float(line[31:37])

    line = fid.readline()
    if line[0:16] == 'BUS DATA FOLLOWS':
        # load bus data (bus types and initial voltages)
        i = 0
        pv = [] 
        pq = []
        slack = None
        bus = dict()
        v = dict()
        s = dict()
        line = fid.readline()
        while line[0:4] != '-999':
            bus[int(line[0:4])] = i

            # read initial voltage
            vhat = float(line[27:33])
            theta = float(line[33:40])*(np.pi/180)
            v[i] = vhat * np.exp(theta*1j)

            # read angle
            dtype = int(line[24:26])
            if dtype == 0 or dtype == 1:
                pq.append(i)
            elif dtype == 2 or (dtype == 3 and slack is not None):
                pv.append(i)
            else:
                slack = i

            # read power
            s[i] = float(line[59:67]) - float(line[40:49])
            s[i] += (float(line[67:75]) - float(line[49:59])) * 1j
            s[i] = s[i] / base_mva

            line = fid.readline()
            i += 1
        n = i
    else:
        print('No bus data found')


    line = fid.readline()
    if line[0:16] != 'BRANCH DATA FOLLOWS':
        # load branch data
        Y = csr_matrix((n,n), dtype=complex)
        line = fid.readline()
        while line[0:4] != '-999':
            i = bus[int(line[0:4])]
            k = bus[int(line[5:9])]
            r = float(line[19:29])
            x = float(line[29:40])
            Y[i,k] = -1.0/(r + x*1j)
            line = fid.readline()

        Y = Y + Y.transpose()
        Y = Y - diags(np.array(Y.sum(1)).squeeze(), 0, shape=(n, n))
    else:
        print('No bus data found')
    
    s_arr = np.zeros(n, dtype=complex)
    for k in s:
        s_arr[k] = s[k]
        
    v_arr = np.zeros(n, dtype=complex)
    for k in v:
        v_arr[k] = v[k]
    
    pv = np.array(pv)
    pq = np.array(pq)
    
    return Y, s_arr, v_arr, slack, pv, pq, base_mva
