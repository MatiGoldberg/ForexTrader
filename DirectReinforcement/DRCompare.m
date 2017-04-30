% -- DRCompare ---------------------------------------------------------
% ...
% ----------------------------------------------------------------------
function h = DRCompare(T1, T2)
h = figure();

subplot(4,1,1)
plot(T1.Inputs.TimeBase,T1.Inputs.Price(:,1),'b',T2.Inputs.TimeBase,T2.Inputs.Price(:,1),'r:');
datetick('x','dd/mm','keepticks');
ylabel('\bf\itPrice');
grid on

subplot(4,1,2)
plot(T1.Inputs.TimeBase,T1.Outputs.F,'b',T2.Inputs.TimeBase,T2.Outputs.F,'r');
datetick('x','dd/mm','keepticks');
ylabel('\bf\itSignal');
grid on

subplot(4,1,3)
plot(T1.Inputs.TimeBase,100*T1.Outputs.Profit,'b',T2.Inputs.TimeBase,100*T2.Outputs.Profit,'r')
datetick('x','dd/mm','keepticks');
ylabel('\bf\itProfit, %')
grid on;

subplot(4,1,4)
plot(T1.Inputs.TimeBase,T1.Outputs.Sharpe,'b',T2.Inputs.TimeBase,T2.Outputs.Sharpe,'r')
datetick('x','dd/mm','keepticks');
ylabel('\bf\itSharp R.')
grid on;

end