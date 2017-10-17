%  FILES AND DIRECTOIES FOR THE ATLASES
% JAkOB
jakob_dir = [brats,'/atlas_data/jakob/']; % all Jakob files.
jakob_cb_file = [jakob_dir, 'jakob_prob_cb_256x256x256.nii.gz'];  % cerebellum file
jakob_cb_240_file = [ jakob_dir, 'jakob_prob_cb_240x240x155.nii.gz'];
jakob_t1_240_file = [ jakob_dir, 'jakob_t1_240x240x155_norm.nii.gz'];
jakob_t1_128_file = [ jakob_dir, 'jakob_t1_128x128x128.nii.gz'];
jakob_t1_240_meanrenorm_file = [jakob_dir, 'jakob_t1_240x240x155_meanrenorm.nii.gz'];
% Addiitonal atlases used for atlas-based segemntation and SIBIA
atlases_14brains = {'0093Y01',  '0097Y01',  '0002Y01',  '0390Y01',  '0094Y01',  '0099Y01',  '0386Y01','0392Y01',  '0098Y01',  '0095Y01',  '0100Y01',  '0004Y01',  '0102Y01',  '0096Y01'};
atlases_10brains = {'0010Y01', '0010Y02', '0014Y01', '0025Y02', '0028Y01', '0095Y01', '0100Y01', '0105Y01', '0144Y01', '0185Y01'};
atlases_20brains = {'0010Y01', '0010Y02', '0014Y01', '0025Y02', '0028Y01', '0095Y01', '0100Y01', '0105Y01', '0144Y01', '0185Y01', '0192Y01' , '0211Y01', '0212Y01', '0247Y01', '0267Y02', '0272Y02', '0331Y01', '0347Y01', '0387Y01', '0387Y02'};
atlases_3brains = {'0002Y01', '0004Y01','0093Y01'};

atlases = atlases_20brains;  % which atlases to use, which they should be defined in the directories below.
atlas20_dir = [brats,'/atlas_data/698_in_jakob_space/'];
atlas20_meanrenorm_dir = [brats, '/atlas_data/698_in_jakob_space_meanrenorm/'];
