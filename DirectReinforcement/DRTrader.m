% -- Direct Reinforcement Trader ---------------------------------------
% Following
% [1] J.Moody & M.Shaffel, "Learning to Trade via Direct Reinforcement", 
%     IEEE Transactions on Neural Networks, Vol.12 No.4 July 2001.
% [2] C.Gold, "FX Trading via Recurrent Reinforcement Learning".
%
% by: M.Goldberg, December 2013.
% ----------------------------------------------------------------------
function T = DRTrader(rates, par, initial_weights, random_series)

% -- Sanity --------------------- %
assert(length(rates) >= par.Frame.window_size,'series is shorter than the window size.');
assert(par.Frame.window_size > par.Frame.training_set, 'window size is smaller than the training set.');
assert(par.Frame.training_set >= par.Frame.inputs,'series too short or too many inputs');
% ------------------------------- %

% -- Consolidate Parameters ----- %
model_parameters = consolidate(par);
% ------------------------------- %

% -- Aux Series ----------------- %
use_aux = (size(rates,2)==2);
if (use_aux)
    TraceMessage('Using auxiliary series.',par.Flags.quiet);
end
% ------------------------------- %

% -- Init ----------------------- %
series_size = length(rates);
num_of_windows = 1 + floor((series_size-par.Frame.window_size)/(par.Frame.window_size-par.Frame.training_set));
TraceMessage(['Number of consecutive windows: ',num2str(num_of_windows)],par.Flags.quiet)
series_size = par.Frame.window_size + (num_of_windows-1)*(par.Frame.window_size-par.Frame.training_set);
TraceMessage(['Series truncated: ',num2str(length(rates)),' --> ',num2str(series_size)],par.Flags.quiet)

T.Outputs.F = zeros(series_size,1);
T.Outputs.F_ut = zeros(series_size,1);
T.Outputs.Sharpe = zeros(series_size,1);
T.Outputs.Profit = zeros(series_size,1);

if (use_aux)
    weights = [initial_weights.v; initial_weights.u; initial_weights.w; initial_weights.s];
else
    weights = [initial_weights.v; initial_weights.u; initial_weights.w];
end
% ------------------------------- %

% -- Main Loop ------------------ %
k = fprintf('--[%d%%]--',0);
for window = 1:num_of_windows
    
    istart = 1+(window-1)*(par.Frame.window_size-par.Frame.training_set);
    iend   = istart + par.Frame.window_size -1;
    
    % (1) Normalize input according to train series
    if (par.Flags.normalize)
        [zn, nscale] = normPrices(rates(istart:iend,:),par.Frame.training_set);
    else
        nscale = 1;
        zn = z;
    end

    r = createRatesFromPrices(zn);

    % (2,3) Train weights, Run Trader
    if (use_aux)
        weights = DRDTrain(r(1:par.Frame.training_set,1),r(1:par.Frame.training_set,2),[model_parameters,par.Model.Zeta],weights,random_series);
        [F_ut, F, P, sharpe] = DRDPass(r(par.Frame.training_set+1:end,1),r(par.Frame.training_set+1:end,2),[model_parameters,par.Model.Zeta], weights);
    else
        weights = DRTrain(r(1:par.Frame.training_set),model_parameters,weights,random_series);
        [F_ut, F, P, sharpe] = DRPass(r(par.Frame.training_set+1:end), model_parameters, weights);
    end
    
    T.Outputs.F(istart+par.Frame.training_set:iend) = F;
    T.Outputs.F_ut(istart+par.Frame.training_set:iend) = F_ut;
    T.Outputs.Sharpe(istart+par.Frame.training_set:iend) = sharpe + T.Outputs.Sharpe(istart+par.Frame.training_set-1);
    T.Outputs.Profit(istart+par.Frame.training_set:iend) = P*nscale(1,1) + T.Outputs.Profit(istart+par.Frame.training_set-1);

    % -- Status Update -- %
    for j=1:k
        fprintf('\b');
    end
    k = fprintf('--[%d%%]--',round(100*window/num_of_windows));
    % ------------------- %    
end
fprintf('\n');

% -- Save Results --------------- %
T.Inputs.Price = rates(1:series_size,1);
T.Inputs.Return = createRatesFromPrices(rates(1:series_size,1));
T.Inputs.Time = (1:series_size)';
T.FinalWeights = weights;
% ------------------------------- %

end

%% Consolidate Parameters
function vec = consolidate(P)
vec = [P.Model.Mu, P.Model.Delta, P.Model.Eta, P.Flags.three_state, ...
       P.Model.Ni, P.Model.Rho1, P.Model.Rho2, P.Model.Rho3, ...
       P.Model.lambda_rate ,P.Frame.epochs];

end

%% Normalization 
function [zn, nscale] = normPrices(z,Tl)
[M,~] = size(z);
nbias = mean(z(1:Tl,:),1);
nscale = std(z(1:Tl,:),1);
zn = (z - ones(M,1)*nbias)./(ones(M,1)*nscale);
end

%% Rates from Prices
function r = createRatesFromPrices(z)
r = [zeros(1,size(z,2));diff(z)];
end
