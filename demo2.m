%%
clear all;
close all;
clc;

disp('The simulation does take quite some time, be patient :-)')
disp('In my Lenovo x230 (i5-3320M, 2.6GHz, 16GB RAM), it takes about 6 seconds')
disp ('I use MATLAB R2018b')

% Convention:
% F -> friction force by the LuGre method
% u -> force applied to the mass 

%% ------------------------------------------------------------------------
tic

%% See Table I from the paper

sigma_0 = 1e5;
sigma_1  = sqrt(1e5);
sigma_2  = 0.4;
Fc = 1;
Fs = 1.5;
vs = 0.001;

%% Draw the overall friction force at steady state condition.
%  This is not shown in the paper

v = -0.005:0.0001:0.005;

for i = 1 : length(v)   
    Fss(i) = lugref_ss(v(i), Fc, Fs, vs, sigma_2);
end

figure
plot(v, Fss)
grid
xlabel('Velocity (m/s)')
ylabel('Friction force (N)')
title('Friction force at steady state condition')

%% Zoom into certain velocity to see its transient behaviour 
%  This is not shown in the paper. We here want to demonstrate that the 
%  LuGre friction model does have a transient behaviour.

clear F Fss v;

ts = 1e-3;
time_span = 20;
t_sol = 0 : ts : time_span;

v = 0.002;
z = 0;

for j = 1 : length(t_sol)
    [F(j), z] = lugref(z, v, Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts);
end

figure
plot(t_sol, F);
grid
xlabel('Time (s)')
ylabel('Friction force (N)')
title('Friction force for v = 0.002 m/s')
xlim([0 0.1]);

%% Apply sinusoidal velocity and measure the friction force (Fig. 3)
% The input to the friction model was the velocity which was changed
% sinusoidally around an equilibrium. The resulting friction force is given 
% as a function of velocity .

figure
hold on
color = 'rgb';

clear F v;

ts = 1e-3;
time_span = 20;
t_sol = 0 : ts : time_span;

omega = [1 10 25];

for i = 1 : length(omega)
    z = 0;
    v = 1e-3 * (cos(omega(i)*t_sol)+1.5); % sine also works
    for j = 1 : length(t_sol)
        [F(j), z] = lugref(z, v(j), Fc, Fs, vs, sigma_0, sigma_1, ...
                           sigma_2, ts);
    end
    
    % Start from t = 5, at the begining, the F response is unconsistent
    % since we don't know hwo to initialize z.
    plot(v(5/ts:end), F(5/ts:end), color(i));
end

grid
xlabel('Velocity (m/s)')
ylabel('Friction force (N)')
title('Hysteresis in friction with varying velocity')
legend('1 rad/s', '10 rad/s', '25 rad/s')

%% Presliding displacement (fig. 2)

% An external force was applied to a unit mass subjected to friction. The 
% applied force was slowly ramped up to 1.425 N which is 95 percents of Fs. 
% The force was then kept constant for a while and later ramped down to the 
% value -1.425 N, where it was kept constant and then ramped up to 1.425 N 
% again.

clear F v
    
time_span = [0 30]; % Let the solver pick its own sapmling rate;

q_initial = [0 0 0];
M = 1; % Unit-mass
    
% Use ode23s
[t_sol, q_sol] = ode23s(@sim_stick_slip, time_span, q_initial, [], ...
                        M, Fs, Fc, sigma_0, sigma_1, sigma_2, vs);   

% The problem is, there is no clean way to pass out other results with
% the built-in solver. We have to recompute the friction force.
for k = 1:length(t_sol)
    zdot = q_sol(k,2) - ( (q_sol(k,3)*abs(q_sol(k,2))*sigma_0) / ...
           (Fc+(Fs-Fc)*exp(-(q_sol(k,2)/vs)^2)) );
    F(k) = sigma_0*q_sol(k,3) + sigma_1 * zdot + sigma_2*q_sol(k,2);
end

figure 

subplot(2,1,1)
title('Simulation of stick-slip motion')
hold on 
plot(t_sol, q_sol(:,1),'b')
plot(t_sol, 0.1*t_sol,'r')
legend('$x$', '$y$', 'Location','best','interpreter','latex')
xlabel('Time (s)')
ylabel('Position (m)')

subplot(2,1,2)
hold on

yyaxis left
plot(t_sol, F);
ylabel('Friction Force (N)')
ylim([0 1.5])

yyaxis right
plot(t_sol, q_sol(:,2));
ylabel('$\frac{dx}{dt}$ (m/s)', 'interpreter','latex')
ylim([0 1.5])

xlabel('Time (s)')

%% Varying Break-Away Force (Fig. 4)

% A force applied to a unit mass was ramped up at different rates, and the 
% friction force when the mass started to slide was determined. ........ 
% The break-away force was therefore determined at the time where a sharp 
% increase in the velocity could be observed. 
%
% We simplify this by checking the first negative gradient of the force. 
% This is actually very difficult, the risk of going unstable is very
% high here, especially at higer force rate.
%
% As soon as we detect the first negative gradient of the force, we must
% stop.

clear F t_sol q_sol;

F_rate = [1 2 3 4 5 10 15 20 25 30 35 40 45 50];

for j = 1 : length(F_rate)
    
    time_span = [0 2]; % Let the solver pick its own sapmling rate;

    q_initial = [0 0 0];
    M = 1; % Unit-mass

    % Use ode23s
    [t_sol, q_sol] = ode23s(@sim_mass_with_ramp_force_input, time_span, ...
                            q_initial, [], M, Fs, Fc, sigma_0, sigma_1, ...
                            sigma_2, vs, F_rate(j));   

    % The problem is, there is no clean way to pass out other results with
    % the built-in solver. We have to recompute the friction force.
    for k = 1:length(t_sol)
        zdot = q_sol(k,2) - ( (q_sol(k,3)*abs(q_sol(k,2))*sigma_0) / ...
               (Fc+(Fs-Fc)*exp(-(q_sol(k,2)/vs)^2)) );
        F(k) = sigma_0*q_sol(k,3) + sigma_1 * zdot + sigma_2*q_sol(k,2);
        if (k>1) && (F(k)-F(k-1)<0)
            break;
        end
    end
    F_break(j) = F(k);
end

figure 
hold on
plot(F_rate, F_break, 'o')
ylim([0.9 1.5])
xlabel('Force rate (N/s)')
ylabel('Break-away force (N)')
title('Varying break-away force')
grid on

%% Presliding displacement (Fig. 2)

% An external force was applied to a unit mass subjected to friction. The 
% applied force was slowly ramped up to 1.425 N which is 95 percents of Fs. 
% The force was then kept constant for a while and later ramped down to the 
% value -1.425 N, where it was kept constant and then ramped up to 1.425 N 
% again.

M = 1; % a unit mass

clear F t_sol q_sol;
    
time_span = [0 65]; % Let the solver pick its own sapmling rate;

q_initial = [0 0 0];
M = 1; % Unit-mass
 
% Use ode23s
options = odeset('RelTol',1e-8,'AbsTol',1e-10); % for a perfect hysteresis

[t_sol, q_sol] = ode23s(@sim_presliding, time_span, q_initial, options, ...
                        M, Fs, Fc, sigma_0, sigma_1, sigma_2, vs);   

% The problem is, there is no clean way to pass out other results with
% the built-in solver. We have to recompute the friction force.
for k = 1:length(t_sol)
    zdot = q_sol(k,2) - ( (q_sol(k,3)*abs(q_sol(k,2))*sigma_0) / ...
           (Fc+(Fs-Fc)*exp(-(q_sol(k,2)/vs)^2)) );
    F(k) = sigma_0*q_sol(k,3) + sigma_1 * zdot + sigma_2*q_sol(k,2);
end

figure
plot(q_sol(:,1),F)
grid on
xlabel('Displacement (m)')
ylabel('Friction force (N)')
title('Presliding displacement')

%% Limit cycles caused by friction
%  Also known as hunting phenomenon because of the integral action.

clear F t_sol q_sol;

time_span = [0 100]; % Let the solver pick its own sapmling rate;

q_initial = [0 0 0 0];
M = 1; % Unit-mass
xd = 1; % Desired position

% Use ode23s
[t_sol, q_sol] = ode23s(@sim_pid, time_span, q_initial, [], ...
                        M, Fs, Fc, sigma_0, sigma_1, sigma_2, vs, xd);   

figure
hold on
plot(t_sol, q_sol(:,1))
plot(t_sol, ones(1,length(t_sol)).*xd);
xlabel('Time (s)')
ylabel('Position (m)')
legend('$x$', '$x_{d}$', 'Interpreter','Latex')
title('PID Simulation')

clear all;

%%
toc