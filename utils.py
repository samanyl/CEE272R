import numpy as np
import cmath

def Y2bM(Y):
    # input: Y: numpy array of Ybus matrix
    # output: 
    # y: the list of (non-zero) admittances
    # M: incidence matrix. Each column represents a connection. 1 for "from" bus, -1 for "to" bus
    n = Y.shape[0]
    k = 0
    edgelist = []
    y = []
    absY = np.abs(Y)
    tol = 1e-8
    for i in range(0, n-1):
        for j in range(i+1, n):
            if absY[i, j] > tol:
                y.append(-Y[i, j])
                edgelist.append([k, i, j])
                k += 1
    m = len(edgelist)
    M = np.zeros((n, m))
    for i in range(m):
        M[edgelist[i][1], i] = 1
        M[edgelist[i][2], i] = -1
    return y, M, edgelist


def id_conv_matrix(ids, n):
    # this function generate the linear mapping that maps a small vector in
    # R^{length(ids)} to a larger vector in R^{n} where the values of the
    # smaller vector is inserted into the appropriate place of the larger
    # vector according to the coordinates in ids
    ns = ids.shape[0]
    A = np.zeros((n, ns))
    for i in range(ns):
        A[ids[i], i] = 1
    return A
