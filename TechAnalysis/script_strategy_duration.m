% check for how long a strategy is successful %

start_date = '20100103';
end_date = '20100201';

tic
T = Trader('Basic54','EURUSD',start_date,end_date);
toc

bar(T.Position.SellTime,T.Position.Revenue);
datetick('x','dd/mm','keepticks')