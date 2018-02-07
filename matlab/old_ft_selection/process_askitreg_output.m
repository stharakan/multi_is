% load stuff
addpath([getenv('MISDIR'),'/matlab/general/']);
SetPath;
SetVariablesTACC;

% set variables 
%psize = 33; 
psize = 33; 
bw = 0.79;
%psize = 17; 
%psize = 9; 
%psize = 5;

% other vars 
prdir = [getenv('PRDIR'),'/'];
askitdir = [getenv('PRDIR'),'/askitfiles/'];
prscratch = [getenv('PRDIRSCRATCH'),'/'];
askitscratch = [getenv('PRDIRSCRATCH'),'/askitfiles/'];
init_str = 'onlystats';
ntr = 40000000;
nte = 9000000;

% load ytrn
yfile = [prdir,init_str,'.ps.',num2str(psize),'.nn.', ...
    num2str(ntr),'.yy.trn.bin2'];
fprintf('Loading ytr file from %s ..\n',yfile);
fid = fopen(yfile,'r');
ytr = fread(fid,Inf,'double');
ytr = ytr(:);
fclose(fid);
fprintf('Ytr size is %d\n',length(ytr));


% load ones
sfile = [askitdir, 'trn.ones.p.',num2str(psize),'.h.',num2str(bw),'.pot']; ...
fprintf(' getting ones from %s ..\n',sfile);
fid2 = fopen(sfile,'r');
p1 = fread(fid2,Inf,'double');
fclose(fid2);
p1 = p1(:);

% load yy
sfile = [askitdir, 'trn.yy.p.',num2str(psize),'.h.',num2str(bw),'.pot']; ...
fprintf(' getting yys from %s ..\n',sfile);
fid2 = fopen(sfile,'r');
py = fread(fid2,Inf,'double');
fclose(fid2);
py = py(:);

% make yg
yg = (py - ytr)./(p1 - 1);
yg = min(max(yg,0),1);

% Print stats
maxy = max(yg);
miny = min(yg);
fprintf(' Max val: %3.2f\n Min val: %3.2f\n',maxy,miny);
lows_trn = sum(ytr < 0.2)/ntr;
his_trn = sum(ytr > 0.8)/ntr;
mids_trn = sum(ytr > 0.4 & ytr < 0.6)/ntr;
lows = sum(yg < 0.2)/ntr;
his = sum(yg > 0.8)/ntr;
mids = sum(yg > 0.4 & yg < 0.6)/ntr;
fprintf(' Hi perc (Tru/Gue): %3.2f %3.2f\n Lo perc (Tru/Gue): %3.2f %3.2f\n Mid perc (Tru/Gue): %3.2f %3.2f\n',...
	his_trn,his,lows_trn,lows,mids_trn,mids);

cmat = confusion_regression(ytr,yg,3)

% print errors
diff = abs(bsxfun(@minus,yg,ytr));
cur_errs = sqrt(sum(diff.^2,1 ))./norm(ytr);
cur_avg_abs_errs = mean( diff,1 );
fprintf('\n   Bw | Erel | Eavg \n'); 
fprintf(' %3.2f | %3.2f | %3.2f\n', bw,...
	cur_errs,cur_avg_abs_errs);

