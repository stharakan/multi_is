function [ pmap ] = MapNearEdema( ps,brain )
%SELECTNEARTUMOR selects points with the following distribution: half the 
% points come from strictly tumor points, then of the remaining half, 75%
% are randomly selected, and 25% are selected to be within 5 pixels of the
% tumor. 

ppb = ps.ppb;
nt_frac = 0.25;

if ppb
    num_tumor = floor(ppb/2);
else
    num_tumor = Inf;
end

% get tumor sample using seg
seg = brain.ReadSeg();
pmap = zeros(size(seg));
tumidx = find(seg == 2);
pmap(tumidx) = min(num_tumor/length(tumidx),1);

% get far tumor sample using flair
flair = brain.ReadFlair();
nzidx = find(flair);
fartumor_idx = setdiff(nzidx,tumidx);

% set up near tumor index
[d1,d2,d3,d4] = size(seg);
[~,ntidx] = PatchIdx2D(7,d1,d2,d3,d4,tumidx);
ntidx = unique(ntidx(:));
ntidx = setdiff(ntidx,tumidx);
ntidx = intersect(ntidx,nzidx);

% set up num_near/fartumor based on num_tumor
num_neartumor = floor(nt_frac * num_tumor);
num_fartumor = num_tumor - num_neartumor;

% sub sample
pmap(ntidx) = num_neartumor/length(ntidx);
pmap(fartumor_idx) = num_fartumor/length(fartumor_idx);
pmap = pmap./(sum(pmap(:)));

end

