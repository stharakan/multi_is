function [ fmat,fcell ] = BrainPatchGStatsFeatures( brain,psize,outdir )
%PATCHGSTATSFEATURES calculates the gabor stats for a given blist and psize.
%It is called from a parent function, but can be called on its own if
%preferred. 

% initialize fmat, fcell
fcell = FeatureCell('patchgstats',psize); 

gflag = nargin > 2;
if gflag
  if isempty(outdir), gflag = false; end;
end

if ~gflag
    dd = length(fcell);
    bw = (psize -1)/2;
    gbank = InitializeGaborBank(bw);
    
    % Read all modalities
    [flair,t1,t1ce,t2] = brain.ReadAllButSeg();
    mm_idx = 1:(dd/4); mm_counter = dd/4;
    nn = numel(flair);
    fmat = zeros(nn,dd);
    
    % flair
    cur_gabor = Myimgaborfilt(flair,gbank,idx);
    cur_stats = GaborToStats(cur_gabor);
    fmat(:,mm_idx) = cur_stats;
    
    % t1
    mm_idx = mm_idx + mm_counter;
    cur_gabor = Myimgaborfilt(t1,gbank,idx);
    cur_stats = GaborToStats(cur_gabor);
    fmat(:,mm_idx) = cur_stats;
    
    % t1ce
    mm_idx = mm_idx + mm_counter;
    cur_gabor = Myimgaborfilt(t1ce,gbank,idx);
    cur_stats = GaborToStats(cur_gabor);
    fmat(:,mm_idx) = cur_stats;
    
    % t2
    mm_idx = mm_idx + mm_counter;
    cur_gabor = Myimgaborfilt(t2,gbank,idx);
    cur_stats = GaborToStats(cur_gabor);
    fmat(:,mm_idx) = cur_stats;
    
else
    fprintf(' computing gabor features first\n');
    %gmat = GetBrainPatchFeatureData(brain,psize,'patchgabor',outdir);
    gmat = GetBrainPatchFeatureData(brain,'patchgabor',psize,outdir);
    fmat = GaborToStats(gmat);
end


end

