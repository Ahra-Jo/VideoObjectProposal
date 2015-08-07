 function SCDLdata = attribute_exp(train_set, new_x, new_feat, U, W, SCDLdata)

new_Ua = new_x - mean(SCDLdata.Ua*SCDLdata.S,2);
% SCDLdata.Ua(:,end+1) = new_Ua;

% compute similarity
X = double(W)*train_set.feat';
sim = X'*new_Ua;
[val idx] = sort(sim);

figure;
for i=1:20
    img = imread([train_set.list{idx(end-i+1)}(1:end-4) '.jpg']);
    subplot(5, 4, i);
    imshow(img);
    title('Top-20');
end

figure;
for i=1:20
    img = imread([train_set.list{idx(i)}(1:end-4) '.jpg']);
    subplot(5, 4, i);
    imshow(img);
    title('Bottom-20');
end


% ************************************************************
new_att_name = input('What is a different thing?: ');
train_set.att_name{end+1} = new_att_name;
% ************************************************************

SCDLdata.dparam.K = SCDLdata.dparam.K + 1;
train_set.feat(end+1,:) = new_feat;
X = double(W)*train_set.feat';
SCDLdata.Ua = mexTrainDL(X, SCDLdata.dparam);
D = SCDLdata.Ua./repmat(sqrt(sum(SCDLdata.Ua.^2)),[size(SCDLdata.Ua,1) 1]);
SCDLdata.S = mexOMP(U, D, SCDLdata.sparam);
