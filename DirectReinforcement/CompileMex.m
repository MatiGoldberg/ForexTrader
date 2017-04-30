%-MEX FILE COMPILATION SCRIPT ------------------------------------------
% CompileMex() compiles all DR mex files.
%
% CompileMex('debug') compiles all mex files with DEBUG symbol defined.
%-----------------------------------------------------------------------
function CompileMex(varargin)
FILES = {'DRTrain.c','DRPass.c','DRDTrain.c','DRDPass.c'};

debug_mode = false;
if (nargin == 1)
    debug_mode = DebugDefined(varargin{1});
end

for i=1:length(FILES)
    Compile(FILES{i}, debug_mode);
end

end

%------------------------------------------------%
function debug = DebugDefined(text)
debug = false;
if ischar(text)
   if strcmp(text,'debug')
       debug = true;
   end
end
TraceMessage('Compiling in DEBUG mode');
end

%------------------------------------------------%
function Compile(filename, debug_mode)
fprintf(['Compiling ',filename,'...\n'])

if (debug_mode)
    eval(['mex -g -DDEBUG ',filename]);
else
    eval(['mex -g ',filename]);
end

fprintf('\bDone.\n');
end