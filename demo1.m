%%
clear all;
close all;
clc;

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
%  This is not shown in the paper.We here want ti demonstrate that the 
%  friction has a transient behaviour

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
title('Friction force for v = 0.002')
xlim([0 0.1]);

%% Apply sinusoidal velocity and measure the friction force (Fig. 3 of the paper)
% The input to the friction model was the velocity which was changed
% sinusoidally around an equilibrium. The resulting friction force is given 
% as a function of velocity 

figure
hold on
color = 'rgb';

clear F v;

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
    
    % Start from t = 5, at the begining, the F response is unconsistent
    % since we don't know hwo to initialize z.
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
% again

ts = 1e-3;
clear F v

M = 1; % a unit mass
F_max = 0.95 * Fs;
F1 = generate_ramp_signal(0, F_max, 10, ts);
F2 = generate_ramp_signal(F_max, F_max, 5, ts);
F3 = generate_ramp_signal(F_max, -F_max, 20, ts);
F4 = generate_ramp_signal(-F_max, -F_max, 5, ts);
F5 = generate_ramp_signal(-F_max, F_max, 20, ts);
F6 = generate_ramp_signal(F_max, F_max, 5, ts);

F = [F1 F2 F3 F4 F5 F6];

f = 0;
z = 0;
v_0 = 0;
x_0 = 0;
v = v_0;

for i = 1:length(F)
    [f(i), z] = lugref(z, v, Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts);
    
    a = (F(i)-f(i)) / M;
    v = v_0 + a * ts;
    x(i) = x_0 + v*ts;
    
    x_0 = x(i);
    v_0 = v;
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

clear F v;

k = 2;

ts = 1e-6; % 1e-4 fails!, very stiff system, needs a better ODE solver
time_span = 30;
t = 0 : ts : time_span;

y = generate_ramp_signal(0, time_span*0.1, time_span, ts);
x = 0;

f = 0;
z = 0;
v_0 = 0;
x_0 = 0;
v = v_0;

for i = 1:length(y)  
    [f(i), z] = lugref(z, v, Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts);
    f_spring = k*(y(i) - x(i));
    
    a = (f_spring - f(i)) / M;
    v = v_0 + a * ts;
    x(i+1) = x_0 + v*ts;
    
    x_0 = x(i+1);
    v_0 = v;
end

% compute the speed of the unit-mass
x_dot = gradient(x)/ts;

figure 
title('Simulation of stick-slip motion')

subplot(2,1,1)
hold on 
plot(t,x(2:end),'b')
plot(t,y,'r')
legend('x', 'y', 'Location','best')
xlabel('Time (s)')
ylabel('Position (m)')

subplot(2,1,2)
hold on

yyaxis left
plot(t,f);
ylabel('Friction Force (N)')
ylim([0 1.5])

yyaxis right
plot(t,x_dot(2:end));
ylabel('Velocity (m/s)')
ylim([0 1.5])

xlabel('Time (s)')

%% Varying Break-Away Force 

% A force applied to a unit mass was ramped up at different rates, and the 
% friction force when the mass started to slide was determined. ........ 
% The break-away force was therefore determined at the time where a sharp 
% increase in the velocity could be observed. 
%
% We simplify this by checking the first negative gradient of the force. 
% This is actually very dit=fficult, the risk of going unstable is very
% high here, especially at higer force rate.
%
% As soon as we detect the first negative gradient of the force, we must
% stop.

ts = 1e-6; % very stiff system, needs a better ODE solver
time_span = 2;
t = 0 : ts : time_span;

M = 1; % a unit mass

f_rate = [1 2 3 4 5 10 20 30 40 45 50];

for j = 1 : length(f_rate)
    
    clear F f v x

    F = generate_ramp_signal(0, f_rate(j)*time_span, time_span, ts);

    f = 0;
    z = 0;
    v_0 = 0;
    x_0 = 0;
    v = v_0;

    for i = 1:length(F)
        [f(i), z] = lugref(z, v, Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts);

        a = (F(i)-f(i)) / M;
        v = v_0 + a * ts;
        x(i) = x_0 + v*ts;

        x_0 = x(i);
        v_0 = v;

        if i > 1 && (f(i)-f(i-1)) < 0
            break;
        end
    end
    f_break(j) = f(i);
end

figure 
hold on
plot(f_rate, f_break, 'o')
ylim([0.9 1.5])
xlabel('Force rate (N/s)')
ylabel('Break-away force (N)')