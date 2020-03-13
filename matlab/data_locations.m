if 0
    bdir_dnn_tumor = '/Users/stharakan/Documents/brain_data/dnn/brats_val_tumor_nvidia_unet_sigmoid/';
    bdir_dnn_tissue = '/Users/stharakan/Documents/brain_data/dnn/brats_val_tissue_nvidia_unet_softmax/';
    bdir = '/Users/stharakan/Documents/brain_data/brats18/ALL/';
    klr_dir = '/Users/stharakan/Documents/rklr/matlab/';
    save_dir = './';
    bcell = {'Brats18_2013_23_1','Brats18_2013_25_1','Brats18_2013_5_1','Brats18_CBICA_AQN_1','Brats18_CBICA_AOZ_1'};
    
    
else
    bdir_dnn_tumor =  '/scratch/03158/tharakan/brats_val_tumor_nvidia_unet_sigmoid/';
    bdir_dnn_tissue = '/scratch/03158/tharakan/brats_val_tissue_nvidia_unet_softmax/';
    bdir =            '/scratch/03158/tharakan/brats18/ALL/';
    
    klr_dir = '/work/03158/tharakan/research/rklr/matlab/';
    save_dir = '/scratch/03158/tharakan/miccai20/';
end


% things to save
klr_model_dir = [save_dir,'/klr_model_files/'];
data_file = [save_dir,'dnn_features.mat'];
single_brain_file = [save_dir,'single_brain_results.mat'];
