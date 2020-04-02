function [] = summaryFigureDNNOverlay(seg,dnn_seg,klr_seg,is_probs,ha)
%f = figure;
highlight_error = true;
prob_tol = 0.25
%ha = tight_subplot(6,1,[.001,.001],[.001,.001],[.001,.001]);
my_im = @(x) imresize(x,1,'nearest');

% my im segs
seg = my_im(seg);
dnn_seg = my_im(dnn_seg);
nzidx = seg ~=0 | dnn_seg ~= 0;
wt_correct_idx = (seg~=0) == (dnn_seg ~=0);
ed_correct_idx = (seg==2) == (dnn_seg ==2);
en_correct_idx = (seg==4) == (dnn_seg ==4);

% set up base colors
reds = cat(3, ones(size(dnn_seg)), zeros(size(dnn_seg)), zeros(size(dnn_seg)));
magenta = cat(3, ones(size(dnn_seg)), zeros(size(dnn_seg)), ones(size(dnn_seg)));
cyan = cat(3, zeros(size(dnn_seg)), ones(size(dnn_seg)), ones(size(dnn_seg)));
yellow = cat(3, ones(size(dnn_seg)), ones(size(dnn_seg)), zeros(size(dnn_seg)));


% properly set up dnn seg
dnn_seg(dnn_seg ~= 4) = dnn_seg( dnn_seg~=4) + 1;
I = dnn_seg ~= 1;
RGBtrips = [0 0 0;
		0 1 1;
		1 0 1;
		1 1 0];
rgbidx = ind2rgb(single(dnn_seg),RGBtrips);
alpha = 0.25;

% im = seg;
% my_title = 'True Segmentation';
% axes(ha(1));
% imshow(my_im(im), [0,4]);


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

% wt var
im = max_var - wt_var;
axes(ha(4));
imshow(my_im(im), [0, max_var - min_var]);
hold on
if highlight_error
    hr = imshow(reds);
    set(hr, 'AlphaData', alpha*(~wt_correct_idx & nzidx));
else
    hr = imshow(cyan);
    set(hr, 'AlphaData', alpha*(I));
end

hold off

% ed var
im = tumor_var(:,:,3);
im(~hi_prob_idx) = min_var;
im = max_var - im;
axes(ha(5));
imshow(my_im(im), [0, max_var - min_var]);
hold on
if highlight_error
    hr = imshow(reds);
    set(hr, 'AlphaData',alpha*(~ed_correct_idx & nzidx));
else
    hr = imshow(magenta);
    set(hr, 'AlphaData', alpha*(dnn_seg == 3));
end

hold off

% en var
im = tumor_var(:,:,4);
im(~hi_prob_idx) = min_var;
%im(wt_cols(:,:,3) < prob_tol) = min_var;
im = max_var - im;
axes(ha(6));
imshow(my_im(im), [0, max_var - min_var]);
hold on
if highlight_error
    hr = imshow(reds);
    set(hr, 'AlphaData', alpha*(~en_correct_idx & nzidx));
else
    hr = imshow(yellow);
    set(hr, 'AlphaData', alpha*(dnn_seg == 4));
end

hold off

end

