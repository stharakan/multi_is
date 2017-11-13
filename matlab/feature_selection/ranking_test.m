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
params.rfeC = rfeC; % epsilon for svr, C for svm
params.useCBR = 1; % bias-correction
params.rfeG = 2^-4; % convergence criteria
params.rfeE = params.rfeC; % liblinear uses separate for svr-eps

% load ranking file
rfile = [scratch_dir,'fr.',init_str,'.',prob_type,'.C.',num2str(params.rfeC),...
    '.nn.',num2str(subset_size),'.mat'];

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

% load labels
fprintf('.');
fname = [scratch_dir,'gabor.ps.',num2str(psize), ...
  '.nn.',num2str(ntr),'.yy.trn.bin'];
fid = fopen(fname,'r');
Ytr = fread(fid,Inf,'*single');
Ytr = double(Ytr(:));
fclose(fid);

% load labels test
fprintf('.');
fname = [scratch_dir,'gabor.ps.',num2str(psize), ...
  '.nn.',num2str(nte),'.yy.tst.bin'];
fid = fopen(fname,'r');
Yte = fread(fid,Inf,'*single');
Yte = double(Yte(:));
fclose(fid);
fprintf('\n');


% Sort features
% sort and get indices
[~,feat_importances] = sort(ftRank);
mean_imp = mean(feat_importances,2);
[~ ,avgftRank ] = sort(mean_imp);

% initialize stuff that we're keeping track of
all_accs = zeros(2,4);
all_accs(:,1) = [0,1.0];
all_preds = zeros(nte,4);
all_preds(:,1) = double(Yte(:));

% run SVM for first 30 features
fprintf('Top 30 feats svm \n');
fprintf(' Extracting training for 30 feats \n');
ft_idx30 = avgftRank(1:30);
Gtr_sel = sparse(double(Gtr(:,ft_idx30) ) );

% svm model
fprintf(' Running model for 30 feats ..');
tic; model = train(Ytr,Gtr_sel,mdl_specs); tt = toc;
fprintf(' took %4.1f secs\n',tt);
clear Gtr_sel

% run prediction
fprintf(' Testing model for 30 feats \n\n');
Gte_sel = sparse(double(Gte(:,ft_idx30) ) );
[pred,acc,probs] = predict(Yte,Gte_sel,model);
clear Gte_sel
all_accs(:,2) = acc(:);
all_preds(:,2) = pred(:);

% run SVM for first 60 features
fprintf('Top 60 feats svm \n');
fprintf(' Extracting training for 60 feats \n');
ft_idx60 = avgftRank(1:60);
Gtr_sel = sparse(double(Gtr(:,ft_idx60) ) );

% svm model
fprintf(' Running model for 60 feats ..');
tic; model = train(Ytr,Gtr_sel,mdl_specs); tt = toc;
fprintf(' took %4.1f secs\n',tt);
clear Gtr_sel

% run prediction
fprintf(' Testing model for 60 feats \n\n');
Gte_sel = sparse(double(Gte(:,ft_idx60) ) );
[pred,acc,probs] = predict(Yte,Gte_sel,model);
clear Gte_sel
all_accs(:,3) = acc(:);
all_preds(:,3) = pred(:);

% run SVM for all features
fprintf('All feats svm \n');
fprintf(' Extracting training for all feats \n');
Gtr_sel = sparse(double(Gtr) );

% svm model
fprintf(' Running model for all feats ..');
tic; model = train(Ytr,Gtr_sel,mdl_specs); tt = toc;
fprintf(' took %4.1f secs\n',tt);
clear Gtr_sel

% run prediction
fprintf(' Testing model for all feats \n\n');
Gte_sel = sparse(double(Gte) );
[pred,acc,probs] = predict(Yte,Gte_sel,model);
clear Gte_sel
all_accs(:,4) = acc(:);
all_preds(:,4) = pred(:);







