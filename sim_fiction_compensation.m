function xdot = sim_fiction_compensation(t, q, M, Fs, Fc, sigma_0, sigma_1, sigma_2, vs, xd)
    Kp = 3;
    Ki = 4;
    Kv = 6;
    
    e = q(1) - xd;
   
    
    % Estimator
    % In reality, Fc, Fs, sigma_0, sigma_1 and sigma_2 will not be known
    % exactly, thus, their values will be different with Table I. However,
    % here we use similar values as in Table I
    k = 10;
    zdot_tilde = q(2) - ( (q(5)*abs(q(2))*sigma_0) / (Fc+(Fs-Fc)*exp(-(q(2)/vs)^2)) ) -k*e;
    F_tilde =  sigma_0*q(3) + sigma_1 * zdot_tilde + sigma_2*q(2);
    
    u = -Kv*q(2)-Kp*e-Ki*q(4) + F_tilde; % the input here is a step function, second derivative of xd is zero
    
    zdot = q(2) - ( (q(3)*abs(q(2))*sigma_0) / (Fc+(Fs-Fc)*exp(-(q(2)/vs)^2)) );
    F = sigma_0*q(3) + sigma_1 * zdot + sigma_2*q(2);

    qdot_1 = q(2);
    qdot_2 = (u - F) / M;
    qdot_3 = zdot;
    qdot_4 = e;
    qdot_5 = zdot_tilde;
    xdot = [qdot_1 ; qdot_2; qdot_3; qdot_4; qdot_5];
end