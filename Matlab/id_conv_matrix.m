function A= id_conv_matrix(ids, n)
% this function generate the linear mapping that maps a small vector in
% R^{length(ids)} to a larger vector in R^{n} where the values of the
% smaller vector is inserted into the appropriate place of the larger
% vector according to the coordinates in ids
ns = length(ids);
A = sparse(n, ns);
for i = 1:ns
    A(ids(i),i) = 1;
end