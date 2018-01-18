function avgs = AveragePatchValues(im,psize,idx)

if nargin < 3
	idx = 1:(numel(im));
end

% create filter matx
p2 = psize * psize;
filt = ones(psize)./(p2);

% filter image (assume at most 3d)
%avg_im = zeros(size(im));
%d3 = size(im,3);
%for di = 1:d3
%	avg_im(:,:,di) = imfilter(im(:,:,di),filt);
%end
avg_im = imfilter(im,filt);

% extract idx
avgs = avg_im(idx);

% round?
avgs = avgs.*(p2);
avgs = round(avgs);
avgs = avgs./p2;

end
