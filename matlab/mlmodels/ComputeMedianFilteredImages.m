% script to compute median filtered images
addpath([getenv('BRATSREPO'),'/matlab/general']);
SetPath;
SetVariablesTACC;
myload_nii = @(filename) load_untouch_nii(filename);
data_type = 'val';
filter_size = [5 5 3];
fprintf('Computing median filtered images for %s data\n',data_type);


switch data_type
case 'tra'
	kde_dir = kde_tra_probs_dir;
	lgbm_dir = lgbm_tra_probs_dir;
	dnn_dir = dnn_tra_probs_dir;
	org_dir = brats17tra_original_dir;
	brains = brats17tra_brains;
	out_dir = med5_tra_probs_dir;
case 'val'
	kde_dir = kde_val_probs_dir;
	lgbm_dir = lgbm_val_probs_dir;
	dnn_dir = dnn_val_probs_dir;
	org_dir = brats17val_original_dir;
	brains = brats17val_brains;
	out_dir = med5_val_probs_dir;

case 'tst'
	kde_dir = kde_tst_probs_dir;
	lgbm_dir = lgbm_tst_probs_dir;
	dnn_dir = dnn_tst_probs_dir;
	org_dir = brats17tst_original_dir;
	brains = brats17tst_brains;
	out_dir = med5_tst_probs_dir;
end

brains = brains;
brns = length(brains);

% loop over brains, compute filters
for bi = 1:brns
counter = 1;
brain = brains{bi};
fprintf('Processing  brain %d out of %d subjects, named %s\n',bi,length(brains),brain);

% load images
t2_file = [org_dir,brain,'/',brain,'_t2_normaff.nii.gz'];
t2_nii = myload_nii([t2_file]);
flair_file = [org_dir,brain,'/',brain,'_flair_normaff.nii.gz'];
flair_nii = myload_nii([flair_file]);
niiout = t2_nii;


% process KDE
cur_im = LoadProbsFromDir(brain,kde_dir,kde_prob_types);
imfilt = medfilt3(cur_im{1}, filter_size);
niiout.img = imfilt;
fprintf('Saving KDE: %s to %s\n',kde_prob_types{1},med5_prob_types{counter}); 
save_untouch_nii(niiout,[out_dir,brain,'.',med5_prob_types{counter},'.nii.gz']);
counter = counter + 1;

% process LGBM
cur_im = LoadProbsFromDir(brain,lgbm_dir,lgbm_prob_types);
imfilt = medfilt3(cur_im{1}, filter_size);
niiout.img = imfilt;
fprintf('Saving LGBM: %s to %s\n',lgbm_prob_types{1},med5_prob_types{counter}); 
save_untouch_nii(niiout,[out_dir,brain,'.',med5_prob_types{counter},'.nii.gz']);
counter = counter + 1;

% process DNN
cur_im = LoadProbsFromDir(brain,dnn_dir,dnn_prob_types);
imfilt = medfilt3(cur_im{1}, filter_size);
niiout.img = imfilt;
fprintf('Saving DNN: %s to %s\n',dnn_prob_types{1},med5_prob_types{counter}); 
save_untouch_nii(niiout,[out_dir,brain,'.',med5_prob_types{counter},'.nii.gz']);
counter = counter + 1;


% process actual images
imfilt = medfilt3(t2_nii.img, filter_size);
niiout.img = imfilt;
fprintf('Saving T2: %s to %s\n','t2',med5_prob_types{counter}); 
save_untouch_nii(niiout,[out_dir,brain,'.',med5_prob_types{counter},'.nii.gz']);
counter = counter + 1;

imfilt = medfilt3(flair_nii.img, filter_size);
niiout.img = imfilt;
fprintf('Saving Flair: %s to %s\n','flair',med5_prob_types{counter}); 
save_untouch_nii(niiout,[out_dir,brain,'.',med5_prob_types{counter},'.nii.gz']);
end
