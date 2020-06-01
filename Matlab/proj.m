%% Read in file
lmp = readmatrix("Menlo_6_N004.csv");
reg = readmatrix("Regulation Services.csv");

%% Data inputs
QD = 8;
QR = 8;
S = 32;
gammaS = 1;
gammaC = 0.8;
gammaRU = 0.25;
gammaRD = 0.25;
t = 1; % 1 hour periods
r = 0;
CD = 0; % maximizing revenue so assume no costs
CR = 0;
P = lmp(:,4); % price vector
PRU = reg(:,6); % reg up price vector
PRD = reg(:,4); % reg down price vector
T = length(P);

%% Linear Optimization
opf = proj_OPF(P,PRU,PRD,CD,CR,QD,QR,S,gammaS,gammaC,gammaRU,gammaRD,T,t,r);

opf.Rev

%% Plot
interval = (1:72); %x-axis

h(1)=plot(interval, P(1:72));
hold on
h(2)=plot(interval, opf.s(1:72));
hold on
h(3)=plot(interval, (opf.qR(1:72) - opf.qD(1:72)));

% h(3)=plot(int, opf.qR);
% hold on
% h(4)=plot(int, opf.qD);
% hold on

legend(h,'P ($/MWh)','s (MWh)','q (MW)');
xlabel('Time of the Day');
