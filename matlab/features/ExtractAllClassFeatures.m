function [ GF,ridxc,yy ] = ExtractAllClassFeatures( ppb,feat_type,brn_dir,ridxc,varargin )
%EXTRACTBINARYCLASSFEATURES extracts ppb all class features for the given
% feature type in feat_type each brain in varargin. The entries in varargin 
% should be be folders in brn_dir.


% length of brains
brns = length(varargin);

% Initialize GF, no way to know size right now
GF = [];
if nargout < 3
	yy = 0;
else
	yy = [];
end

% check if ridxc is empty
load_ind = isempty(ridxc);

% Loop over brns 
for bi = 1:brns
    % read brains
		if yy == 0
    	[ flair,t1,t1ce,t2 ] = ReadBratsBrain( brn_dir,varargin{bi} );
		else
    	[ flair,t1,t1ce,t2,seg ] = ReadBratsBrain( brn_dir,varargin{bi} );
		end

		if load_ind
			[~, ridx ] = SubSampleNearTumorIdx( ppb,seg,flair,10);
			ridxc{bi} = ridx;
		else
			if brns == 1
				ridx = ridxc;
			else
				ridx = ridxc{bi};
			end
		end
    
    % Features for that brain, all mods
		switch feat_type
		case 'gabor'
    [GFsm] = GetSelectGaborFeatures( ridx,varargin{bi} );
		case 'window'
    GFsm = GetSelectWindowFeatures(5,ridx, flair,t1,t1ce,t2 ); 
		case 'patch'
    GFsm = GetSelectPatchFeatures(3,ridx, flair,t1,t1ce,t2 );
		case 'diff'
    GFsm = GetIntDiffFeatures( flair(ridx),t1(ridx),t1ce(ridx),t2(ridx) );
		case 'int'
    GFsm = GetIntFeatures( flair(ridx),t1(ridx),t1ce(ridx),t2(ridx) );
		end
    
    % Load into GF, after removing zeros
    GF = [GF;GFsm];
		if  (yy == 0)
			% do nothing
		else
			yy = [yy;seg(ridx)];
		end
end

yy = yy(:);


end


