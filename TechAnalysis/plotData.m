%-Plot-Data--------------------------------------------------
% h = plotData(T,varargin)
% options:
%   - candle
%   - indicators
%   - thick
% Plots Forex data struct with additional data if present
% see Trader for creating struct T.
%------------------------------------------------------------
function h = plotData(T,varargin)
linewidth = 1.0; % default

%-check varargin for options-----%
plot_candles = isIn('candle',varargin);
plot_indicators = isIn('indicators',varargin);

if (isIn('thick',varargin))
    linewidth = 2.0;
end 
%------------------------------------------------------------%

%-open figure and define axes1-------------------------------%
scrsz = get(0,'ScreenSize'); % [x y dx dy]
h = figure('Position',[scrsz(3)/10 scrsz(4)/10 8*scrsz(3)/10 8*scrsz(4)/10]);

% define Axes
if (plot_indicators)
    axes1 = axes('Parent',h,'Position',[0.05 0.55 0.9 0.4]);
else
    axes1 = axes('Parent',h,'Position',[0.1 0.1 0.8 0.8]);
end    
box(axes1,'on');
hold(axes1,'all');

range_under_a_day = (T.Data.time(end)-T.Data.time(1) < 1);

% title data
if (range_under_a_day)
    title(['\bf\it',T.Data.curr, ' FX data ', T.Data.start_date]);
else
    title(['\bf\it',T.Data.curr, ' FX data ', T.Data.start_date, ' - ', T.Data.end_date]);
end
%------------------------------------------------------------%

%-define axes2, axes3----------------------------------------%
if (plot_indicators)
    % define axes2
    axes2 = axes('Parent',h,'Position',[0.05 0.3 0.9 0.2]);
    box(axes2,'on');
    hold(axes2,'all');
    
    % define axes2
    axes3 = axes('Parent',h,'Position',[0.05 0.05 0.9 0.2]);
    box(axes3,'on');
    hold(axes3,'all');
    
    % get axes handles
    ch = get(h,'children');
    ch = sort(ch);
    h1 = ch(1);
    h2 = ch(2);
    h3 = ch(3);
    clear ch
else
    h1 = get(h,'children');
end
%------------------------------------------------------------%

%-plot data on axes1-----------------------------------------%
legend_text_1 = {};
legend_text_2 = {};
legend_text_3 = {};
axes(h1);
hold on;

if (plot_candles)
    
    if (strcmp(T.Data.freq,'Days'))
        plotCandle(T.Data);
        legend_text_1 = cat(2,legend_text_1,{'CP high/low','closing price','closing price'});
    else
        plotErrorBars(T.Data)
        legend_text_1 = cat(2,legend_text_1,'closing price','closing price');        
    end

else
    
    plot(T.Data.time, T.Data.close,'k','linewidth',linewidth);
    %plot(T.Data.time, T.Data.high,'g:','linewidth',linewidth);
    %plot(T.Data.time, T.Data.low,'r:','linewidth',linewidth);
    %legend_text_1 = cat(2,legend_text_1,'closing price','high','low');
    legend_text_1 = cat(2,legend_text_1,'closing price');

end

%-plot indicator data----------------------------------------%
if (plot_indicators) && (~isempty(T.Indicators))
    
    names = fieldnames(T.Indicators);
    ref = mean(T.Data.close);
    for i=1:length(names)
        % decide which axes to use according to it's mean
        indicator = getfield(T.Indicators,names{i});
        if (mean(indicator) > 3*ref)
            axes(h3);
            legend_text_3 = cat(2,legend_text_3,names{i});
        elseif (mean(indicator) < ref/3)
            axes(h2);
            legend_text_2 = cat(2,legend_text_2,names{i}); 
        else
            axes(h1);
            legend_text_1 = cat(2,legend_text_1,names{i});             
        end
        plot(T.Data.time,indicator,'color',getRandomColor(),'linewidth',linewidth-0.5);
        
    end
    clear field_name ref;
end
%------------------------------------------------------------%

%-plot strategy----------------------------------------------%
axes(h1);
plot(T.Position.BuyTime, T.Position.RateAtBuy,'bo','MarkerFaceColor','b');
plot(T.Position.SellTime, T.Position.RateAtSale,'ro','MarkerFaceColor','r');
%------------------------------------------------------------%

%-finish axes1-----------------------------------------------%
axes(h1);
if (range_under_a_day)
    datetick('x',15);
else
    datetick('x','dd/mm','keepticks'); %, HH:MM
end
legend(legend_text_1);
hold off
grid on
%------------------------------------------------------------%

%-finish axes2, axes3----------------------------------------%
if (plot_indicators)
        
    axes(h2);
    % x-label data
    if (range_under_a_day)
        datetick('x',15);
    else
        datetick('x','dd/mm','keepticks');
    end
    
    if (~isempty(legend_text_2))
        legend(legend_text_2);
    end

    hold off
    grid on
    
    axes(h3);
    % x-label data
    if (range_under_a_day)
        datetick('x',15);
    else
        datetick('x','dd/mm','keepticks');
    end
    
    if (~isempty(legend_text_3))
        legend(legend_text_3);
    end

    hold off
    grid on
end
%------------------------------------------------------------%

end

%------------------------------------------------------------%
function plotErrorBars(D)
x = D.time;
y = D.close;
u = D.high - D.close;
l = D.close - D.low;
d = [0.1;diff(y)];

x1 = x(d>0);
y1 = y(d>0);
l1 = l(d>0);
u1 = u(d>0);

x2 = x(d<0);
y2 = y(d<0);
l2 = l(d<0);
u2 = u(d<0);

errorbar(x1, y1, l1, u1, 'k^', 'MarkerFaceColor', 'g');
errorbar(x2, y2, l2, u2, 'kv', 'MarkerFaceColor', 'r');

end

%------------------------------------------------------------%
function plotCandle(D)
candle(D.high,D.low,D.close,D.open,'k',D.time);
ch = get(gca,'children');
set(ch(1),'FaceColor','r')
set(ch(2),'FaceColor','g')
end

%------------------------------------------------------------%
function t = isIn(str,cell_array)
t = sum(strcmp(str,cell_array)) > 0;
end

%------------------------------------------------------------%
function c = getRandomColor()
c = rand(1,3);
end





