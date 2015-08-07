function run_obj_tracking(p_num, img, model, opts)
% use Edge_boxes and KLT tracker

%% detect Edge Box bounding box proposals (see edgeBoxes.m)
% if i_num == 1,
% img = imread(title{1});
% img = imresize(img, 0.5);
[img_h img_w dim] = size(img);
% Convert the first box into a list of 4 points
% This is needed to be able to visualize the rotation of the object.

g_img = rgb2gray(img);
% for bbox_num=1:size(gt,1),
%     points{bbox_num} = detectMinEigenFeatures(g_img, 'ROI', gt(bbox_num,1:4));
%     %         pointImage = insertMarker(img, points.Location, '+', 'Color', 'white');
%     %         imshow(pointImage), title('Detected interest points');
%     
%     tracker{bbox_num} = vision.PointTracker('MaxBidirectionalError', 2);
%     
%     initialize(tracker{bbox_num}, points{bbox_num}.Location, g_img);
%     %     pre_obj_num = size(gt,1); % object number of a previous frame
%     
%     old_track_box = gt;
% end
% end

oldPoints = points;
for i_num=2:5:length(title)
    i_num
    img = imread(title{i_num});
    img = imresize(img, 0.5);
    
    % Convert the first box into a list of 4 points
    % This is needed to be able to visualize the rotation of the object.
    
    g_img = rgb2gray(img);
        
    % Edge Box
%     tic, 
    bbox=edgeBoxes(img,model,opts);
%     toc
    
    %     oldPoints = points;
    
    for obj_num=1:size(old_track_box,1),
%         [points, isFound] = step(tracker{obj_num}, img);
    [points, isFound] = step(tracker{obj_num}, g_img);
        visiblePoints = points(isFound, :);
        oldInliers = oldPoints{obj_num}(isFound, :);
        
        if size(visiblePoints, 1) >= 2
            % Estimate the geometric transformation between the old points
            % and the new points and eliminate outliers
            [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
                oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
            
            % Apply the transformation to the bounding box points
            tmp_bbox = old_track_box(obj_num,1:4);
            bbox2points = [tmp_bbox(1), tmp_bbox(2); tmp_bbox(1)+tmp_bbox(3), tmp_bbox(2); ...
                tmp_bbox(1) + tmp_bbox(3), tmp_bbox(2) + tmp_bbox(4); tmp_bbox(1), tmp_bbox(2)+tmp_bbox(4)];

            
            bbox2points = transformPointsForward(xform, bbox2points);
            
            % Insert a bounding box around the object being tracked
            bboxPolygon = reshape(bbox2points', 1, []);
            old_track_box(obj_num, :) = [max(1,round(bboxPolygon(1))), max(1,round(bboxPolygon(2))), ...
                round(bboxPolygon(3))-round(bboxPolygon(1)), ...
                round(bboxPolygon(8))-round(bboxPolygon(2))];
            %             img = insertShape(img, 'Polygon', bboxPolygon, ...
            %                 'LineWidth', 2);
            
            if size(old_track_box,1) > 0,
                [max_score_box score] = compute_matching_rate(img_h, img_w, old_track_box(obj_num, :), bbox);
                if score > 0.7
                    old_track_box(obj_num,:) = max_score_box(1,1:4); % x y w h
                else
                    old_track_box(obj_num,:) = old_track_box(obj_num,1:4);
                end
                img = draw_box(img, old_track_box(obj_num,1),old_track_box(obj_num,2), ...
                    old_track_box(obj_num,3)+old_track_box(obj_num,1),old_track_box(obj_num,4)+old_track_box(obj_num,2), ...
                    [255 0 0]);
            end
            % Display tracked points
            %             img = insertMarker(img, visiblePoints, '+', ...
            %                 'Color', 'white');
            
            % Reset the points
            oldPoints{obj_num} = visiblePoints;
            setPoints(tracker{obj_num}, oldPoints{obj_num});
            
            isFound = [];
            visiblePoints = [];
            oldInliers = [];

        else
            if size(old_track_box,1) > 0,
                old_track_box(obj_num,:) = [];  
            end
        end
        
    end
    imshow(img);

end