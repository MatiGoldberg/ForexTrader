% --- Basic Trader-------------------------------------------
% http://forex-strategies-revealed.com/simple/double-account-per-month                                                                                   
% Indicators: 8 EMA, 34 EMA, Stochastic, MACD                                                                                                             
% Buy Rule:               
%       1. EMA8 > EMA34 (=uptrend)
%       2. Stoch. < 20  (=oversold)
%       3. MACD_signal < MACD_Histogram (=price reversal)
% Sell Rule: 
%       1. EMA8 < EMA34 (=downtrend)
%       2. Stoch. > 80  (=overbought)
%       3. MACD_signal > MACD_Histogram (=price reversal)
%       OR: stop loss = support level
% --- Basic Trader-------------------------------------------
function T = Basic54Trader(varargin)
%---Defines------------%
BUY_SUM = 1;
INITIAL_BANK = 0;
DEFAULT_THRESHOLD = 1e-3;
DEFAULT_SHORT_PERIOD = 8;
DEFAULT_LONG_PERIOD = 34;
DEFAULT_SR_PERIOD = 60;
DEFAULT_SL_MARGIN = 5;  % percent
%----------------------%

%---Variables----------%
buy_sum = BUY_SUM;
initial_bank = INITIAL_BANK;
threshold = DEFAULT_THRESHOLD;
short_period = DEFAULT_SHORT_PERIOD;
long_period = DEFAULT_LONG_PERIOD;
sr_period = DEFAULT_SR_PERIOD;
stop_loss_margin = DEFAULT_SL_MARGIN;
%-----------------------%

%---Arguments----------%
varargin = reconfigureVarargin(varargin);
parseVarargin;
%----------------------%

%----------------------%
T.Trade.CashIn= @(Indicators,Time) Basic54CashIn(Indicators,Time);
T.Trade.CashOut = @(Indicators,Position,Time) Basic54CashOut(Indicators,Position,Time);
T.Trade.BuySum = @(Indicators,Time) buy_sum;
T.Trade.GenerateIndicators = @(Data) Basic54Indicators(short_period, long_period, sr_period, Data);
T.Trade.StopLoss = @(Indicators,Time) Basic54StopLoss(stop_loss_margin,Indicators,Time);
T.Bank = initial_bank;
%----------------------%

end

%% --- Indicators ------------------------------------------------------ %%
function I = Basic54Indicators(short_period, long_period, sr_period, Data)
ema_short = getIndicator('EMA', Data, short_period);
ema_long = getIndicator('EMA', Data, long_period);
macd = getIndicator('MACD',Data,12,26,9);
stoch = getIndicator('Stoch',Data,9,3,3);
sr = getIndicator('SR',Data,sr_period);

I.EMAshort = ema_short;
I.EMAlong = ema_long;
I.Fast_D = stoch.d_line;
I.Signal = macd.Signal;
I.Histogram = macd.Histogram;
I.Support = sr.Support;
I.Resistance = sr.Resistance;

% I = struct(['EMA_',num2str(short_period)], ema_short,...
%            ['EMA_',num2str(long_period)], ema_long);

end

%% --- Investment Rule ------------------------------------------------- %%
function buy = Basic54CashIn(I,t) % Threshold, Indicator struct, time
% [EMA_short, EMA_long] = getEMAs(I);

if ((I.EMAshort(t) < I.EMAlong(t)) && (I.Fast_D(t) < 20) && (I.Signal(t) < I.Histogram(t)))
    buy = true;
else
    buy = false;
end

end

%% --- Cashout Rule ---------------------------------------------------- %%
function sell = Basic54CashOut(I,~,t) %(Indicators,Position,Time)
% [EMA_short, EMA_long] = getEMAs(I);

sell_condition = ((I.EMAshort(t) > I.EMAlong(t)) && (I.Fast_D(t) > 80) && (I.Signal(t) > I.Histogram(t)));

if (sell_condition)
    sell = true;
else
    sell = false;
end

end

%% --- Stop Loss ------------------------------------------------------- %%
function StopLoss = Basic54StopLoss(stop_loss_margin,Indicators,Time)

% Stop loss = margin [%] under support level at purchase

StopLoss = Indicators.Support(Time) - stop_loss_margin*...
    (Indicators.Resistance(Time) - Indicators.Support(Time))/100 ;

end

%% --- Get Short and Long EMAs from Indicator Struct ------------------- %%
% function [Short, Long] = getEMAs(I)
% names = fieldnames(I);
% if (length(names) ~= 2)
%     error('unexpected number of fields');
% end
% 
% a = str2num(names{1}(5:end));
% b = str2num(names{2}(5:end));
% 
% if( ~isnumeric(a) || ~isnumeric(b) )
%     error('unexpected indicator name');
% end
% 
% if (b>a) % a = short, b = long
%     Short = getfield(I,names{1});
%     Long = getfield(I,names{2});
% else     % a = long, b = short
%     Short = getfield(I,names{2});
%     Long = getfield(I,names{1});
% end
% 
% end

%% --- Reconfigure varargin -------------------------------------------- %%
function new_vai = reconfigureVarargin(vai)
if ((~isempty(vai)) && (iscell(vai)) && (iscell(vai{1})))
    new_vai = vai{1}; 
end
end
