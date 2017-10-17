addpath('./../general/');
SetPath;
SetVariablesTACC;

% Set this to wherever all probabilities which need to be flipped are stored
prob_dir = [brats,'/classification/askit_results/meanrenorm/meanrenormTrn_res_knn_gabor_50M/'];
out_dir = [brats,'/classification/askit_results/meanrenorm/meanrenormTrn_res_knn_gabor_50M_rot/'];
%prob_dir = [brats,'/classification/askit_results/meanrenorm/meanrenormVal_res_knn_gabor_50M/'];
%out_dir = [brats,'/classification/askit_results/meanrenorm/meanrenormVal_res_knn_gabor_50M_rot/'];

%% Just used to test script
%truth_dir = [brats,'/preprocessed/trainingdata/meanrenorm/'];
%brain_cell = {'Brats17_CBICA_AAB_1', 'Brats17_CBICA_AAG_1'...
%  ,'Brats17_CBICA_AAL_1','Brats17_CBICA_AAP_1' };

% Get list of brains
brnfiles = dir([prob_dir,'*.nii.gz']);
num_brains = length(brnfiles);

for bi = 1:num_brains
		bfile = brnfiles(bi).name;
		fprintf(['Processing %d of %d\nBrain file: %s\n'],bi,num_brains,bfile);

		% Load brain
		nii = load_untouch_nii([prob_dir,bfile]);
		
		% Rotate
		nii.img = rot90(nii.img,2);

		% Save flipped version
		save_untouch_nii(nii,[out_dir,bfile]);
	
		%% Just used to test script
		%[flair,~,~,~,seg] = ReadIdxBratsBrain(truth_dir,brain_cell{bi});

		%% Compute dice
		%nzidx = flair ~= 0;
		%D1 = seg(nzidx) ~= 0;
		%D2 = nii.img(nzidx) > 0.25;
		%dice_pre = compute_dice(D1,D2) 
		%
		%% Compute dice post
		%D2p = nii.img(nzidx) > 0.25;
		%dice_post = compute_dice(D1,D2p)
end
