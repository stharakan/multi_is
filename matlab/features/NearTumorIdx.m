function [idx,ntp] = NearTumorIdx(buf,seg,ntp)
%NEARTUMORIDX subsamples ntp points from points that 
%the set of pixels that are buf pixels away from the tumor,
%which is defined by nonzero values of seg.

psize = buf*2 + 1;
[d1,d2,d3,d4] = size(seg);

nzidx = find(seg(:));

[~,all_pix] = PatchIdx(psize,d1,d2,d3,d4,nzidx);

tum_pix = unique(all_pix(:));

idx = setdiff(tum_pix,nzidx);

ntp = min(ntp,length(idx));

idx = randsample(idx,ntp);


end
