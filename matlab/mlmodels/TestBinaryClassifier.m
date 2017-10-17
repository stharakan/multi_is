function [ Yte,idx,probs ] = TestBinaryClassifier( filenm,feature_type,cur_brn,sub_idx )
%TESTBINARYCLASSIFIER runs the classifer for the normal vs whole tumor task for the
%given date on the test set X. The output is the estimated classification 
%scores: accuracy for each brain, and dice for each class and each brain.
%Additionally, each estimated segmentation is saved in save_dir as
%brn_bla_NvWT_estseg.nii.gz. 

% Get validation directory
validation_info; % get validation directory val_dir

% assumes model already exists so load first
Mdl = TrainTreeModel(filenm);

% load brain features and idx
[Xte,idx] = LoadValFeatures(val_dir,feature_type,cur_brn);
if nargin > 3
	Xte = Xte(sub_idx, :);
	idx = idx(sub_idx);
end

% Predict new business
[Yte,~,~,probs] = Mdl.predict(Xte);

end

