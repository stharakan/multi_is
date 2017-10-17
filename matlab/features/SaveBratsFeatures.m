function [ GF,seg ] = SaveBratsFeatures( dir,sv_file,feat_type,varargin )
%LOADBRATSINTFEATURES loads the brains specified in varargin from the 
%directory given in dir. The 4-d feature vector of intensities is computed
%and saved to sv_file. sv_file is assumed to not have an extension, this
%can be changed. feat_type specifies the type of feature, currently we have
%'int', 'intdiff', and 'patch'.
%
% ----  HOW TO USE -----
% 
% Suppose we need to open brains Brats17_TCIA_101_1 and Brats17_TCIA_307_1
% from directory '/path/to/dir' and extract the intensity features while 
% saving the features and segmentation to a file, '/path/to/file/file.dat'.
% We can call this function as shown below:
%
% dir = '/path/to/dir/'; % specify directory containing brain folders
% sv_file = '/path/to/file/file'; % exclude .dat
% feat = 'int'; % specify feature type
% brns = {'Brats17_TCIA_101_1','Brats17_TCIA_307_1'}; % brns into cell
%
% The final call can be either 1 or 2.
% 1. [GF,seg] = SaveBratsFeatures(dir,sv_file,feat,brns{:});
% 2. [GF,seg] = SaveBratsFeatures(dir,sv_file,feat,'Brats17_TCIA_101_1', ...
%       'Brats17_TCIA_307_1');
%


% Load brain images
[ flair,t1,t1ce,t2,seg ] = ReadBratsBrain( dir,varargin{:} );

% Make into features
switch feat_type
    case 'int'
        [ GF ] = GetIntFeatures( flair,t1,t1ce,t2 );
    case 'intdiff'
        [ GF ] = GetIntDiffFeatures( flair,t1,t1ce,t2 );
    case 'patch'
        [ GF ] = GetPatchFeatures( flair,t1,t1ce,t2 );
    case 'gabor'
        [ GF ] = GetGaborFeatures( flair,t1,t1ce,t2 );
    otherwise
        error('Unrecognized feature type');
end

% make seg into vec
seg = seg(:);

% write to file
if ~isempty(sv_file)
    fid = fopen([sv_file,'.dat']);
    fwrite(fid,GF,'single');
    fclose(fid);
    
    % write seg to file
    fid = fopen([sv_file,'_seg.dat']);
    fwrite(fid,single(seg),'single');
    fclose(fid);
end
end

