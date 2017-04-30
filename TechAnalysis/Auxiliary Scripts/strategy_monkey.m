function S = strategy_monkey(D,varargin)
DEFAULT_TRANSACTIONS = 1;
INITIAL_FUND = 1000;
quiet = false;

transactions = DEFAULT_TRANSACTIONS;
fund_a = INITIAL_FUND;
fund_b = 0;

parseVarargin;

% get random moments for transactions
k = rand(1,2*transactions);
k = sort(k);
key_index = ceil(k*length(D.time));
S.buy_value = D.close(key_index(1:2:end));
S.buy_time = D.time(key_index(1:2:end));
S.sell_value = D.close(key_index(2:2:end));
S.sell_time = D.time(key_index(2:2:end));

% make the transactions

for i = 1:transactions
    % buy
    fund_b = fund_a / S.buy_value(i);
    %fund_a = 0;
    
    % sell
    fund_a = fund_b * S.sell_value(i);
    %fund_b = 0;
end

S.ROI = 100*(fund_a-INITIAL_FUND)/INITIAL_FUND;
if ~quiet
    disp(['    - ROI: ',num2str(S.ROI),'%']);
end

end