% --- Basic Trader-------------------------------------------
% http://forex-strategies-revealed.com/trading-strategy-ema                                                                                       
% Indicators: 10 EMA, 25 EMA*, 50 EMA                                                                                                             
% Buy Rule: When 10 EMA crosses 25 EMA and 50 EMA going up.                                                                                    
% Sell Rule: When 10 EMA crosses 25 EMA and 50 EMA going down.
% * (I removed 25 EMA)
% --- Basic Trader-------------------------------------------
function T = BasicTrader(varargin)
%---Defines------------%
BUY_SUM = 1;
INITIAL_BANK = 0;
DEFAULT_THRESHOLD = 1e-3;
DEFAULT_SHORT_PERIOD = 10;
DEFAULT_LONG_PERIOD = 50;
%----------------------%

%---Variables----------%
buy_sum = BUY_SUM;
initial_bank = INITIAL_BANK;
threshold = DEFAULT_THRESHOLD;
short_period = DEFAULT_SHORT_PERIOD;
long_period = DEFAULT_LONG_PERIOD;
%-----------------------%

%---Arguments----------%
varargin = reconfigureVarargin(varargin);
parseVarargin;
%----------------------%

%----------------------%
T.Trade.CashIn = @(Indicators,Time) BasicCashIn(threshold,Indicators,Time);
T.Trade.CashOut = @(Indicators,Position,Time) BasicCashOut(Indicators,Position,Time);
T.Trade.BuySum = @(Indicators,Time) buy_sum;
T.Trade.GenerateIndicators = @(Data) BasicIndicators(short_period, long_period, Data);
T.Trade.StopLoss = @(Indicators,Time) BasicStopLoss(Indicators,Time);
T.Bank = initial_bank;
%----------------------%

end

%% --- Indicators ------------------------------------------------------ %%
function I = BasicIndicators(short_period, long_period, Data)
ema_short = getIndicator('EMA', Data, short_period);
ema_long = getIndicator('EMA', Data, long_period);

% I.EMA_short = ema_short;
% I.EMA_long = ema_long;

I = struct(['EMA_',num2str(short_period)], ema_short,...
           ['EMA_',num2str(long_period)], ema_long);

end

%% --- Investment Rule ------------------------------------------------- %%
function buy = BasicCashIn(th,I,t) % Threshold, Indicator struct, time
[EMA_short, EMA_long] = getEMAs(I);

if (EMA_short(t) - EMA_long(t) > th)
    buy = true;
else
    buy = false;
end

end

%% --- Cashout Rule ---------------------------------------------------- %%
function sell = BasicCashOut(I,~,t) %(Indicators,Position,Time)
[EMA_short, EMA_long] = getEMAs(I);

if (EMA_short(t) - EMA_long(t) < 0)
    sell = true;
else
    sell = false;
end

end

%% --- Stop Loss ------------------------------------------------------- %%
function S = BasicStopLoss(~,~)   % (Indicators,Time);
S = 0;
end


%% --- Get Short and Long EMAs from Indicator Struct ------------------- %%
function [Short, Long] = getEMAs(I)
names = fieldnames(I);
if (length(names) ~= 2)
    error('unexpected number of fields');
end

a = str2num(names{1}(5:end));
b = str2num(names{2}(5:end));

if( ~isnumeric(a) || ~isnumeric(b) )
    error('unexpected indicator name');
end

if (b>a) % a = short, b = long
    Short = getfield(I,names{1});
    Long = getfield(I,names{2});
else     % a = long, b = short
    Short = getfield(I,names{2});
    Long = getfield(I,names{1});
end

end

%% --- Reconfigure varargin -------------------------------------------- %%
function new_vai = reconfigureVarargin(vai)
if ((~isempty(vai)) && (iscell(vai)) && (iscell(vai{1})))
    new_vai = vai{1}; 
end
end
