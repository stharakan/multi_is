filename = './single_brain_results.mat';

load(filename);

tumor_klr_probs = sum(klr_probs(:,:,2:end),3);
tumor_dnn_probs = sum(dnn_probs(:,:,1:3),3);
tumor_dnn_probs(tumor_dnn_probs > 1) = 1;
tumor_klr_is_probs =  mean(is_probs,3);
tumor_klr_is_probs = NormalizeClassProbabilities(tumor_klr_is_probs);
tumor_klr_is_probs = sum(tumor_klr_is_probs(:,2:end),2);

my_im = @(x) imresize(x,3,'nearest');

%% segmentations
figure;
im = seg;
my_title = 'True Segmentation';
subplot(2,2,1);
imshow(my_im(im), []);
title(my_title);

im = klr_seg;
my_title = 'KLR Segmentation';
subplot(2,2,2);
image_handle = imshow(my_im(im), []);
title(my_title);

im = dnn_seg;
my_title = 'DNN Segmentation';
subplot(2,2,3);
image_handle = imshow(my_im(im), []);
title(my_title);

im = reshape( mode(is_segs,2), size(dnn_seg));
my_title = 'KLR-IS Segmentation';
subplot(2,2,4);
image_handle = imshow(my_im(im), []);
title(my_title);

%% probabilities -- means
figure;
im = seg;
my_title = 'True Segmentation';
subplot(2,2,1);
imshow(my_im(im), []);
title(my_title);

im = tumor_klr_probs;
subplot(2,2,2);
my_title = 'KLR WT probs';
image_handle = imshow(my_im(im), []);
title(my_title);

im = tumor_dnn_probs;
subplot(2,2,3);
my_title = 'DNN WT probs';
image_handle = imshow(my_im(im), []);
title(my_title);

im = reshape( tumor_klr_is_probs, size(seg));
my_title = 'KLR-IS WT probs';
subplot(2,2,4);
image_handle = imshow(my_im(im), []);
title(my_title);

%% probabilities -- variances
wt_cols = permute( sum(is_probs(:,2:end,:),2), [1,3,2]) ;
wt_var = var( wt_cols, 0, 2);
tumor_var = var( is_probs, 0, 3);

figure;
im = seg;
my_title = 'True seg';
subplot(2,2,1);
imshow(my_im(im), []);
title(my_title);

im = reshape(tumor_var(:,4), size(seg));
subplot(2,2,2);
my_title = 'EN var';
image_handle = imshow(my_im(im), []);
title(my_title);

im = reshape(tumor_var(:,3), size(seg));
subplot(2,2,3);
my_title = 'ED var';
image_handle = imshow(my_im(im), []);
title(my_title);

im = reshape(wt_var, size(seg));
my_title = 'WT var';
subplot(2,2,4);
image_handle = imshow(my_im(im), []);
title(my_title);

