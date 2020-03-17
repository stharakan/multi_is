function [] = summaryFigureDNNOverlay(seg,dnn_seg,klr_seg,is_probs,ha)
%f = figure;
prob_tol = 0.45;
%ha = tight_subplot(6,1,[.001,.001],[.001,.001],[.001,.001]);
my_im = @(x) imresize(x,1,'nearest');

% my im segs
seg = my_im(seg);
dnn_seg = my_im(dnn_seg);
nzidx = seg ~=0 | dnn_seg ~= 0;
wt_correct_idx = seg~=0 & dnn_seg ~=0;
ed_correct_idx = seg==2 & dnn_seg ==2;
en_correct_idx = seg==4 & dnn_seg ==4;

% properly set up dnn seg
dnn_seg(dnn_seg ~= 4) = dnn_seg( dnn_seg~=4) + 1;
I = dnn_seg ~= 1;
RGBtrips = [0 0 0;
		0 1 1;
		1 0 1;
		1 1 0];
rgbidx = ind2rgb(single(dnn_seg),RGBtrips);
alpha = 0.25;

im = seg;
my_title = 'True Segmentation';
axes(ha(1));
imshow(my_im(im), [0,4]);


im = seg;
my_title = 'True Segmentation';
axes(ha(2));
imshow(my_im(im), [0,4]);
%title(my_title);
hold on
h = imshow(rgbidx);
hold off
set(h, 'AlphaData', alpha*I);

im = klr_seg;
my_title = 'KLR Segmentation';
axes(ha(3));
imshow(my_im(im), [0,4]);
%title(my_title);
hold on
h = imshow(rgbidx);
hold off
set(h, 'AlphaData', alpha*I);

% im = dnn_seg;
% my_title = 'DNN Segmentation';
% axes(ha(2));
% imshow(my_im(im), []);
% title(my_title);

% probabilities -- variances
wt_cols = permute(sum(is_probs(:,:,2:end,:),3),[1,2,4,3]);
wt_var = var( wt_cols, 0, 3);
med_wt_cols = median(wt_cols, 3);
tumor_var = var( is_probs, 0, 4);
hi_prob_idx = med_wt_cols > prob_tol;
min_var = min(wt_var(hi_prob_idx))
max_var = max(wt_var(hi_prob_idx))
wt_var(~hi_prob_idx) = min_var;


im = max_var - wt_var;
my_title = 'WT var';
axes(ha(4));
imshow(my_im(im), [0, max_var - min_var]);
%title(my_title);
hold on
blues = cat(3, zeros(size(dnn_seg)), ones(size(dnn_seg)), ones(size(dnn_seg)));
h = imshow(blues);
hold off
set(h, 'AlphaData',alpha*I);

im = tumor_var(:,:,3);
im(wt_cols(:,:,2) < prob_tol) = min_var;
im = max_var - im;
axes(ha(5));
my_title = 'ED var';
imshow(my_im(im), [0, max_var - min_var]);
%title(my_title);
hold on
reds = cat(3, ones(size(dnn_seg)), zeros(size(dnn_seg)), zeros(size(dnn_seg)));
greens = cat(3, zeros(size(dnn_seg)), ones(size(dnn_seg)), zeros(size(dnn_seg)));

cur_dnn_seg = dnn_seg; cur_dnn_seg(dnn_seg ~= 3) = 0;
rgbidx = ind2rgb(single(cur_dnn_seg),RGBtrips);
h = imshow(rgbidx);
hold off
set(h, 'AlphaData',alpha*I);

im = tumor_var(:,:,4);
im(wt_cols(:,:,3) < prob_tol) = min_var;
im = max_var - im;
%im(~hi_prob_idx) = min_var;
axes(ha(6));
my_title = 'EN var';
image_handle = imshow(my_im(im), [0, max_var - min_var]);
%title(my_title);
hold on
cur_dnn_seg = dnn_seg; cur_dnn_seg(dnn_seg ~= 4) = 0;
rgbidx = ind2rgb(single(cur_dnn_seg),RGBtrips);
h = imshow(rgbidx);
hold off
set(h, 'AlphaData', alpha*I);

end

