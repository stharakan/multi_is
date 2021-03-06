% addpath, variables
addpath([getenv('BRATSREPO'),'/matlab/general/']);
SetPath;
SetVariablesTACC;
myload_nii = @(filename) load_untouch_nii(filename);

% params
sfbs = [0.7,1.0,2.5];nsfbs = length(sfbs);
nangs = 8; nfreqs = 3; naf = nangs*nfreqs;
modalities = 4;
scratch_dir = [getenv('PRDIR'),'/'];
tot_gabor_features = 128;
patch_sizes = 9; 
tot_gabor_features = 16;
patch_sizes = 5;
trn_perc = 0.8;
use_new_idx=false;
feature_type = 'window';

% index file/ brain lists
idxstr = 'BRATS_50M_Meta';
idxfile_loc = [training_model_dir,idxstr,'.idxs.mat'];
fprintf('Loading indices from %s\n',idxfile_loc);
idxfile = load(idxfile_loc);
lggs = length(idxfile.lggcell);
hggs = length(idxfile.hggcell);
brn_dir = [brats,'/preprocessed/trainingdata/meanrenorm/'];
brncell = GetBrnList(brn_dir);
ntot = sum(cellfun('length',[idxfile.ridxc_lgg(:);idxfile.ridxc_hgg(:)]));


if use_new_idx
% split lists here (if not done)
fprintf('Split not done, computing now..\n');
idxfile.ridxc_hgg{1} = [];
trn_lgg_brn_ind = randperm(lggs, round(lggs*trn_perc));
trn_hgg_brn_ind = randperm(hggs, round(hggs*trn_perc));
ntot = sum(cellfun('length',[idxfile.ridxc_lgg(:);idxfile.ridxc_hgg(:)]));
ntr = sum(cellfun('length',[idxfile.ridxc_lgg(trn_lgg_brn_ind(:))';idxfile.ridxc_hgg(trn_hgg_brn_ind(:))']));
nte = ntot - ntr;

% resave into idxfile, train_test + ntr + nte
save(idxfile_loc,'trn_lgg_brn_ind','trn_hgg_brn_ind','ntr','nte','-append');
fprintf('Training split contains %3.2f percent of total\n',ntr/ntot); 
fprintf('Training: %d\nTesting: %d\nTotal: %d\n',ntr,nte,ntot);
Gtr_tot = zeros(ntr,nangs*modalities,nsfbs,'single');
Gte_tot = zeros(nte,nangs*modalities,nsfbs,'single');
train_idx_50M = []; test_idx_50M = [];
counter = 0;

% create index for training w/in 50m, loop over brains
for ii = 1:(lggs+ hggs)
  % get ridx -> gives extraction index
  if ii <= lggs
    cell_no = ii;
    ridx = idxfile.ridxc_lgg{ii};
    brain = idxfile.lggcell{ii};
    brn_type = 'LGG';
    trn_flag = ismember(cell_no,trn_lgg_brn_ind);
  else
    cell_no = ii - lggs;
    ridx = idxfile.ridxc_hgg{cell_no};
    brain = idxfile.hggcell{cell_no};
    trn_flag = ismember(cell_no,trn_hgg_brn_ind);
    brn_type = 'HGG';
  end

  rr = length(ridx);
  if rr == 0
    continue
  end
    
  if strcmp(brain, 'Brats17_2013_10_1')
    continue
  end
  % determine if training or testing, append to appropriate index vector
  cur_idx = (counter + 1):(counter + rr); 
  if trn_flag
    train_idx_50M = [train_idx_50M;cur_idx(:)];
  else
    test_idx_50M = [test_idx_50M;cur_idx(:)];
  end

  % end loop
  counter = counter + rr;
end

% reset to 40M and 9M for training/testing
ntr = length(train_idx_50M);
nte = length(test_idx_50M);
bla = randperm(ntr,40000000);
train_idx_50M = train_idx_50M(bla);
bla = randperm(nte,9000000);
test_idx_50M = test_idx_50M(bla);
ntr = length(train_idx_50M);
nte = length(test_idx_50M);

fprintf('Changed training size: %d\n',ntr);
fprintf('Changed testing size: %d\n',nte);

save([scratch_dir,'trte_splits.mat'],'train_idx_50M','test_idx_50M');
else
load([scratch_dir,'trte_splits.mat']);
ntr = length(train_idx_50M);
nte = length(test_idx_50M);
end

fprintf('Test/train indices created\n');
% loop over patch sizes
for pp = 1:length(patch_sizes)
  psize = patch_sizes(pp);
  ss = pp;

  % load current patch size features/labels
  fname = [scratch_dir,feature_type,'.ps.',num2str(psize), ...
    '.nn.',num2str(ntot),'.dd.', num2str(tot_gabor_features), '.XX.bin'];
  fid = fopen(fname);
  Gcur = fread(fid,Inf,'*single');
  Gcur = reshape(Gcur, [], tot_gabor_features);
  fclose(fid);

  fname = [scratch_dir,feature_type,'.ps.',num2str(psize), ...
    '.yy.bin'];
  fid = fopen(fname);
  Ycur = fread(fid,Inf,'*single');
  fclose(fid);
  
  yysize = size(Ycur);
  ggsize = size(Gcur);

  % split into training/ test 
  Gtr = Gcur(train_idx_50M,:);
  Gte = Gcur(test_idx_50M,:);
  Ytr = Ycur(train_idx_50M); 
  Yte = Ycur(test_idx_50M); 
%size(Gtr)

  % save training/testing features + labels
  fname = [scratch_dir,feature_type,'.ps.',num2str(psize),'.nn.', ...
    num2str(ntr),'.dd.', num2str(tot_gabor_features), '.XX.trn.bin'];
  fid = fopen(fname,'w');
  fwrite(fid,Gtr,'single');
  fclose(fid);

  fname = [scratch_dir,feature_type,'.ps.',num2str(psize),'.nn.', ...
    num2str(nte),'.dd.', num2str(tot_gabor_features), '.XX.tst.bin'];
  fid = fopen(fname,'w');
  fwrite(fid,Gte,'single');
  fclose(fid);

  fname = [scratch_dir,feature_type,'.ps.',num2str(psize), ...
    '.nn.',num2str(ntr),'.yy.trn.bin'];
  fid = fopen(fname,'w');
  fwrite(fid,single(Ytr),'single');
  fclose(fid);
  
  fname = [scratch_dir,feature_type,'.ps.',num2str(psize), ...
    '.nn.',num2str(nte),'.yy.tst.bin'];
  fid = fopen(fname,'w');
  fwrite(fid,single(Yte),'single');
  fclose(fid);

  % end patch loop
  %Gtr_tot(:,:,pp) = Gtr;
  %Gte_tot(:,:,pp) = Gte;
end


% save big mat
if 0
Gtr_tot = reshape(Gtr_tot, ntr, nangs*modalities*nsfbs);
Gte_tot = reshape(Gte_tot, nte, nangs*modalities*nsfbs);


fname = [scratch_dir,'gabor50M.wv.4.sfb.ALL.dd.',...
   num2str(nangs *modalities*nsfbs), '.XX.trn.bin'];
fid = fopen(fname,'w');
fwrite(fid,Gtr_tot,'single');
fclose(fid);

fname = [scratch_dir,'gabor50M.wv.4.sfb.ALL.dd.',...
   num2str(nangs *modalities*nsfbs), '.XX.tst.bin'];
fid = fopen(fname,'w');
fwrite(fid,Gte_tot,'single');
fclose(fid);


fname = [scratch_dir,'gabor50M.wv.4.sfb.ALL', ...
  '.yy.bin'];
fid = fopen(fname,'r');
Ytot = fread(fid,Inf,'*single');
fclose(fid);

Ytr = Ytot(train_idx_50M); 
Yte = Ytot(test_idx_50M); 

fname = [scratch_dir,'gabor50M.wv.4.sfb.ALL',...
  '.yy.trn.bin'];
fid = fopen(fname,'w');
fwrite(fid,Ytr,'single');
fclose(fid);

fname = [scratch_dir,'gabor50M.wv.4.sfb.ALL', ...
  '.yy.tst.bin'];
fid = fopen(fname,'w');
fwrite(fid,Yte,'single');
fclose(fid);
end
