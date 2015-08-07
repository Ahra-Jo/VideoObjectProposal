function runlog

fprintf('#### path_configure #### \n');
img_path = path_configure;

%% load caffe model
fprintf('#### caffe_configure #### \n');
caffe_configure;
mean_img = load('ilsvrc_2012_mean');

%% load lme model
fprintf('#### load LME model #### \n');
load('lme_W_AWA15_150807.mat');
load('lme_U_AWA15_150807.mat');
lme_param = lme_param_configure; % for lifelong learning
%% load train feature
% load labels
load('AWA_train15_label.mat');
% load features
load('AWA_train15_feature.mat');
% load feature list
load('AWA_train15_list.mat');

train_set.feat = train_feat;
train_set.label = train_label;
train_set.list = train_list; 

% load test data
load('AWA_test15_label.mat');
load('AWA_test15_feature.mat');
load('AWA_test15_list.mat');

test_set.feat = test_feat;
test_set.label = test_label;
test_set.list = test_list;

% load attribute
load('/hdd/awa/Animals_with_Attributes/Attribute_mat.mat');
SCDLdata.Ua = Attribute_mat;

% scdl param. configure
[SCDLdata.sparam  SCDLdata.dparam] = scdl_configure;

% filter param.
filter_param.d = 0.01;
filter_param.r = 
fprintf('#### START #### \n');
[seen_list, unseen_list, unfamiliar_list] = main_algo(img_path, model, opts, mean_img, W, U, SCDLdata, lme_param, train_set, test_set);

