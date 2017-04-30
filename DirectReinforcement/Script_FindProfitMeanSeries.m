function d = Script_FindProfitMeanSeries(Samples)
SERIES_LEN = 19000;

d = zeros(SERIES_LEN,Samples);
parfor i=1:Samples
    d(:,i) = GetTradeProfit(i);
end

plot(mean(d,2));

% hist(100*d,20);
% title('\itProfit Distribution');
% xlabel('\it%');
% 
% Mu = mean(d);
% Sig = std(d);
% 
% annotation(gcf,'textbox',...
%     [0.15 0.75 0.15 0.15],...
%     'String',{['\it\mu = ',num2str(Mu)],['\it\sigma = ',num2str(Sig)]},...
%     'FitBoxToText','on',...
%     'LineStyle','none');

end

function p = GetTradeProfit(i)
T = RunDRTrader('EURUSD','20090312','20090331',[],'quiet',1);
fprintf('\b\b\b\b\b\b\b\b\b\b Simulation done {%d}\n',i);
p = T.Outputs.Profit;
end