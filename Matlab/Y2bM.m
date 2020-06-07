function [y,M,edgelist] = Y2bM(Y)
n = size(Y,1);
k = 1;
edgelist = [];
y = [];
absY = abs(Y);
tol = 1e-8;
for i = 1:(n-1)
    for j = (i+1):n
        if absY(i,j)>tol
            y = [y;-Y(i,j)];
            edgelist = [edgelist; k, i, j];
            k = k+1;
        end
    end
end
m = length(edgelist);
M = sparse(n,m);
for i = 1:m
    M(edgelist(i,2),i) = 1;
    M(edgelist(i,3),i) = -1;
end
