function Fss = lugref_ss(v, Fc, Fs, vs, sigma_2)
    r = -(v/vs).^2;
    
    % This equation is not lebaled on the paper, it is in the bottom left 
    % of the 2nd page 
    Fss = Fc*sign(v)+ (Fs - Fc) * exp(r) .* sign(v) + sigma_2 * v;      
end