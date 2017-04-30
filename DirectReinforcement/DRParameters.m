% --- DRParameters.m ----------------------------------------------------
% par = DRParameters(varargin);
% Creates default parameter struct to be used with DRTRader.m.             
% Parameters can be changed with varargin in the format: 
% par = DRParameters('Parameter',value,...)
%
% Direct Reinforcement Trader, 
% Created by: E.Kot & M.Goldberg
% November, 2013
% -----------------------------------------------------------------------
function par = DRParameters(varargin)

% -- Integrity -- %
varargin = deCapsulate(varargin);
checkVarargin(varargin);
% --------------- %

% -- Set Parameters -- %
par = addChangesToDefaults(getDefaultValues(),varargin);
% -------------------- %

end


% -----------------------------------------------------------------------
function defaults = getDefaultValues()
defaults.Model.Mu = 1;             % Purchase units
defaults.Model.Zeta = 1;           % Aux series weight
defaults.Model.Delta = 0;          % Transaction cost MU*0.2/100;
defaults.Model.Eta = 0.01;         % EMA parameter for diff SR
defaults.Model.Rho1 = 0.35;        % learning parameter
defaults.Model.Rho2 = 0.035;       % learning parameter
defaults.Model.Rho3 = 0.0035;      % learning parameter
defaults.Model.Ni = 1e-5;          % weight decay
defaults.Model.lambda_rate = 0.99; % Exploration vs. Exploitation decay

defaults.Flags.quiet = false;
defaults.Flags.produce_plot = false;
defaults.Flags.normalize = true;
defaults.Flags.three_state = false;
defaults.Flags.fix_data = false;

defaults.Frame.window_size = 5000;
defaults.Frame.training_set = 4000;
defaults.Frame.inputs = 25;
defaults.Frame.epochs = 10;

defaults.Weight.spread = 0.04;
defaults.Weight.bias   = 0;
end

% -----------------------------------------------------------------------
function checkVarargin(inputs)
inputs = deCapsulate(inputs);

assert(mod(length(inputs),2)==0,'Unbalanced Varargin');

for i=1:length(inputs)/2
    assert(ischar(inputs{2*i-1}),['Parameter name must be a string [varargin{',num2str(2*i-1),'}]']);
    
    assert(isnumeric(inputs{2*i}),['Parameter value must be numeric [varargin{',num2str(2*i),'}]']);
    
    %assert(sum(size(inputs{2*i}))<=2,'As for now, none of the parameters are matrices. all scalars');
    % I'm removing this condition because some inputs might not be relevant
    % to DRParameters function.
end

end

% -----------------------------------------------------------------------
function par = addChangesToDefaults(par,inputs)
field_names = fieldnames(par);

for i=1:length(inputs)/2
    parameter = inputs{2*i-1};
    value = inputs{2*i};
    assigned = false;
    
    for f=1:length(field_names)
        fldnm = field_names{f};
        
        if isfield(par.(fldnm),parameter)
            par.(fldnm).(parameter) = value;
            assigned = true;
            TraceMessage(['Changed parameter [',parameter,' = ',num2str(value),']'],par.Flags.quiet);
            break;
        end
    end
    
    if (~assigned)
        TraceMessage(['Unrecognized parameter, discarding [',parameter,']'],par.Flags.quiet,'warning');
    end
    
end

end

% -----------------------------------------------------------------------
function v = deCapsulate(cell_inputs)
assert(iscell(cell_inputs));

if ((length(cell_inputs)==1) && (iscell(cell_inputs{1})))
    v = cell_inputs{1};
else
    v = cell_inputs;
end

end