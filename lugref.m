function [F, z] = lugref(z, v, Fc, Fs, vs, sigma_0, sigma_1, sigma_2, ts)
    r = -(v/vs)^2;
    g_v = (Fc + (Fs - Fc) * exp(r)) / sigma_0;          % eq. 4
    z_dot = v - abs(v) * z / g_v;                       % eq. 1 
    z = z + z_dot * ts;

    F = sigma_0 * z + sigma_1 * z_dot + sigma_2 * v;    % eq. 3
end