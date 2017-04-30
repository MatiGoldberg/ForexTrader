function wma = getWMA(D,window_size)

% --- Arguments ----------------------------------- %
vector_length = length(D.close);
if (window_size >= vector_length)
    warning('window is larger than subject vector. using default');
    window_size = DEFAULT_WINDOW_SIZE;
end
% ------------------------------------------------- %

vec = D.close;

% --- Calculate MA -(only-past-data)--------------- %
wma = zeros(size(vec));
wma(1:window_size) = vec(window_size+1);
weight_vector = get_weight_vector(window_size);

for i=window_size:vector_length
    wma(i) = sum((vec((i-window_size+1):i).*weight_vector));
end
% -return wma -%
end

% ------------------------------------------------- %
function wv = get_weight_vector(ws)
wv = linspace(1,0,ws+1);
wv = wv./(sum(wv));
wv = wv(1:end-1)';
end
