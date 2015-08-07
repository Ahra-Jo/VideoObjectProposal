function lme_param = lme_param_configure

% Set up general parameters for the experiment
lme_param.dimk = 15; % Projection dimension. This will decide the dimensionality of hte learned space.
lme_param.dim = 4096; % Original feature dimensionality
%numex = 30; % Number of training instances per class 
lme_param.expno = 1; % Split to use
% Set up parameters for LME
lme_param.parallel = 0; % Whether to use the GPU parallelization using parallel processing package
lme_param.maxalter = 20; % Maximum number of alternations 
lme_param.maxiter = 1000; % Maximum number of iterations
lme_param.projected = 1; % Whether to use the projection or regularization for l2-norm regularization
lme_param.stochastic = 1; % Whether to use stochastic gradient
% param.numsamples = 100; % Number of samples to consider for gradient computation at each step
% param.numsamples = 1000; % Number of samples to consider for gradient computation at each step
lme_param.numsamples = 50; % Number of samples to consider for gradient computation at each step
lme_param.steprule = 'diminishing'; % Step rule for the SGD
lme_param.eta = 1; % Learning rate 
lme_param.S = []; % C x C Semantic similarity between classes.
lme_param.val = []; % Validation set.
lme_param.lambda = 1; % L2-regularization parameter


