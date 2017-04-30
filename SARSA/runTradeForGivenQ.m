function [] = runTradeForGivenQ(Q, start_date,end_date)
%--Get-Data---------------------------------------------
disp('>> Getting FX Data...');
fx_data = getForexData('EURUSD', start_date, end_date);
%-------------------------------------------------------

% -- prepare parameters for sarsa algirothm ------------
disp('>> Preparing States...');
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
%-------------------------------------------------------

%-Starting Simulation-----------------------------------
disp('>> Starting Simulation');
total_reward = zeros(training_period,1);
buy_rate = 0;

rate = [];
index = [];
ri = 1;

% -- first state --
action = 0; % hold
state = [fx_data.CP(1), fx_data.SEMA(1), fx_data.LEMA(1), fx_data.RSI(1), 0];
state_index  = getStateIndex(state, state_list);
action_index = getActionIndex(action, action_list);


% -- loop --

for i=1:training_period
    % act and get the next state (+discretization)
    next_state = doAction(action_list(action_index), state_list(state_index,:), fx_data, i);
    next_state_index = getStateIndex(next_state, state_list);
    % collect the reward
    [reward, buy_rate] = getReward(state_list(state_index,:), next_state, buy_rate); % state before discretization
    if (reward ~= 0)
        % an action [buy/sell] had been made
        rate(ri) = buy_rate;
        index(ri) = i;
        ri = ri+1;
    end
    total_reward(i) = total_reward(i) + reward;
    % select the next action
    next_action_index = getNextActionIndex(Q, next_state_index);
    
    
    % Update the Qtable, that is,  learn from the experience
    %Q = updateQTable(state_index, action_index, reward, next_state_index, next_action_index, Q , parameters);  % SARSA
    
    % increment
    state_index = next_state_index;
    action_index = next_action_index;

end


%-------------------------------------------------------
disp('>> done.');

plotResults(fx_data, total_reward, rate, index);

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
% state vector: [close price (CP), short EMA, long EMA, RSI, position_state];

cp_states   = linspace(min(forex_data.CP)  , max(forex_data.CP)  , 10);
sema_states = linspace(min(forex_data.SEMA), max(forex_data.SEMA), 10);
lema_states = linspace(min(forex_data.LEMA), max(forex_data.SEMA), 10);
rsi_states  = linspace(0,100,3);
position_states = [0,1]; % out/in

state_list = setprod(cp_states, sema_states, lema_states, rsi_states, position_states);
end

%% Build Action List
function action_list = buildActionList()
% Two posible actions: Hold Position (0), Change Position (1) [buy/sell]
action_list = [0;1];
end

%% Get State Index
function si = getStateIndex(state, state_list)
k = state_list - ones(size(state_list,1),1)*state;
distance = sum(k.*k,2);
[~,si] = min(distance);
end


%% Get Action Index
function ai = getActionIndex(action, ~) % // (action, action_list)
ai = round(action) + 1;
end

%% Do Action
function next_state = doAction(action, state, fx_data, i)
% State: [CP, SEMA, LEMA, RSI, Position]
position = state(5);
if (action == true) % change state
    new_position = ~position;
else
    new_position = position;
end

next_state = [fx_data.CP(i), fx_data.SEMA(i), fx_data.LEMA(i), fx_data.RSI(i), new_position];

end

%% Get Reward
function [reward, action_rate] = getReward(state, next_state, buy_rate)
position = state(5);
next_position = next_state(5);

if (next_position > position) % BUY

    reward = -100;
    action_rate = next_state(1); 
    % return close price at buy

elseif (next_position < position) % SELL
    
    action_rate = next_state(1);
    reward = 100*action_rate/buy_rate;
    % return close price at sell    

else
    
    reward = 0;
    action_rate = buy_rate;

end

end

%% Get Next Action, Get Best Action (Greedy)
function next_action_index = getNextActionIndex(Q, state_index)

% choose best action
[~,next_action_index] = max(Q(state_index,:));

end

%% Plot Results
function plotResults(fx_data, reward, rate, index)
figure
subplot(2,1,1)
hold on
plot(fx_data.CP);
plot(index, rate, 'rx');
subplot(2,1,2)
plot(reward/100,'k');

end