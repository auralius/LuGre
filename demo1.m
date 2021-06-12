%%
clear all;
close all;
clc;

disp('The simulation does take quite some time, be patient :-)')
disp('In my Lenovo x230 (i5-3320M, 2.6GHz, 16GB RAM), it takes about 30 seconds')
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

clear F v;

ts = 1e-3;
time_span = 20;
t = 0 : ts : time_span;

v = 0.002;
z = 0;

for j = 1 : length(t)
    [F(j), z] = lugref(z, v, Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts);
end

figure
plot(t, F);
grid
xlabel('Time (s)')
ylabel('Friction force (N)')
title('Friction force for v = 0.002 m/s')
xlim([0 0.1]);

%% Apply sinusoidal velocity and measure the friction force (Fig. 3 of the paper)
% The input to the friction model was the velocity which was changed
% sinusoidally around an equilibrium. The resulting friction force is given 
% as a function of velocity .

figure
hold on
color = 'rgb';

clear F Fss v;

ts = 1e-3;
time_span = 20;
t = 0 : ts : time_span;

omega = [1 10 25];

for i = 1 : length(omega)
    z = 0;
    v = 1e-3 * (cos(omega(i)*t)+1.5); % sine also works
    for j = 1 : length(t)
        [F(j), z] = lugref(z, v(j), Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts);
    end
    
    % Start from t = 5, at the begining, the F response is inconsistent
    % since we don't know how to initialize z. Here, we initialize z with 0.
    plot(v(5/ts:end), F(5/ts:end), color(i));
end

grid
xlabel('Velocity (m/s)')
ylabel('Friction force (N)')
title('Hysteresis in friction with varying velocity')
legend('1 rad/s', '10 rad/s', '25 rad/s')

%% Presliding displacement

% An external force was applied to a unit mass subjected to friction. The 
% applied force was slowly ramped up to 1.425 N which is 95 percents of Fs. 
% The force was then kept constant for a while and later ramped down to the 
% value -1.425 N, where it was kept constant and then ramped up to 1.425 N 
% again.

ts = 1e-3;
clear F v

M = 1; % a unit mass

u_max = 0.95 * Fs; % 95 %
u1 = generate_ramp_signal(0, u_max, 10, ts);
u2 = generate_ramp_signal(u_max, u_max, 5, ts);
u3 = generate_ramp_signal(u_max, -u_max, 20, ts);
u4 = generate_ramp_signal(-u_max, -u_max, 5, ts);
u5 = generate_ramp_signal(-u_max, u_max, 20, ts);
u6 = generate_ramp_signal(u_max, u_max, 5, ts);

u = [u1 u2 u3 u4 u5 u6]; % put them together

% Some initializations
F = 0;
z = 0;
x_0 = 0;
v = 0;

% Do the simulation for all input u
for i = 1:length(u)
    [F(i), z] = lugref(z, v, Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts);
    
    a = (u(i)-F(i)) / M;
    v = v + a * ts;
    x(i) = x_0 + v*ts;
    
    x_0 = x(i);
end

figure
plot(x,F)
grid on
xlabel('Displacement (m)')
ylabel('Friction force (N)')
title('Presliding displacement')

%% Stick-slip motion (Fig. 5)

% A unit mass is attached to a spring with stiffness k = 2 N/m. The end of
% the spring is pulled with constant velocity, i.e., dy/dt = 0.1 m/s. 

clear F v u u1 u2 u3 u4 u5 u6;

k = 2; % stiffness k = 2 N/m

ts = 1e-6; % 1e-4 fails, this is very stiff system, we need a better ODE solver
time_span = 30;
t = 0 : ts : time_span;

% generate_ramp_signal(min_val, max_val, t_max, ts)
% The velocity is 0.1 m/s, it means if we start from t=0 to t=time_span
% then our travel distace is 0.1*time_span
y = generate_ramp_signal(0, time_span*0.1, time_span, ts);

% Some initializations
x = 0;
z = 0;
x_0 = 0;
v = 0;

% Do the simulation
for i = 1:length(y)  
    [F(i), z] = lugref(z, v, Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts);
    u_spring = k*(y(i) - x(i));
    
    a = (u_spring - F(i)) / M;
    v = v + a * ts;
    x(i+1) = x_0 + v * ts;
    
    x_0 = x(i+1);
end

% Compute the speed of the unit-mass
x_dot = gradient(x)/ts;

figure 

subplot(2,1,1)
title('Simulation of stick-slip motion')
hold on 
plot(t,x(2:end),'b')
plot(t,y,'r')
legend('$x$', '$y$', 'Location','best','interpreter','latex')
xlabel('Time (s)')
ylabel('Position (m)')

subplot(2,1,2)
hold on

yyaxis left
plot(t,F);
ylabel('Friction Force (N)')
ylim([0 1.5])

yyaxis right
plot(t,x_dot(2:end));
ylabel('$\frac{dx}{dt}$ (m/s)', 'interpreter','latex')
ylim([0 1.5])

xlabel('Time (s)')

%% Varying Break-Away Force 

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

ts = 1e-6; % very stiff system, we need a better ODE solver
time_span = 2;
t = 0 : ts : time_span;

M = 1; % a unit mass

% I am just guessing from Fig. 4
F_rate = [1 2 3 4 5 10 20 30 40 45 50];

for j = 1 : length(F_rate)
    
    % Always clear up the old values
    clear F v x x_dot

    u = generate_ramp_signal(0, F_rate(j)*time_span, time_span, ts);

    F = 0;
    z = 0;
    x_0 = 0;
    v = 0;

    for i = 1:length(u)
        [F(i), z] = lugref(z, v, Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts);

        a = (u(i)-F(i)) / M;
        v = v + a * ts;
        x(i) = x_0 + v*ts;

        x_0 = x(i);

        % When motion occurs, the resulting force suddenly drops
        % See Fig. 6 (bottom figure)
        if i > 1 && (F(i)-F(i-1)) < 0
            break;
        end
    end
    F_break(j) = F(i);
end

figure 
hold on
plot(F_rate, F_break, 'o')
ylim([0.9 1.5])
xlabel('Force rate (N/s)')
ylabel('Break-away force (N)')
grid on

%% Limit cycles caused by friction
%  Also known as hunting phenomenon because of the integral action.

clear F x y u;

ts = 1e-5; % 1e-4 fails, very stiff system, needs a better ODE solver
time_span = 100;
t = 0 : ts : time_span;

% PID parameters
Kv = 6;
Kp = 3;
Ki = 4;

% Desired position for the mass, its intial position is x = 0
xd = 1;

% Some initializations
z = 0;
x_0 = 0;
v = 0;
x = x_0;

% The integral of error with respect to time
int_e = 0;

for i = 1:length(t)
    [F(i), z] = lugref(z, v, Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts);
    
    e = x(i) - xd;
    int_e = int_e + e * ts; 
    u = -Kv*v - Kp*e - Ki*int_e; % eq. 11
    
    a = (u - F(i)) / M;
    v = v + a * ts;
    x(i+1) = x_0 + v * ts;
    
    x_0 = x(i+1);
end

figure
hold on
plot(t, x(2:end))
plot(t, ones(1,length(t)).*xd);
xlabel('Time (s)')
ylabel('Position (m)')
legend('$x$', '$x_{d}$', 'Interpreter','Latex')
title('PID Simulation')

clear all;

%% ------------------------------------------------------------------------
toc