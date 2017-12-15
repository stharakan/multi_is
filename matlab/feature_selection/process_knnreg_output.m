% load stuff
addpath([getenv('MISDIR'),'/matlab/general/']);
SetPath;
SetVariablesTACC;

% set variables 
bw_ranks = [15 60 90 120]; 
%psize = 33; dd = 120;
psize = 33; dd = 30;
nnmax = 256;
%psize = 17; dd = 120;
%psize = 9; dd = 96;
%psize = 5; dd = 16;

% other vars 
prdir = [getenv('PRDIR'),'/'];
knndir = [getenv('PRDIRSCRATCH'),'/knnfiles/'];
prscratch = [getenv('PRDIRSCRATCH'),'/'];
init_str = 'onlystats';
ntr = 40000000;
nte = 9000000;
kk = 256;

% load ytrn
yfile = [prdir,init_str,'.ps.',num2str(psize),'.nn.', ...
    num2str(ntr),'.yy.trn.bin'];
fprintf('Loading ytr file from %s ..\n',yfile);
fid = fopen(yfile,'r');
%ytr = fread(fid,Inf,'double');
ytr = fread(fid,Inf,'single');
ytr = ytr(:);
fclose(fid);
fprintf('Ytr size is %d\n',length(ytr));

for bw_rank = bw_ranks
fprintf('Processing bw %d\n',bw_rank)

% load reg out
sfile = [knndir, 'nnreg.ps.',num2str(psize),'.nn.',num2str(ntr), ...
    '.dd.',num2str(dd),'.kk.',num2str(nnmax),'.bw.',num2str(bw_rank),'.bin'];
fprintf('Saving yg to %s ..\n',sfile);
fid2 = fopen(sfile,'r');
yg = fread(fid2,Inf,'double');
fclose(fid2);
yg = yg(:);

% Print stats
maxy = max(yg);
miny = min(yg);
fprintf(' Max val: %3.2f\n Min val: %3.2f',maxy,miny);
lows = sum(yg < 0.2)/ntr;
his = sum(yg > 0.8)/ntr;
mids = sum(yg > 0.4 & yg > 0.6)/ntr;
fprintf(' Hi perc: %3.2f\n Lo val: %3.2f\n Mid val: %3.2f\n',lows,his,mids);
[N,edges] = histcounts(yg,10)
end
