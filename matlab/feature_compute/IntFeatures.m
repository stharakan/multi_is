function [ feat_mat ] = IntFeatures( blist )
%INTFEATURES computes intensity features from the 4 modalities of each
%brain in blist. 

% initialize matrix
feat_mat = zeros(blist.tot_points,4);

% loop over brains
for bi = 1:blist.num_brains
    % find current idx, brain
    cur_idx = blist.pt_inds{bi};
    cur_brain = blist.MakeBrain(bi);
    
    % Read all but seg
    [flair,t1,t1ce,t2] = cur_brain.ReadAllButSeg();
    
    % load parts we need
    feat_idx = blist.WithinTotalIdx(bi);
    feat_mat(feat_idx,:) = [flair(cur_idx(:)), t1(cur_idx(:)), ...
        t1ce(cur_idx(:)), t2(cur_idx(:))];
end


end

