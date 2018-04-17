function [ out_mat ] = GetImagePatchStats( image,psize )
%GETPATCHSTATS computes statistics for a given patch matrix pmat.

nn = numel(image);
out_mat = zeros(nn,4);
out_mat = cast(out_mat,'like',image);

% means
h = fspecial('average',psize);
cur_vec = imfilter(image,h,'same');
out_mat(:,1) = cur_vec(:);

% stds
cur_vec = stdfilt(image,true(psize));
out_mat(:,2) = cur_vec(:);

% median
cur_vec = zeros(size(image));
for si = 1:size(image,3)
    cur_vec(:,:,si) = medfilt2(image(:,:,si),[psize psize]);
end
out_mat(:,3) = cur_vec(:);

% two norm
cur_vec = imfilter(image.*image,h,'same');
cur_vec = cur_vec(:).*(psize*psize);
out_mat(:,4) = sqrt(cur_vec);

end

