% --- sanity-check varargin cell-vector --------------------------------- %
if (mod(length(varargin),2) ~= 0)
    error('unbalanced varargin. must be in the form [parameter],[value]')
end
% ----------------------------------------------------------------------- %

% --- find out if 'quiet' is defined ------------------------------------ %
if (~exist('quiet','var'))
    quiet = false;
end
% ----------------------------------------------------------------------- %

% --- evaluate arguments ------------------------------------------------ %
for i=1:(length(varargin)/2)
    if isnumeric(varargin{2*i})
        eval([varargin{2*i-1},' = ',num2str(varargin{2*i}),';']);
        if ~quiet
            disp(['    - change parameter: ',varargin{2*i-1},' = ',num2str(varargin{2*i})]);
        end
        
    else
        eval([varargin{2*i-1},' = ',varargin{2*i},';']);
        if ~quiet
            disp(['    - change parameter: ',varargin{2*i-1},' = ',varargin{2*i}]);
        end
        
    end
end
% ----------------------------------------------------------------------- %
clear i;