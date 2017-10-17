% Add path to other code
addpath('./../features/');
addpath('./../readbrns/');
p = genpath('./../external'); % this should be where save_nii/read_nii is located
addpath(p); % add load_nii

% Feature selection for model
feature_type = 'int';
modelname = 'testrun';
dd = GetFeatureDimension(feature_type);

% directories
mdl_dir = '/org/groups/padas/lula_data/medical_images/brain/BRATS17/classification/training/models/'; % directory contatining model file
feat_dir = '/org/groups/padas/lula_data/medical_images/brain/BRATS17/classification/training/'; % directory containing training features
val_brn_dir = '/org/groups/padas/lula_data/medical_images/brain/BRATS17/preprocessed/validationdata/pre-norm-aff/'; % directory containing validation brain images
val_feature_dir = '/org/groups/padas/lula_data/medical_images/brain/askit_files/validation/'; % directory containing validation features
save_dir = '/org/groups/padas/lula_data/medical_images/brain/BRATS17/classification/validation/output_files/'; % directory where images should be saved to
mdlfile = [modelname,'.',feature_type,'.mat']; % name of model file to save or load


% load trainign data --> task is binary N v WT TODO this should be its own script
disp('Training data');
[~,bb] = system(['cd ',feat_dir,' && ls ./*',feature_type,'* -1']);
fid = fopen([feat_dir,bb(3:(end-1))]);
Xtr = fread(fid,'single'); fclose(fid);
Xtr = reshape(Xtr,[],dd);
[~,bb] = system(['cd ',feat_dir,' && ls ./*labs* -1']);
fid = fopen([feat_dir,bb(3:(end-1))]);
ytr = fread(fid,'single'); fclose(fid);
ytr(ytr ~= 0) = 1;
ytr(ytr == 0) = -1;

% Load model file, or train if it does not exist
disp('Model training');
mdlfile_loc = [mdl_dir, mdlfile];
[ Mdl ] = TrainTreeModel(mdlfile_loc, Xtr,ytr );
 
% Run on test brain
disp('testing model');
brncell = GetBrnList(val_brn_dir); % Get list of brains in validation directory
val_brn = brncell{1}; % test run with just one brain
[ Yte,image_idx,probs ] = TestBinaryClassifier( mdlfile_loc,feature_type,val_brn );

% Save output probs
disp('Saving probs');
classes = {'N','WT'};
SaveProbs(save_dir,val_brn,probs,classes,image_idx,feature_type);

% Save output segmentation
disp('Saving seg');
SaveSeg(save_dir,val_brn,Yte,image_idx,feature_type);

