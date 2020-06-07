import numpy as np
import cmath
import cvxpy as cvx
from utils import *

def dcopf_stor(net, gen, load, stor):
    T = load['T']
    if not np.all(np.isreal(net['Y'])):
        net['Y'] = np.imag(net['Y'])
    y, M, linelist = Y2bM(net['Y'])
    net['y'] = y
    net['M'] = M
    net['linelist'] =linelist
    # generate a set of matrices that maps the short vector (e.g. of length gen.ng)
    # to long vectors (of length net.n) by inserting zeros.
    gen['conv'] = id_conv_matrix(gen['id'], net['n'])
    load['conv'] = id_conv_matrix(load['id'], net['n'])
    stor['conv'] = id_conv_matrix(stor['id'], net['n'])
    
    PG = cvx.Variable([gen['ng'], T])
    theta = cvx.Variable([net['n'], T])
    u = cvx.Variable([stor['ns'], T])
    b = cvx.Variable([stor['ns'], T+1])
    CQ_diag = np.diag(gen['CQ'].reshape(-1))
    lambda_diag = np.diag(stor['lambda'].reshape(-1))
    cost = 0
    for t in range(T):
        cost += cvx.quad_form(PG[:, t], CQ_diag) + gen['CL'].T * PG[:, t]
    constraints = [PG >= 0,
                   gen['conv'] * PG - load['conv'].dot(load['L']) - stor['conv'] * u == -net['Y'] * theta, # power balance
                   np.diag(net['y']).dot(net['M'].T) * theta <= np.tile(net['C'],reps=T), # line capacity
                   np.diag(net['y']).dot(net['M'].T) * theta >= -np.tile(net['C'],reps=T), # line capacity
                   b[:, 1:] == lambda_diag * b[:, :-1] + u, # storage updates
                   b >= np.zeros((stor['ns'], T+1)), # storage capacity limits
                   b <= np.tile(stor['B'],reps=T+1), # storage capacity limits
                   u >= -np.tile(stor['U'],reps=T), # charging/discharging limits
                   u <= np.tile(stor['U'],reps=T) # charging/discharging limits
                  ]
    prob = cvx.Problem(cvx.Minimize(cost), constraints)
    result = prob.solve()
    
    data = {}
    data['net'] = net
    data['gen'] = gen
    data['load'] = load
    data['result'] = {}
    data['result']['PG'] = PG
    data['result']['theta'] = theta
    data['result']['u'] = u
    data['result']['b'] = b
    data['result']['lmp'] = -constraints[1].dual_value
    data['result']['cost'] = cost.value
    return data
