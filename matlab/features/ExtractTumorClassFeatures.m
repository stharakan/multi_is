function [ GF,yy,ridxc ] = ExtractTumorClassFeatures( ppb,feat_type,brn_dir,varargin )

% length of brains
brns = length(varargin);

% Initialize GF, no way to know size right now
GF = [];
yy = [];

% Loop over brns 
for bi = 1:brns
    % read brains
    [ flair,t1,t1ce,t2,seg ] = ReadBratsBrain( brn_dir,varargin{bi} );
		[~, ridx ] = SubSampleTumorIdx( ppb,seg );
		ridxc{bi} = ridx;
    
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

yy = yy(:); % y has classes 1, 2, and 4


end

