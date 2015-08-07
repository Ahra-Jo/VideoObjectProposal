function [img_path file_info] = path_configure(video_name)
code_path = '/v1/projects/VideoObjectProposal/code/';
data_path = '/home/ahra/ADL/';

%% addpath for image data
addpath([data_path 'ADL_annotations/object_annotation/']);
addpath([data_path 'ADL_annoted_frames/' video_name]);
addpath([data_path 'ADL_code/']);
addpath([code_path 'rcnn/datasets/train40_jpg/']);
%% get file information
img_path = [data_path 'ADL_annoted_frames/' video_name '/'];
file_info = dir([img_path '/*.jpg']);

%% addpath for edge box
addpath(genpath([code_path 'Edge_Boxes/']));

%% addpath for accuracy drawing
addpath([code_path 'drawing_accuracy/']);

%% addpath for CNN
addpath('/v1/projects/VideoObjectProposal/caffe/matlab/caffe');

%% addpath for data (train model)
addpath('/v1/projects/VideoObjectProposal/data/');

%% addpath for lme
addpath(genpath([code_path 'lme/']));

%% addpath for spams lib
addpath(genpath([code_path 'spams-matlab/']));

%% addpath for sparse coding and dictionary learning
addpath([code_path 'scdl/']);