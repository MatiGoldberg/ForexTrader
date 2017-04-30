% -- Support and Resistence ------------------------
% ** attempt based on local minima/maxima **
% --------------------------------------------------
function [sup,res] = getSR(D,window_size)

% --- Arguments ----------------------------------- %
vector_length = length(D.close);
if (window_size >= vector_length)
    error('window is larger than subject vector.');
end
% ------------------------------------------------- %

vec = D.close;

% --- Calculation --------------------------------- %
sup = zeros(size(vec));
res = zeros(size(vec));

% - part 1: up to window_size - %
for i=1:window_size
    sup(i) = min(vec(1:i));
    res(i) = max(vec(1:i));
end
% ---------------------------- %

% - part 2: window_size and on - %
for i=(window_size+1):vector_length
    sup(i) = min(vec((i-window_size+1):i));
    res(i) = max(vec((i-window_size+1):i));
end
% ---------------------------- %

end

% ------------------------------------------------- %
function wv = get_weight_vector(ws)
wv = linspace(1,0,ws+1);
wv = wv./(sum(wv));
wv = wv(1:end-1)';
end
