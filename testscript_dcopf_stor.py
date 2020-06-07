from load_cdf import *
from utils import *
from dcopf_stor import *
import numpy as np
import cmath
import scipy.sparse
import cvxpy as cvx
from scipy.sparse import csr_matrix, diags


Y, sC, vC, slack, pv, pq, mva = load_cdf('ieee14cdf.txt')
Y = Y.toarray()

# network data
net = {}
net['n'] = 14      # number of buses in the network
net['m'] = 20   # number of lines in the network
net['Y'] = Y    # Y matrix for the network 
net['C'] = 10 * np.ones((net['m'], 1))  # line capacities
net['mva'] = mva   # power base
net['slack'] = slack  # id for slack bus

# generator data
gen = {}
gen['id'] = np.concatenate([np.array([slack]), pv])  # indices for gen buses
gen['ng'] = gen['id'].shape[0]  # number of gen buses
gen['CQ'] = 2 * np.ones((gen['ng'], 1)) # quadratic cost coeff
gen['CL'] = np.ones((gen['ng'], 1)) # line cost coeff

# load data
load = {}
load['id'] = pq # indices for load buses
load['nl'] = load['id'].shape[0] # number of load buses
load['T'] = 24  # time periods for the load data
load['L'] = np.random.uniform(0, 1, (load['nl'], load['T']))  # load profile, each row for a load, each column for a period
# load['L'] = 0.4 * np.ones((load['nl'], load['T']))

# storage data
stor = {}
stor['id'] = np.array([0, 4])  # indices for storage buses
stor['ns'] = stor['id'].shape[0]  # number of stor buses
stor['B'] = 10 * np.ones((stor['ns'], 1))   # storage capacities
stor['U'] = 3 * np.ones((stor['ns'], 1))   # per period charging/discharging capacities
stor['lambda'] = np.ones((stor['ns'], 1))   # storage efficiencies

data = dcopf_stor(net, gen, load, stor)
print(data['result']['cost'])
