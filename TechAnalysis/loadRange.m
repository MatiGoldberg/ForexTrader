%-Load Range-------------------------------------------------
% R = loadRange(currency, start_date, end_date)
%
% loadRange supports three formats for start/end date:
% 1. 'yyyymmdd' - data in minutes.
% 2. 'yyyymm'   - data in hours.
% 3. 'yyyy'     - data in days.
%
% available currencies: GBPUSD, EURUSD
%
% File structure: YYYYMMDD.txt
%                 <hhmm> <open> <high> <low> <close>
%
% File structure: YYYYMM.txt
%                 <DDhh> <open> <high> <low> <close>
%
% File structure: YYYY.txt
%                 <MMDD> <open> <high> <low> <close>
%------------------------------------------------------------
function R = loadRange(currency, start_date, end_date)
n_start = datenum(splitDate(start_date));
n_end = datenum(splitDate(end_date));

if (length(start_date) ~= length(end_date))
    error('different timescales between start and end date');
end

if (~strcmp(currency,'GBPUSD') && ~strcmp(currency,'EURUSD'))
    error('invalid currency. [GBPUSD, EURUSD]');
end

if (n_start > n_end)
    error('Start date is after End date')
end

if (n_start == n_end)
    disp('    - Single file.');
end

L = length(start_date);
switch L
    case 8
        freq = 'Minutes';
    case 6
        freq = 'Hours';
    case 4
        freq = 'Days';
    otherwise
        error('Bad input: start_date');
end

% create an empty struct
R = struct('curr',currency,'time',[],'high',[],'low',[],'open',[],'close',[]);

% all the rest
last_added_date = 'yyyy';
for n = (n_start):(n_end)
    added_date = getDate(n,freq);
    % in the case of months/years, jumps are not in 1 day. 
    % not optimal, i know.
    if (~strcmp(last_added_date,added_date))
        R = addDate(R,added_date);
    end
    last_added_date = added_date;
end

R.freq = freq;
R.start_date = datestr(R.time(1));
R.end_date   = datestr(R.time(end));

end


%% --- LOAD A SINGLE DAY ---
function D = loadDate(currency, my_date)
PATH = '..\Data\';

%---Parameter checkup--------------------------------------%
try
    v = splitDate(my_date);
catch err
    error(['invalid date format: ',err.message]);
end

%---Load Data----------------------------------------------%
try
    raw = dlmread([PATH,currency,'\',my_date,'.txt'],',');
catch err
    error('Invalid file');
end

if (size(raw,2) ~= 5)
    error('bad file size');
end

%---Format Output------------------------------------------%
% create date vector from format: <hhmm> <open> <high> <low> <close> 
D.time  = createSerialDateNum(v, raw(:,1));
D.high  = raw(:,3);
D.low   = raw(:,4);
D.open  = raw(:,2);
D.close = raw(:,5);
D.start_date = datestr(D.time(1));
D.end_date   = datestr(D.time(end));
end

%% --- Convert-Date-And-Time-To-Time-Identifier ---
function v_date = createSerialDateNum(date_vec,vd_date)
v = ones(size(vd_date));
iy = date_vec(1); im = date_vec(2); id = date_vec(3);

v_hour = floor(vd_date/100);
v_minute = vd_date - 100*v_hour;

v_date = datenum([v.*iy, v.*im, v.*id, v_hour, v_minute, zeros(size(v))]);

end

%% --- LOAD A SINGLE MONTH ---
function D = loadMonth(currency, my_date)
PATH = '..\Data\';

%---Parameter checkup--------------------------------------%
try
    v = splitDate(my_date);
catch err
    error(['invalid date format: ',err.message]);
end

%---Load Data----------------------------------------------%
try
    raw = dlmread([PATH,currency,'\',my_date,'.txt'],',');
catch err
    error('Invalid file');
end

if (size(raw,2) ~= 5)
    error('bad file size');
end

%---Format Output------------------------------------------%
% create date vector from format: <DDhh> <open> <high> <low> <close>
D.time  = createSerialDateNum2(v(1), v(2), raw(:,1));
D.high  = raw(:,3);
D.low   = raw(:,4);
D.open  = raw(:,2);
D.close = raw(:,5);
D.start_date = datestr(D.time(1));
D.end_date   = datestr(D.time(end));
end

%% --- Convert-Date-And-Time-To-Time-Identifier ---
function v_date = createSerialDateNum2(i_year,i_month,v_DDhh)
v = ones(size(v_DDhh));

v_days = floor(v_DDhh/100);
v_hours = v_DDhh-100*v_days;
v_minutes = zeros(size(v));
v_seconds = v_minutes;

v_date = datenum([v*i_year, v*i_month, v_days, v_hours, v_minutes, v_seconds]);

end

%% --- LOAD A SINGLE YEAR ---
function D = loadYear(currency, my_date)
PATH = '..\Data\';

%---Parameter checkup--------------------------------------%
try
    v = splitDate(my_date);
catch err
    error(['invalid date format: ',err.message]);
end

%---Load Data----------------------------------------------%
try
    raw = dlmread([PATH,currency,'\',my_date,'.txt'],',');
catch err
    error('Invalid file');
end

if (size(raw,2) ~= 5)
    error('bad file size');
end

%---Format Output------------------------------------------%
% create date vector from format: <MMDD> <open> <high> <low> <close>
D.time  = createSerialDateNum3(v(1), raw(:,1));
D.high  = raw(:,3);
D.low   = raw(:,4);
D.open  = raw(:,2);
D.close = raw(:,5);
D.start_date = datestr(D.time(1));
D.end_date   = datestr(D.time(end));
end

%% --- Convert-Date-And-Time-To-Time-Identifier ---
function v_date = createSerialDateNum3(i_year,v_mmdd)
v = ones(size(v_mmdd));

v_months = floor(v_mmdd/100);
v_days = v_mmdd-100*v_months;

v_date = datenum([v*i_year, v_months, v_days]);

end

%% --- Split-Date-String-to-Integets ---
function v = splitDate(my_date)

L = length(my_date);

switch L
    case 4
        iy = str2num(my_date(1:4));
        im = 1;
        id = 1;
        
    case 6
        iy = str2num(my_date(1:4));
        im = str2num(my_date(5:6));
        id = 1;

    case 8
        iy = str2num(my_date(1:4));
        im = str2num(my_date(5:6));
        id = str2num(my_date(7:8));

    otherwise
        error('bad input in splitDate');    
end

if (iy<2001 || iy>2012) || (im>12 || im<1) || (id>31 || id<1)
    error('arguments out of range');
end

v = [iy, im, id];

end

%% --- Get-Date-in-Format-From-Identifier ---
function my_date = getDate(num, freq)

switch freq
    case 'Minutes'
        my_date = datestr(num,'yyyymmdd');

    case 'Hours'
        my_date = datestr(num,'yyyymm');
        
    case 'Days'
        my_date = datestr(num,'yyyy');
        
    otherwise
        error('Invalid Frequency');
end

end

%% --- Add-Date-To-Range ---
function new_R = addDate(R, new_date)

L = length(new_date);

try
    switch L
        case 8
            new_D = loadDate(R.curr, new_date);
        case 6
            new_D = loadMonth(R.curr, new_date);
        case 4
            new_D = loadYear(R.curr, new_date);
        otherwise
            error('Invalide date type');
    end
    
    new_R.curr = R.curr;
    new_R.time = [R.time;new_D.time];
    new_R.high = [R.high;new_D.high];
    new_R.low  = [R.low ;new_D.low ];
    new_R.open = [R.open; new_D.open];
    new_R.close = [R.close; new_D.close];

catch err
    disp(['    - missing ', new_date]);
    new_R = R;
end

end



