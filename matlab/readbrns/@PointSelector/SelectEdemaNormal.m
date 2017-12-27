function [ idx ] = SelectEdemaNormal( ps,brain,ppb )
%SELECTEDEMANORMAL picks edema points and healthy points at random at an
%even ratio for a total of ppb points, taken from brain. If ppb = 0, all
%edema points and a corresponding number of healthy points are selected

% get tumor sample using seg
seg = brain.ReadSeg();
ed_idx = find(seg == 2);
tot_edema = length(ed_idx);

% make sure we have correct amount of things
num_edema = min(floor(ppb/2),tot_edema);
ed_idx = randsample(ed_idx,num_edema);

% find normal index
tum_idx = find(seg);
flair = brain.ReadFlair();
b_idx = find(flair);
no_idx = setdiff(b_idx, tum_idx);

% subsample appropriately
num_healthy = ppb - num_edema;
no_idx = randsample(no_idx,num_healthy);

% concatenate
idx = [ed_idx(:);no_idx(:)];

end

