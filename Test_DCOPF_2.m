clear all;
clc;

Y = [1/0.5i+1/0.2i -1/0.5i -1/0.2i;
    -1/0.5i 1/0.5i+1/0.4i -1/0.4i;
    -1/0.2i -1/0.4i 1/0.2i+1/0.4i];
PGl = [0; 0; 0];
PGu = [1; 1; 0];
thetal = -ones(3,1);
thetau = ones(3,1);
CQ = [1; 1; 0];
CL = [1; 1; 0];
PF = [1 1 1];
slack=1;
PD = [0;0.3;0.4];

dcopf=DCOPF_2(Y,PGl,PGu,PD,thetal,thetau,CQ,CL,PF,slack);

dcopf.PF_opt
dcopf.Cost
dcopf.P_opt
dcopf.theta_opt
dcopf.LMP_opt

