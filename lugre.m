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

%%
ts = 1e-6;
time_span = 0.1;
t = 0 : ts : time_span;

%% Velocity range
v = -0.005:0.0001:0.005;

%%
for i = 1 : length(v)
    z = 0;
    for j = 1 : length(t)
        r = -(v(i)/vs)^2;
        g = (Fc + (Fs - Fc) * exp(r)) / sigma_0;
        z_dot = v(i) - abs(v(i)) * z / g;
        z = z + z_dot * ts;
        
        F(j) = sigma_0 * z + sigma_1 * z_dot + sigma_2 * v(i);
    end
    Fss(i) = F(end);
end

plot(v, Fss)
grid
xlabel('Velocity (m/s)')
ylabel('Friction force (N)')
title('Friction force at steady state condition')

%% Zoom into certain velocity to see its transient behaviour
clear F v;
v = 0.002;
z = 0;
for j = 1 : length(t)
    r = -(v/vs)^2;
    g = (Fc + (Fs - Fc) * exp(r)) / sigma_0;
    z_dot = v - abs(v) * z / g;
    z = z + z_dot * ts;
    
    F(j) = sigma_0 * z + sigma_1 * z_dot + sigma_2 * v;
end

figure
plot(t, F);
grid
xlabel('Time (s)')
ylabel('Friction force (N)')
title('Friction force for v = 0.002')

%% Apply sinusoidal velocity and measure the friction force (Fig. 3 of the paper)
figure
hold on
color = ['rgb'];
clear F v;
t = 0 : ts : 10;
omega = [1 10 25];
for i = 1 : length(omega)
    z = 0;
    v = 0.001 * (sin(omega(i)*t)+1.5);
    for j = 1 : length(t)
        r = -(v(j)/vs)^2;
        g = (Fc + (Fs - Fc) * exp(r)) / sigma_0;
        z_dot = v(j) - abs(v(j)) * z / g;
        z = z + z_dot * ts;

        F(j) = sigma_0 * z + sigma_1 * z_dot + sigma_2 * v(i);
    end
    % Start from t = 3 up to the end
    plot(v(3*1/ts:end), F(3*1/ts:end), color(i));
end

grid
xlabel('Velocity (m/s)')
ylabel('Friction force (N)')
title('Hysteresis in friction with varying velocity')
legend('1 rad/s', '10 rad/s', '25 rad/s')
