function cma = getCMA(D)

vector_length = length(D.close);

% --- Calculate MA -(only-past-data)--------------- %
vec = D.close;
cma = zeros(size(vec));
cma(1) = vec(1);
for i=2:vector_length
    %cma(i) = mean(a(1:i));
    cma(i) = cma(i-1)*(i-1)/i + vec(i)/i;
end

%--return cma--%

end
