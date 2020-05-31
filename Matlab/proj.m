%% Read in file
file = readmatrix("Menlo_6_N004.csv");

%% Data inputs
QD = 8;
QR = 8;
S = 32;
gammaS = 1;
gammaC = 0.8;
gammaRU = 0.25;
gammaRD = 0.25;
T = 24;
t = 1; % 1 hour periods
r = 0;
CD = 0; % maximizing revenue so assume no costs
CR = 0;
P = file((1:24),4); % price vector

%% Linear Optimization
opf = proj_OPF(P,CD,CR,QD,QR,S,gammaS,gammaC,gammaRU,gammaRD,T,t,r);
