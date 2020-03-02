% script to create data set from dnn features

% specify variables
data_locations;
feat_type = 'all';
dir_to_search = bdir_dnn_tissue;
near_tumor_pixel_distance = 20;
trn_perc = 0.8;
rounding_power = 1;
save_file = 'test.mat';

% get list of brains
%brn_cell = dnn_file_list(dir_to_search);


% Select points, get trn and test
ps = PointSelector('neartumor',near_tumor_pixel_distance);
blist = DNNBrainPointList(bdir,bcell,ps,bdir_dnn_tissue,bdir_dnn_tumor,'./');
[trn_list,tst_list] = blist.SplitAndRound(trn_perc,rounding_power);
[trn_list,val_list] = trn_list.SplitAndRound(trn_perc,rounding_power);

% Get features for training/testing
Xtrain = single(DNNFeatures(trn_list,feat_type));
Xtest  = single(DNNFeatures(val_list,feat_type));

% Get labels for training/testing
Ytrain = single(GetSegVals(trn_list));
Ytest  = single(GetSegVals(val_list));

% Save dataset
save(save_file,'Xtrain','Xtest','Ytrain','Ytest','trn_list','tst_list','val_list');