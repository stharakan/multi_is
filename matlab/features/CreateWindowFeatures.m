function [ GF ] = CreateWindowFeatures( brn_dir,sv_file,psize,varargin )
%CREATEGABORFEATURES essentially reads the brain files passed in varargin,
%which should be locaed in brn_dir. Then Window features are computed, 1
%brain at a time, and stored in GF. GF does not save the voxels where the
%imaging was 0.
%
% INPUT:
% brn_dir: path to brain file folders
% sv_file: where to save binary output
% varargin{i}: string of the ith brain, stored in /brn_dir/varargin{i}/ ..
%
% OUTPUT:
% GF: Window feature matrix 
%
% ----- HOW TO USE  ----
%
% To create the Window features for brnA, images in
% /path/to/brn/brnA/brnA_*.nii.gz, we set 
% 
% brn_dir = /path/to/brn/;
% brns = 'brnA';
%
% To also save to /path/to/sv/file.bla, we set 
%
% sv_file = /path/to/sv/file.bla
% 
% set psize
%
% psize = 5;
%
% To avoid saving, set to []. We can then call this function
%
% [ GF,nzidx ] = CreateWindowFeatures( brn_dir,sv_file,psize,brns );
% 

% length of brains
brns = length(varargin);

% Initialize GF, no way to know size right now
GF = [];

% Loop over brns 
for bi = 1:brns
    % read brains
    [ flair,t1,t1ce,t2 ] = ReadBratsBrain( brn_dir,varargin{bi} );
    
    % Gabor for that brain, all mods
    GFsm = GetWindowFeatures( psize,flair,t1,t1ce,t2 );
    
    % Load into GF, after removing zeros
    nzidx = flair(:) ~= 0;
    GF = [GF;GFsm(nzidx,:)];
end

% ensure single precision
GF = single(GF);

if ~isempty(sv_file)
    % save output to binary file
    fid = fopen(sv_file,'w');
    fwrite(fid,GF,'single');
    fclose(fid);
end

end

