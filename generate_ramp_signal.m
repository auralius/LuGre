function signal=generate_ramp_signal(min_val, max_val, t_max, ts)

rate = (max_val - min_val) * ts /t_max;
signal = min_val : rate : max_val;

end