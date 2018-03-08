function [ fmat,fcell ] = PatchStatsFeatures( blist,psize )
%PATCHSTATSFEATURES calculates the patch stats for a given blist and psize.
%It is called from a parent function, but can be called on its own if
%preferred. 

% initialize fmat, fcell
fcell = blist.FeatureCell('patchstats',psize); 
dd = length(fcell);
fmat = zeros(blist.tot_points,dd);
print_skip = 5;

for bi=1:blist.num_brains
    % extract relevant indices
    brain = blist.MakeBrain(bi);
    idx = blist.pt_inds{bi};
    curpts = length(idx);
    curfeats = zeros(curpts,dd);
    mm_idx = 1:(dd/4); mm_counter = dd/4;
    if mod(bi,print_skip) == 0
        fprintf(' proc brain %s, %d of %d\n',brain.bname,...
            bi,blist.num_brains);
    end
    
    % Read all modalities
    [flair,t1,t1ce,t2] = brain.ReadAllButSeg();
    [d1,d2,d3,d4] = size(flair);
    [~,patch_inds] = PatchIdx2D(psize,d1,d2,d3,d4,idx); 
    
    % flair 
    cur_patches = flair(patch_inds);
    cur_stats = GetPatchStats(cur_patches);
    curfeats(:,mm_idx) = cur_stats;
    
    % t1 
    mm_idx = mm_idx + mm_counter;
    cur_patches = t1(patch_inds);
    cur_stats = GetPatchStats(cur_patches);
    curfeats(:,mm_idx) = cur_stats;
    
    % t1ce
    mm_idx = mm_idx + mm_counter;
    cur_patches = t1ce(patch_inds);
    cur_stats = GetPatchStats(cur_patches);
    curfeats(:,mm_idx) = cur_stats;
    
    % t2
    mm_idx = mm_idx + mm_counter;
    cur_patches = t2(patch_inds);
    cur_stats = GetPatchStats(cur_patches);
    curfeats(:,mm_idx) = cur_stats;
    
    % load into full matrix
    fmat(blist.WithinTotalIdx(bi),:) = curfeats;
    
end


end

