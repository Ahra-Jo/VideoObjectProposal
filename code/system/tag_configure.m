function tag_img = tag_configure(base_category)

for i=1:length(base_category)
    tag_img{i} = imresize(text2im(base_category{i}), 0.7);
end
