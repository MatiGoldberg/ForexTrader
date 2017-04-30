function RSI = getRSI(D,varargin)
% http://en.wikipedia.org/wiki/Relative_strength_index
% RSI > 70 - overbought
% RSI < 30 - oversold
DEFAULT_PERIOD = 14;

period = DEFAULT_PERIOD;
if (length(varargin) == 1)
    period = varargin{1};
end

vec = D.close;
dvec = cat(2,0,diff(vec)');
up_dvec = zeros(size(dvec)); up_dvec(dvec>0) = dvec(dvec>0);
dn_dvec = zeros(size(dvec)); dn_dvec(dvec<0) = -dvec(dvec<0);

C_up.close = up_dvec;
C_dn.close = dn_dvec;

up_ema = getEMA(C_up,period);
dn_ema = getEMA(C_dn,period);

RS = (up_ema)./(dn_ema);
RSI = 100 * (1-1./(1+RS));
RSI(1) = 100;
end