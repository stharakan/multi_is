function [idx] = SelectEdemaDistribution(ps,brain)
%SELECTRANDOM randomly selects ppb points from 
% all the points that have a nonzero 
% flair component for the given brain. 

% get params
psize = ps.psize;
perc = ps.ppb;

% read seg/flair
flair = brain.ReadFlair();
nzidx = find(flair);
clear flair
seg = brain.ReadSeg();
imsize = size(seg,1) * size(seg,2);
target =2;

% get patch probs
ppvec = AveragePatchValues(double(seg == target),psize,nzidx);
buckets = 0:0.1:1;
inc = (1/psize)^2;
buckets(1) = inc - eps;
buckets(end) = buckets(end) - inc + eps;
nb = length(buckets);
idx = [];
pvec = [];

% sort into 10 buckets (hard coded), get num
for bi = 1:nb
    if bi == nb
        bucket_idx = ppvec > (buckets(bi) - (1/psize)^2);
    else
        bucket_idx = (ppvec >= buckets(bi)) & (ppvec < buckets(bi+1));
    end
    
    % bucket index calcs
    num_pts_in_bucket = sum(bucket_idx);
    num_sel = round(num_pts_in_bucket * perc);
    cur_idx = nzidx(bucket_idx);
    pbvec = ppvec(bucket_idx);
    
    % randsample from each bucket
    fin_idx = randsample(cur_idx,num_sel);
    idx = [idx;fin_idx(:)];
    pvec = [pvec;pbvec(:)];
end

% get healthy stuff -- slices?
tpts = length(idx);
zidx = nzidx(seg(nzidx) == 0);
if 0    
    hidx = randsample(zidx,tpts);
else
    % divide up slices
    nzidx_slices = sort(unique(ceil(nzidx./imsize)),'ascend');
    slices = length(nzidx_slices);
    slice_bool_idx = any(reshape(seg(:,:,nzidx_slices) == target,[],slices),1);
    slice_idx = nzidx_slices(slice_bool_idx);
    
    % find indices of healthy pts
    slice_zidx = ceil(zidx./imsize);
    
    % find tumor perc
    tumor_slice_pts = round((sum(slice_bool_idx)/slices)*tpts);   
    healthy_slice_pts = tpts - tumor_slice_pts;
    
    % identify tumor subset of zidx
    member_list = ismember(slice_zidx,slice_idx);
    tidx = randsample(zidx(member_list),tumor_slice_pts);
    
    % identify healthy subset of zidx
    fidx = randsample(zidx(~member_list),healthy_slice_pts);
    
    % combine
    hidx = [tidx(:);fidx(:)];
end

% combine
idx = [idx;hidx(:)];
pvec = [pvec;zeros(tpts,1)];



end
