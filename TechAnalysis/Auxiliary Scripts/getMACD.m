function [MACD, Signal, Histogram] = getMACD(D,varargin)
% http://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:moving_average_conve
% http://en.wikipedia.org/wiki/MACD
DEFAULT_P1 = 12;
DEFAULT_P2 = 26;
DEFAULT_P3 = 9;

p1 = DEFAULT_P1;
p2 = DEFAULT_P2;
p3 = DEFAULT_P3;

if (~isempty(varargin)) && (length(varargin) ~= 3)
    error('should get three parameters');
elseif (length(varargin) == 3)
    p1 = varargin{1};
    p2 = varargin{2};
    p3 = varargin{3};
    %disp(['    - parameters: ',num2str(p1),', ',num2str(p2),', ',num2str(p3)]);
end

ema1 = getEMA(D,p1);    % EMA 12
ema2 = getEMA(D,p2);    % EMA 26

% -- MACD = EMA12 - EMA26 --
MACD = ema1-ema2;     
% --------------------------
C.close = MACD;

% -- Signal = EMA9 of MACD --
Signal = getEMA(C,p3);
% ---------------------------

% ---------------------------
Histogram =  MACD - Signal;
% ---------------------------


end