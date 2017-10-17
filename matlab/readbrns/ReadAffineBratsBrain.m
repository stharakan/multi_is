function [ flair,t1,t1ce,t2,seg,hdr ] = ReadAffineBratsBrain( brats_dir,varargin )
%READAFFINEBRATSBRAIN reads in brats brain files in varargin from directory dir. 
%This will only give image matrices, to get full nii files, use ReadBratsNii.
%The best way to do this is to pass in a cell array of brats brains with
%array{:}. If the header is desired, it is passed out as the final
%argument, but only the header for t2 is passed. 
%
% ----  HOW TO USE -----
% 
% Suppose we need to open brains Brats17_TCIA_101_1 and Brats17_TCIA_307_1
% from directory '/path/to/dir'. We would run the following:
%
% dir = '/path/to/dir/'; % specify directory containing brain folders
% brns = {'Brats17_TCIA_101_1','Brats17_TCIA_307_1'}; % brns into cell
%
% The final call can be either 1 or 2.
% 1. [flair,t1,t1ce,t2,seg,hdr] = ReadAffineBratsBrain(dir,brns{:});
% 2. [flair,t1,t1ce,t2,seg,hdr] = ReadAffineBratsBrain(dir,'Brats17_TCIA_101_1',...
%       'Brats17_TCIA_307_1');


% Check if directory uses preprocessing
bb = length(varargin);


% Find size of brats brains
flair = zeros(240,240,155,bb); % Size hard coded, might change w/reg
t1 = flair;
t1ce = flair;
t2 = flair;
if nargout > 4
	seg = flair;
end
% Loop over brains
for bi = 1:bb
    cur_lab = varargin{bi};
    file_base = [brats_dir,cur_lab,'/',cur_lab];
    
    % Load flair
    str = load_nii([file_base,'_flair_normaff.nii.gz']);
    flair(:,:,:,bi) = str.img;
    
    
    % Load t1
    str = load_nii([file_base,'_t1_normaff.nii.gz']);
    t1(:,:,:,bi) = str.img;
    
    % Load t1ce
    str = load_nii([file_base,'_t1ce_normaff.nii.gz']);
    t1ce(:,:,:,bi) = str.img;
    
    % Load t2
    str = load_nii([file_base,'_t2_normaff.nii.gz']);
    t2(:,:,:,bi) = str.img;
    
    % Load seg
		if nargout > 4
   		str1 = load_nii([file_base,'_seg_aff.nii.gz']);
    	seg(:,:,:,bi) = str1.img;
		end
end

hdr = str.hdr;


end

