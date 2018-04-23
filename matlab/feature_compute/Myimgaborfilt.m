function [ fmat ] = Myimgaborfilt( im,gbank,idx )
%MYIMGABORFILT is a simple wrapper for imgaborfilt which allows for the
%processing of 3d arrays. The output is returned as a 2d array; only 
%on the gabor features for those indices are returned (idx x feature). 

% initial sizes
[d1,d2,slcs] = size(im);
slice_size = d1*d2;
gg = length(gbank);
iflag = true;

% set up fmat
if nargin < 3
    iflag = false;
    nn = numel(im);
else
    nn = length(idx);

    % divide index to find slice ownership
    slice_idx = ceil(idx./slice_size);
    slice_mod = mod(idx,slice_size);
end

% initialize matrix
fmat = zeros(nn,gg);
fmat = cast(fmat,'like',im);


% loop over slices, process image
for si = 1:slcs
    do_cur = true;
    cur_slice = (1 + (slice_size)*(si-1)):(slice_size*si);

    if iflag
        % check which of idx is present
        cur_slice = slice_idx == si;
        do_cur = any(cur_slice);
    end
        

    if do_cur 
        % take gabor of image
        filtered = imgaborfilt(im(:,:,si),gbank);
        filtered = reshape(filtered, [],gg);
        
        if iflag
            filtered = filtered(slice_mod(cur_slice),:);
        end
        
        % load into mat
        fmat( cur_slice,:) = filtered;
    end
end

end

