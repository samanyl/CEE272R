%% Read in file
lmp = readmatrix("2019_DA_LMP.csv");
reg = readmatrix("2019_RU_RD.csv");

%% Data inputs
QD = 8;
QR = 8;
S = 32;
gammaS = 1;
gammaC = 0.9;
gammaRU = 0.25;
gammaRD = 0.25;
t = 1; % 1 hour periods
r = 0;
CD = 0; % maximizing revenue so assume no costs
CR = 0;
P = lmp(:,3); % price vector
PRU = reg(:,3); % reg up price vector
PRD = reg(:,4); % reg down price vector
T = length(P);

%% Linear Optimization
opf = proj_OPF(P,PRU,PRD,CD,CR,QD,QR,S,gammaS,gammaC,gammaRU,gammaRD,T,t,r);

opf.Rev

%% Plot
interval = (1:72); %x-axis

% LMP Prices & Arbitrage
% h(1)=plot(interval, P(2401:2472));
% hold on
% h(2)=plot(interval, (opf.qR(2401:2472) - opf.qD(2401:2472)));
% hold on
% legend(h,'P ($/MWh)','q (MW)');

% Regulation Prices & Reg Up/Down
% h(1)=plot(interval, PRU(2401:2472));
% hold on
% h(2)=plot(interval, PRD(2401:2472));
% hold on
% h(3)=plot(interval, (opf.qRD(2401:2472) - opf.qRU(2401:2472)));
% hold on
% legend(h,'PRU ($/MW)','PRD ($/MW)','qR (MW)');

% % State of Charge & All Charging Decisions
h(1)=plot(interval, opf.s(1:72));
hold on
h(2)=plot(interval, (opf.qR(1:72) - opf.qD(1:72)));
hold on
h(3)=plot(interval, (opf.qRD(1:72) - opf.qRU(1:72)));
hold on
legend(h,'s (MWh)','q (MW)','qR (MW)');


% legend(h,'P ($/MWh)','s (MWh)','q (MW)','qR (MW)','PRU ($/MW)','PRD ($/MW)');

% h(1)=plot(interval, opf.s(1:72));
% hold on
% h(2)=plot(interval, PRU(1:72));
% hold on
% h(3)=plot(interval, PRD(1:72));
% hold on
% h(4)=plot(interval, (opf.qRD(1:72) - opf.qRU(1:72)));
% hold on
% legend(h,'s (MWh)','PRU ($/MW)','PRD ($/MW)','qR (MW)');

% legend(h,'P ($/MWh)','s (MWh)','q (MW)','qR (MW)','PRU ($/MW)','PRD ($/MW)');
xlabel('Time of the Day');