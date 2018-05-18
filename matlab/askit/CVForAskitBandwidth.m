function [bw] = CVForAskitBandwidth(bdir,outdir,fkeep,stype,psize,ftype,pstr,ppb,target,kk,kcut)

% initialize loop stuff
if isempty(outdir)
  outdir = [getenv('PRDIRSCRATCH'),'/'];
end
if isempty(bdir)
  bdir = [getenv('BRATSDIR'),'/preprocessed/trainingdata/meanrenorm/'];
end
if isempty(stype)
  stype = 'reg01';
end
ntrn = 208; ntst = 52;

% initialize ps
if strcmp(pstr,'edemadist')
  ps = PointSelector(pstr,ppb,psize);
else
  ps = PointSelector(pstr,ppb);
end
fprintf('Point selector: %s\n',ps.PrintString());

% load lists
disp('Loading train and lists..\n');
trn = BrainPointList.LoadList(outdir,ps,ntrn);
trn.PrintListInfo();

% load training
filebase = trn.MakeFeatureDataString(ftype,psize);
data_file = [outdir,'knntrn.dd.',num2str(fkeep),'.',filebase];
fid = fopen(data_file,'r');
Gmat = fread(fid,Inf,'double');
Gmat = reshape(Gmat, fkeep, [])';
[nn,dd] = size(Gmat);
fclose(fid);

% find median of 100 random points
med_dist = FindMedianDistance(Gmat); 
fprintf('Median computed distance: %3.3f\n',med_dist);
all_bws = FindBwsFromMedian(med_dist);

% truncate (won't rewrite if already there
fprintf('Finishing truncation training..\n')
nnfile = [outdir,'nntrnlist.dd.',num2str(fkeep),'.',filebase(1:(end-3)),'kk.',num2str(kk),'.bin'];
knn_file = [outdir,'nntrnlist.dd.',num2str(fkeep),'.',filebase(1:(end-3)),'kk.',num2str(kcut),'.bin'];
TruncateKNNFile(nnfile,knn_file,kcut,trn.tot_points);

% Load answers (y file), save fname for later
fprintf('Loading ppvec and potential files..\n');
pfile = trn.MakePPvecFile(psize,target);
pfile = [outdir,pfile];
fid = fopen([pfile],'r');
ytr = fread(fid,Inf,'double'); ytr = ytr(:);
fclose(fid);

% initialize 0s
ntr = size(ytr,1);
Yg = zeros(ntr,length(all_bws));
Avg_dices = zeros(ntr,1);
  
% Get indices
low_idx = ytr < 0.33; num_lo = sum(low_idx);
hig_idx = ytr > 0.66; num_hi = sum(hig_idx);
mid_idx = ytr >= 0.33 & ytr <= 0.66; num_mid = sum(mid_idx);
  

% bw loop
for bi = 1:length(all_bws)
  bw = all_bws(bi);
  fprintf(' running bw %4.3f\n', bw);

  % Generate file names
  chargesyy = pfile;
  charges1s = 'ones';
  [file1s,fileyy] = GeneratePotentialFiles(pfile,ftype,bw);
  

  % Call Askit runner
  fprintf(' calling ASKIT from system ..\n');
  [p1] = AskitMatlabRunner(data_file,knn_file,charges1s,nn,dd,kcut,bw,file1s); 
  [py] = AskitMatlabRunner(data_file,knn_file,chargesyy,nn,dd,kcut,bw,fileyy);

  % Get guess
  yg = (py - ytr)./(p1 - 1);
  yg = min(max(yg,0),1);
  Yg(:,bi) = yg;

  % confusion/dice
  cmat = confusion_regression(ytr,yg,3);
  dices = diag(cmat)./( sum(cmat,1)' + sum(cmat,2) - diag(cmat));
  Avg_dices(bi,:) = dices(:)';
  
  % print errors
  diff = abs(bsxfun(@minus,yg,ytr));
  cur_errs = @(idx) sqrt(sum(diff(idx).^2,1 ))./norm(ytr(idx));
  cur_avg_abs_errs =@(idx) mean( diff(idx),1 );
  
  T = table({'Low';'Mid';'High'}, [num_lo;num_mid;num_hi], ...
  	[cur_errs(low_idx);cur_errs(mid_idx);cur_errs(hig_idx)],...
  	[cur_avg_abs_errs(low_idx);cur_avg_abs_errs(mid_idx);cur_avg_abs_errs(hig_idx)], ...
  	dices(:));
  T.Properties.VariableNames = {'Class','Quantity','E_rel','E_avg','Dice'};
  T

end

% print final error
[final_dice,final_ind] = max(mean(Avg_dices,2));
bw = all_bws(final_ind);

disp('');
fprintf('FINAL AVERAGE DICE: %f\nFINAL CHOSEN BW: %f\n',final_dice,bw);
disp('');

% save errors, bw's to matlab data file 
%suffix = ['.mat'];
%potfile = strrep(pfile,'bin',suffix);
%matfile = strrep(potfile,'ppv',['cvbw']);
%save(matfile,'Avg_dices','bw','all_bws');

end
