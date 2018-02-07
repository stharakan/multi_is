
% load stuff
addpath([getenv('MISDIR'),'/matlab/general/']);
SetPath;
SetVariablesTACC;

% set variables 
bw_rank = 30; 
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

% load knn
knnfile = [knndir,init_str,'.ps.',num2str(psize), ...
    '.nn.',num2str(ntr),'.dd.',num2str(dd),'.kk.', ...
    num2str(kk),'.bin'];
fprintf('Loading knn file from %s ..\n',knnfile);
fid = fopen(knnfile,'r');

nns = fread(fid,1,'int32');

id_idx = 5:2:((2*nns)+1);
dd_idx = id_idx - 1;
ids = zeros(ntr,1);
yg = zeros(ntr,1);
nn_ids = zeros(nns-1,1);
nn_dists = zeros(nns-1,1);
oob_count = 1;

for ni=1:ntr
	if mod(ni,100000) == 0, fprintf('.'); end
	cur_pt = fread(fid,2*nns + 1,'double');
	cur_pt = cur_pt(:);
	ids(ni) = cur_pt(1) + 1; % account for c++ idx
	
	nn_ids = cur_pt(id_idx)' + 1; % account for c++ indexing
	nn_dists = cur_pt(dd_idx)';

	% scale by bw
	[ nn_dists_scale ] = NNDistanceScaleToRank( nn_dists,bw_rank );
	
	% exponential to get potentials
	potentials = exp( -0.5 .* (nn_dists_scale).^2 );
	potentials = potentials./sum(potentials);

	% reorder ytr by nn_ids for a multiply
	pt_weights = ytr(nn_ids);

	ycur = potentials * pt_weights(:);
	yg( ids(ni) ) = ycur;
	
	if mod(ni,1000000) == 0
		cur_idx = ids(1:ni);
		[~,reo_idx] = sort(cur_idx);
		ygt = yg(reo_idx);
		ytt = ytr(cur_idx);
		cur_err = norm(ygt - ytt)/norm(ytt);
		cur_avg_abs_err = mean( abs( ytt - ygt ) );
		fprintf('%2dM | rel err: %3.2f | avg abs err: %3.2f\n ',...
			ni/1000000,cur_err,cur_avg_abs_err); 
	end
end



fclose(fid);
if ~issorted(ids)
    fprintf('Need to sort ids ..\n');
    [~, reo_idx] = sort(ids);
    yg = yg(reo_idx);
end
yg = yg(:);

rel_error = norm(ytr - yg)/norm(ytr)
abs_errors = abs(ytr - yg);
avg_abs_error = mean(abs_errors)

% save to knnfiles
sfile = [knndir, 'nnreg.ps.',num2str(psize),'.nn.',num2str(ntr), ...
    '.kk.',num2str(min(nnmax,nns)),'.bw.',num2str(bw_rank),'.bin'];
fprintf('Saving yg to %s ..\n',sfile);
fid2 = fopen(sfile,'w');
fwrite(fid2,yg,'double');
fclose(fid2);



