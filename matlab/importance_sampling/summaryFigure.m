function [f] = summaryFigure(seg,dnn_seg,klr_seg,is_probs)
f = figure;
ha = tight_subplot(2,3,[.001,.001],[.001,.001],[.001,.001]);
my_im = @(x) imresize(x,3,'nearest');


im = seg;
my_title = 'True Segmentation';
axes(ha(1));
imshow(my_im(im), []);
title(my_title);

im = klr_seg;
my_title = 'KLR Segmentation';
axes(ha(3));
imshow(my_im(im), []);
title(my_title);

im = dnn_seg;
my_title = 'DNN Segmentation';
axes(ha(2));
imshow(my_im(im), []);
title(my_title);

% probabilities -- variances
wt_cols = permute(sum(is_probs(:,:,2:end,:),3),[1,2,4,3]);
wt_var = var( wt_cols, 0, 3);
tumor_var = var( is_probs, 0, 4);
max_var = max(tumor_var(:))
min_var = min(tumor_var(:))


im = wt_var;
my_title = 'WT var';
axes(ha(4));
imshow(my_im(im), [min_var, max_var]);
title(my_title);

im = tumor_var(:,:,3);
axes(ha(5));
my_title = 'ED var';
imshow(my_im(im), [min_var,max_var]);
title(my_title);

im = tumor_var(:,:,4);
axes(ha(6));
my_title = 'EN var';
image_handle = imshow(my_im(im), [min_var,max_var]);
title(my_title);
end

