% addpath, variables
addpath([getenv('MISDIR'),'/matlab/general/']);
SetPath;
SetVariablesTACC;
myload_nii = @(filename) load_untouch_nii(filename);
scratch_dir = [getenv('SCRATCH'),'/training_matrices/'];
ntr = 40000000;
tot_gabor_features = 240;
psize = 33;

% save training/testing features + labels
fname = [scratch_dir,'gaborstats.ps.',num2str(psize),'.nn.', ...
    num2str(ntr),'.dd.', num2str(tot_gabor_features), '.XX.trn.bin'];
fid = fopen(fname,'r');
Gtr = fread(fid,Inf,'single');
fclose(fid);

%fname = [scratch_dir,'gabor.ps.',num2str(psize),'.nn.', ...
%  num2str(nte),'.dd.', num2str(tot_gabor_features), '.XX.tst.bin'];
%fid = fopen(fname,'w');
%fwrite(fid,Gte,'single');
%fclose(fid);

fname = [scratch_dir,'gaborstats.ps.',num2str(psize), ...
    '.nn.',num2str(ntr),'.yy.trn.bin'];
fid = fopen(fname,'r');
Ytr = fread(fid,Inf,'single');
fclose(fid);

%fname = [scratch_dir,'gabor.ps.',num2str(psize), ...
%  '.nn.',num2str(nte),'.yy.tst.bin'];
%fid = fopen(fname,'w');
%fwrite(fid,Yte,'single');
%fclose(fid);

fprintf('Whitening data ...\n');
means_Gtr = mean(Gtr,2);
Gtr = bsxfun(@minus,Gtr,means_Gtr);
stds = std(Gtr,0,2);
Gtr = bsxfun(@rdivide,Gtr,stds);

fprintf('Running SVM RFE ...\n');
ftSel_SVMRFECBR(Gtr,round(Ytr));
