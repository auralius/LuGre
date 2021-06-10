function xdot = sim_pid(~, q, M, Fs, Fc, sigma_0, sigma_1, sigma_2, vs, xd)
    Kp = 3;
    Ki = 4;
    Kv = 6;
    
    e = q(1) - xd;
    
    u = -Kv*q(2)-Kp*e-Ki*q(4);
   
    zdot = q(2) - ( (q(3)*abs(q(2))*sigma_0) / (Fc+(Fs-Fc)*exp(-(q(2)/vs)^2)) );
    F = sigma_0*q(3) + sigma_1 * zdot + sigma_2*q(2);

    qdot_1 = q(2);
    qdot_2 = (u - F) / M;
    qdot_3 = zdot;
    qdot_4 = e;
    xdot = [qdot_1 ; qdot_2; qdot_3; qdot_4];
end