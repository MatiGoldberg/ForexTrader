function RFT = getRFT(D,window_size,Tmin)
vec = D.close;

RFT = zeros(size(vec));
RFT(1:window_size) = vec(1:window_size);
for i=(window_size):length(D.close)
    x  = vec((i-window_size+1):i);
    xt = LPF(x,Tmin); 
    RFT(i) = xt(end);
end

%--return rft--%

end

%%-----------------------------------------------------------------------%%
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