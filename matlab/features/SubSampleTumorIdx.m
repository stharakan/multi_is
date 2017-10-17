function [ntot, trnidx,tstidx ] = SubSampleTumorIdx( ntot,seg )
%SUBSAMPLETUMORIDX subsamples points from seg which have nonzero values in
%seg (ntot number of points). The points should be roughly equally
%distributed between normal and abnormal points. Further, they should be
%equally distributed between brains, as well as maintain the normal
%proportions within the abnormal classes.

% making test?
tstidx = 0;


% initialize
[d1,d2,slc_per_brn,brns] = size(seg);
brn_pixels = d1*d2*slc_per_brn;
nzidx = seg(:) ~= 0;
tottum = sum(nzidx);
ntot = min(tottum,ntot);
ppbrn = floor(ntot/brns); % for now assume it divides, and is div /2
trnidx = zeros(ppbrn,brns);

% pick indices
totvec = (1:numel(seg))';
ntidx = totvec( nzidx );
ntidx = randsample(ntidx,ntot);

% split into train/test 
if nargout > 2 
	ntidx = ntidx(:);

	trnidx = [ntidx(1:(end/2))];
	tstidx = [ntidx( (end/2 + 1):end)];

else
	trnidx = [ntidx(:)];
end

end

