% --- Get Stochastic Oscillator ----------------------------------------- 
% http://www.ehow.com/how_5131646_calculate-stochastics-make-stochastic-oscillator.html 
% http://en.wikipedia.org/wiki/Stochastic_oscillator
% http://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:stochastic_oscillator
% fast %K line: k_line[n] = 100*{CP[n] - lowCP} / {highCP - lowCP}.           
% CP = closing price, high/low = last N periods. (default - 14)                          
% fast %D line: EMA of %K for past M periods. (default - 3)                            
% slow %D line: EMA of %D for past P priods. (default - 3)   
% Stoch > 80 is overbought; < 20 is oversold
% ----------------------------------------------------------------------- 
function [k_line, d_line, s_line] = getStochasticOsc(D,varargin)
DEFAULT_FAST_K_PERIOD = 14;
DEFAULT_FAST_D_PERIOD = 3;
DEFAULT_SLOW_D_PERIOD = 3;

fast_k_period = DEFAULT_FAST_K_PERIOD;
fast_d_period = DEFAULT_FAST_D_PERIOD;
slow_d_period = DEFAULT_SLOW_D_PERIOD;

if (length(varargin) == 3)
    fast_k_period = varargin{1};
    fast_d_period = varargin{2};
    slow_d_period = varargin{3};
elseif (~isempty(varargin))
    error('expecting 3 parameters: fast_k (N), fast_d (M), slow_d (P)');
end

vec = D.close;
vector_length = length(D.close);
start = max([fast_k_period,fast_d_period,slow_d_period]);

% -- calculate %K line -----------
k_line = zeros(vector_length,1);
for i=start:vector_length
    sub_vec = vec((i-fast_k_period+1):i);
    k_line(i) = 100 * (vec(i) - min(sub_vec)) / (max(sub_vec) - min(sub_vec));
end
% --------------------------------

% -replace NaNs ------------------
k_line(isnan(k_line)) = 100;
% --------------------------------

% -- calculate %D lines ----------
C.close = k_line;
d_line = getEMA(C,fast_d_period);

C.close = d_line;
s_line = getEMA(C,slow_d_period);
% --------------------------------
end

