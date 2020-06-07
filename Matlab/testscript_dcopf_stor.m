%% CEE 272R DC OPF with Storage, testscript
clc;close all;
% addpath('./dataIEEEcdf');
[Y,sC,vC,slack,pv,pq,mva] = load_cdf('ieee14cdf.txt');
% [y,M,lineList] = Y2bM(Y);

%% network data
net.n = 14; % number of buses in the network
net.m = 20; % number of lines in the network
net.Y = Y; % Y matrix for the network 
net.C = 10*ones(net.m,1); % line capacities
net.mva = mva; % power base
net.slack = slack; % id for slack bus


%% generator data
gen.id = [slack;pv]; % indices for gen buses
gen.ng = length(gen.id); % number of gen buses
gen.CQ = 2*ones(gen.ng,1); % quadratic cost coeff
gen.CL = ones(gen.ng,1); %line cost coeff


%% load data
load.id = pq; % indices for load buses
load.nl = length(pq); % number of load buses
load.T = 24; % time periods for the load data
load.L = rand(load.nl,load.T); % load profile, each row for a load, each column for a period


%% storage data
stor.id = [1;5]; % indices for storage buses
stor.ns = length(stor.id); % number of stor buses
stor.B = 10*ones(stor.ns,1); % storage capacities
stor.U = 3*ones(stor.ns,1); % per period charging/discharging capacities
stor.lambda = ones(stor.ns,1); % storage efficiencies

%%
dcopf_stor(net, gen, load, stor)


