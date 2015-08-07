function [max_score_box val bbox] = compute_matching_rate(img_h, img_w, track_box, bbox)
    template_box = zeros(img_h,img_w);
    
%     % tracking result box axis
    track_box_x = max(1, track_box(1));
    track_box_y = max(1, track_box(2));
    track_box_x2 = track_box_x + track_box(3);
    track_box_y2 = track_box_y + track_box(4);
    
%     track_box_region = track_box(3) * track_box(4);
    template_box(track_box_y:track_box_y2, track_box_x:track_box_x2) = 1;

    % bbox axis
    abbox_x(:,1) = max(1,bbox(:, 1));
    abbox_y(:,1) = max(1,bbox(:, 2));
    abbox_x2(:,1) = min(bbox(:,3)+abbox_x(:,1),img_w);
    abbox_y2(:,1) = min(bbox(:,4)+abbox_y(:,1),img_h);

%     bbox_region = bbox(:,3) .* bbox(:,4);
    
%     union_region = track_box_region + bbox_region;,e
        
%     intsc_region = abs(track_box_x2-bbox(:,1)).*abs(track_box_y2-bbox(:,2));
for i=1:size(bbox,1)
    
    score_box = template_box;
    
    score_box(abbox_y(i):abbox_y2(i), abbox_x(i):abbox_x2(i)) = ...
        score_box(abbox_y(i):abbox_y2(i), abbox_x(i):abbox_x2(i)) + 1;
    
    % compute intersection/union
    ints = numel(find(score_box(:)==2)); % insersection
    score(i) = ints/numel(find(score_box(:)>0));       
end

[val idx] = max(score);
if val > 0.6
    max_score_box = bbox(idx,1:4);
    bbox(idx,:) = [];
else
    max_score_box = track_box;
end
% fprintf('maximum score: %f\n', val);