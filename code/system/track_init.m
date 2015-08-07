function [old_track_box, oldPoints] = track_init(img, g_img, model, opts)

fprintf('=== tracking initialization === \n');
img = imread([img_path file_info(1).name]);
img = imresize(img, 0.5);
[img_h img_w dim] = size(img);
g_img = rgb2gray(img);
bbox = edgeBoxes(img, model, opts);
bbox = box_filter(bbox, img, imgnet_mean_img, W, U, filter_param);
for bbox_num=1:size(bbox,1),
    points{bbox_num} = detectMinEigenFeature(g_img, 'ROI', bbox(bbox_num,1:4));
    tracker{bbox_num} = vision.PointTracker('MaxBidirectionalError', 2);
    initialize(tracker{bbox_num}, points{bbox_num}.Locataion, g_img);
    old_track_box = bbox;
end

oldPoints = points;
