function MSTD = getMSTD(D,period)

vec = D.close;
vec_length = length(D.close);

MSTD = zeros(size(D.close));
MSTD(1:period) = std(vec(1:period));

for i=(period+1):vec_length
    sub_vec = vec(i-period+1:i);
    MSTD(i) =  std(sub_vec);
end

end