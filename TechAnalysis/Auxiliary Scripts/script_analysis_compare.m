%--Analysis: Compare--%
clear all
close all
clc

first_day = datenum(2010,1,1);
last_day = datenum(2010,12,31);

disp('Running Monkey Analysis...')
Xmonkey = analysis_monkey('quite',1,'first_day',first_day,'last_day',last_day);
%disp('Running Basic 10/50 Analysis...')
%Xbasic1050 = analysis_basic('quite',1,'first_day',first_day,'last_day',last_day,'threshold',1e-3);
disp('Running Basic54 Analysis...')
Xbasic54 = analysis_basic54('quite',1,'first_day',first_day,'last_day',last_day);
disp('Running Basic54 w/o stop_loss Analysis...')
Xbasic54_nsl = analysis_basic54('quite',1,'first_day',first_day,'last_day',last_day,'use_stop_loss',0);
t = first_day:(last_day-1);

figure()
hold on
plot(t,Xmonkey,'r');
%plot(t,Xbasic1050,'b');
plot(t,Xbasic54,'k');
plot(t,Xbasic54_nsl,'b');

% legend(['Monkey [',num2str(round(mean(Xmonkey)*100)/100),']'],...
%     ['Basic EMA10/50 [',num2str(round(mean(Xbasic1050)*100)/100),']'],...
%     ['Basic54 [',num2str(round(mean(Xbasic54)*100)/100),']']);

legend(['Monkey [',num2str(round(mean(Xmonkey)*100)/100),']'],...
    ['Basic54 [',num2str(round(mean(Xbasic54)*100)/100),']'],...
       ['Basic54 w/o stop loss [',num2str(round(mean(Xbasic54_nsl)*100)/100),']']);

datetick('x','dd/mm','keepticks');
hold off
grid on
