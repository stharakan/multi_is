if ~exist(brats)
    error('Need to define ''brats'' variable first using the SetPath() script\n');
end;


% Machine learing files (features, training data and models)
% Directory below is were we store the training models from MATLAB,
% e.g., decision trees 
training_features_dir =[brats,'/classification/training/'];
training_model_dir = [brats,'/classification/training/models/'];

% the different feature types are used to automatically load
% features fore each brain. Also these are the features used in
% different classifiers
feature_types = {'int','gabor'};
featurefile{1} =[training_features_dir,'BRATS_fix.pb20000.trn.nn.5214772.dd.4.int.bin'];  feature_d{1}=single(4);
featurefile{2} =[training_features_dir,'BRATS_fix.pb20000.trn.nn.5214772.dd.288.gabor.bin']; feature_d{2}=single(288);
labelfile{1} = [training_features_dir,'BRATS_fix.pb20000.trn.nn.5214772.labs.bin'];


%  FILES AND DIRECTOIES FOR THE ATLASES
% JAkOB 
jakob_dir = [brats,'/atlas_data/jakob/']; % all Jakob files.
jakob_cb_file = [jakob_dir, 'jakob_prob_cb_256x256x256.nii.gz'];  % cerebellum file
jakob_cb_240_file = [ jakob_dir, 'jakob_prob_cb_240x240x155.nii.gz'];
jakob_t1_240_file = [ jakob_dir, 'jakob_t1_240x240x155_norm.nii.gz'];
jakob_t1_128_file = [ jakob_dir, 'jakob_t1_128x128x128.nii.gz'];
% test cases
atlases_14brains = {'0093Y01',  '0097Y01',  '0002Y01',  '0390Y01',  '0094Y01',  '0099Y01',  '0386Y01','0392Y01',  '0098Y01',  '0095Y01',  '0100Y01',  '0004Y01',  '0102Y01',  '0096Y01'};
atlases_3brains = {'0002Y01', '0004Y01','0093Y01'}; 



% BELLOW are directories for classification of images
%{ 
  Given a dataset with name "DNAME" we define the following directories:
  DNAME_original_dir - where the images that have been normialized and registered to an atlas sit.
  DNAME_features_dir - for ML we need to compute the feature for each brain and this is where we put them.

  DNAME_classification_BINARYLABEL_dir - directory with the binary
      classificaiton results for each voxel in the target brain.
      BINARYLABEL can be one of NOvWTDNAME, ALvEDDNAME, and others. 

  DNAME_atlases_METHOD_dir - we use atlas-based segmentation for 
          normal tissue. "method indicates the registration METHOD
          (currently METHOD is one of: claire, demons). Each brain has to be registered 
          diffemorphically to an atlas (which are int he BRATS17 directory)
%}

% Penn17glistr data
penn_original_dir = [brats,'/preprocessed/PennValidationImagesPreprocessed/pre-norm-aff/']; 
penn_features_dir=[brats,'/classification/penndata/'];

penn_atlases_claire_dir  = [brats,'/preprocessed/diff_registered_to_atlases/PennValidationImages/claire/betav=5E-3/'];
conf= 'exp-symmetric-iter-10x5x2-nx-256x256x256-sigmaU-0.0-sigmaD-3.5/';
penn_atlases_demons_dir = [brats,'/preprocessed/diff_registered_to_atlases/PennValidationImages/demons/',conf];
clear('conf');

penn_classification_NOvWT_dir = [brats,'/classification/penndata_results/NOvWTPenn/'];
penn_classification_ALvED_dir = [brats,'/classification/penndata_results/ALvEDPenn/'];

penn_brains = {'AAAC', 'AAMH', 'AAAN', 'AAMP', 'AAQD', 'AAWI', 'AAXN' };
penn_2brains ={'AAAC','AAAN'};


%Brats17 validation data
brats17val_original_dir= [brats,'/preprocessed/validationdata/bratsvalidation_240x240x155/pre-norm-aff/'];
brats17val_features_dir=[brats,'/classification/validation/'];

brats17val_atlases_claire_dir = [brats,'/preprocessed/diff_registered_to_atlases/Brats17ValidationData/claire/'];                   
conf= 'exp-symmetric-iter-10x5x2-nx-240x240x155-sigmaU-0.0-sigmaD-3.5/';
brats17val_atlases_demons_dir = [brats,'/preprocessed/diff_registered_to_atlases/Brats17ValidationData/demons/',conf];
clear('conf');

brats17val_classification_NOvWT_dir = [brats,'/classification/validation_results/NOvWTBrats17/'];
brats17val_classification_ALvED_dir = [brats,'/classification/validation_results/ALvEDBrats17/'];



% Brats17 training data sample
brats17trsa_originalhgg_dir= [brats,'/preprocessed/trainingdata/HGG/pre-norm-aff/'];
brats17trsa_originallgg_dir= [brats,'/preprocessed/trainingdata/LGG/pre-norm-aff/'];
brats17trsa_features_dir=[brats,'/classification/Brats17TrainingDataSample/'];

brats17trsa_atlases_claire_dir = [brats,'/preprocessed/diff_registered_to_atlases/Brats17TrainingData/claire/'];                   
conf= 'exp-symmetric-iter-10x5x2-nx-240x240x155-sigmaU-0.0-sigmaD-3.5/';
brats17trsa_atlases_demons_dir = [brats,'/preprocessed/diff_registered_to_atlases/Brats17TrainingData/demons/',conf];
clear('conf');

brats17trsa_classification_NOvWT_dir = [brats,'/classification/Brats17TrainingDataSample_results/NOvWTBrats17/'];
brats17trsa_classification_ALvED_dir = [brats,'/classification/Brats17TrainingDataSample_results/ALvEDBrats17/'];


% Brats17 testing data 
brats17tst_original_dir = [brats,'/augTestData/'];
brats17tst_features_dir = [brats,'/classification/augTestData/'];
brats17tst_results_dir = [brats,'/classification/augTestData_results/'];
%brats17tst_brains = GetBrnList(brats17tst_original_dir); --> call this to get brains!

