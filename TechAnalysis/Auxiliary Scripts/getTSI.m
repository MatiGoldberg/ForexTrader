% -- True Strength Indicator ------------------------------
% http://en.wikipedia.org/wiki/True_strength_index
% TSI(CP,r,s) = 100*EMA(EMA(d,r),s)/EMA(EMA(|d|,r),s)
% where: d(n) = CP(n)-CP(n-1)
%        r,s are typically 25, 13
% TSI > 25 is overbought. TSI < -25 is oversold.
% use:
%   TSI = getTSI(D), or:
%   TSI = getTSI(D,r,s);
% ---------------------------------------------------------
function TSI = getTSI(D,varargin)
DEFAULT_R = 25;
DEFAULT_S = 13;

r = DEFAULT_R;
s = DEFAULT_S;

if length(varargin) == 2
    r = varargin{1};
    s = varargin{2};
elseif ~isempty(varargin)
    error('expecting 3 arguments: getTSI(D,r,s)');
end

delta = [0;diff(D.close)];

% --calculate nominator--
C.close = delta;
ema_nom = getEMA(C,r);
C.close = ema_nom;
nom = getEMA(C,s);
% -----------------------

% --calculate denominator--
C.close = abs(delta);
ema_denom = getEMA(C,r);
C.close = ema_denom;
denom = getEMA(C,s);
% -------------------------

TSI = 100 * (nom./denom);

end


