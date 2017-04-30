function x = analysis_basic54(varargin)
% - Defaults ---------------------------------------- %
DEFAULT_ATTEMPTS = -1;
DEFAULT_CURRENCY = 'EURUSD';
quiet = false;
% --------------------------------------------------- %

% - Parameters -------------------------------------- %
attempts = DEFAULT_ATTEMPTS;
currency = DEFAULT_CURRENCY;
first_day = datenum(2001,1,2);
last_day = datenum(2012,7,31);
use_stop_loss = true;
parseVarargin;
% --------------------------------------------------- %

% - Analysis Space ---------------------------------- %
if (attempts == -1) 
    % run over all days in range
    attempts = last_day - first_day;
    day = first_day:1:last_day;
else
    % random days
    day = first_day + round(rand(1,attempts))*(last_day - first_day);
end
% --------------------------------------------------- %

x = zeros(1,attempts);
parfor i=1:attempts
    try
        D = loadDate(currency, getDayString(day(i)));
        % for now - no parameters %
        S = strategy_basic54(D,'quiet',1,'use_stop_loss',use_stop_loss);
        x(i) = S.ROI;
    catch err
        x(i) = 0;
    end
end

end

function s = getDayString(num)
s = datestr(num,'yyyymmdd');
end