function [seen_list, unseen_list, unfamiliar_list] = main_algo(img_path, model, opts, W, U, SCDLdata, lme_param, train_set, test_set)

seen_list = [];
unseen = [];
unfamiliar = [];

X = W*train_set.feat;
SCDLdata.S = mexLasso(X, double(SCDLdata.Ua));
len = size(test_label,1);

% TEST
for i=1:len,
    fprintf('%d / %d \n', i, len);
    
    feat = test_set.feat(i,:);
    new_x = double(W*feat');
    
    % sparse coding
    S_new = mexLasso(new_x, double(SCDLdata.Ua), SCDLdata.sparam);
    
    min_d = compute_distane(S_new, SCDLdata.S);
    min_r = compute_residual(new_x, SCDLdata.Ua, SCDLdata.S);

    % ================== Seen ================== 
    if min_d < filter_param.d
        % LME classification
        [label prob] = infer_system(W, U, feat);
        result(i, 5) = label;
        seen_list{i} = test_set.list{i};
        %train_set.feat(end+1,:) = feat;
    % unseen or unfamiliar    
    else 
        min_r = compute_residual(new_x, SCDLdata.Ua, SCDLdata.S); 
        
        % ================== Unseen ================== 
        if min_r < filter_param.r
            fprintf('Unseen: \n');
            unseen_list{i} = test_set.list{i};
%             % expand dictionary dim.
%             [W, U, train_set, drawing_info] = lme_train_class_exp(train_set, feat, lme_param, drawing_info);    
%             
%             % Update Ua, S (Dictionary learning, Sparse coding)
%             WX = double(W*(train_set.feat)');
%             SCDLdata.Ua = mexTrainDL(WX, SCDLdata.dparam);
%             D = SCDLdata.Ua./repmat(sqrt(sum(SCDLdata.Ua.^2)),[size(SCDLdata.Ua,1) 1]);
%             SCDLdata.S = mexOMP(U, double(D), SCDLdata.sparam);         
                             
            
        % ================== Unfamiliar ================== 
         else
            fprintf('Unfamiliar: \n');
            unfamiliar_list{i} = test_set.list{i};
%             SCDLdata = attribute_exp(train_set, new_x, feat, U, W, SCDLdata);
%             [W, U, train_set, drawing_info] = lme_train_class_exp(train_set, feat, lme_param, drawing_info);
%             bbox_result(i, 5) = size(train_set.cnt_table,2); % label
         end
     end

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
    
    
    

    
