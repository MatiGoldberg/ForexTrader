function [F_ut, F, P, sharpe] = DRDPassSeries(r, y, parameters, weights)

% -- Sanity ---------------------- %
assert(length(parameters)>=4);
assert(length(weights)>2);
assert(length(r)==length(y),'Aux and price series must be of same length');
% -------------------------------- %

% -- Setting Parameters ---------- %
series_len = length(r);
inputs = (length(weights)-2)/2;

[F,F_ut,R,Rs,P] = initSimulationParameters(series_len);

% Differential Sharpe Ratio
[A,B,sharpe] = initSRParameters(series_len);

% Parameters
[Mu,Delta,Eta,three_state_th,Zeta] = parseParameters(parameters);

% Weights
[w,u,v,s] = parseWeights(weights);
% -------------------------------- %

    
for t = (inputs+1):series_len
          
    % 1) Make Decision
    wr = sum(w'*r(t-inputs:t-1));
    sy = sum(s'*y(t-inputs:t-1));
    F_ut(t) = tanh( u*F_ut(t-1) + wr + sy + v ); 
    
    if (three_state_th)
        F(t) = threeState(F_ut(t),three_state_th);           
    else
        F(t) = sign(F_ut(t));
    end
    
    % 2) Evaluate Return and Profit
    R(t) = Mu*(F(t-1)*r(t) - Delta*abs(F(t)-F(t-1)));
    P(t) = P(t-1) + R(t);
    Rs(t) = R(t) + Zeta*F(t-1)*y(t);
    % for now, the preformence function U(t) is Differential Sharpe Ratio.

    % 3) Calculate Sharpe Ratio
    dA = Rs(t)    - A(t-1);
    dB = Rs(t).^2 - B(t-1);
    A(t) = A(t-1) + Eta*dA;
    B(t) = B(t-1) + Eta*dB;
    sharpe(t) = A(t)/B(t);
      
end

end


%% parse weights
function [w,u,v,s] = parseWeights(weights)
inputs = (length(weights)-2)/2;
w = weights(1:inputs);
u = weights(inputs+1);
v = weights(inputs+2);
s = weights(inputs+3:end);
end

%% three state
function out = threeState(in,th)

if in>th
    out = 1;
elseif in<-th;
    out = -1;
else
    out = 0;
end

end

%% parse parameters
function [Mu,Delta,Eta,three_state,Zeta] = parseParameters(parameters)
Mu      = parameters(1);
Delta   = parameters(2);
Eta     = parameters(3);
three_state = parameters(4);
Zeta    = parameters(11);
end

%% init sharpe ratio parameters
function [A,B,sharpe] = initSRParameters(series_len)
A = zeros(series_len,1);
B = ones(series_len,1);
sharpe = zeros(series_len,1); 
end

%% init simulation parameters
function [F,F_ut,R,Rs,P] = initSimulationParameters(series_len)
F    = zeros(series_len,1);
F_ut = zeros(series_len,1);
R    = zeros(series_len,1);
Rs   = zeros(series_len,1);
P    = zeros(series_len,1);
end