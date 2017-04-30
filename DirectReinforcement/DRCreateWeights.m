% -- DRCreateWeights ----------------------------------------------------
% Supplies initial weights for DRTrader, according to the number of 
% inputs, addition of an auxilliary series and predefined statistics.
function weights = DRCreateWeights(par,add_aux)
L = par.Frame.inputs * (1+add_aux) + 2;
% -- Creation --
weights.vec = randn(L,1)*par.Weight.spread + par.Weight.bias;

% -- Distribution --
weights.v = weights.vec(1:par.Frame.inputs);
weights.u = weights.vec(par.Frame.inputs+1);
weights.w = weights.vec(par.Frame.inputs+2);
if (add_aux)
   weights.s =  weights.vec(par.Frame.inputs+3:end);
end

TraceMessage(['Created ',num2str(length(weights.vec)),' weights.'],par.Flags.quiet);
end
