% addpath, variables
addpath([getenv('MISDIR'),'/matlab/general/']);
SetPath;
SetVariablesTACC;
myload_nii = @(filename) load_untouch_nii(filename);

% params
scratch_dir = [getenv('SCRATCH'),'/training_matrices/'];
scratch_dir = [getenv('PRDIR'),'/']; 
tot_gabor_features = 128;
num_stats = 6;
nangs = 8;
num_filters = tot_gabor_features/nangs;
psize = 9;
ntr = 40000000;
nte = 9000000;

% index file/ brain lists
%idxstr = 'BRATS_50M_Meta';
%idxfile_loc = [training_model_dir,idxstr,'.idxs.mat'];
%fprintf('Loading indices from %s\n',idxfile_loc);
%idxfile = load(idxfile_loc);

% load training/testing features + labels
fprintf('Loading testing/training \n');
fname = [scratch_dir,'gabor.ps.',num2str(psize),'.nn.', ...
  num2str(ntr),'.dd.', num2str(tot_gabor_features), '.XX.trn.bin'];
fid = fopen(fname,'r');
Gtr = fread(fid,Inf,'*single');
Gtr = reshape(Gtr,ntr,tot_gabor_features);
fclose(fid);

% load testing
fname = [scratch_dir,'gabor.ps.',num2str(psize),'.nn.', ...
  num2str(nte),'.dd.', num2str(tot_gabor_features), '.XX.tst.bin'];
fid = fopen(fname,'r');
Gte = fread(fid,Inf,'*single');
Gte = reshape(Gte,nte,tot_gabor_features);
fclose(fid);

%% load labels
%fname = [scratch_dir,'gabor.ps.',num2str(psize), ...
%  '.nn.',num2str(ntr),'.yy.trn.bin'];
%fid = fopen(fname,'r');
%Ytr = fread(fid,Inf,'*single');
%Ytr = Ytr(:);
%fclose(fid);
%
%% load labels test
%fname = [scratch_dir,'gabor.ps.',num2str(psize), ...
%  '.nn.',num2str(nte),'.yy.tst.bin'];
%fid = fopen(fname,'r');
%Yte = fread(fid,Inf,'*single');
%Yte = Yte(:);
%fclose(fid);


% add statistics to gabor matrices
fprintf('Looping over filters\n');
base_idx = 1:nangs;
Gout_trn = zeros(ntr,num_filters*(num_stats) ,'single');
Gout_tst = zeros(nte,num_filters*(num_stats) ,'single');
for fi = 1:num_filters
feat_idx = base_idx + (fi - 1)*nangs;

% compute stats trn
trn_upd = ComputeStats(Gtr(:,feat_idx) );

% compute stats tst
tst_upd = ComputeStats(Gte(:,feat_idx) );

upd_idx = (1:(num_stats)) + (fi - 1)*(num_stats); 
Gout_trn(:,upd_idx) = trn_upd;
Gout_tst(:,upd_idx) = tst_upd;

end

% save gout trn/tst
fprintf('Saving file\n');
fname = [scratch_dir,'onlystats.ps.',num2str(psize),'.nn.', ...
  num2str(ntr),'.dd.', num2str(num_stats*num_filters), '.XX.trn.bin'];
fid = fopen(fname,'w');
fwrite(fid,Gout_trn,'single');
fclose(fid);

fname = [scratch_dir,'onlystats.ps.',num2str(psize),'.nn.', ...
  num2str(nte),'.dd.', num2str(num_stats*num_filters), '.XX.tst.bin'];
fid = fopen(fname,'w');
fwrite(fid,Gout_tst,'single');
fclose(fid);
