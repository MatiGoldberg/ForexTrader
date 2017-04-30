k = min(length(Re.time),length(Rg.time));
for i=1:k
    if (Re.time(i) ~= Rg.time(i))
        disp([datestr(Re.time(i)),' != ',datestr(Rg.time(i))]);
        break;
    end
end

