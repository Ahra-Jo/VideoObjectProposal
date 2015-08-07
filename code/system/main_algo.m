function main_algo(img_path, file_info, model, opts, imgnet_mean_img, W, U, drawing_info, save_video_name, recording_on, filter_param, SCDLdata, lme_param, train_set)
% use Edge_boxes

% video recording configure
if recording_on,
    writerObj = VideoWriter(save_video_name);
    writerObj.FrameRate = 1;
    open(writerObj);
end

% ===========================================
fprintf('=== tracking initialization === \n');
img = imread([img_path file_info(1).name]);
img = imresize(img, 0.5);
[img_h img_w dim] = size(img);
g_img = rgb2gray(img);
bbox = edgeBoxes(img, model, opts);
bbox = box_reduce_mean(img_h, img_w, bbox);
bbox = box_filter(bbox(:,1:4), img, imgnet_mean_img, W, U, filter_param);

for bbox_num=1:size(bbox,1),
    [points{bbox_num}, pointTracker{bbox_num}] = init_track_info(g_img, bbox(bbox_num,1:4));
    initialize(pointTracker{bbox_num}, points{bbox_num}.Location, g_img);
end

oldPoints = points;
old_bbox = bbox;

for i=1:size(bbox,1)
    img = draw_box(img, bbox(i,1),bbox(i,2), bbox(i,3)+bbox(i,1),bbox(i,4)+bbox(i,2), bbox(i,5), drawing_info);
end

imshow(img);
% =========================================== %

%% detect Edge Box bounding box proposals (see edgeBoxes.m)
for i=2:1000,
    fprintf('%d \n', i);
    img = imread([img_path file_info(i).name]);
    img = imresize(img, 0.5);
    [img_h img_w dim] = size(img);
    
    bbox = edgeBoxes(img, model, opts);
    bbox = box_reduce_mean(img_h, img_w, bbox(:,1:4));
  
    % ===========================================
    g_img = rgb2gray(img); % for KLT
    cnt = 0;
    for obj_num=1:size(old_bbox,1),
        
        % Track the points. Note that some points may be lost.
        [points, isFound] = step(pointTracker{obj_num}, g_img);
        visiblePoints = points(isFound, :);
        oldInliers = oldPoints{obj_num}(isFound, :);
                
        if size(visiblePoints, 1) >= 2 % need at least 2 points
            
            % Estimate the geometric transformation between the old points
            % and the new points and eliminate outliers
            [xform, oldInliers, visiblePoints] = estimateGeometricTransform(oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
            
            % Apply the transformation to the bounding box points
            bboxPoints = bbox2point(old_bbox(obj_num,1:4));
            bboxPoints = transformPointsForward(xform, bboxPoints);
            
            % Insert a bounding box around the object being tracked
            bboxPolygon = reshape(bboxPoints',1,[]);
            tmp_bbox = point2bbox(bboxPolygon);
            
            % compare with edgeBox candidates.
            if ~isempty(bbox)
                [tmp_bbox val bbox] = compute_matching_rate(img_h, img_w, tmp_bbox, bbox);        
            end
            
            if ((sum((tmp_bbox) > 0) == 4) && (tmp_bbox(1)+tmp_bbox(3) < img_w) && (tmp_bbox(2)+tmp_bbox(4) < img_h))
                cnt = cnt + 1;
                new_bbox(cnt,1:4) = tmp_bbox;
                % Reset the points
                newPoints{cnt} = visiblePoints;
                setPoints(pointTracker{cnt}, newPoints{cnt});
            end
            
            isFound = [];
            visiblePoints = [];
            oldInliers = [];            

        end
        
    end
    
    if ~isempty(bbox)
        for bbox_num=1:size(bbox,1),
            [newPoints{cnt+bbox_num}, pointTracker{cnt+bbox_num}] = init_track_info(g_img, bbox(bbox_num,1:4));
            initialize(pointTracker{cnt+bbox_num}, newPoints{cnt+bbox_num}.Location, g_img);
        end
        new_bbox(end+1:end+size(bbox,1),:) = bbox(:,1:4);
    end
    
    % =========================================== %
    if size(new_bbox,2) > 1
        % known vs. unfamiliar vs. unknown 
        
%         new_bbox = box_filter(new_bbox, img, imgnet_mean_img, W, U, filter_param);
        [new_bbox, W, U, SCDLdata, lme_param, train_set, drawing_info] = box_classifier(new_bbox, img, imgnet_mean_img, W, U, filter_param, SCDLdata, lme_param, train_set, drawing_info);
        old_bbox = new_bbox;
        oldPoints = newPoints;
        old_bbox = round(old_bbox);          
        
        for k=1:size(old_bbox,1),
            img = draw_box(img, old_bbox(k,1), old_bbox(k,2), old_bbox(k,3)+old_bbox(k,1), old_bbox(k,4)+old_bbox(k,2), old_bbox(k,5), drawing_info);
        end
    end
    
    imshow(img);
    
    new_bbox = [];
    newPoints = [];
    
    
    % video recording
    if recording_on,
        %         surf(sin(2*pi*i/20)*Z,Z);
        frame = getframe;
        writeVideo(writerObj, frame);
    end
    
end

% video close
if recording_on,
    close(writerObj);
end

function [points, pointTracker] = init_track_info(g_img, bbox)

    points = detectMinEigenFeatures(g_img, 'ROI', bbox);
    pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
    
    