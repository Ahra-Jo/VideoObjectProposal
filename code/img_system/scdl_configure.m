function [sparam dparam] = scdl_configure

% sparse coding
sparam.lambda = 1; % not more than 20 non-zeros coefficients
sparam.numThreads = -1; % number of processors/cores to use; the default choice is -1, and uses all the cores of the machine
sparam.mode=3;
sparam.pos = true;

% dictionary learning
dparam.K=85;
dparam.lambda = 0.15;
dparam.numThreads = -1;
dparam.verbose = false;
dparam.modeParam = 0;
dparam.iter=1000;
dparam.gamma1=0.3;
dparam.modeD=3;
