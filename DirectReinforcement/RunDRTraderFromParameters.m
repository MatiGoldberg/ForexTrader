function T = RunDRTraderFromParameters()

% -- Tracing -- %
clearLogFile();
TraceMessage('*** START: RunDRTraderFromParameters ***');
% ------------- %

% -- Consider Inputs -- %
parameters = DRParameters(varargin);
% --------------------- %

% -- Get Rates -- %
R = DRLoadRange(currency,start_date,end_date,parameters.Flags.fix_data);
rates = R.close;
TraceMessage('Setting rates to R.close');
assert(length(rates)>parameters.Frame.window_size,'Series smaller than window size');
% --------------- %

% -- Auxilliary Series -- %
%add_aux = exist('aux_series','var');
add_aux = ~isempty(aux_series);
if (add_aux)
    assert(length(aux_series) >= length(rates),'Auxiliary series too short')
    aux_series = aux_series(1:length(rates));
    rates = [rates,aux_series];
    TraceMessage(['Aux Series added and truncated [',num2str(length(rates)),']']);
end
% ----------------------- %

% -- Initial Settings -- %
initial_weights = DRCreateWeights(parameters,add_aux);
random_series = createRandomSeries(parameters);
% ---------------------- %

% -- Run DRTrader -- %
TraceMessage('--- Executing Trader ---'); tic
T = DRTrader(rates, parameters, initial_weights, random_series);
TraceMessage(['--- Trader Ended [',parseTime(toc),'] ---'])
% ------------------ %

% -- Construct Outputs -- %
T.Parameters = parameters;
T.InitialWeights = initial_weights;
T.Inputs.Series = rates(:,1);
T.Inputs.TimeBase = R.time(1:length(T.Inputs.Time));
T.Inputs.RandomSeries = random_series;
if (add_aux)
    T.Inputs.AuxSeries = aux_series;
end
% ----------------------- %

% -- Plot Results -- %
if (parameters.Flags.produce_plot)
    DRPlot(T);
end
% ------------------ %

% -- Tracing -- %
TraceMessage('*** END: RunDRTraderFromParameters ***');
saveLogFile([datestr(now,30),'RunDRTraderFromParameters.txt']);
% ------------- %

end

% -----------------------------------------------------------------------
function S = createRandomSeries(par)
S = randn(par.Frame.training_set*par.Frame.epochs,1);
end

% ----------------------------------------------------------------------
function s = parseTime(t_sec)

if (t_sec<60)           % Seconds
    s = [num2str(t_sec,2),'s'];
elseif (t_sec< 3600)    % Minutes
    m = floor(t_sec/60);
    s = [num2str(m),'m',num2str(round(t_sec-60*m)),'s'];
else                    % Hours
    h = floor(t_sec/3600);
    m = floor((t_sec-h*3600)/60);
    s = [num2str(h),'h',num2str(m),'m',num2str(round(t_sec-3600*h-60*m)),'s'];
end
end