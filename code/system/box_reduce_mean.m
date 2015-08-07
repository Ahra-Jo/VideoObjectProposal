%-----------------------------------------------------------------------------
function curr_fixed_box = box_reduce_mean(img_h, img_w, bbox)
%-----------------------------------------------------------------------------

curr_fixed_box = [];
far_boxes = bbox;

while size(far_boxes,1) > 0,
    
    box_a = far_boxes(1,:);
    box_b = far_boxes(2:end,:);
    [fixed_boxes, far_boxes] = box_compare(box_a, box_b, img_h, img_w);
    
    curr_fixed_box(end+1,:) = fixed_boxes;
    
end



function [fixed_box, far_boxes] = box_compare(box_a, box_b, img_h, img_w)

tmp = zeros(img_h, img_w);

tmp(box_a(1,2):box_a(1,2)+box_a(1,4), box_a(1,1):box_a(1,1)+box_a(1,3)) = 1;
tmp = repmat(tmp, [1 1 size(box_b,1)]);

near_boxes = [];
far_boxes = [];

for i=1:size(box_b,1)
    tmp(box_b(i,2):box_b(i,2)+box_b(i,4), box_b(i,1):box_b(i,1)+box_b(i,3),i) = tmp(box_b(i,2):box_b(i,2)+box_b(i,4), box_b(i,1):box_b(i,1)+box_b(i,3),i)+1;
    a = tmp(:,:,i);
    
    inter_sec = numel(find(a(:)==2));
    inter_rate = (inter_sec/numel(find(a(:)>0)));    
    
    if inter_rate > 0.5,
        near_boxes(end+1,:) = box_b(i,:);
    else
        far_boxes(end+1,:) = box_b(i,:);
    end

end

if size(near_boxes,1) > 0,
    near_boxes(end+1,:) = box_a;
    fixed_box = round(mean(near_boxes,1));
else
    fixed_box = box_a;
end

