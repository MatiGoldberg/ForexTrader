function sma = getSMA(D,window_size)
vector_length = length(D.close);

% --- Consider Arguments -------------------------- %
if (window_size >= vector_length)
    error('window is larger than subject vector');
end
% ------------------------------------------------- %

vec = D.close;

% --- Calculate MA -(only-past-data)--------------- %
%~ not using movavg on purpose ~%
sma = zeros(size(vec));
sma(1:window_size) = vec(window_size+1);

for i=(window_size+1):vector_length
    sma(i) = sum((vec((i-window_size+1):i)))/window_size;
    %sma(i) = sma(i-1) + (vec(i) - vec(i-window_size))/window_size;
end

%-return sma-%

end


