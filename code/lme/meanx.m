function xmean = meanx(x, y)
numclass = length(unique(y));
xmean = zeros(size(x,1),numclass);

for i=1:numclass
	sampleperclass(i) = length(find(y==i));
	xi = x(:,find(y==i));
	ximean = mean(xi,2);
	xmean(:,i) = ximean;
	N = length(find(y==i));
	rep = repmat(ximean, 1, N);
	meansqdist(i) = sum(sum((rep-xi).^2))/N;
end
