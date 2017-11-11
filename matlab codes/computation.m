% Kaichen Zhang & Xiaoyu Gao EE597 project
% Numerical calculations based on Bianchis article
clear; clc; close all;
% Set default parameters from the article
SIFS = 28; DIFS = 128; slot_time = 50; prop_delay = 1;% us
PayLoad = 8184; MAC_header = 272; PHY_header = 128; ack = 112; % bits
Packet = MAC_header + PHY_header + PayLoad; % bits
ACK = 112 + PHY_header; % bits
Ts = (Packet + SIFS + ACK + DIFS + 2 * prop_delay) / slot_time;
Tc = (Packet + DIFS + prop_delay) / slot_time;

% Set the window size and stage number by typing inputs
W = input('Minimum backoff window size: (in slot time)\n');
m = input('Maximum stage number: \n');

% Computation
throughput = [];
for n = 5 : 1 : 100 % Start from 5 stations condition
    fun = @(p) (p-1+(1-2*(1-2*p)/((1-2*p)*(W+1)+ p*W*(1-(2*p)^m)))^(n-1));
    % P is the probability that transmitted packet collide
    P = fzero(fun,[0,1]); 
    % tau is probability that a station transmits in a generic slot time
    tau = 2*(1-2*P)/((1-2*P)*(W+1)+ P*W*(1-(2*P)^m));
    % Ptr is that in a slot time there is at least one transmission
    Ptr = 1 - (1 - tau) ^ n;
    % Ps is the probability that a transmission is successful
    Ps = n * tau * (1 - tau) ^ (n - 1) / Ptr;
    % ETX is the number of consecutive idle slots between two consecutive transmissions on the channel
    E_Idle = 1 / Ptr - 1;
    % Throughput = Ps * E[P] / (ETX + Ps * Ts + (1 - Ps) * Tc)
    throughput = [throughput, Ps*(PayLoad/slot_time)/(E_Idle+Ps*Ts+(1-Ps)*Tc)];
end
plot(5 : 1 : 100,throughput,'LineWidth',1.5);
hold on;
axis([0 100 0 1]);
xlabel('Number of Stations');
ylabel('Total throughput');
title('Total throughput vs Number of different stations in basic case');
grid on;