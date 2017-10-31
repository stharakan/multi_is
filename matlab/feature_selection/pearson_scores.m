% addpath, variables
addpath([getenv('MISDIR'),'/matlab/general/']);
SetPath;
SetVariablesTACC;
myload_nii = @(filename) load_untouch_nii(filename);

% params
scratch_dir = [getenv('SCRATCH'),'/training_matrices/'];
nangs = 8;
tot_gabor_features = 160;
num_filters = tot_gabor_features/nangs;
tot_features = num_filters * (nangs + 4);
%patch_sizes = 33;
psize = 33;
ntr = 40000000;
nte = 9000000;

% index file/ brain lists
idxstr = 'BRATS_50M_Meta';
idxfile_loc = [training_model_dir,idxstr,'.idxs.mat'];
fprintf('Loading indices from %s\n',idxfile_loc);
idxfile = load(idxfile_loc);

% load training/testing features + labels
fname = [scratch_dir,'gaborstats.ps.',num2str(psize),'.nn.', ...
  num2str(ntr),'.dd.', num2str(tot_features), '.XX.trn.bin'];
fid = fopen(fname,'r');
Gtr = fread(fid,Inf,'*single');
size(Gtr)
Gtr = reshape(Gtr,ntr,tot_features);
fclose(fid);

% load testing
fname = [scratch_dir,'gaborstats.ps.',num2str(psize),'.nn.', ...
  num2str(nte),'.dd.', num2str(tot_features), '.XX.tst.bin'];
fid = fopen(fname,'r');
Gte = fread(fid,Inf,'*single');
Gte = reshape(Gte,nte,tot_features);
fclose(fid);

% load labels
fname = [scratch_dir,'gabor.ps.',num2str(psize), ...
  '.nn.',num2str(ntr),'.yy.trn.bin'];
fid = fopen(fname,'r');
Ytr = fread(fid,Inf,'*single');
Ytr = Ytr(:);
fclose(fid);

% load labels test
fname = [scratch_dir,'gabor.ps.',num2str(psize), ...
  '.nn.',num2str(nte),'.yy.tst.bin'];
fid = fopen(fname,'r');
Yte = fread(fid,Inf,'*single');
Yte = Yte(:);
fclose(fid);

% process p-scores
trn_pscores = corr(Gtr, Ytr) 
tst_pscores = corr(Gte, Yte) 


 save('./pearson_scores_wstats_50M.mat','trn_pscores','tst_pscores');
