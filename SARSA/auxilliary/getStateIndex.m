function [t1, t2] = getStateIndex(state, state_list)
tic
s1 = SI1(state, state_list);
t1 = toc;
tic
s2 = SI2(state, state_list);
t2 = toc;
end

function i = SI1(state,state_list)
k = state_list - ones(size(state_list,1),1)*state;
distance = sum(k.*k,2);
[~,i] = min(distance);
end

function i = SI2(state,state_list)
k = state_list - ones(size(state_list,1),1)*state;
distance = sum(abs(k),2);
[~,i] = min(distance);
end