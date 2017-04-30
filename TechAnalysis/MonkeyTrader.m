% --- Monkey Trader------------------------------------------
% "Random" Trade strategy, used as a reference
% -----------------------------------------------------------
function T = MonkeyTrader(varargin)
%---Defines------------%
BUY_SUM = 1;
INITIAL_BANK = 0;
%----------------------%

%---Variables----------%
buy_sum = BUY_SUM;
initial_bank = INITIAL_BANK;
%-----------------------%

%---Arguments----------%
varargin = reconfigureVarargin(varargin);
parseVarargin;
%----------------------%

%----------------------%
T.Trade.CashIn = @(Indices,Time) MonkeyCashIn(Indices,Time);
T.Trade.CashOut = @(Indices,Position,Time) MonkeyCashOut(Indices,Position,Time);
T.Trade.BuySum = @(Indices,Time) buy_sum;
T.Trade.GenerateIndicators = @(Data) MonkeyIndicators();
T.Trade.StopLoss = @(Indicators,Time) MonkeyStopLoss(Indicators,Time);
T.Bank = []; T.Bank(1) = initial_bank;
%----------------------%

end

%% --- Indicators ------------------------------------------------------ %%
function I = MonkeyIndicators()
I = {};
end

%% --- Investment Rule ------------------------------------------------- %%
function buy = MonkeyCashIn(~,~) %(Indicators,Time)

EAGERNESS=0.005;

a = rand();

if (a <= EAGERNESS)
    buy = true;
else
    buy = false;
end

end

%% --- Cashout Rule ---------------------------------------------------- %%
function sell = MonkeyCashOut(~,~,~) %(Indicators,Position,Time)

EAGERNESS=0.01;

a = rand();

if (a <= EAGERNESS)
    sell = true;
else
    sell = false;
end

end

%% --- Alternative Cashout Rule ---------------------------------------- %%
% function sell = MonkeyCashOut1(~,~,~) %(Indicators,Position,Time)
% 
% EAGERNESS=0.01;
% 
% a = rand();
% if (a <= EAGERNESS)
%     sell = true;
% else
%     sell = false;
% end
% 
% end

%% --- Alternative Cashout Rule ---------------------------------------- %%
% function sell = MonkeyCashOut2(~,~,~) %(Indicators,Position,Time)
% 
% Delay_min = 120;
% Delay = Delay_min /(24*60);
% 
% if (Position.BuyTime-Time >= Delay)
%     sell = true;
% else
%     sell = false;
% end
% 
% end

%% --- Stop Loss ------------------------------------------------------- %%
function S = MonkeyStopLoss(~,~)   % (Indicators,Time);
S = 0;
end

%% --- Reconfigure varargin -------------------------------------------- %%
function new_vai = reconfigureVarargin(vai)
if ((~isempty(vai)) && (iscell(vai)) && (iscell(vai{1})))
    new_vai = vai{1}; 
end
end
