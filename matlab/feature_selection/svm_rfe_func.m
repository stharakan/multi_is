function [] = svm_rfe_func(rfeC,rfeE)

if nargin == 1
  rfeE = rfeC;
end

% addpath, variables
addpath([getenv('MISDIR'),'/matlab/general/']);
SetPath;
SetVariablesTACC;
myload_nii = @(filename) load_untouch_nii(filename);
scratch_dir = [getenv('SCRATCH'),'/training_matrices/'];
ntr = 40000000;
tot_gabor_features = 240;
init_str = 'gaborstats';
tot_gabor_features = 120;
init_str = 'onlystats';
psize = 17;
subset_size = 1000000;
runs = 20;
tol = 1e-6;
  
fprintf('Setting kernel params ...\n');
prob_type = 'reg' % reg (SVR) or class (SVM)
params.kerType = 0; % linear kernel
params.rfeC = rfeC; % epsilon for svr, C for svm
params.useCBR = 1; % bias-correction
params.rfeG = 2^-4; % convergence criteria
params.rfeE = rfeE; % liblinear uses separate for svr-eps
params

% save training/testing features + labels
fprintf('Reading x ...\n');
fname = [scratch_dir,init_str,'.ps.',num2str(psize),'.nn.', ...
    num2str(ntr),'.dd.', num2str(tot_gabor_features), '.XX.trn.bin'];
fid = fopen(fname,'r');
Gtr_tot = fread(fid,Inf,'*single');
Gtr_tot = reshape(Gtr_tot,ntr,tot_gabor_features);
fclose(fid);

%fname = [scratch_dir,init_str,'.ps.',num2str(psize),'.nn.', ...
%  num2str(nte),'.dd.', num2str(tot_gabor_features), '.XX.tst.bin'];
%fid = fopen(fname,'w');
%fwrite(fid,Gte,'single');
%fclose(fid);

fprintf('Reading y ...\n');
fname = [scratch_dir,'gabor.ps.',num2str(psize), ...
    '.nn.',num2str(ntr),'.yy.trn.bin'];
fid = fopen(fname,'r');
Ytr_tot = fread(fid,Inf,'*single');
y0 = sum(round(Ytr_tot) == 0);
y1 = sum(round(Ytr_tot) == 1);
ymax = max(Ytr_tot);
ymin = min(Ytr_tot);
fprintf('Y 0s: %d\nY 1s: %d\nY min: %3.2f\nYmax: %3.2f\n',y0,y1,ymin,ymax);
fclose(fid);

%fname = [scratch_dir,'gabor.ps.',num2str(psize), ...
%  '.nn.',num2str(nte),'.yy.tst.bin'];
%fid = fopen(fname,'w');
%fwrite(fid,Yte,'single');
%fclose(fid);

fprintf('Whitening data ...\n');
usable_idx = Ytr_tot > tol & Ytr_tot < (1-tol);
ntr = sum(usable_idx)
Gtr_tot = Gtr_tot(usable_idx,:);
Ytr_tot = Ytr_tot(usable_idx);
[Gtr_tot,means,stds] = whiten(Gtr_tot);
Ytr_tot = logit(Ytr_tot);


% loop over # runs?
for ri = 1:runs
  fprintf('Run %d\n',ri);
  fprintf('Getting random subset ...\n');
  rng('shuffle');
  ridx = randperm(ntr,subset_size);
  Gtr = double(Gtr_tot(ridx,:));
  Ytr = double(Ytr_tot(ridx));
  Ytr = Ytr(:);
  
  % need this for liblinear..
  %Ytr = sparse(Ytr);
  Gtr = sparse(Gtr);

  fprintf('Running SVM RFE ...\n');
  tic;
  if strcmp(prob_type,'class')
    Ytr = round(Ytr);
    Ytr(Ytr == 0) = -1;
    [ftRank,ftScore] = ftSel_SVMRFECBR_lin_cla(Gtr,Ytr,params);
  elseif strcmp(prob_type,'reg')
    [ftRank,ftScore] = ftSel_SVMRFECBR_lin(Gtr,Ytr,params);
  end

  rfe_time = toc;
  fprintf('SVM RFE took %d\n',rfe_time);
  
  ftRank = ftRank(:);
  
  fname = [scratch_dir,'fr.',init_str,'.ps.',num2str(psize),'.',prob_type,'.C.',num2str(params.rfeC),...
    '.e.',num2str(params.rfeE),'.nn.',num2str(subset_size),'.mat'];
  if ~exist(fname,'file')
    % if the file does not exist
    ftScores{1} = ftScore;
    save(fname,'ftRank','ftScores');
  else
    % file does exist -- add to it
    ff = load(fname);
    ftRank = [ff.ftRank,ftRank];
    ftScores = ff.ftScores;
    ftScores{ end + 1 } = ftScore;
    save(fname,'ftRank','ftScores');
  end

end  
end
