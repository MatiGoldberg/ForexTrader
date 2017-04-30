%-Fix Data--------------------------------------------------
% D = fixData(D)
%
% Re-creates D structure so that the time line is continuous.
% I'ts better to used 'fixed' structure for analysis.
%
% TODO: correct to all time scales
%------------------------------------------------------------
function new_D = fixData(D)

if (~strcmp(D.freq,'Minutes'))
    new_D = D;
    return;
end
   
SAMPLES_PER_DAY = 24*60; % mins, 24 hrs, 60 min/hr
ONE_SECOND = 1/SAMPLES_PER_DAY;

% find the range of the data
days = floor(D.time(end)) - floor(D.time(1)) + 1;
num_of_samples = length(D.time);

if (num_of_samples == SAMPLES_PER_DAY*days)
    TraceMessage('Data Fixed');
    new_D = D;
    return;
end

% if there are 'holes' in the original timeline... re-create struct.
new_D.curr = D.curr;
new_D.freq = D.freq;
start_time = round(D.time(1));  % starts at 00:00
new_D.time = linspace(start_time, start_time+days-ONE_SECOND, SAMPLES_PER_DAY*days)';
new_D.high = zeros(SAMPLES_PER_DAY*days,1);
new_D.low  = zeros(SAMPLES_PER_DAY*days,1);
new_D.open = zeros(SAMPLES_PER_DAY*days,1);
new_D.close = zeros(SAMPLES_PER_DAY*days,1);
new_D.start_date = D.start_date;
new_D.end_date   = D.end_date;

% embed data in its rightful position
k=1;
for i=1:num_of_samples
    while(new_D.time(k) < D.time(i))
        k = k+1;
    end
    new_D.high(k) = D.high(i);
    new_D.low(k) = D.low(i);
    new_D.open(k) = D.open(i);
    new_D.close(k) = D.close(i);
end

% fill remaining zeros with previous data.
V = 1:SAMPLES_PER_DAY*days;
I = V(new_D.high == 0);

if (I(1) == 1)
    new_D.high(1) = getFirstNonZeroValue(D.high);
    new_D.low(1) = getFirstNonZeroValue(D.low);
    new_D.open(1) = getFirstNonZeroValue(D.open);
    new_D.close(1) = getFirstNonZeroValue(D.close);
    I = I(2:end);
end

for i=1:length(I)
    new_D.high(I(i)) = new_D.high(I(i)-1);
    new_D.low(I(i)) = new_D.low(I(i)-1);
    new_D.open(I(i)) = new_D.open(I(i)-1);
    new_D.close(I(i)) = new_D.close(I(i)-1);
end
    
end

%-GET-FIRST-NON-ZERO-VALUE------------------------------------------%
function v = getFirstNonZeroValue(s)
i = 1;
while (s(i) == 0)
    i = i+1;
end

v = s(i);

end
