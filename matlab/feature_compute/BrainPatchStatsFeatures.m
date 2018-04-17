function [ fmat,fcell ] = BrainPatchStatsFeatures( brain,psize )
%PATCHSTATSFEATURES calculates the patch stats for a given blist and psize.
%It is called from a parent function, but can be called on its own if
%preferred. 

% initialize fmat, fcell
fcell = FeatureCell('patchstats',psize); 
dd = length(fcell);
mm_idx = 1:(dd/4); mm_counter = dd/4;

% Read all modalities
[flair,t1,t1ce,t2] = brain.ReadAllButSeg();
nn = numel(flair);
fmat = zeros(nn,dd);

% flair
cur_stats = GetImagePatchStats(flair,psize);
fmat(:,mm_idx) = cur_stats;

% t1
mm_idx = mm_idx + mm_counter;
cur_stats = GetImagePatchStats(t1,psize);
fmat(:,mm_idx) = cur_stats;

% t1ce
mm_idx = mm_idx + mm_counter;
cur_stats = GetImagePatchStats(t1ce,psize);
fmat(:,mm_idx) = cur_stats;

% t2
mm_idx = mm_idx + mm_counter;
cur_stats = GetImagePatchStats(t2,psize);
fmat(:,mm_idx) = cur_stats;


end

