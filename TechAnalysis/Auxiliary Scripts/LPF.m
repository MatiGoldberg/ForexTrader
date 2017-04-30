function xt = LPF(x,Tmin)

window_size = length(x);    % min

Fs = 1/1;       % [1/per]
Fc = 1/Tmin;    % [1/per]

if (Fc > Fs/2)
    error('Tmin too low');
end

fi = round((window_size)*Fc/(Fs/2));

y = fft(x);
y((fi+1):(end-fi)) = 0;
xt = abs(ifft(y));

end