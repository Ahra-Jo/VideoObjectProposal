function [bbox_result, W, U, SCDLdata, lme_param, train_set, drawing_info] = box_classifier(bbox, img, imgnet_mean_img, W, U, filter_param, SCDLdata, lme_param, train_set, drawing_info)
[img_h img_w img_dim] = size(img);
for i=1:size(bbox,1),
    x1 = max(1,bbox(i,1));
    y1 = max(1,bbox(i,2));
    x2 = min(x1+bbox(i,3), img_w);
    y2 = min(y1+bbox(i,4), img_h);
    box_img = img(y1:y2, x1:x2,:);
    
    % feature extraction
    feat = extract_caffe_feature(box_img,imgnet_mean_img);
    
    new_x = double(W*feat);
    % sparse coding
    S_new = mexLasso(new_x, double(SCDLdata.Ua), SCDLdata.sparam);
    
    min_d = compute_distance(S_new, SCDLdata.S);
    min_r = compute_residual(new_x, SCDLdata.Ua, SCDLdata.S);
    bbox_result(i, 1:4) = bbox(i,1:4);
    
    % ================== Seen ================== 
%     if min_d < filter_param.d
%         % LME classification
%         [label prob] = infer_system(W, U, feat);
%         bbox_result(i, 5) = label;
%         %bbox_result(i, 6) = prob;
%         train_set.cnt_table(1, label) = train_set.cnt_table(1, label) + 1;
%         train_set.feature_list{end+1,1} = [label sprintf('_%0.6d', train_set.cnt_table(1, label)) '.mat'];
%         train_set.feat(end+1,:) = feat;
%     % unseen or unfamiliar    
%     else 
%         min_r = compute_residual(new_x, SCDLdata.Ua, SCDLdata.S); 
        
        % ================== Unseen ================== 
%         if min_r < filter_param.r
%             fprintf('Unseen: \n');
            % expand dictionary dim.
%             [W, U, train_set, drawing_info] = lme_train_class_exp(train_set, feat, lme_param, drawing_info);
%             
%             % save train image
%             imwrite(box_img, ['/hdd/trained_imges/' train_set.feature_list{end}(1:end-4) '.jpg']);
%             bbox_result(i, 5) = size(train_set.cnt_table,2); % label
%             
%             % Update Ua, S (Dictionary learning, Sparse coding)
%             WX = double(W*(train_set.feat)');
%             SCDLdata.Ua = mexTrainDL(WX, SCDLdata.dparam);
%             D = SCDLdata.Ua./repmat(sqrt(sum(SCDLdata.Ua.^2)),[size(SCDLdata.Ua,1) 1]);
%             SCDLdata.S = mexOMP(U, double(D), SCDLdata.sparam);         
                             
            
        % ================== Unfamiliar ================== 
%         else
            fprintf('Unfamiliar: \n');
            SCDLdata = attribute_exp(train_set, new_x, feat, U, W, SCDLdata);
            [W, U, train_set, drawing_info] = lme_train_class_exp(train_set, feat, lme_param, drawing_info);
            imwrite(box_img, ['/hdd/trained_imges/' train_set.feature_list{end}(1:end-4) '.jpg']);
            bbox_result(i, 5) = size(train_set.cnt_table,2); % label
%         end
%     end
     
%     % thresholding
%     if prob > filter_param.prob,
%         bbox_result(i, 1:4) = bbox(i,:);
%         bbox_result(i, 5) = label;
%         bbox_result(i, 6) = prob;
%     else
%         bbox_result(i, 1:4) = bbox(i,:);
%         bbox_result(i, 5) = 11;
%         bbox_result(i, 6) = prob;
%     end
end


% ------------ FUNCTION compute distance ------------
function min_d = compute_distance(S_new, S)

S_new = repmat(S_new,[1 size(S,2)]);
d = mean(abs(full(S_new) - full(S)),1);
min_d = min(d);

% ------------ FUNCTION compute residual ------------
function min_r = compute_residual(X, Ua, S)

r = (repmat(X,[1,size(Ua,1)]) - (Ua*S)).^2;
r = sqrt(sum(r,1));
r = r./size(X,1); % normalization
min_r = min(r);


