% Stanford University - CEE272R - Spring 2020

% Inputs:
% QD - max quantity that can be sold/discharged in a single period
% QR - max quantity that can be bought/recharged in a single period
% S - max storage cappacity
% gammaS - storeage efficiency
% gammaC - conversion efficiency
% gammaRU - regulation up efficiency
% gammaRD - regulation down efficiency
% T - number of 1 hour intervals
% r - interest rate, continuous compounding
% t - delta t (time period)
% CD = cost of discharging at time t ($/MWh)
% CR - cost of recharging at time t ($/MWh)
% P - price of electricity (LMP) at time t ($/MWh)
% PRU - price of regulation up at time t ($/MWh)
% PRD - price of regulation down at time t ($/MWh)

% Outputs:
% .qR - quantity of energy purchase (recharged) at time t (MWh)
% .qD - quantity of energy sold (discharged) at time t (MWh)
% .qRU - quantity of energy offered into the regulation up market at time t (MWh)
% .qRD - quantity of energy offered into the regulation up market at time t (MWh)
% .S - state of charge at time t
% .Rev - maximized revenue
% .LMP_opt - Locational marginal price [nx1]

function [opf]=proj_OPF(P,PRU,PRD,CD,CR,QD,QR,S,gammaS,gammaC,gammaRU,gammaRD,T,t,r)

cvx_begin
    variable qD(T); % optimization variable: qD
    variable qR(T); % optimization variable: qR
    variable s(T); % optimization variable: S
    variable qRU(T); % optimization variable: qRU
    variable qRD(T); % optimization variable: qRD

%     minimize(-(((P - CD)' * qD - (P + CR)' * qR) * exp(-r * t))) % objective function
    minimize(-(((P - CD)' * qD + (PRU + gammaRU * (P - CD))' * qRU + (PRD - gammaRD * (P + CR))' * qRD - (P + CR)' * qR) * exp(-r * t)))
    subject to

    %%%% arbitrage constraints
%     s(2:T) == gammaS * s(1:T-1) + gammaC * qR(2:T) - qD(2:T);
%     s(1) == 0;
%     qD(1) == 0; % do we need to enforce this?
%     0 <= s <= S;
%     0 <= qR <= QR;
%     0 <= qD <= QD;

    %%%% arbitrage and regulation constraints
    s(2:T) == gammaS * s(1:T-1) + gammaC * qR(2:T) - qD(2:T) + gammaC * gammaRD * qRD(2:T) - gammaRU * qRU(2:T);
    s(1) == 0;
    0 <= s <= S;
    0 <= (qR + qRD) <= QR;
    0 <= (qD + qRU) <= QD;
    0 <= (qD + qRD) <= QD; % to enforce no charging and discharging at the same time
    0 <= (qR + qRU) <= QR; % to enforce no charging and discharging at the same time
    0 <= qRU;
    0 <= qRD;
    0 <= qR;
    0 <= qD;

cvx_end

opf.Rev=-cvx_optval;
opf.s = s;
opf.qR = qR;
opf.qD = qD;
opf.qRU = qRU;
opf.qRD = qRD;

end