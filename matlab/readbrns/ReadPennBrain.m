function [ flair,t1,t1ce,t2,seg,probs,hdr] = ReadPennBrain( penn_dir,varargin )
%READPENNBRAINS loads the brains given in the cell array brn_cell, loading
%flair, t1, t1ce, t2, seg.

%startup; % get penn brain dir
if isempty(penn_dir)
    penn_dir = '/org/groups/padas/lula_data/medical_images/brain/penn17glistr/';
end
bb = length(varargin);

% images are 192 x 256 x 192
flair = zeros(192,256,192,bb);
t1 = flair;
t1ce = flair;
t2 = flair;
seg = flair;


for bi = 1:bb
    cur_lab = varargin{bi};
    file_base = [penn_dir,cur_lab,'/',cur_lab];
    
    % Load flair
    str = load_nii([file_base,'_flair_pp.nii.gz']);
    flair(:,:,:,bi) = str.img;
    
    
    % Load t1
    str = load_nii([file_base,'_t1_pp.nii.gz']);
    t1(:,:,:,bi) = str.img;
    
    % Load t1ce
    str = load_nii([file_base,'_t1ce_pp.nii.gz']);
    t1ce(:,:,:,bi) = str.img;
    
    % Load t2
    str = load_nii([file_base,'_t2_pp.nii.gz']);
    t2(:,:,:,bi) = str.img;
    
    % Load seg
    str1 = load_nii([file_base,'_manualCorrected.nii.gz']);
    seg(:,:,:,bi) = str1.img;
    
end

if nargout > 5
    probs = ReadPennProbs(penn_dir,varargin{:});
end
hdr = str.hdr;
end

