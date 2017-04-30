% --- Exponentialy Moving Average ----------------- 
% ema = getEMA(D,periods)
%
% E(n) = k*P(n) + (k-1)*P(n-1)                      
% k = 2 / (N + 1)                                   
% ------------------------------------------------- 
function ema = getEMA(D,period)

% --- Arguments ----------------------------------- %
vector_length = length(D.close);
alpha = 2/(period+1);

if (alpha > 1) || (alpha < 0)
    error('alpha value must be in range [0,1]');
end
% ------------------------------------------------- %

vec = D.close;

% --- Calculate MA -(only-past-data)--------------- %
%~ not using movavg on purpose ~%
ema = zeros(size(vec));
ema(1) = vec(1);
for i=2:vector_length
    ema(i) = alpha*vec(i) + (1-alpha)*ema(i-1);
end

% -- return ema -- %

end
