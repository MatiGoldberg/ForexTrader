%--find optimal parameters for basic strategy--%
clear all

% reference: 19/5/2010
D = loadDate('EURUSD',2010,5,19);
sp = 5:1:25;
lp = 25:5:80;

R = zeros(length(sp),length(lp));

for i=1:length(sp)
    for j=1:length(lp)
        Sb = strategy_basic(D,'short_period',sp(i),'long_period',lp(j));
        R(i,j) = Sb.ROI;
    end
end

bar3(R);

m = max(max(R));
M = (R==m);
short = sp(sum(M,2)>=1); short = short(end);
long = lp(sum(M,1)>=1); long = long(end);
disp(['Optimized Parameters: ',num2str(long),', ',num2str(short)]);
