function [ flair,t1,t1ce,t2,seg] = ReadAffinePennBrain( penn_dir,varargin )
%READPENNBRAINS loads the brains given in the cell array brn_cell, loading
%flair, t1, t1ce, t2, seg.

%startup; % get penn brain dir
if isempty(penn_dir)
    penn_dir = '/org/groups/padas/lula_data/medical_images/brain/penn17glistr/';
end
bb = length(varargin);

% images are 192 x 256 x 192
flair = zeros(256,256,256,bb);
t1 = flair;
t1ce = flair;
t2 = flair;
seg = flair;


for bi = 1:bb
    cur_lab = varargin{bi};
    file_base = [penn_dir,cur_lab,'/',cur_lab];
    
    % Load flair
    str = load_nii([file_base,'_flair_normaff_256x256x256.nii.gz']);
    flair(:,:,:,bi) = str.img;
    
    
    % Load t1
    str = load_nii([file_base,'_t1_normaff_256x256x256.nii.gz']);
    t1(:,:,:,bi) = str.img;
    
    % Load t1ce
    str = load_nii([file_base,'_t1ce_normaff_256x256x256.nii.gz']);
    t1ce(:,:,:,bi) = str.img;
    
    % Load t2
    str = load_nii([file_base,'_t2_normaff_256x256x256.nii.gz']);
    t2(:,:,:,bi) = str.img;
    
    % Load seg
    str1 = load_nii([file_base,'_manualCorrected_aff_256x256x256.nii.gz']);
    seg(:,:,:,bi) = str1.img;
    
end

end

