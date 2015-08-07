dparam = SCDLdata.dparam;
sparam = SCDLdata.sparam;
dparam.K = 50;
fprintf('============ Dictionary learning ============ \n');
Ua = mexTrainDL(double(X),dparam);
fprintf('=============== Sparse coding =============== \n');
D = Ua./repmat(sqrt(sum(Ua.^2)),[size(Ua,1) 1]);
U_tmp = X./repmat(sqrt(sum(X.^2)),[size(X,1) 1]);
S = mexLasso(double(U_tmp), double(D), sparam);

k=2;
[val idx1] = sort(S(k,:), 'descend');
figure;
for i=1:100
   img = imread(['/v1/projects/VideoObjectProposal/code/rcnn/datasets/train40_jpg/' train_set.list{idx1(i)}(1:end-4) '.jpg']); 
   subplot(10,10,i);
   imshow(img);
end

[val idx2] = find(S(k,:) == 0);
figure;
for i=1:100
   img = imread(['/v1/projects/VideoObjectProposal/code/rcnn/datasets/train40_jpg/' train_set.list{idx2(i)}(1:end-4) '.jpg']); 
   subplot(10,10,i);
   imshow(img);
end