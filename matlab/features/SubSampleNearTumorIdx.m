function [ntot, trnidx,tstidx ] = SubSampleNearTumorIdx( ntot,seg,flair,buf )
%SUBSAMPLENEARTUMORIDX subsamples points from seg which have nonzero values in
%flair (ntot number of points). The points should be roughly equally
%distributed between normal and abnormal points. Further, they should be
%equally distributed between brains, as well as maintain the normal
%proportions within the abnormal classes.

% making test?
tstidx = 0;
if ~ntot
	ntot = sum(seg(:) ~= 0)*2;
end

% initialize
[d1,d2,slc_per_brn,brns] = size(seg);
ppbrn = floor(ntot/brns); % for now assume it divides, and is div /2
trnidx = zeros(ppbrn,brns);
brn_pixels = d1*d2*slc_per_brn;
nzidx = flair(:) ~= 0;
tottum = sum(seg(:) ~= 0 & nzidx);
ntot = min(tottum*2,ntot);

totvec = (1:numel(seg))';
npidx = totvec( nzidx & (seg(:) == 0));
npidx = randsample(npidx,ceil(ntot/2));
apidx = totvec( nzidx & (seg(:) ~= 0));
apidx = randsample(apidx,floor(ntot/2));

nnp = length(npidx);
ntp = round(nnp*0.2);
nnp = nnp - ntp;
ntpidx = NearTumorIdx(buf,seg,ntp);
npidx = npidx(1:nnp);

if nargout > 2 
	npidx = npidx(:);
	apidx = apidx(:);

	trnidx = [npidx(1:(end/2));ntpidx(1:(end/2));apidx(1:(end/2))];
	tstidx = [npidx( (end/2 + 1):end); ntpidx( (end/2 + 1):end );apidx( (end/2 + 1):end)];

else
	trnidx = [npidx(:);ntpidx(:);apidx(:)];
end

end

