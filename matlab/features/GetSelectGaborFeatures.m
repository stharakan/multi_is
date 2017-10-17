function [ GF ] = GetSelectGaborFeatures( ridx,varargin )
%GETGABORFEATURES will get the given gabor features on possibly multimodal
%data. For each of the m modalities, it will run 72 different 2-D Gabor
%filters on each slice given. 
%
% ----- HOW TO USE  ----
% Suppose we have already extracted flair, t1, t1ce, and t2 from a given
% set of brains. In order to get the features, we simply call the function
% as shown below:
%
% GF = GetGaborFeatures(flair,t1,t1ce,t2);
%
% If we want to use filenames to call these features, see
% CreateGaborFeatures, which can also save features to a binary file.
%
%  [GFsm,ridx] = GetSelectGaborFeatures( ppb,seg,flair,t1,t1ce,t2 );

% hard code gabor directory
gab_dir = '/org/groups/padas/lula_data/medical_images/brain/gabor_features/';

brns = length(varargin);
GF = [];

% mri size
mri_size = 240*240*155;
feats = 8 * 3 * 3 * 4;

% loop over brains
for bi = 1:brns
	% open file, load
	filenm = [gab_dir,varargin{bi},'_gabor.bin'];
	fid = fopen(filenm,'r');
	GFsm = fread(fid,[mri_size,feats],'single');
	fclose(fid);
	
	% pick part of GFsm
	if brns == 1
		GFsm = GFsm(ridx,:);
	else
		GFsm = GFsm(ridx{bi},:);
	end

	% put into GF
	GF = [GF;GFsm];

end


end

