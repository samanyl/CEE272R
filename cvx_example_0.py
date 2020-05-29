import cvxpy as cvx
import numpy as np

np.random.seed(5)
A = np.random.randn(5, 3)
b = np.random.randn(5)

x = cvx.Variable(3) # define the variable with its dimension
objective = cvx.norm(A*x - b, p=2) # define the objective function
constraints = [x <= 0.3, x>= -0.5, x[0] == 0]
prob = cvx.Problem(cvx.Minimize(objective), constraints)
result = prob.solve()
print(result)  # optimal value of objective
print(objective.value)  # optimal value of objective
print(x.value)