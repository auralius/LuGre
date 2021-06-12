function xdot = sim_stick_slip(t, q, M, Fs, Fc, sigma_0, sigma_1, sigma_2, vs)   
    k = 2;              % stiffness of the spring
    y = 0.1*t;          % y is moving with 0.1 m/s of speed
    u = k * (y - q(1)); % force by the spring
   
    zdot = q(2) - ( (q(3)*abs(q(2))*sigma_0) / (Fc+(Fs-Fc)*exp(-(q(2)/vs)^2)) );
    F = sigma_0*q(3) + sigma_1 * zdot + sigma_2*q(2);

    qdot_1 = q(2);
    qdot_2 = (u - F) / M;
    qdot_3 = zdot;
    xdot = [qdot_1 ; qdot_2; qdot_3 ];
end