%%
clear all;
close all;
clc;

%%
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
