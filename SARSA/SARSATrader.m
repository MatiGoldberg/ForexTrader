% -- SARSA Trader ------------------------------------------------
% Q = SARSATrader(start_date, end_date, max_episodes)
% finds optimal Q-Table for a specific period based on SARSA
% machine learning algorithm.
% http://en.wikipedia.org/wiki/SARSA
% ----------------------------------------------------------------
function [total_reward,Q] = SARSATrader(start_date, end_date, max_episodes)
CURRENCY = 'EURUSD';

disp('>> Preparing SARSA Data...');
% -- get forex data --------------------------
fx_data = getForexData(CURRENCY, start_date, end_date);
% --------------------------------------------

% -- prepare parameters for sarsa algirothm --
training_period   = length(fx_data.CP);  % set training for the complete
                                         % period. in future scripts, we
                                         % can try to train for the first
                                         % X% of the data and test the
                                         % algorithm for the rest.
state_list  = buildStateList(fx_data);
action_list = buildActionList();

n_states    = size(state_list,1);
n_actions   = size(action_list,1);
disp(['>> ',num2str(n_states),' states']);
Q           = buildQTable(n_states, n_actions);

parameters.alpha = 0.3;        % learning rate
parameters.gamma = 1.0;        % discount factor
parameters.epsilon = 0.01; %0.001   % probability of random action selection

total_reward = zeros(max_episodes,1);
% ---------------------------------------------

% -- episode loop -----------------------------
disp('>> Strarting Episodes...');
% figure
for i = 1:max_episodes    
    [total_reward(i),Q ] = runEpisode(training_period, Q, parameters, state_list, action_list, fx_data); 
    
    disp(['>> Espisode: ',int2str(i),'  Reward:',num2str(total_reward(i)),' epsilon: ',num2str(parameters.epsilon)])
    parameters.epsilon = parameters.epsilon * 0.99;

    subplot(3,1,3);
    plot((1:i),total_reward(1:i))      
    title(['Episode: ',int2str(i),' epsilon: ',num2str(parameters.epsilon)])  
    xlabel('Episodes')
    ylabel('Reward')    
    drawnow
end



% ---------------------------------------------
disp('>> done.');
end

%% Get Forex Data
function forex_data = getForexData(currency, start_date, end_date)
D = loadRange(currency, start_date, end_date);
D = fixData(D);
forex_data.CP   = D.close;
forex_data.SEMA = getIndicator('EMA',D,8);
forex_data.LEMA = getIndicator('EMA',D,34);
forex_data.RSI  = getIndicator('RSI',D,60);
end

%% Build State List
function state_list = buildStateList(forex_data)
% state vector: [close price (CP), short EMA, long EMA, RSI];

% cp_states   = getRange(min(forex_data.CP),   max(forex_data.CP),   0.001);
% sema_states = getRange(min(forex_data.SEMA), max(forex_data.SEMA), 0.001);
% lema_states = getRange(min(forex_data.LEMA), max(forex_data.LEMA), 0.001);
% rsi_states  = getRange(0, 100, 10);
% position_states = [0,1];

cp_states   = linspace(min(forex_data.CP)  , max(forex_data.CP)  , 8);
sema_states = linspace(min(forex_data.SEMA), max(forex_data.SEMA), 8);
lema_states = linspace(min(forex_data.LEMA), max(forex_data.SEMA), 8);
rsi_states  = linspace(0,100,2);
position_states = [0,1]; % out/in

state_list = setprod(cp_states, sema_states, lema_states, rsi_states, position_states);
end

% function range = getRange(min_val, max_val, resolution)
% range = min_val:resolution:max_val;
% end

%% Build Action List
function action_list = buildActionList()
% Two posible actions: Hold Position (0), Change Position (1) [buy/sell]
action_list = [0;1];
end

%% Build Q Table
function Q = buildQTable(n_states, n_actions)
Q = zeros(n_states, n_actions);
% Q = rand(n_states, n_actions);
end
