function [] = different_uncertainties_plot(brain_name, max_tumor_idx, seg, dnn_seg, ...
    is_probs,is_vars, is_aleatorics, is_covariances,extra_str)

figure;
ha = tight_subplot(2,2,[.001,.001],[.001,.001],[.001,.001]);


data_locations;

% get flair
brn = BrainReader(bdir,brain_name);
fl = brn.ReadT2();
if strcmp(extra_str,'coronal') 
    fl = fl(:,max_tumor_idx,:);
    fl = permute(fl,[1,3,2]);
else
    fl = fl(:,:,max_tumor_idx);
end
nzidx = fl ~= 0;

% set variances/probs to 0
nzidx_all = repmat(nzidx,1,1,size(is_vars,3));
%is_vars(~nzidx_all) = 0;
is_probs(~nzidx_all) = 0.0;
is_probs(~nzidx) = 1.0;

% subset
[rows,cols] = getTumorBox(dnn_seg);
fl = fl(rows,cols);
cur_seg = seg(rows,cols);
cur_dnn_seg = dnn_seg(rows,cols);
cur_is_probs = is_probs(rows,cols,:);
cur_is_vars = is_vars(rows,cols,:) ;
% 
% 
% 
% % flair
% plot_im(fl,ha(1),[]);
% 
% % seg
% plot_im(cur_seg,ha(2), [0,4]);
% 
% % dnn seg
% plot_im(cur_dnn_seg,ha(3),[0,4]);
% 
% % is probs
% plot_im(sum(cur_is_probs(:,:,2:end),3), ha(4),[0,1]);

reds = cat(3, ones(size(cur_dnn_seg)), zeros(size(cur_dnn_seg)), zeros(size(cur_dnn_seg)));
alpha_overlay = 0.25* (cur_dnn_seg ~= cur_seg); 

% is vars
overlayedImage(sum(cur_is_vars(:,:,2:end),3), ha(1),reds,alpha_overlay);
% loop and set is cov/is ale/is ratio
cur_is_cov_mat = is_covariances(rows,cols,:,:);
cur_is_ale_mat = is_aleatorics(rows,cols,:,:);
cur_is_ratio = zeros(size(cur_dnn_seg));
cur_is_cov = cur_is_ratio;
cur_is_ale = cur_is_ratio;
for ii = 1:size(cur_is_cov_mat,1)
    for jj = 1:size(cur_is_cov_mat,2)
        cur_cov = det(permute(cur_is_cov_mat(ii,jj,:,:),[3,4,1,2]));
        
        cur_ale_mat = permute(cur_is_ale_mat(ii,jj,:,:),[3,4,1,2]);
        cur_ale = norm(cur_ale_mat,'fro');
        
        
        cur_is_cov(ii,jj,:) = cur_cov;
        cur_is_ale(ii,jj,:) = cur_ale;
        cur_is_ratio(ii,jj,:) = cur_cov/cur_ale;
    end
end

% is cov
overlayedImage( cur_is_cov,ha(2),reds,alpha_overlay);

% is aleatorics
overlayedImage( cur_is_ale,ha(3),reds,alpha_overlay);

% is ratio
overlayedImage(cur_is_ratio,ha(4),reds,alpha_overlay);



end

function [] = overlayedImage(im, ax,im_overlay, alpha_overlay)
axes(ax);
max_var = max(im(:));

im = max_var - im;


imshow(im,[0,max_var]);
hold on
h = imshow(im_overlay);
hold off
set(h, 'AlphaData', alpha_overlay);
end

function plot_im(im, ax,bds,flip)
if nargin == 3
    flip = false;
end

axes(ax)
if flip
    max_var = max(im(:));
    im = max_var - im;
end
imshow(im,bds)
end
