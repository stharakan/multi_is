function [ pmap ] = MapEdemaDistribution( ps,brain )
%MAPEDEMADISTRIBUTION produces a probability map for the given
%PointSelector obj on the Brain brain. The output is returned as a 3-d
%grayscale matrix.

% get params
psize = ps.psize;
perc = ps.ppb;

% read seg/flair
flair = brain.ReadFlair();
nzidx = find(flair);
clear flair
seg = brain.ReadSeg();
imsize = size(seg,1) * size(seg,2);
target = 2;
pmap_nzidx1 = zeros(length(nzidx),1);
pmap_nzidx2 = zeros(length(nzidx),1);
pmap = zeros(size(seg));

% get patch probs
ppvec = AveragePatchValues(double(seg == target),psize,nzidx);
pnz = ppvec >= (1/psize^2 -eps);
pmap(nzidx(pnz)) = perc;

% get healthy stuff -- slices?
tpts = perc * sum(pnz);
zidx = nzidx(seg(nzidx) == 0);

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
tmp = zidx(member_list);
pts_on_slices = sum(member_list);
pmap(tmp) = pmap(tmp) + tumor_slice_pts/pts_on_slices;


% identify healthy subset of zidx
tmp = zidx(~member_list);
pts_on_slices = sum(~member_list);
pmap(tmp) = pmap(tmp) + healthy_slice_pts/pts_on_slices;

sump = sum(pmap(:));
pmap = pmap./sump;

fprintf('Error check: %f',sum(pmap(:)));

end

