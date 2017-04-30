% --- Basic Strategy: EMA ----------------------------------------------- 
% http://forex-strategies-revealed.com/simple/double-account-per-month             
%                                                                         
% Indicators: 8 EMA, 34 EMA, Stochastic, MACD                                      
%                                                                         
% Buy Rule:               
%       1. EMA8 > EMA34 (=downtrend)
%       2. Stoch. < 20  (=oversold)
%       3. MACD_signal < MACD_Histogram (=price reversal)
%
% Sell Rule: 
%       1. EMA8 < EMA34 (=uptrend)
%       2. Stoch. > 80  (=overbought)
%       3. MACD_signal > MACD_Histogram (=price reversal)
%       OR: stop loss = support level
% ----------------------------------------------------------------------- 
function S = strategy_basic54(D,varargin)
HOLD = 1; BUY = 2; SELL = 3;    % states
INITIAL_FUND = 1000;
%DEFAULT_STOP_LOSS = 0.5e-3;
quite = false;
debug = false;
use_stop_loss = true;

fund_a = INITIAL_FUND;
fund_b = 0;
short_period = 8;
long_period = 34;
%stop_loss = DEFAULT_STOP_LOSS;
parseVarargin;

% -- get Indicators -- %
ema_short = getEMA(D,short_period);
ema_long = getEMA(D,long_period);
[~,fast_d,~] = getStochasticOsc(D,9,3,3);
[~,signal,histogram] = getMACD(D,12,26,9);
[support,resistance] = getSR(D,60);
env = resistance - support;
% -------------------- %

indices = [];
position = BUY;
for t = 1:length(D.time);
    
    switch position
        case BUY
            % time to buy
            if ((ema_short(t)<ema_long(t)) && (fast_d(t)<20) && (signal(t)<histogram(t)))
                
                fund_b = fund_a / D.close(t);  % XXXUSD
                fund_a = 0;

                position = SELL;
                indices = [indices,t];
                
                buy_price = D.close(t);
                sold = false;
                
                if (use_stop_loss)
                    stop_loss = support(t) - 0.0*env(t);
                else
                    stop_loss = 0;
                end

            end        
        
        case SELL
            
            sell_condition = ((ema_short(t)>ema_long(t)) && (fast_d(t)>80) && (signal(t)>histogram(t)));
            stop_loss_condition = (D.close(t) < stop_loss);
            
            % time to sell
            if  (~sold) && (sell_condition || stop_loss_condition)

               fund_a = fund_b * D.close(t);
               fund_b = 0;
               
               indices = [indices,t];
               
               sold = true;
               
               if (debug)
                   sell_price = D.close(t);
                   if (stop_loss_condition)
                       disp(['    - (',num2str(buy_price),', ',num2str(sell_price),') ',...
                       num2str(sell_price-buy_price),' *']);
                   else
                       disp(['    - (',num2str(buy_price),', ',num2str(sell_price),') ',...
                       num2str(sell_price-buy_price)]);                       
                   end
               end
               
            end
            
            % exit position when sell condition is met
            if (sell_condition)
                position = HOLD;
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
    
    if (~sold)
        fund_a = fund_b * D.close(t);
        fund_b = 0;
        indices = [indices,t];
        sold = true;
        if (debug)
            sell_price = D.close(t);
            disp(['    - (',num2str(buy_price),', ',num2str(sell_price),') '...
                ,num2str(sell_price-buy_price),' END']);
        end
    end
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