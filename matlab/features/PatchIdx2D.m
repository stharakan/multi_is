function [ d2_idx,feat_idx ] = PatchIdx2D( psize,vert,horz,slc_per_brn,brns,lin_idx )
%PATCHIDX produces the index of points that are needed relative to a any
%point for a given patch size psize and index imsize. For now, we assume
%psize is a perfect cube. Psize is assumed to be odd. If lin_idx is passed,
%the index is added to those pixels to make a feature_idx matrix.

    
feat_idx = 0;
    
% initialize stuff 
phalf = (psize-1)/2;
tot_slcs = slc_per_brn * brns;
imsize = vert*horz;
tot_vox = tot_slcs * imsize;  
patch_sz = (psize^2);

% make patch index
init_vec = (-phalf):(phalf); % first dim
d2_patch_vec = repmat(init_vec',1,psize) + ...
    vert.*repmat(init_vec,psize,1); % second dim
d2_idx = d2_patch_vec(:)';
%d3_idx = repmat(d2_patch_vec,1,psize) + ...
%    imsize.*repmat(init_vec,psize*psize,1); % third dim
%d3_idx = d3_idx(:)';


if nargin > 5
    feat_idx = repmat(lin_idx(:), 1,patch_sz);
    feat_idx = bsxfun(@plus,feat_idx,d2_idx);
    feat_idx = max( min(feat_idx,tot_vox),1); % assume the image has been zeropadded
end

end

