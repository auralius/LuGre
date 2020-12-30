function xdot = sim_presliding(t, q, M, Fs, Fc, sigma_0, sigma_1, sigma_2, vs)
    rate = 0.1425;
    
    if t <= 10
        u = rate*t;    
    elseif t > 10 && t <= 15
        u = 1.425;
    elseif t > 15 && t <= 35
        u = 1.425 - rate*(t-15);
    elseif t > 35 && t <= 40
        u = -1.425;
    elseif t > 40 && t <= 60
        u = -1.425 + rate*(t-40);  
    elseif t > 60
        u = 1.425;
    end
   
    zdot = q(2) - ( (q(3)*abs(q(2))*sigma_0) / (Fc+(Fs-Fc)*exp(-(q(2)/vs)^2)) );
    F = sigma_0*q(3) + sigma_1 * zdot + sigma_2*q(2);

    qdot_1 = q(2);
    qdot_2 = (u - F) / M;
    qdot_3 = zdot;
    xdot = [qdot_1 ; qdot_2; qdot_3 ];
end