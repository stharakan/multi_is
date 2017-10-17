function [ P,hdr ] = ReadPennProbs( penn_dir,varargin )
%READPENNPROBS reads the class probabilities from the given brain labels nd
%returns it in a 2D matrix. Dimension 1 concatenates all voxels across all
%dimensions of all brains, and Dimension 2 corresponds to the labels 0-9.
%
% The probabilities are for the following classes:
% 1 - Background
% 2 - CSF
% 3 - Gray Matter
% 4 - White Matter
% 5 - Vessel
% 6 - Edema *taken from truth data*
% 7 - Necrosis + Non-Enhancing *taken from truth data*
% 8 - Enhancing Tumor *taken from truth data* 
% 9 - Cerebellum


bb = length(varargin);
if isempty(penn_dir)
    penn_dir = '/org/groups/padas/lula_data/medical_images/brain/penn17glistr/';
end
class_idx = [0,1,2,3,4,9]; 
class_ld_idx = class_idx + 1; class_ld_idx(end) = 9;
imsize3d = 192*256*192;
P = zeros((imsize3d*bb),9,'single');

for bi = 1:bb
    % Pick out current lab/idx
    cur_lab = varargin{bi};
    file_base = [penn_dir,cur_lab,'/',cur_lab];
    bb_idx = (1:imsize3d)' + (bi-1)*imsize3d;
    
    % Read segmentation
    str = load_nii([file_base,'_manualCorrected.nii.gz']);
    seg = str.img(:);
    tum_idx = seg ~= 0;
    
    % Process segmentation of edema, necrosis, and enhancing
    P(bb_idx,6) = seg == 2;
    P(bb_idx,7) = seg == 1;
    P(bb_idx,8) = seg == 4;
    
    % Loop over 10 classes
    for ci = 1:length(class_idx);
        cur_class = class_idx(ci);
        cur_ld = class_ld_idx(ci);
        
        filename = [penn_dir,cur_lab,'/scan_posterior_',num2str(cur_class),'.nii.gz'];
        %filename = [penn_dir,cur_lab,'/scan_prior_',num2str(cur_class),'.nii.gz'];
        str = load_nii(filename);
        
        % Load into P
        cur_probs = str.img(:);
        cur_probs(tum_idx) = 0; % take out tumor
        P(bb_idx,cur_ld) = cur_probs;
        
    end
    
end

% Normalize all probs
sumP = sum(P,2);
P = bsxfun(@rdivide,P,sumP);
hdr = str.hdr;
end
