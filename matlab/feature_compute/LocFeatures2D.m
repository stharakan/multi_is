function [ feat_mat ] = LocFeatures2D( blist )
%Computes location (x,y) features of each pixel in blist. Note that points
%on different slices in the same position will share features.

% get brain sizing info
brn_size = blist.brn_size;
feat_mat = zeros(blist.tot_points,2);

% loop over brains
for bi = 1:blist.num_brains
    % find current idx
    cur_idx = blist.pt_inds{bi};
    
    % transform idx to x,y
    [xx,yy,~] = ind2sub(brn_size,cur_idx);
    
    % load into feat mat
    feat_idx = blist.WithinTotalIdx(bi);
    feat_mat(feat_idx,:) = [xx(:),yy(:)];
    
end

end

