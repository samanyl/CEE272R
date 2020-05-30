%% storage data
randn('seed', 1);
T = 96; % 15 minute intervals in a 24 hour period
t = (1:T)';
p = exp(-cos((t-15)*2*pi/T)+0.01*randn(T,1));
L = 2*exp(-0.6*cos((t+40)*pi/T) -0.7*cos(t*4*pi/T)+0.01*randn(T,1));

plot(t/4, p);
hold on
plot(t/4, L);

%% storage operation
op = storage_operation(p,L,35,3,3,T);
op.cost_opt
op.u_opt
op.b_opt

%% plot results - 1b
plot(t/4, op.u_opt);
hold on
plot(t/4, op.b_opt);

%% storage operation w/ varying B
B = (1:150);
cost3 = zeros(1,150);
cost1 = zeros(1,150);
for b = 1:150
    op3 = storage_operation(p,L,b,3,3,T);
    cost3(b) = op3.cost_opt;

    op1 = storage_operation(p,L,b,1,1,T);
    cost1(b) = op1.cost_opt;
end

%% plot results - 1c
plot(B,cost3)
hold on
plot(B,cost1)

%% Cost Histogram
clear all;
clc;

Y = [1/0.1i+1/0.3i -1/0.1i -1/0.3i;
    -1/0.1i 1/0.1i+1/0.2i -1/0.2i;
    -1/0.3i -1/0.2i 1/0.3i+1/0.2i];
PGl = [0; 0; 0];
PGu = [1; 1; 0];
PF = [1 1 1];
thetal = -ones(3,1);
thetau = ones(3,1);
cost = zeros(1,100);
slack=1;
L2 = 0.100;
L3 = 0.150;
A1 = 10;
A2 = 5;
zscore = 3;

for i = 1:100
    CQ = [1; 1; 0];
    T = 3;
    t = 24; % 24 hours in one day
    sigma1_DA = (A1 * (1 - exp(-t/T)))/1000;
    sigma2_DA = (A2 * (1 - exp(-t/T)))/1000;
    C = 2;
    PD = [0;
          normrnd(L2,sigma1_DA) + zscore*sigma1_DA;
          normrnd(L3,sigma2_DA) + zscore*sigma2_DA];

    dam=DayAhead(Y,PGl,PGu,PD,PF,thetal,thetau,CQ,C,slack); % Day Ahead Dispatch

    s = sum(dam.P_opt,'all');
    t = 1; % 1 hour in 1 hour
    sigma1_HA = (A1 * (1 - exp(-t/T)))/1000;
    sigma2_HA = (A2 * (1 - exp(-t/T)))/1000;
    check = normrnd(L2,sigma1_HA) + zscore * sigma1_HA + normrnd(L3,sigma2_HA) + zscore * sigma2_HA;

    if s < check % check if hour ahead dispatch is needed
        CQ = [3; 3; 0];
        C = 6;
        PD = [-dam.P_opt(1);
               normrnd(L2,sigma1_HA) + zscore * sigma1_HA - dam.P_opt(2);
               normrnd(L3,sigma2_HA) + zscore * sigma2_HA];

        ham=DayAhead(Y,PGl,PGu,PD,PF,thetal,thetau,CQ,C,slack); % Hour Ahead Dispatch
    else
        ham.Cost = 0;
        ham.P_opt = [0;0;0];
    end

    loss = 1000 * (L2 + L3 - (sum(dam.P_opt,'all') + sum(ham.P_opt,'all')));

    if loss < 0
        cost(i) = ((1000*dam.P_opt(1))^2 + (1000*dam.P_opt(2))^2 + 2) + 3 * ((1000*ham.P_opt(1))^2 + (1000*ham.P_opt(2))^2 + 2);
    else
        cost(i) = ((1000*dam.P_opt(1))^2 + (1000*dam.P_opt(2))^2 + 2) + 3 * ((1000*ham.P_opt(1))^2 + (1000*ham.P_opt(2))^2 + 2) + loss;
    end
end

histogram(cost)

%% Cost Boxplots - costs

A1_1 = A1/2;
A2_1 = A2/2;

for i = 1:100
    CQ = [1; 1; 0];
    T = 3;
    t = 24; % 24 hours in one day
    sigma1_DA = (A1_1 * (1 - exp(-t/T)))/1000;
    sigma2_DA = (A2_1 * (1 - exp(-t/T)))/1000;
    C = 2;
    PD = [0;
          normrnd(L2,sigma1_DA) + zscore*sigma1_DA;
          normrnd(L3,sigma2_DA) + zscore*sigma2_DA];

    dam=DayAhead(Y,PGl,PGu,PD,PF,thetal,thetau,CQ,C,slack); % Day Ahead Dispatch

    s = sum(dam.P_opt,'all');
    t = 1; % 1 hour in 1 hour
    sigma1_HA = (A1_1 * (1 - exp(-t/T)))/1000;
    sigma2_HA = (A2_1 * (1 - exp(-t/T)))/1000;
    check = normrnd(L2,sigma1_HA) + zscore * sigma1_HA + normrnd(L3,sigma2_HA) + zscore * sigma2_HA;

    if s < check % check if hour ahead dispatch is needed
        CQ = [3; 3; 0];
        C = 6;
        PD = [-dam.P_opt(1);
               normrnd(L2,sigma1_HA) + zscore * sigma1_HA - dam.P_opt(2);
               normrnd(L3,sigma2_HA) + zscore * sigma2_HA];

        ham=DayAhead(Y,PGl,PGu,PD,PF,thetal,thetau,CQ,C,slack); % Hour Ahead Dispatch
    else
        ham.Cost = 0;
        ham.P_opt = [0;0;0];
    end

    loss = 1000 * (L2 + L3 - (sum(dam.P_opt,'all') + sum(ham.P_opt,'all')));

    if loss < 0
        cost2(i) = ((1000*dam.P_opt(1))^2 + (1000*dam.P_opt(2))^2 + 2) + 3 * ((1000*ham.P_opt(1))^2 + (1000*ham.P_opt(2))^2 + 2);
    else
        cost2(i) = ((1000*dam.P_opt(1))^2 + (1000*dam.P_opt(2))^2 + 2) + 3 * ((1000*ham.P_opt(1))^2 + (1000*ham.P_opt(2))^2 + 2) + loss;
    end
end

A1_1 = 2 * A1;
A2_1 = 2 * A1;

for i = 1:100
    CQ = [1; 1; 0];
    T = 3;
    t = 24; % 24 hours in one day
    sigma1_DA = (A1_1 * (1 - exp(-t/T)))/1000;
    sigma2_DA = (A2_1 * (1 - exp(-t/T)))/1000;
    C = 2;
    PD = [0;
          normrnd(L2,sigma1_DA) + zscore*sigma1_DA;
          normrnd(L3,sigma2_DA) + zscore*sigma2_DA];

    dam=DayAhead(Y,PGl,PGu,PD,PF,thetal,thetau,CQ,C,slack); % Day Ahead Dispatch

    s = sum(dam.P_opt,'all');
    t = 1; % 1 hour in 1 hour
    sigma1_HA = (A1_1 * (1 - exp(-t/T)))/1000;
    sigma2_HA = (A2_1 * (1 - exp(-t/T)))/1000;
    check = normrnd(L2,sigma1_HA) + zscore * sigma1_HA + normrnd(L3,sigma2_HA) + zscore * sigma2_HA;

    if s < check % check if hour ahead dispatch is needed
        CQ = [3; 3; 0];
        C = 6;
        PD = [-dam.P_opt(1);
               normrnd(L2,sigma1_HA) + zscore * sigma1_HA - dam.P_opt(2);
               normrnd(L3,sigma2_HA) + zscore * sigma2_HA];

        ham=DayAhead(Y,PGl,PGu,PD,PF,thetal,thetau,CQ,C,slack); % Hour Ahead Dispatch
    else
        ham.Cost = 0;
        ham.P_opt = [0;0;0];
    end

    loss = 1000* (L2 + L3 - (sum(dam.P_opt,'all') + sum(ham.P_opt,'all')));

    if loss < 0
        cost3(i) = ((1000*dam.P_opt(1))^2 + (1000*dam.P_opt(2))^2 + 2) + 3 * ((1000*ham.P_opt(1))^2 + (1000*ham.P_opt(2))^2 + 2);
    else
        cost3(i) = ((1000*dam.P_opt(1))^2 + (1000*dam.P_opt(2))^2 + 2) + 3 * ((1000*ham.P_opt(1))^2 + (1000*ham.P_opt(2))^2 + 2) + loss;
    end
end

%% Cost Boxplot - plots

boxplot([cost(:), cost2(:), cost3(:)]);

%% Conservative Alphas
zscore = 2.33; % alpha = 0.01
% zscore = 1.96; % alpha = 0.05

for i = 1:100
    CQ = [1; 1; 0];
    T = 3;
    t = 24; % 24 hours in one day
    sigma1_DA = (A1 * (1 - exp(-t/T)))/1000;
    sigma2_DA = (A2 * (1 - exp(-t/T)))/1000;
    C = 2;
    PD = [0;
          normrnd(L2,sigma1_DA) + zscore*sigma1_DA;
          normrnd(L3,sigma2_DA) + zscore*sigma2_DA];

    dam=DayAhead(Y,PGl,PGu,PD,PF,thetal,thetau,CQ,C,slack); % Day Ahead Dispatch

    s = sum(dam.P_opt,'all');
    t = 1; % 1 hour in 1 hour
    sigma1_HA = (A1 * (1 - exp(-t/T)))/1000;
    sigma2_HA = (A2 * (1 - exp(-t/T)))/1000;
    check = normrnd(L2,sigma1_HA) + zscore * sigma1_HA + normrnd(L3,sigma2_HA) + zscore * sigma2_HA;

    if s < check % check if hour ahead dispatch is needed
        CQ = [3; 3; 0];
        C = 6;
        PD = [-dam.P_opt(1);
               normrnd(L2,sigma1_HA) + zscore * sigma1_HA - dam.P_opt(2);
               normrnd(L3,sigma2_HA) + zscore * sigma2_HA];

        ham=DayAhead(Y,PGl,PGu,PD,PF,thetal,thetau,CQ,C,slack); % Hour Ahead Dispatch
    else
        ham.Cost = 0;
        ham.P_opt = [0;0;0];
    end

    loss = 1000 *(L2 + L3 - (sum(dam.P_opt,'all') + sum(ham.P_opt,'all')));

    if loss < 0
        costA(i) = ((1000*dam.P_opt(1))^2 + (1000*dam.P_opt(2))^2 + 2) + 3 * ((1000*ham.P_opt(1))^2 + (1000*ham.P_opt(2))^2 + 2);
    else
        costA(i) = ((1000*dam.P_opt(1))^2 + (1000*dam.P_opt(2))^2 + 2) + 3 * ((1000*ham.P_opt(1))^2 + (1000*ham.P_opt(2))^2 + 2) + loss;
    end
end

%%
histogram(costA)
