function bbox_result = box_filter(bbox, img, imgnet_mean_img, W, U, filter_param)
[img_h img_w img_dim] = size(img);
for i=1:size(bbox,1),
    x1 = max(1,bbox(i,1));
    y1 = max(1,bbox(i,2));
    x2 = min(x1+bbox(i,3), img_w);
    y2 = min(y1+bbox(i,4), img_h);
    box_img = img(y1:y2, x1:x2,:);
    
    % feature extraction
    feat = extract_caffe_feature(box_img,imgnet_mean_img);
    
    % LME classification
    [label prob] = infer_system(W, U, feat);
    
    % thresholding
    if prob > filter_param.prob,
        bbox_result(i, 1:4) = bbox(i,:);
        bbox_result(i, 5) = label;
        bbox_result(i, 6) = prob;
    else
        bbox_result(i, 1:4) = bbox(i,:);
        bbox_result(i, 5) = 11;
        bbox_result(i, 6) = prob;
    end
end

% if size(bbox_result,1) > 1
%     bbox_result = box_reduce(bbox_result, size(img,1), size(img,2), filter_param);
% end

%-----------------------------------------------------------------------------
function fixed_box = box_reduce(bbox, img_h, img_w, filter_param)
%-----------------------------------------------------------------------------

kind_label = unique(bbox(:,6));
% new_bbox = [];
fixed_box = [];
for i=1:length(kind_label)
    idx = find(bbox(:,6) == kind_label(i));
    remain_boxes_idx = idx;
    if length(idx) == 1,
        fixed_box(end+1,:) = bbox(idx,:);
    else
        while size(remain_boxes_idx,1) > 1,
            %         [n k] = min(remain_boxes_idx);
            box_a = bbox(remain_boxes_idx(1),:);
            box_b = bbox(remain_boxes_idx(2:end),:);
            [remain_boxes_idx, compare_result_boxes, curr_final_box] = box_compare(box_a, box_b, img_h, img_w, filter_param);
            fixed_box(end+1,:) = curr_final_box;
        end
        if ~isempty(compare_result_boxes)
            fixed_box(end+1:end+size(compare_result_boxes,1),:) = compare_result_boxes;
        end
    end
end




function [remain_boxes_idx, compare_result_boxes, fixed_final_box] = box_compare(box_a, box_b, img_h, img_w, filter_param)

tmp = zeros(img_h, img_w);

tmp(box_a(1,2):box_a(1,2)+box_a(1,4), box_a(1,1):box_a(1,1)+box_a(1,3)) = 1;
tmp = repmat(tmp, [1 1 size(box_b,1)]);
tmp_prob = box_a(1,7);
tmp_idx = 0;
remain_boxes_idx = [];
fixed_final_box = [];
compare_result_boxes = [];
for i=1:size(box_b,1)
    tmp(box_b(i,2):box_b(i,2)+box_b(i,4), box_b(i,1):box_b(i,1)+box_b(i,3),i) = tmp(box_b(i,2):box_b(i,2)+box_b(i,4), box_b(i,1):box_b(i,1)+box_b(i,3),i)+1;
    a = tmp(:,:,i);
    inter_rate = (numel(find(a(:)==2))/numel(find(a(:)>0)));    
    
    if inter_rate > filter_param.ints,
        if tmp_prob < box_b(i,7)
            tmp_prob = box_b(i,7);
            tmp_idx = i;
        end
    else
        remain_boxes_idx(end+1) = i;
    end
end

if ~isempty(remain_boxes_idx)
    compare_result_boxes(1:size(remain_boxes_idx,2),:) = box_b(remain_boxes_idx,:);
end

if tmp_idx == 0,
    fixed_final_box(end+1,:) = box_a;
else
    fixed_final_box(end+1,:) = box_b(tmp_idx,:);
end







