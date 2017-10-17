if ~exist(brats)
    error('Need to define ''brats'' variable first using the SetPath() script\n');
end;

SetAtlasVariables;
SetBrainCollectionVariables;
nnzquantile = @(img,value) quantile(  img(img(:)>0), value);

%Also can use function to get brains in directory: brats17tst_brains = GetBrnList(brats17tst_original_dir); --> call this to get brains!

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

%%%%%%%%%%%%%%%%%%%%%% VALIDATION DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Brats17 validation data
brats17val_original_dir= [brats,'/preprocessed/validationdata/bratsvalidation_240x240x155/pre-norm-aff/'];
brats17val_features_dir=[brats,'/classification/validation/'];
brats17val_meanrenorm_dir = [brats,'/preprocessed/validationdata/meanrenorm/'];

brats17val_atlases_claire_dir = [brats,'/work/00921/biros/BRATS17/preprocessed/diffreg_atlases_to_brats17'];
conf= 'exp-symmetric-iter-10x5x2-nx-240x240x155-sigmaU-0.0-sigmaD-3.5/';
confTACC= 'exp-symmetric-iter-15x10x5-nx-240x240x155-sigmaU-0.0-sigmaD-3.5/';
brats17val_atlases_demons_dir = [brats,'/preprocessed/diff_registered_to_atlases/Brats17ValidationData/demons/',confTACC];
clear('conf');


brats17val_classification_NOvWT_dir = [brats,'/classification/validation_results/NOvWTBrats17/'];
brats17val_classification_ALvED_dir = [brats,'/classification/validation_results/ALvEDBrats17/'];


%%%%%%%%%%%%%%%%%%%%%  TESTING DATA %%%%%%%%%%%%%%%%%%%%%  

% Brats17 testing data
brats17tst_original_dir = [brats,'/augTestData/'];
brats17tst_features_dir = [brats,'/classification/augTestData/'];
brats17tst_results_dir = [brats,'/classification/augTestData_results/'];


% testing
brats17tst_atlases_claire_dir = [brats,'/preprocessed/diff_registered_to_atlases/claire/BratsTestingData/'];
brats17tst_atlases_demons_dir = [brats,'/preprocessed/diff_registered_to_atlases/demons/BratsTestingData/'];

%%%%%%%%%%%%%%%%%%%%%  TRAINING DATA %%%%%%%%%%%%%%%%%%%%%  

% TRAINING DATA
brats17tra_atlases_claire_dir = [brats,'/preprocessed/diff_registered_to_atlases/claire/BratsTrainingData/'];
brats17tra_atlases_demons_dir = [brats,'/preprocessed/diff_registered_to_atlases/demons/BratsTrainingData/'];
brats17tra_original_dir = [brats,'/preprocessed/trainingdata/all-pre-norm-aff/'];


%%%%%%%%%%%%%%%%%%%%%  PENN DATA %%%%%%%%%%%%%%%%%%%%%  


% Penn17glistr data
penn_original_dir = [brats,'/preprocessed/PennValidationImagesPreprocessed/pre-norm-aff/'];
penn_features_dir=[brats,'/classification/penndata/'];
penn_atlases_claire_dir  = [brats,'/preprocessed/diff_registered_to_atlases/PennValidationImages/claire/betav=5E-3/'];
conf= 'exp-symmetric-iter-10x5x2-nx-256x256x256-sigmaU-0.0-sigmaD-3.5/';
penn_atlases_demons_dir = [brats,'/preprocessed/diff_registered_to_atlases/PennValidationImages/demons/',conf];
clear('conf');

penn_classification_NOvWT_dir = [brats,'/classification/penndata_results/NOvWTPenn/'];
penn_classification_ALvED_dir = [brats,'/classification/penndata_results/ALvEDPenn/'];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Below we list a series of directories for use 
% with combined classifier. The structure is as follows
% 
% (classifier_name)_(tra/tst/val)_probs_dir
%
% I also set the tags (all possible probabilitiy types in a given dir)

% dnn
dnn_tra_probs_dir = [brats,'/classification/dnn_results/Training/Training_prob/AGG/'];
dnn_tst_probs_dir = [brats,'/classification/dnn_results/Test_prob/'];
dnn_val_probs_dir = [brats,'/classification/dnn_results/validation/Validation_prob/'];
dnn_prob_types = {'dnn.probs.WT'};

% lgbm
lgbm_tst_probs_dir = [brats,'/userbrats/BRATS17tharakan/augTestData_results/NOvWTlgbm.gabor/'];
lgbm_val_probs_dir = [brats,'/classification/validation_results/NOvWT_lgbm50M.gabor/'];
lgbm_tra_probs_dir = [brats,'/classification/trainingfeatures_results/NOvWTlgbm.gabor/'];
lgbm_prob_types = {'gabor.probs.WT'};

% kde
kde_tst_probs_dir = [brats,'/classification/askit_results/augTestData_res_kde_gabor_5M_h1.4/'];
kde_val_probs_dir = [brats,'/classification/askit_results/validation_res_kde_gabor_5M_h1.4/'];
kde_tra_probs_dir = [brats,'/classification/askit_results/trainingfeatures_res_kde_gabor_5M_h1.4/'];
kde_prob_types = {'gabor.probs.WT'};

% comb5
comb5_tra_probs_dir = [brats,'/combinedclassification/combclass_dnnprob_lgbm_kde_tra/'];
comb5_tst_probs_dir = [brats,'/combinedclassification/combclass_dnnprob_lgbm_kde_tst/'];
comb5_val_probs_dir = [brats,'/combinedclassification/combclass_dnnprob_lgbm_kde_val/'];
comb5_prob_types = { 'probsAll.WT','segMorph.WT','probsAvg.WT','probsEnt.WT','probsSup.WT'};


% med5
med5_tra_probs_dir = [brats,'/combinedclassification/median_filtered_tra/'];
med5_tst_probs_dir = [brats,'/combinedclassification/median_filtered_tst/'];
med5_val_probs_dir = [brats,'/combinedclassification/median_filtered_val/'];
med5_prob_types = { 'medkde.WT','medlgbm.WT','meddnn.WT','medflair.WT','medt2.WT' };

% sibia
sibia_val_probs_dir = [brats,'/userbrats/BRATS17dmalhotr/sibia_output/Brats17ValidationData/all_classifications/'];
sibia_tra_probs_dir = [brats,'/userbrats/BRATS17dmalhotr/sibia_output/Brats17TrainingData/all_classifications/'];
sibia_tst_probs_dir = [brats,'/userbrats/BRATS17dmalhotr/sibia_output/Brats17TestingData/all_classifications/'];
sibia_prob_types = { 'sibiaout.probs.WT','sibiaout.probs.CSF','sibiaout.probs.WMGM' };

% knn
knn_tra_probs_dir = [brats,'/classification/askit_results/trainingfeatures_res_knn_gabor_50M/'];
knn_tst_probs_dir = [brats,'/classification/askit_results/augTestData_res_knn_gabor_50M/'];
knn_prob_types = {'gabor.probs.WT'};




