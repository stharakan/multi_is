function [ GF,yy,ridxc ] = ExtractBinaryClassFeatures( ppb,feat_type,brn_dir,ridxc,varargin )
%EXTRACTBINARYCLASSFEATURES extracts ppb binary class features for the given
% feature type in feat_type each brain in varargin. The entries in varargin 
% should be be folders in brn_dir.


% length of brains
brns = length(varargin);

% Initialize GF, no way to know size right now
GF = [];
yy = [];

% check if ridxc is empty
load_ind = isempty(ridxc);

% Loop over brns 
for bi = 1:brns
    % read brains
    [ flair,t1,t1ce,t2,seg ] = ReadBratsBrain( brn_dir,varargin{bi} );
		if load_ind
			[~, ridx ] = SubSampleNearTumorIdx( ppb,seg,flair );
			ridxc{bi} = ridx;
		else
			ridx = ridxc{bi};
		end
    
    % Features for that brain, all mods
		switch feat_type
		case 'gabor'
    [GFsm] = GetSelectGaborFeatures( ridx,varargin{bi} );
		case 'window'
    GFsm = GetSelectWindowFeatures(5,ridx, flair,t1,t1ce,t2 ); 
		case 'patch'
    GFsm = GetSelectPatchFeatures(3,ridx, flair,t1,t1ce,t2 );
		case 'intdiff'
    GFsm = GetIntDiffFeatures( flair(ridx),t1(ridx),t1ce(ridx),t2(ridx) );
		case 'int'
    GFsm = GetIntFeatures( flair(ridx),t1(ridx),t1ce(ridx),t2(ridx) );
		end
    
    % Load into GF, after removing zeros
    GF = [GF;GFsm];
		yy = [yy;seg(ridx)];
end

yy = yy(:);
yy(yy == 0) = -1;
yy(yy ~=-1) = 1;


end


