function [ fmat,fcell ] = BrainPatchGaborFeatures( brain,psize )
%PATCHSTATSFEATURES calculates the patch stats for a given blist and psize.
%It is called from a parent function, but can be called on its own if
%preferred. 

% initialize fmat, fcell
fcell = FeatureCell('patchgabor',psize); 
dd = length(fcell);
mm_idx = 1:(dd/4); mm_counter = dd/4;

% bw and gabor bank
bw = (psize -1)/2;
gbank = InitializeGaborBank(bw);

% Read all modalities
[flair,t1,t1ce,t2] = brain.ReadAllButSeg();
nn = numel(flair);
fmat = zeros(nn,dd);

% flair
cur_gabor = Myimgaborfilt(flair,gbank);
fmat(:,mm_idx) = cur_gabor;

% t1
mm_idx = mm_idx + mm_counter;
cur_gabor = Myimgaborfilt(t1,gbank);
fmat(:,mm_idx) = cur_gabor;

% t1ce
mm_idx = mm_idx + mm_counter;
cur_gabor = Myimgaborfilt(t1ce,gbank);
fmat(:,mm_idx) = cur_gabor;

% t2
mm_idx = mm_idx + mm_counter;
cur_gabor = Myimgaborfilt(t2,gbank);
fmat(:,mm_idx) = cur_gabor;

end
