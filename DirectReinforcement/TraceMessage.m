% -TraceMessage---------------------------------------------------------
% TraceMessage(msg,quiet,...)
% Prints msg to a log file and if quiet is false, to command line also.
% The message to the command line is in the format:
% HH:MM:SS [function] your message
% and the line to log.txt is in the format:
% DD-MM-YYYY HH:MM:SS [file|function] your message
%
% TraceMessage(msg,quiet,'warning')
% Prints a message to the command line in RED and to log.txt as before.
% ---------------------------------------------------------------------
function TraceMessage(msg,quiet,varargin)
[ST,~] = dbstack();
warning_msg = ((nargin==3) && (strcmp(varargin{1},'warning')));

% Create Trace
log_line = [getTime('log'),'\t[',getFileName(ST),'|',getFuncName(ST),'()]\t'];
cmd_line = [getTime('cmd'),'\t[',getFuncName(ST),'()]\t'];

% add WARNING prefix
if (warning_msg)
    msg = ['WARNING: ',msg];
end

% Save in file
addToLog([log_line,msg]);

if (quiet)
    return;
end

% Show in command line
if (warning_msg)
    fprintf(cmd_line);
    fprintf(2,[msg,'\n']);
else
    fprintf([cmd_line,msg,'\n']);
end

end

% ----------------------------------------------------------------------
function funcname = getFuncName(ST)
if length(ST) > 1
    funcname = ST(2).name;
else
    funcname = ST.name;
end

end

% ----------------------------------------------------------------------
function filename = getFileName(ST)
if length(ST) > 1
    filename = ST(2).file;
else
    filename = ST.file;
end

end

% ----------------------------------------------------------------------
function cur_time = getTime(fmt)
if strcmp(fmt,'log')
    cur_time = datestr(now);
else
    cur_time = datestr(now,13);
end
end

% ----------------------------------------------------------------------
function addToLog(line)
fid = fopen('log.txt','a+');
fprintf(fid,[line,'\r\n']);
fclose(fid);
end

