~~ DRTrader.m ~~
DRTrader.m uses Direct Reinforcement to learn a trading strategy for a given signal.
This is actually a 'flat' neural-network algorithm, only instead of using a reference output, it improves the weights
accordint to the improvement of a performence function (in this case - differential sharpe ratio).


Use cases:
---------
(1) T = DRTrader(series_len,train_len,inputs,epochs);
DRTrader would create a trader which makes trading decisions according to the last <inputs> elements.
The weight training process would use the first <train_len> samples, and repeat <epoch> times.
once the training process is complete, DRTrader would use the produced trader to run over the whole <series_len> samples.

T is a struct which inclues the following fields:
- Inputs {Price, Return, Time}
- Outputs {F, F_ut, Sharpe, Profit} - F is the thresholded trading signal
- Parameters {Frame, Model}
- Weights

(2) T = DRTrader(series_len,train_len,inputs,epochs,'parameter_name',parameter_value);
DRTrader.m accepts additional parameters in the known duplet sets.

Generally, every parameter can be changed using this format. for exmaple:
T - DRTrader(4000, 2000, 5, 25, 'Delta',0.02);
would run DRTrader with a transaction cost of 2%.

Specifically
use {'use_mex',0} to avoid using MEX-file Trainer and Runner.
use {'produce_plot',1} in order to plot the results in the end of the 
use {'prices',z} to enter your own price series
use {'quiet',1} to supress printouts

Supported prices_type values: ** will be removed in newer versions **
- 'artificial_new'
- 'artificial_preset' loads prices present in prices.mat file.
- 'real_2011' loads 2011 EURUSD prices in 1Hr resolution
- 'real_2010' loads 2010 EURUSD prices in 1Hr resolution
It is better to introduce your own prices.

Getting Started:
T = DRTrader(4000,4000,5,25,'produce_plot',1);

Example:
R = loadRange('EURUSD','20070729','20070802');
z = r.close;
T = DRTrader(5000, 5000, 5, 25, 'prices',z);
DRPlot(T);

~~ DRTRader2.m ~~
DRTrader2.m runs the same trader, only it receives a complete parameter struct as an input.
This way it is easier to run it in scripts. {see find_optimal_parameters.m}

Use case:
T = DRTrader2(z,par);
where <z> is a price series, and <par> is a struct with all parameters:

par.Mu = 1;             % Purchase units
par.Delta = 0;          % Transaction cost MU*0.2/100;
par.Eta = 0.055;        % EMA parameter for diff SR
par.Rho1 = 0.35;        % learning parameter
par.Rho2 = par.Rho1/10; % learning parameter
par.Rho3 = par.Rho2/10; % learning parameter
par.Ni = 1e-5;          % weight decay
par.Lambda_rate = 0.99;
...

and so on.



Future Improvements:
1) Re-order the DRTrader functions for more intuitive use.
2) Add an option to add additional series as an input.
3) Produce an algorithm to find optimal parameters for a given signal. this is crutial in real-life data.