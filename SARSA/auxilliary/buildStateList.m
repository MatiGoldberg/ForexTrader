function state_list = buildStateList(forex_data)
% state vector: [close price (CP), short EMA, long EMA, RSI, position_state];

cp_states   = linspace(min(forex_data.CP)  , max(forex_data.CP)  , 10);
sema_states = linspace(min(forex_data.SEMA), max(forex_data.SEMA), 10);
lema_states = linspace(min(forex_data.LEMA), max(forex_data.SEMA), 10);
rsi_states  = linspace(0,100,3);
position_states = [0,1]; % out/in

state_list = setprod(cp_states, sema_states, lema_states, rsi_states, position_states);
end