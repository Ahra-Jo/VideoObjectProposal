function img_path = path_configure
code_path = '/v1/projects/VideoObjectProposal/code/';

%% addpath for CNN
addpath('/v1/projects/VideoObjectProposal/caffe/matlab/caffe');

%% addpath for data (train model)
addpath('/v1/projects/VideoObjectProposal/data/');
addpath('/v1/projects/VideoObjectProposal/data/lme/');

%% addpath for img 
img_path = '/hdd/awa/JPEGImages/';
addpath (genpath(img_path));

%% addpath for lme
addpath(genpath([code_path 'lme/']));

%% addpath for spams lib
addpath(genpath([code_path 'spams-matlab/']));

%% addpath for sparse coding and dictionary learning
addpath([code_path 'scdl/']);
