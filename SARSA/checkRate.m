function checkRate()
load rate

transactions = length(rate)/2;
fund = 1;

ratio = zeros(transactions,1);
for i=1:transactions
    ratio(i) = rate(2*i)/rate(2*i-1);
    fund = fund * ratio(i);
end

plot(ratio)
fund