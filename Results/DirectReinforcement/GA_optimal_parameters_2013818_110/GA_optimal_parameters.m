% FIND_OPTIMAL_PARAMETERS, GA style
% finds best parameters for a given time series z
function par = GA_optimal_parameters(z,varargin)

% -- Framework Parameters ------- %
defaults.Mu = 1;             % Purchase units
defaults.Delta = 0;          % Transaction cost MU*0.2/100;
samples = 50;
generations = 25;
population_size   = 100;
recombinatio_size = 60;
new_gene_size     = 35;
save_output = false;
% ------------------------------- %

% -- Default Values ------------- %
defaults.inputs = 5;
defaults.epochs = 25;
defaults.train_len = 5000;
defaults.weight_spread = 8;
defaults.weight_bias = 0;

defaults.Ni = 1e-5;
defaults.Eta = 0.01;
defaults.Rho1 = 0.35;
defaults.Rho2 = 0.035;
defaults.Rho3 = 0.0035;
defaults.Lambda_rate = 0.99;
% ------------------------------- %

% -- Gene Pool ------------------ %
parrange.inputs         = linspace(3,25,23); 
parrange.epochs         = linspace(15,25,5);
parrange.weight_spread  = logspace(-2,2,25);
parrange.weight_bias    = linspace(-0.5,0.5,10);

parrange.Ni             = logspace(-5,-4,10);       % weight decay
parrange.Eta            = logspace(-1.5,-1,10);     % EMA parameter for diff SR
parrange.Rho1           = logspace(-2,-0.5,10);     % weight learning parameter
parrange.Rho2           = logspace(-3,-1.5,10);     % weight learning parameter
parrange.Rho3           = logspace(-4,-2.5,10);     % weight learning parameter
parrange.Lambda_rate    = [0.98, 0.99, 0.999];      % exploration-exploitation tradeoff
% ------------------------------- %
parseVarargin;

tic
% -- Create Initial Population -- %
pop = getPopulation(population_size,parrange,defaults);
% disp(['- Population: ',num2str(toc)]); tic;


for gen=1:generations
% -- Evaluate Performence ------- %
    per = evalPerformence(z, pop, samples);
%     disp(['- Performence: ',num2str(toc)]); tic;

% -- Sort Results --------------- %
    [~,order] = sort(per);  % in ascending order
    pop = pop(order);
    per = sort(per);
%     disp(['- Sort: ',num2str(toc)]); tic;

% -- Recombination -------------- %
    pop(new_gene_size+1:new_gene_size+recombinatio_size) = ...
        recombinate(pop(new_gene_size+1:new_gene_size+recombinatio_size));
%     disp(['- Recombination: ',num2str(toc)]);

% -- Enter Fresh Population ----- %
    % Maybe this should be dynamic %
    pop(1:new_gene_size) = getPopulation(new_gene_size,parrange,defaults);
    
    disp(['- Best so far [',num2str(gen),'/',num2str(generations),']: ',num2str(per(end))]);
end
toc

par = pop(end);
% disp(['- Final Score: ',num2str(per(end))]);

% save script file
if (save_output)
    dir_name = getDirName();
    mkdir(dir_name);
    copyfile([mfilename,'.m'],[dir_name,'\',mfilename,'.m']);

% save results
    save results
    movefile('results.mat',[dir_name,'\results.mat'],'f');
end

end

%% Create Population
function pop = getPopulation(pop_size, parrange, defaults)
field_names = fieldnames(defaults);
pop(1:pop_size) = struct('Mu',[],'Delta',[],'Eta',[],'Ni',[],'Rho1',[],...
    'Rho2',[],'Rho3',[],'Lambda_rate',[],'epochs',[],'train_len',[],'inputs',[]);

for f=1:length(field_names)
    fldnm = field_names{f};
    
    if ~isfield(parrange,fldnm)
        % set default value
        [pop(1:pop_size).(fldnm)] = deal(defaults.(fldnm));
    else
        % set random values from range
        range = length(parrange.(fldnm));
        indices = randi(range,pop_size,1);
        values = num2cell(parrange.(fldnm)(indices));
        [pop(1:pop_size).(fldnm)] = deal(values{:});
    end

end

end

%% Evaluate Performence
function per = evalPerformence(z, par, samples)
pop_size = length(par);
temp_per = zeros(samples,1);
per = zeros(pop_size,1);

for i=1:pop_size
    
    parfor s = 1:samples
        T = DRTrader2(z,par(i));

        % calculate performence
        top = T.Outputs.Profit(end);
        slope =  top / par(i).train_len;
        sig = std(T.Outputs.Profit - (1:par(i).train_len)'.*slope);
        sharpe  = top/sig;
        crosses = crossCount(T.Outputs.F);

        temp_per(s) = sharpe*crosses*(par(i).train_len-1-crosses);
    end
    per(i) = mean(temp_per);
    
end

end

%% RECOMBINATE
function pop = recombinate(pop)
pop_size = length(pop);
per = randperm(pop_size);
field_names = fieldnames(pop(1));
num_of_fields = length(field_names);

for k=1:pop_size/2
    break_point = randi(num_of_fields);
    % i,j are indices of the recombinated items
    i = per(2*k-1);
    j = per(2*k-0);
    p1 = pop(i);
    p2 = pop(j);
    
    for f = 1:break_point
       fldnm =  field_names{f};
       pop(i).(fldnm) = p2.(fldnm);
       pop(j).(fldnm) = p1.(fldnm);
    end
    
end

end

%% Get Results Directory Name
function dir_name = getDirName()
dv = datevec(now);
dir_name = [mfilename,'_',num2str(dv(1)),num2str(dv(2)),num2str(dv(3)),'_',num2str(dv(4)),num2str(dv(5))];

end

