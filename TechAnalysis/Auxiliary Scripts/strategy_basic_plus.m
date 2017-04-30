% --- Basic Strategy: EMA ----------------------------------------------- 
% http://forex-strategies-revealed.com/trading-strategy-ema               
%                                                                         
% Indicators: 10 EMA, 25 EMA, 50 EMA                                      
%                                                                         
% Buy Rule: When 10 EMA crosses 25 EMA and 50 EMA going up.              
%                                                                         
% Sell Rule: When 10 EMA crosses 25 EMA and 50 EMA going down.
%
% ADDED: stop loss
% ----------------------------------------------------------------------- 
function S = strategy_basic_plus(D,varargin)
HOLD = 1; BUY = 2; SELL = 3;    % states
INITIAL_FUND = 1000;
DEFAULT_THRESHOLD = 1e-3;
DEFAULT_STOP_LOSS = 2e-3;   
quite = false;

fund_a = INITIAL_FUND;
fund_b = 0;
threshold = DEFAULT_THRESHOLD;
short_period = 10;
long_period = 50;
stop_loss = DEFAULT_STOP_LOSS;
parseVarargin;

ema_short = getEMA(D,short_period);
ema_long = getEMA(D,long_period);
delta = ema_short-ema_long;

indices = [];
position = BUY;
for t = 1:length(D.time);
    
    switch position
        case BUY
            if (delta(t) > threshold)
                % time to buy
                fund_b = fund_a / D.close(t);  % XXXUSD
                fund_a = 0;
                buy_price = D.close(t);

                position = SELL;
                indices = [indices,t];
            end        
        
        case SELL
            if (delta(t) < 0) || (buy_price - D.close(t) > stop_loss)
               % time to sell
               fund_a = fund_b * D.close(t);
               fund_b = 0;
               position = HOLD;
               indices = [indices,t];
            end
              
        case HOLD  
            position = BUY;
            %break;
            
        otherwise
            break;
    end
        
end

if position == SELL
    % must sell at the end of the period
    fund_a = fund_b * D.close(t);
    fund_b = 0;
    indices = [indices,t];
end

S.buy_time = D.time(indices(1:2:end));
S.buy_value = D.close(indices(1:2:end));
S.sell_time = D.time(indices(2:2:end));
S.sell_value = D.close(indices(2:2:end));

S.ROI = 100*(fund_a-INITIAL_FUND)/INITIAL_FUND;
if ~quiet
    disp(['    - ROI: ',num2str(S.ROI),'%']);
end

end