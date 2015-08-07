function [model, opts] = edgebox_configure

%% load pre-trained edge detection model and set opts (see edgesDemo.m)
model = load('models/forest/modelBsds');
model = model.model;
model.opts.multiscale = 0;
model.opts.sharpen = 1;
model.opts.nThreads = 5;

%% set up opts for edgeBoxes (see edgeBoxes.m)
opts = edgeBoxes;
opts.alpha = .65;           % step size of sliding window search
opts.beta = .9;             % nms threshold for object proposals
opts.minScore = .01;        % min score of boxes to detect
opts.maxBoxes = 100;         % max number of boxes to detect
