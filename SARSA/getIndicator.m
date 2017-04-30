function I = getIndicator(type,D,varargin)

switch type
    case 'EMA'
        I = getEMA(D,varargin{1});
    case 'SMA'
        I = getSMA(D,varargin{1});
    case 'WMA'
        I = getWMA(D,varargin{1});
    case 'Stoch'
        I = getStochOsc(D,varargin);
    case 'MACD'
        I = getMACD(D,varargin);
    case 'RSI'
        I = getRSI(D,varargin{1});
    case 'TSI'
        I = getTSI(D,varargin);
    case 'SR'
        I = getSupportResistance(D,varargin{1});
    case 'RFT'
        I = getRFT(D,varargin);
    case 'Sharpe'
        I = getSharpe(D,varargin);
    otherwise
        error('Undefined Indicator');
end

end

%% --- Exponentialy Moving Average -------------- %% 
% E(n) = k*P(n) + (k-1)*P(n-1)                      
% k = 2 / (N + 1)                                   
% -------------------------------------------------% 
function ema = getEMA(D,period)
% --- Arguments ---------------------------------- %
vector_length = length(D.close);
alpha = 2/(period+1);

if (period < 1) || (period > vector_length)
    error('period must be in range [1, vector_length]');
end
% ------------------------------------------------ %
vec = D.close;
% --- Calculate MA -(only-past-data)-------------- %
ema = zeros(size(vec));
ema(1) = vec(1);
for i=2:vector_length
    ema(i) = alpha*vec(i) + (1-alpha)*ema(i-1);
end
end

%% --- Simple Moving Average -------------------- %%
function sma = getSMA(D,period)
% --- Arguments ---------------------------------- %
vector_length = length(D.close);
% --- Consider Arguments ------------------------- %
if (period < 1) || (period > vector_length)
    error('period must be in range [1, vector_length]');
end
% ------------------------------------------------ %
vec = D.close;
% --- Calculate MA -(only-past-data)-------------- %
sma = zeros(size(vec));
sma(1:period) = vec(period+1);
for i=(period+1):vector_length
    sma(i) = sum((vec((i-period+1):i)))/period;
end
end

%% --- Weighted Moving Average ------------------- %%
function wma = getWMA(D,period)
% --- Arguments ----------------------------------- %
vector_length = length(D.close);
if (period < 1) || (period > vector_length)
    error('period must be in range [1, vector_length]');
end
% ------------------------------------------------- %
vec = D.close;
% --- Calculate MA -(only-past-data)--------------- %
wma = zeros(size(vec));
wma(1:period) = vec(period+1);
weight_vector = get_weight_vector(period);

for i=period:vector_length
    wma(i) = sum((vec((i-period+1):i).*weight_vector));
end
end

% ------------------------------------------------- %
function wv = get_weight_vector(ws)
wv = linspace(1,0,ws+1);
wv = wv./(sum(wv));
wv = wv(1:end-1)';
end

%% --- Get Stochastic Oscillator ----------------- %%
% http://www.ehow.com/how_5131646_calculate-stochastics-make-stochastic-oscillator.html 
% http://en.wikipedia.org/wiki/Stochastic_oscillator
% http://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:stochastic_oscillator
% fast %K line: k_line[n] = 100*{CP[n] - lowCP} / {highCP - lowCP}.           
% CP = closing price, high/low = last N periods. (default - 14)                          
% fast %D line: EMA of %K for past M periods. (default - 3)                            
% slow %D line: EMA of %D for past P priods. (default - 3)   
% Stoch > 80 is overbought; < 20 is oversold
% ------------------------------------------------- % 
function I = getStochOsc(D,varargin)
DEFAULT_FAST_K_PERIOD = 14;
DEFAULT_FAST_D_PERIOD = 3;
DEFAULT_SLOW_D_PERIOD = 3;

fast_k_period = DEFAULT_FAST_K_PERIOD;
fast_d_period = DEFAULT_FAST_D_PERIOD;
slow_d_period = DEFAULT_SLOW_D_PERIOD;

varargin = reconfigureVarargin(varargin);
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
I.k_line = zeros(vector_length,1);
for i=start:vector_length
    sub_vec = vec((i-fast_k_period+1):i);
    I.k_line(i) = 100 * (vec(i) - min(sub_vec)) / (max(sub_vec) - min(sub_vec));
end
% --------------------------------

% -replace NaNs ------------------
I.k_line(isnan(I.k_line)) = 100;
% --------------------------------

% -- calculate %D lines ----------
C.close = I.k_line;
I.d_line = getEMA(C,fast_d_period);

C.close = I.d_line;
I.s_line = getEMA(C,slow_d_period);
% --------------------------------
end

%% --- get MACD Lines ------------------------------- %%
% http://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:moving_average_conve
% http://en.wikipedia.org/wiki/MACD
function I = getMACD(D,varargin)
DEFAULT_P1 = 12;
DEFAULT_P2 = 26;
DEFAULT_P3 = 9;

p1 = DEFAULT_P1;
p2 = DEFAULT_P2;
p3 = DEFAULT_P3;

varargin = reconfigureVarargin(varargin);
if (~isempty(varargin)) && (length(varargin) ~= 3)
    error('should get three parameters');
elseif (length(varargin) == 3)
    p1 = varargin{1};
    p2 = varargin{2};
    p3 = varargin{3};
    %disp(['    - parameters: ',num2str(p1),', ',num2str(p2),', ',num2str(p3)]);
end

ema1 = getEMA(D,p1);    % EMA 12
ema2 = getEMA(D,p2);    % EMA 26

% -- MACD = EMA12 - EMA26 --
I.MACD = ema1-ema2;     
% --------------------------
C.close = I.MACD;

% -- Signal = EMA9 of MACD --
I.Signal = getEMA(C,p3);
% ---------------------------

% ---------------------------
I.Histogram =  I.MACD - I.Signal;
% ---------------------------
end


%% --- Relative Strength Indicator -------------------- %%
% http://en.wikipedia.org/wiki/Relative_strength_index
% RSI > 70 - overbought
% RSI < 30 - oversold
function RSI = getRSI(D,period)
vec = D.close;
dvec = cat(2,0,diff(vec)')';
up_dvec = zeros(size(dvec)); up_dvec(dvec>0) = dvec(dvec>0);
dn_dvec = zeros(size(dvec)); dn_dvec(dvec<0) = -dvec(dvec<0);

C_up.close = up_dvec;
C_dn.close = dn_dvec;

up_ema = getEMA(C_up,period);
dn_ema = getEMA(C_dn,period);

RS = (up_ema)./(dn_ema);
RSI = 100 * (1-1./(1+RS));
RSI(1) = 100;
end


%% --- True Strength Indicator ------------------------ %%
% http://en.wikipedia.org/wiki/True_strength_index
% TSI(CP,r,s) = 100*EMA(EMA(d,r),s)/EMA(EMA(|d|,r),s)
% where: d(n) = CP(n)-CP(n-1)
%        r,s are typically 25, 13
% TSI > 25 is overbought. TSI < -25 is oversold.
% use:
%   TSI = getTSI(D), or:
%   TSI = getTSI(D,r,s);
% ------------------------------------------------------
function TSI = getTSI(D,varargin)
DEFAULT_R = 25;
DEFAULT_S = 13;

r = DEFAULT_R;
s = DEFAULT_S;

varargin = reconfigureVarargin(varargin);
if length(varargin) == 2
    r = varargin{1};
    s = varargin{2};
elseif ~isempty(varargin)
    error('expecting 3 arguments: getTSI(D,r,s)');
end

delta = [0;diff(D.close)];

% --calculate nominator--
C.close = delta;
ema_nom = getEMA(C,r);
C.close = ema_nom;
nom = getEMA(C,s);
% -----------------------

% --calculate denominator--
C.close = abs(delta);
ema_denom = getEMA(C,r);
C.close = ema_denom;
denom = getEMA(C,s);
% -------------------------

TSI = 100 * (nom./denom);

end

%% --- Support and Resistence --------------------- %%
% ** attempt based on local minima/maxima **
% -------------------------------------------------
function I = getSupportResistance(D,period)
% --- Arguments ----------------------------------- %
vector_length = length(D.close);
if (period >= vector_length)
    error('window is larger than subject vector.');
end
% ------------------------------------------------- %
vec = D.close;
% --- Calculation --------------------------------- %
I.Support = zeros(size(vec));
I.Resistance = zeros(size(vec));

% - part 1: up to window_size - %
for i=1:period
    I.Support(i) = min(vec(1:i));
    I.Resistance(i) = max(vec(1:i));
end
% ---------------------------- %

% - part 2: window_size and on - %
for i=(period+1):vector_length
    I.Support(i) = min(vec((i-period+1):i));
    I.Resistance(i) = max(vec((i-period+1):i));
end
% ---------------------------- %

end

%% --- Reverse Fourier Transform ------------------- %%
% the concept is to use Fourier Transform in order to
% smooth the curve. we transform to Freq spectrum, 
% remove high-freq data and come back.
% Tmin = the minimal allowable movement in periods
% --------------------------------------------------
function RFT = getRFT(D,varargin)
DEFAULT_CHUNK_SIZE = 1;
DEFAULT_T_MIN = 10;

Tmin = DEFAULT_T_MIN;
chunk = DEFAULT_CHUNK_SIZE;

varargin = reconfigureVarargin(varargin);

if length(varargin) == 3
    window_size = varargin{1};
    Tmin = varargin{2};
    chunk = varargin{3};
elseif length(varargin) == 2
    window_size = varargin{1};
    Tmin = varargin{2};
elseif length(varargin) == 1
    window_size = varargin{1};
end

% check sanity
if (chunk > window_size)
   error('chunk size must be smaller than window size'); 
end

vec = D.close;
% --- calculate RFT ------------------
buf = mod(length(D.close)-window_size,chunk);
RFT = zeros(size(vec));
RFT(1:window_size+buf) = vec(1:window_size+buf);
for i=(window_size+buf):chunk:length(D.close)
    x = vec((i-window_size+1):i);
    xt = LowPassFilter(x,Tmin);
    RFT((i-chunk+1):i) = xt((end-chunk+1):end);
end
end

function xt = LowPassFilter(x,Tmin)
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


%% --- Sharpe Ratio Indicator ------------------------ %%
% http://en.wikipedia.org/wiki/Sharpe_ratio
% ------------------------------------------------------
function S = getSharpe(D,varargin)
DEFAULT_WINDOW = 60;

w = DEFAULT_WINDOW;

varargin = reconfigureVarargin(varargin);
if length(varargin) == 1
    w = varargin{1};
elseif ~isempty(varargin)
    error('expecting 1 arguments: getSharpe(D,window_size)');
end

vec = D.close;
S = zeros(size(vec));
for i = (window_size+1):length(vec)
    S(i) = mean(vec(i-window_size:i))./std(vec(i-window_size:i));
end


end


%% --- Reconfigure varargin ---------------------- %%
function new_vai = reconfigureVarargin(vai)
if ((~isempty(vai)) && (iscell(vai)) && (iscell(vai{1})))
    new_vai = vai{1}; 
end
end
