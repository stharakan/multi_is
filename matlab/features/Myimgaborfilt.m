function [ fmat ] = Myimgaborfilt( im,gbank,idx )
%MYIMGABORFILT is a simple wrapper for imgaborfilt which allows for the
%processing of 3d arrays. The output is returned as a 2d array; only 
%on the gabor features for those indices are returned (idx x feature). 

% initial sizes
[d1,d2,slcs] = size(im);
slice_size = d1*d2;
gg = length(gbank);

% set up fmat
if nargin < 3
    idx = 1:numel(im);
end
nn = length(idx);
fmat = zeros(nn,gg);
fmat = cast(fmat,'like',im);

% divide index to find slice ownership
slice_idx = ceil(idx./slice_size);
slice_mod = mod(idx,slice_size);

% loop over slices, process image
for si = 1:slcs
    % check which of idx is present
    cur_slice = slice_idx == si;
    
    if any(cur_slice)
        % take gabor of image
        filtered = imgaborfilt(im(:,:,si),gbank);
        filtered = reshape(filtered, [],gg);
        filtered_trunc = filtered(slice_mod(cur_slice),:);
        
        % load into mat
        fmat( cur_slice,:) = filtered_trunc;
    end
end

end

