function filter_param = box_filter_config

filter_param.prob = 0.6;
filter_param.ints = 0.3; 
filter_param.d = 3; % seen or not  % d = min|s_new - s|
filter_param.r = 10; % unseen or unfamiliar  % r = min||Wx_new - UaSm||_2