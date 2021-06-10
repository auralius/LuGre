%% Demo of frictio compensation
% What the paper doesn't say is that if you tune the PI and velocity gains, the performance is better then the friction
% observer. 
%
% The given input xd is a step function, thus the second derivative of xd
% is zero. The last term of Eq. 14 is removed.
%

%%
clear;
close all;
clc;

%% ------------------------------------------------------------------------
tic

%% Input Parameter for optimally tuned PI and velocity gains

sigma_0 = 1e5;
sigma_1  = sqrt(1e5);
sigma_2  = 0.4;
Fc = 1;
Fs = 1.5;
vs = 0.001;

% Controller gains
Kp = 609.4;
Ki = 0;
Kv = 40.2;
k = 0;

clear F t_sol q_sol;

time_span = [0 10]; % Let the solver pick its own sapmling rate;

q_initial = [0 0 0 0 0];
M = 1; % Unit-mass
xd = 1; % Desired position

% Use ode23s
options = odeset('RelTol',1e-6,'AbsTol',1e-7); % for a perfect hysteresis
[t_sol, q_sol] = ode23s(@sim_fiction_compensation, time_span, q_initial, [], ...
                        M, Fs, Fc, sigma_0, sigma_1, sigma_2, vs, xd,Kp,Ki,Kv,k);   

figure
hold on
plot(t_sol, q_sol(:,1))
plot(t_sol, ones(1,length(t_sol)).*xd);
xlabel('Time (s)')
ylabel('Position (m)')
legend('$x$', '$x_{d}$', 'Interpreter','Latex')
title('PID position control with friction observer')

