function [trnidx,ntot ] = TumorIdx( ntot,seg )
%TUMORIDX subsamples points from seg which have nonzero values in
%seg (ntot number of points). The points should be roughly equally
%distributed between normal and abnormal points. Further, they should be
%equally distributed between brains, as well as maintain the normal
%proportions within the abnormal classes.

% initialize
[d1,d2,slc_per_brn,brns] = size(seg);
brn_pixels = d1*d2*slc_per_brn;
nzidx = seg(:) ~= 0;
tottum = sum(nzidx);
ntot = min(tottum,ntot);
ppbrn = floor(ntot/brns); % for now assume it divides

% pick indices
totvec = (1:numel(seg))';
ntidx = totvec( nzidx );
ntidx = randsample(ntidx,ntot);

% Set up output
trnidx = [ntidx(:)];
end

