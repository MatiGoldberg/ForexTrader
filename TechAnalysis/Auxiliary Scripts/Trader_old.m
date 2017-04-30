% --- TRADER SUPER-FUNCTION ------------------------------------------
% Use: function T = Trader(trader_type, currency, start_date, end_date)
% Parameters:
%   - trader_type: 'Monkey', 'Basic', ...
%   - currency: 'GBPUSD' or 'EURUSD'
%   - start_date: in format 'yyyymmdd'
%   - end_date: in format 'yyyymmdd'
% Trader super-function runs a trade strategy in the desired range, 
% returning struct T which contains FX data, indicators and positions.
% see plotData for plotting.
% --------------------------------------------------------------------
function T = Trader(trader_type, currency, start_date, end_date, varargin)

%--Load trader type and set struct---------------%
switch trader_type
    case 'Monkey'
        T = MonkeyTrader(varargin);
    case 'Basic'
        T = BasicTrader(varargin);
    case 'Basic54'
        T = Basic54Trader(varargin);
    otherwise
        error('Unfamiliar trader type')
end

T.Position.SumInvested = [];
T.Position.RateAtBuy = [];
T.Position.BuyTime = [];
T.Position.UnitsBought = [];
T.Position.RateAtSale = [];
T.Position.SellTime = [];
T.Position.Revenue = [];
T.Position.StopLoss = [];
              
%--Load data---------------------------------%
T.Data = loadRange(currency, start_date, end_date);
T.Data = fixData(D.Data);
vector_length = length(T.Data.time);

%--Generate Indices--------------------------%
T.Indicators = T.Trade.GenerateIndicators(T.Data);

%==Trading Loop==============================%
n=1;
inPosition = false;

for currentTime = 1:vector_length
    
    if (currentTime == 1)
        previousTime=1;
    else
        previousTime=currentTime-1;
    end
    
    %---State-Machine-----------------------------------------------------%
    if ~inPosition
        
        Decision = T.Trade.InvestmentRule(T.Indicators, currentTime);
        
        switch Decision
            case 'Buy'
                inPosition = true;
                
                %--Deciside on investment----------------------%
                SumInvested = T.Trade.BuySum(T.Indicators, currentTime);
                
                %--Record Buying data--------------------------%
                T.Position.RateAtBuy(n) = T.Data.close(currentTime);
                T.Position.BuyTime(n) = T.Data.time(currentTime);
                T.Position.SumInvested(n) = SumInvested;
                T.Position.UnitsBought(n) = SumInvested/T.Position.RateAtBuy(n);
                T.Position.StopLoss(n) = T.Trade.StopLoss(T.Indicators,currentTime);
                %--Update account------------------------------%
                T.Bank(currentTime)=T.Bank(previousTime);%-T.Position(n).SumInvested;
                
            case 'DoNothing'
                T.Bank(currentTime)=T.Bank(previousTime);
            otherwise
                error('InvestmentRule encountered an error');
        end
    else
        % Dicision = SellRule & StopLoss
        Decision = T.Trade.CashOut(T.Indicators, T.Position, currentTime);
      
        switch Decision
            case 'Sell'
                inPosition = false;
                
                %--Record Selling data--------------------------%
                T.Position.RateAtSale(n) = T.Data.close(currentTime);
                T.Position.SellTime(n) = T.Data.time(currentTime);
                T.Position.Revenue(n) = T.Position.UnitsBought(n)*T.Position.RateAtSale(n)-T.Position.SumInvested(n);
                
                %--Update account------------------------------%
                T.Bank(currentTime) = T.Bank(previousTime)+T.Position.Revenue(n);
                
                n=n+1;
            case 'DoNothing'
                T.Bank(currentTime) = T.Bank(previousTime);
            otherwise
                error('CashOut encountered an error');
        end
    end
    %---State-Machine-END-------------------------------------------------%
end

%--Display Resluts---------- 
if (~isempty(T.Position.Revenue))
    disp(['    - ',num2str(length(T.Position.Revenue)),' positions, ',...
        'average revenue: ', num2str(tround(mean(T.Position.Revenue),4)),...
        ' (+/-) ',num2str(tround(std(T.Position.Revenue),4))]);
end
%---------------------------

disp('    - Trader Script ended successfully.');

end


%% --- TROUND: Round to digit ------------------
function x = tround(n,d)
x = round((10^d) * n) / (10^d);
end
             