function data = dcopf_stor(net, gen, load, stor)

T = load.T;
if ~isreal(net.Y)
    net.Y = imag(net.Y);
end
[net.y,net.M,net.lineList] = Y2bM(net.Y);
% generate a set of matrices that maps the short vector (e.g. of length gen.ng)
% to long vectors (of length net.n) by inserting zeros

gen.conv = id_conv_matrix(gen.id, net.n);
load.conv = id_conv_matrix(load.id, net.n);
stor.conv = id_conv_matrix(stor.id, net.n);

cvx_begin
    variable PG(gen.ng,T);
    variable theta(net.n,T);
    variable u(stor.ns,T);
    variable b(stor.ns,T+1);
    dual variable lmp;
    cost = 0;
    for t = 1:T
        cost = cost + PG(:,t)'*diag(gen.CQ)*PG(:,t) + gen.CL'*PG(:,t);
    end
    minimize (cost);
    subject to 
        PG >= 0;
        lmp : gen.conv*PG - load.conv*load.L - stor.conv*u  ==  -net.Y*theta; % power balance
        -repmat(net.C,1,T) <= diag(net.y)*net.M'*theta <= repmat(net.C,1,T); % line capacity
        b(:,2:end) == diag(stor.lambda)*b(:,1:end-1) + u; % storage updates
        zeros(stor.ns,T+1) <= b <= repmat(stor.B,1,T+1); % storage capacity
        -repmat(stor.U,1,T) <= u <= repmat(stor.U,1,T); % charging/discharging limits
cvx_end
data.net = net; data.gen = gen; data.load = load; 
data.result.PG = PG; data.result.theta = theta; data.result.u = u; data.result.b = b;
data.result.lmp = lmp;
