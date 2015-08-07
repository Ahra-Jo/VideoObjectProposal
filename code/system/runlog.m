function runlog(video_name)
if ~exist('video_name','var')
    video_name = 'P_01';
end

fprintf('#### path_configure #### \n');
tic
[img_path file_info] = path_configure(video_name);
toc

%% EdgeBox param. configure
fprintf('#### edgebox_configure #### \n');
[model opts] = edgebox_configure;

%% load annotations
fprintf('#### load annotation #### \n');
load(['/home/ahra/ADL/ADL_annotations/object_annotation/object_annot_' video_name '.mat']);

%% find annoted frames
% annot_frames = unique(sort(str2num(cell2mat(annot(:,6)))));

%% load caffe model
fprintf('#### caffe_configure #### \n');
caffe_configure;
mean_img = load('ilsvrc_2012_mean');

%% load lme model
fprintf('#### load LME model #### \n');
% load('lme_W_ADL_150716.mat');
% load('lme_U_ADL_150716.mat');
% load('lme_W_150715.mat');
% load('lme_U_150715.mat');
load('lme_W_ImageNet_150801.mat');
load('lme_U_ImageNet_150801.mat');
lme_param = lme_param_configure; % for lifelong learning
%% load train feature
% load labels
load('/v1/projects/VideoObjectProposal/data/ImageNet_url_train_label.mat');
% load features
load('/v1/projects/VideoObjectProposal/data/ImageNet_url_train_feature.mat');
% load feature list
load('/v1/projects/VideoObjectProposal/data/ImageNet_url_feature_list.mat');
load('/v1/projects/VideoObjectProposal/data/ImageNet_url_feature_category_cnt_table.mat');
% load train projected W*xtr
load('X.mat');

train_set.feat = train_feat;
train_set.label = label;
train_set.list = feature_list; 
train_set.cnt_table = category_cnt_table;
%% sparse coding and dictionary learning configure
% load sparse coding and dictionary learning initial data
load('Ua.mat');
load('S.mat');

SCDLdata.Ua = double(Ua);
SCDLdata.S = S;

% scdl param. configure
[SCDLdata.sparam  SCDLdata.dparam] = scdl_configure;

%% box filter param. configure
filter_param = box_filter_config;

%% window color and tag configure
base_category =  {'bottle', 'fridge', 'kettle', 'microwave', 'mug/cup' , 'oven/stove', 'soap_liquid',...
    'tap', 'tv', 'washer/dryer', 'unknown'};
drawing_info.tag_img = tag_configure(base_category);
drawing_info.col = mk_category_color(length(base_category));

%% Video recording configure
save_path = '/v1/projects/VideoObjectProposal/data/video_result/';
save_video_name = [save_path video_name '_test_' date '.avi'];
recording_on = 0;

%% START !
fprintf('#### START #### \n');
main_algo(img_path, file_info, model, opts, mean_img, W, U, drawing_info, save_video_name, recording_on, filter_param, SCDLdata, lme_param, train_set);

