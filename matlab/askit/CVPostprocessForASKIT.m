function [] = CVPostprocessForASKIT(outdir,psize,ftype,pstr,ppb,target)

% initialize loop stuff
if isempty(outdir)
  outdir = [getenv('PRDIRSCRATCH'),'/'];
end
ntrn = 208; ntst = 52;

% initialize ps
if strcmp(pstr,'edemadist')
  ps = PointSelector(pstr,ppb,psize);
else
  ps = PointSelector(pstr,ppb);
end
fprintf('Point selector: %s\n',ps.PrintString());
fprintf('Feature type: %s\n',ftype);

% load lists
fprintf('Loading train list..\n');
trn = BrainPointList.LoadList(outdir,ps,ntrn);
trn.PrintListInfo();

%ppvfile=$(ls ${OUTDIR}/ppv*${PSSTR}*${PSP1}*.${PSIZE}.*208.*${TARGET}*)
%potfile=${ppvfile%.bin}.pot
%yyfile=${potfile/ppv/trn.${FTYPE}.yy};
%onesfile=${potfile/ppv/trn.${FTYPE}.1s};

% load ytr
fprintf('Loading ppvec and potential files..\n');
pfile = trn.MakePPvecFile(psize,target);
fid = fopen([outdir,pfile],'r');
ytr = fread(fid,Inf,'double'); ytr = ytr(:);
fclose(fid);

% Load bandwidths
bwfile = strrep([outdir,pfile],'bin',['mat']);
bwfile = strrep(bwfile,'ppv',['cvbws.',ftype]);
bwstruct = load(bwfile);
all_bws = bwstruct.all_bws;
num_bws = length(all_bws);

% initialize base files
potfile = strrep(pfile,'bin','pot');
base_file1s = strrep(potfile,'ppv',['trn.',ftype,'.1s']);
base_fileyy = strrep(potfile,'ppv',['trn.',ftype,'.yy']);

% initialize error holders
avg_dice = zeros(num_bws,1);
all_yg = zeros(length(ytr),num_bws);

% Loop over bandwidths
for bi = 1:num_bws
  bw = all_bws(bi);
  bw_str = ['trn.h.',num2str(bw)];
  fprintf(' Processing bandwidth %.2f\n',bw);
  
  % load 1s
  file1s = strrep(base_file1s,'trn',bw_str);
  fid = fopen([outdir,file1s],'r');
  p1 = fread(fid,Inf,'double'); p1 = p1(:);
  fclose(fid);
  
  % load ys
  fileyy = strrep(base_fileyy,'trn',bw_str);
  fid = fopen([outdir,fileyy],'r');
  py = fread(fid,Inf,'double'); py = py(:);
  fclose(fid);
  
  % make yg
  fprintf(' computing guess ..\n');
  yg = (py - ytr)./(p1 - 1);
  yg = min(max(yg,0),1);
  
  % Get indices
  low_idx = ytr < 0.33; num_lo = sum(low_idx);
  hig_idx = ytr > 0.66; num_hi = sum(hig_idx);
  mid_idx = ytr >= 0.33 & ytr <= 0.66; num_mid = sum(mid_idx);
  
  % error computing
  diff = abs(bsxfun(@minus,yg,ytr));
  cur_errs = @(idx) sqrt(sum(diff(idx).^2,1 ))./norm(ytr(idx));
  cur_avg_abs_errs =@(idx) mean( diff(idx),1 );
  cmat = confusion_regression(ytr,yg,3)
  dices = diag(cmat)./( sum(cmat,1)' + sum(cmat,2) - diag(cmat));
  
  % print errors
  T = table({'Low';'Mid';'High'}, [num_lo;num_mid;num_hi], ...
  	[cur_errs(low_idx);cur_errs(mid_idx);cur_errs(hig_idx)],...
  	[cur_avg_abs_errs(low_idx);cur_avg_abs_errs(mid_idx);cur_avg_abs_errs(hig_idx)], ...
  	dices(:));
  T.Properties.VariableNames = {'Class','Quantity','E_rel','E_avg','Dice'};
  T
  avg_dices(bi) = mean(dices);
  all_yg(:,bi) = yg(:);
  
end

[max_dice,max_ind] = max(avg_dices);
bw = all_bws(max_ind);
disp('------------------------')
T = table(all_bws(:),avg_dices(:)); 
T.Properties.VariableNames = {'Bw','AvgDice'};
T
fprintf('Max dice: %.2f\nBest bw: %.2f\n',max_dice,bw);

save(bwfile,'bw','max_dice','avg_dices','all_yg','-append');

end

