import cvxpy as cvx
import numpy as np

PL = 20 # load
CQ = np.array([3, 2]) # cost; coefficients of quadratic terms
CL = np.array([1, 10]) # cost; coefficients of linear terms
F = 6 # line capacity

# define the optimization problem
PG = cvx.Variable(2) # optimization variables: PG1 and PG2
P12 = cvx.Variable(1) # optimization variables: P12

objective = cvx.quad_form(PG, np.diag(CQ)) + PG * CL # objective function. compact form of 
                                                     # CQ(1)*PG(1)^2+CL(1)*PG(1) +CQ(2)*PG(2)^2+CL(2)*PG(2)

constraints = [PG[0] == P12, PG[1] + P12 == PL, -F <= P12, P12 <= F]
prob = cvx.Problem(cvx.Minimize(objective), constraints)
result = prob.solve()

print(objective.value)  # optimal value of objective
print(PG.value)
print(P12.value)

# Note: depending on how to express the equality constraints, 
# the returned dual variables (LMPs) could be negative.
print(-constraints[0].dual_value)  # LMP1
print(-constraints[1].dual_value)  # LMP2