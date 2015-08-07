function tracker(g_img, old_track_box, oldPoints)

for obj_num=1:size(old_track_box,1),
    [points, isFound] = step(tracker{obj_num}, g_img);      
    visiblePoints = points(isFound, :);
    oldInliers = oldPoints{obj_num}(isFound, :);
    
    if size(visiblePoints, 1) >= 2
        % Estimate the geometric tgransformation between the old points
        % and the new points and eliminate outliers
        [xform, oldInliers, visiblePoints] = estimateGeometricTransform(oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
        
        % Apply the transformation to the bounding box points
        tmp_bbox = old_track_box(obj_num, 1:4);
        bbox2points = [tmp_bbox(1), tmp_bbox(2); tmp_bbox(1)+tmp_bbox(3), tmp_bbox(2); tmp_bbox(1)+tmp_bbox(3), tmp_bbox(2)+tmp_bbox(4); tmp_bbox(2)+tmp_bbox(4)];
        
        bbox2points = transformPointsForward(xform, bbox2points);
        
        % Insert a bounding box around the object being tracked
        bboxPolygon = reshape(bbox2points', 1, []);
        old_track_box(obj_num,:) = [max(1, round(bboxPolygon(1))), max(1, round(bboxPolygon(2))), round(bboxPolygon(3))-round(bboxPolygon(1)), round(bboxPolygon(8))-round(bboxPolygon(2))];
    else
        if size(old_track_box,1) > 0,
            old_track_box(obj_num,:) = [];
        end
    end
end