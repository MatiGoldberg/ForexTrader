function [final_total_reward,Q] = runEpisode(max_steps, Q, parameters, state_list, action_list, fx_data)
HOLD = 0;
total_reward = zeros(max_steps,1);
buy_rate = 0;

start_state = [fx_data.CP(1), fx_data.SEMA(1), fx_data.LEMA(1), fx_data.RSI(1), HOLD];
state_index  = getStateIndex(start_state, state_list);
action_index = getActionIndex(HOLD, action_list);

rate = [];
index = [];
ri = 1;

for i = 1:max_steps
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
    
    % select the next action (greedy selection)
    % next_action = getNextAction(Q, next_state_index, parameters.epsilon);
    % next_action_index = getActionIndex(next_action, action_list);
    next_action_index = getNextActionIndex(Q, next_state_index, parameters.epsilon);
    
    % Update the Qtable, that is,  learn from the experience
    Q = updateQTable(state_index, action_index, reward, next_state_index, next_action_index, Q , parameters);  % SARSA
    
    % increment
    state_index = next_state_index;
    action_index = next_action_index;
    
end

save rate rate

final_total_reward = total_reward(max_steps);

plotResults(fx_data, total_reward, rate, index);

end

%% Get State Index
% -- Get State Index ---------------------------------------------
% si = getStateIndex(state, state_list);
% inputs: state vector [1xN]
%         state list: list of all states as produced by setprod.
% outputs: index of the closest state
% algorithm: calculate distance from each state as the
%            sum of the squared difference of each component
%            of the vector. return the state of minimal distance.
% ----------------------------------------------------------------
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
function next_action_index = getNextActionIndex(Q, state_index, epsilon)

if rand() > epsilon
    % choose best action
    [~,next_action_index] = max(Q(state_index,:));
else
    next_action_index = randi(2,1,1);
end

end


%% Update Q Table according to SARSA algorithm
function new_Q = updateQTable(si, ai, r, nsi, nai, Q , parameters)
% (state_index, action_index, reward, next_state_index, next_action_index, Q , parameters) %
gamma = parameters.gamma;
alpha = parameters.alpha;
new_Q = Q;
new_Q(si, ai) = Q(si, ai) + alpha*(r+gamma*Q(nsi, nai) - Q(si, ai));

end

function plotResults(fx_data, reward, rate, index)
subplot(3,1,1)
hold on
plot(fx_data.CP);
plot(index, rate, 'rx');
subplot(3,1,2)
plot(reward/100,'k');

end

