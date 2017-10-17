function [ ] = CreateGaborFeatures( brn_dir,sv_dir,varargin )
%CREATEGABORFEATURES essentially reads the brain files passed in varargin,
%which should be locaed in brn_dir. Then Gabor features are computed, 1
%brain at a time, and stored in GF. GF does not save the voxels where the
%imaging was 0.
%
% INPUT:
% brn_dir: path to brain file folders
% sv_dir: where to save binary output
% varargin{i}: string of the ith brain, stored in /brn_dir/varargin{i}/ ..
%
% OUTPUT:
% GF: Gabor feature matrix 
%
% ----- HOW TO USE  ----
%
% To create the Gabor features for brnA, images in
% /path/to/brn/brnA/brnA_*.nii.gz, we set 
% 
% brn_dir = /path/to/brn/;
% brns = 'brnA';
%
% To also save to /path/to/sv/brnA_gabor.bla, we set 
%
% sv_dir = /path/to/sv/
% 
% To avoid saving, set to []. We can then call this function
%
% [ GF,nzidx ] = CreateGaborFeatures( brn_dir,sv_dir,brns );
% 

% length of brains
brns = length(varargin);


% Loop over brns 
for bi = 1:brns
    % read brains
		cur_brn = varargin{bi};
    [ flair,t1,t1ce,t2 ] = ReadBratsBrain( brn_dir,cur_brn );
    
    % Gabor for that brain, all mods
    GFsm = GetGaborFeatures( flair,t1,t1ce,t2 );
		GFsm = single(GFsm);
    
		
		if ~isempty(sv_dir)
			% get size for reading info
			[nn,dd] = size(GFsm);

    	% save output to binary file
    	fid = fopen([sv_dir,cur_brn,'_gabor.bin'],'w');
    	fwrite(fid,GFsm,'single');
    	fclose(fid);
		end


end

% ensure single precision

end

