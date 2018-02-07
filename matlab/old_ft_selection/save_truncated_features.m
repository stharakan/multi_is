% addpath, variables
addpath([getenv('MISDIR'),'/matlab/general/']);
SetPath;
SetVariablesTACC;

% params
scratch_dir = [getenv('SCRATCH'),'/training_matrices/'];
tot_gabor_features = 120;
psize = 33;
subset_size = 1e6;
ntr = 40000000;
nte = 9000000;
init_str = 'onlystats';
prob_type = 'reg';
params.kerType = 0; % linear kernel
params.rfeC = 100; % epsilon for svr, C for svm
params.useCBR = 1; % bias-correction
params.rfeG = 2^-4; % convergence criteria
params.rfeE = 0.1; % liblinear uses separate for svr-eps
params
tol = 0
kk = 30

% load ranking file
rfile = [scratch_dir,'fr.',init_str,'.',prob_type,'.C.',num2str(params.rfeC),...
    '.e.',num2str(params.rfeE),'.nn.',num2str(subset_size),'.mat'];
mdl_specs = sprintf('-s 11 -c %f -e %f -p %f -q',params.rfeC,params.rfeG,params.rfeE);

% load scores, initialize cells
load(rfile);
mod_cell = {'FLAIR','T1','T1CE','T2'};
ang_cell = {};
stat_cell = {'avg','max','med','std','l2','l1'};
bw_cell = {'2','4','8','16','32'};

% compute all other quantities from cell arrays
modalities = length(mod_cell);
angles = length(ang_cell);
bws = length(bw_cell);
stat_features_per_filter = length(stat_cell);
features_per_filter = stat_features_per_filter + angles;
tot_feats = size(ftRank,1);
feats_per_modality = tot_feats/modalities;
filters_per_modality = feats_per_modality/(features_per_filter);
tot_filters = tot_feats/features_per_filter;

% load training/testing features + labels
fprintf('Loading testing/training ');
fname = [scratch_dir,init_str,'.ps.',num2str(psize),'.nn.', ...
  num2str(ntr),'.dd.', num2str(tot_gabor_features), '.XX.trn.bin'];
fid = fopen(fname,'r');
Gtr = fread(fid,Inf,'*single');
Gtr = reshape(Gtr,ntr,tot_gabor_features);
fclose(fid);

% load testing
fprintf('.');
fname = [scratch_dir,init_str,'.ps.',num2str(psize),'.nn.', ...
  num2str(nte),'.dd.', num2str(tot_gabor_features), '.XX.tst.bin'];
fid = fopen(fname,'r');
Gte = fread(fid,Inf,'*single');
Gte = reshape(Gte,nte,tot_gabor_features);
fclose(fid);

% Sort features
% sort and get indices
[~,feat_importances] = sort(ftRank);
mean_imp = mean(feat_importances,2);
[~ ,avgftRank ] = sort(mean_imp);

% Extract first 30 features + save
fprintf(' Extracting training for 30 feats \n');
ft_idxkk = avgftRank(1:kk);
Gtr_sel = double(Gtr(:,ft_idxkk) ) ;

fname = [scratch_dir,init_str,'.ps.',num2str(psize),'.nn.', ...
  num2str(ntr),'.dd.', num2str(kk), '.XX.trn.bin'];
fid = fopen(fname,'w');
fwrite(fid,Gtr_sel,'double');
fclose(fid);
clear Gtr_sel

% same for testing
fprintf(' Extracting testing for 30 feats \n');
Gte_sel = double(Gte(:,ft_idxkk) ) ;
fname = [scratch_dir,init_str,'.ps.',num2str(psize),'.nn.', ...
  num2str(nte),'.dd.', num2str(kk), '.XX.tst.bin'];
fid = fopen(fname,'w');
fwrite(fid,Gte_sel,'double');
fclose(fid);
clear Gtr_sel


