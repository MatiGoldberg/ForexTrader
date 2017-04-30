% ~~ Direct Reinforcement Trader ~~
% Following
% [1] J.Moody & M.Shaffel, "Learning to Trade via Direct Reinforcement", 
%     IEEE Transactions on Neural Networks, Vol.12 No.4 July 2001.
% [2] C.Gold, "FX Trading via Recurrent Reinforcement Learning".
%
% by: M.Goldberg, July-August 2013.

function T = DRConsecutiveTrader(prices, window_size, train_size, inputs, epochs, varargin)

% -- Default Parameters --------- %
Mu = 1;             % Purchase units
Delta = 0;          % Transaction cost MU*0.2/100;
Eta = 0.01;         % EMA parameter for diff SR
Rho1 = 0.35;        % learning parameter
Rho2 = Rho1/10;     % learning parameter
Rho3 = Rho2/10;     % learning parameter
Ni = 1e-5;          % weight decay
weights = 0;
weights_type = 'random';
weight_spread = 1/(inputs+2);
weight_bias = 0;
Lambda_rate = 0.99;
quiet = false;
use_mex = true;
produce_plot = false;
normalize = true;
three_state = false;
series_size = length(prices);
% ------------------------------- %

% -- Varargin ------------------- %
parseVarargin;
% ------------------------------- %

% -- Sanity --------------------- %
assert(series_size >= window_size,'series is shorter than the window size.');
assert(window_size > train_size, 'window size is smaller than the training set.');
assert(train_size >= inputs,'series too short or too many inputs');
% ------------------------------- %

% -- Consolidate Parameters ----- %
parameters = [Mu, Delta, Eta, three_state, Ni, Rho1, Rho2, Rho3, Lambda_rate ,epochs];
% ------------------------------- %

% -- Init ----------------------- %
if length(prices)>=series_size
    z = prices(1:series_size);
    clear prices;
else
    error('Prices series too short');
end

if length(weights) == (inputs+2)
    if (~quiet)
        disp('    - Receiving Weights');
    end
    w = weights(1:inputs);
    u = weights(inputs+1);
    v = weights(inputs+2);
else
    [w, u, v] = initWeights(inputs,weights_type);
    if strcmp(weights_type,'random')
        w = w*weight_spread + weight_bias;
        u = u*weight_spread + weight_bias;
        v = v*weight_spread + weight_bias;
    end
    weights = [w; u; v];
end
% ------------------------------- %

% -- Main Loop ------------------ %
num_of_windows = 1 + floor((series_size-window_size)/(window_size-train_size));
disp(['Number of windows: ',num2str(num_of_windows)])
series_size = window_size + (num_of_windows-1)*(window_size-train_size);
disp(['Series truncated: ',num2str(length(z)),' --> ',num2str(series_size)])

T.Outputs.F = zeros(series_size,1);
T.Outputs.F_ut = zeros(series_size,1);
T.Outputs.Sharpe = zeros(series_size,1);
T.Outputs.Profit = zeros(series_size,1);

for window = 1:num_of_windows
    
    istart = 1+(window-1)*(window_size-train_size);
    iend   = istart + window_size -1;
    
    
    % (0) Initialize Weights
    [w, u, v] = initWeights(inputs,weights_type);
    if strcmp(weights_type,'random')
        w = w*weight_spread + weight_bias;
        u = u*weight_spread + weight_bias;
        v = v*weight_spread + weight_bias;
    end
    weights = [w; u; v];

    % (1) Normalize input according to train series
    if (normalize)
        [zn, nscale] = normPrices(z(istart:iend),train_size);
    else
        nscale = 1;
        zn = z;
    end

    r = createRatesFromPrices(zn);

    % (2) Train weights
    epsilon = randn(train_size*epochs,1);
    
    if (use_mex)
        weights = DRTrain(r(1:train_size),parameters,weights,epsilon);
    else
        weights = DRTrainWeights(r(1:train_size),parameters,weights,epsilon);
    end

	% (3) Run Trader
    if (use_mex)
        [F_ut, F, P, sharpe] = DRPass(r(train_size+1:end), parameters, weights);
    else
        [F_ut, F, P, sharpe] = DRPassSeries(r(train_size+1:end), parameters, weights);
    end
    
    T.Outputs.F(istart+train_size:iend) = F;
    T.Outputs.F_ut(istart+train_size:iend) = F_ut;
    T.Outputs.Sharpe(istart+train_size:iend) = sharpe + T.Outputs.Sharpe(istart+train_size-1);
    T.Outputs.Profit(istart+train_size:iend) = P*nscale + T.Outputs.Profit(istart+train_size-1);

end

% -- Save Results --------------- %
T.Inputs.Price = z(1:series_size);
T.Inputs.Return = createRatesFromPrices(z(1:series_size));
T.Inputs.Time = (1:series_size)';
T.Weights = weights;
T.Parameters.Frame = [series_size,train_size,window_size];
T.Parameters.Model = parameters;
% ------------------------------- %

% -- Plotting -------------- %
if produce_plot
    h = DRPlot(T);
end
% -------------------------- %

end

%% Init Weights
function [w,u,v] = initWeights(inputs,init_type)
switch init_type
    case 'random'
        w = randn(inputs,1)/inputs;
        u = randn(1)/inputs;
        v = randn(1)/inputs;
        
    case 'ones'
        w = ones(inputs,1);
        u = 1;
        v = 1;
        
    otherwise
        error('unrecognized init type');
end
end

%% Normalization 
function [zn, nscale] = normPrices(z,Tl)
nbias = mean(z(1:Tl));
nscale = std(z(1:Tl));
zn = (z-nbias)./nscale;
end

%% Rates from Prices
function r = createRatesFromPrices(z)
r = [0;diff(z)];
end
