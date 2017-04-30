function d = Script_FindProfitDist(Samples)

d = zeros(1,Samples);
parfor i=1:Samples
    d(i) = GetTradeProfit(i);
end

hist(100*d,20);
title('\itProfit Distribution');
xlabel('\it%');

Mu = mean(d);
Sig = std(d);

annotation(gcf,'textbox',...
    [0.15 0.75 0.15 0.15],...
    'String',{['\it\mu = ',num2str(Mu)],['\it\sigma = ',num2str(Sig)]},...
    'FitBoxToText','on',...
    'LineStyle','none');

end

function p = GetTradeProfit(i)
T = RunDRTrader('EURUSD','20090312','20090331',[],'quiet',1,'window_size',10000,'training_set',8000);
fprintf('\b\b\b\b\b\b\b\b\b\b Simulation done {%d}\n',i);
p = T.Outputs.Profit(end);
end