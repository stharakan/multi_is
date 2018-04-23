function [] = PostprocessForASKIT(outdir,psize,ftype,pstr,ppb,target)

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

% load ytr
fprintf('Loading ppvec and potential files..\n');
pfile = trn.MakePPvecFile(psize,target);
fid = fopen([outdir,pfile],'r');
ytr = fread(fid,Inf,'double'); ytr = ytr(:);
fclose(fid);

% initialize file names
potfile = strrep(pfile,'bin','pot');
file1s = strrep(potfile,'ppv',['trn.',ftype,'.1s']);
fileyy = strrep(potfile,'ppv',['trn.',ftype,'.yy']);

% load 1s
fid = fopen([outdir,file1s],'r');
p1 = fread(fid,Inf,'double'); p1 = p1(:);
fclose(fid);

% load ys
fid = fopen([outdir,fileyy],'r');
py = fread(fid,Inf,'double'); py = py(:);
fclose(fid);

% make yg
fprintf('Computing guess ..\n');
yg = (py - ytr)./(p1 - 1);
yg = min(max(yg,0),1);

% Print stats
low_idx = ytr < 0.33; num_lo = sum(low_idx);
hig_idx = ytr > 0.66; num_hi = sum(hig_idx);
mid_idx = ytr >= 0.33 & ytr <= 0.66; num_mid = sum(mid_idx);
ntr = length(ytr);
lows_trn = sum(low_idx)/ntr;
his_trn = sum(hig_idx)/ntr;
mids_trn = sum(mid_idx)/ntr;
lows = sum(yg < 0.33)/ntr;
his = sum(yg > 0.66)/ntr;
mids = sum(yg > 0.33 & yg < 0.66)/ntr;
fprintf(' Hi perc (Tru/Gue): %3.2f %3.2f\n Lo perc (Tru/Gue): %3.2f %3.2f\n Mid perc (Tru/Gue): %3.2f %3.2f\n',...
	his_trn,his,lows_trn,lows,mids_trn,mids);

cmat = confusion_regression(ytr,yg,3)
dices = diag(cmat)./( sum(cmat,1)' + sum(cmat,2) - diag(cmat));

% print errors
diff = abs(bsxfun(@minus,yg,ytr));
cur_errs = @(idx) sqrt(sum(diff(idx).^2,1 ))./norm(ytr(idx));
cur_avg_abs_errs =@(idx) mean( diff(idx),1 );
%fprintf('\n   Class | Erel | Eavg \n'); 
%fprintf([' Low | %3.2f | %3.2f\n',...
%       	' Mid | %3.2f | %3.2f\n',...
%	' Hi | %3.2f | %3.2f\n'],...
%	cur_errs(low_idx),cur_avg_abs_errs(low_idx),
%	cur_errs(mid_idx),cur_avg_abs_errs(mid_idx),
%	cur_errs(hig_idx),cur_avg_abs_errs(hig_idx));

T = table({'Low';'Mid';'High'}, [num_lo;num_mid;num_hi], ...
	[cur_errs(low_idx);cur_errs(mid_idx);cur_errs(hig_idx)],...
	[cur_avg_abs_errs(low_idx);cur_avg_abs_errs(mid_idx);cur_avg_abs_errs(hig_idx)], ...
	dices(:));
T.Properties.VariableNames = {'Class','Quantity','E_rel','E_avg','Dice'};
T

end

