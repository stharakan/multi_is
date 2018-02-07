function [] = KNNRegressionLoop_func(psize,dd,bw_ranks) 

% load stuff
addpath([getenv('MISDIR'),'/matlab/general/']);
SetPath;
SetVariablesTACC;

% set variables 
nnmax = 256;

fprintf(['Running regression on training with psize %d, dim %d,',...
	'max bw rank %d and min bw rank %d'],psize,dd,max(bw_ranks),min(bw_ranks));
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
bbs = length(bw_ranks);
id_idx = 5:2:((2*nns)+1);
dd_idx = id_idx - 1;
ids = zeros(ntr,1);
yg = zeros(ntr,bbs);
nn_ids = zeros(nns-1,1);
nn_dists = zeros(nns-1,1);
oob_count = 1;
avgdistanceNN = zeros(ntr,bbs);

for ni=1:ntr
	if mod(ni,100000) == 0 
		%cur_ids = nn_ids(1:20)
		%cur_dists = nn_dists(1:20)
	end
	cur_pt = fread(fid,2*nns + 1,'double');
	cur_pt = cur_pt(:);
	ids(ni) = cur_pt(1) + 1; % account for c++ idx
	
	nn_ids = cur_pt(id_idx)' + 1; % account for c++ indexing
	nn_dists = cur_pt(dd_idx)';
	
	avgdistanceNN(ni,:) = nn_dists(bw_ranks);

	%for bi = 1:bbs
	%bw_rank= bw_ranks(bi);
	%% scale by bw
	%%[ nn_dists_scale ] = NNDistanceScaleToRank( nn_dists,bw_rank );
	%
	%% exponential to get potentials
	%%potentials = exp( -0.5 .* (nn_dists_scale).^2 );
	%%if mod(ni,100000) == 0 
	%%format long
	%%potentials = potentials./sum(potentials)
	%%else
	%%potentials = potentials./sum(potentials);
	%%end

	%% reorder ytr by nn_ids for a multiply
	%pt_weights = ytr(nn_ids);

	%%ycur = potentials * pt_weights(:);
	%%yg( ids(ni),bi ) = ycur;
	%yg( ids(ni),bi ) = sum(pt_weights(1:bw_rank))/bw_rank;
	%end
	
	%if mod(ni,100000) == 0 
	%tru = ytr( ids(ni) )
	%yg( ni, :)
	%end
	%
	%if mod(ni,1000000) == 0
	%	cur_idx = ids(1:ni);
	%	[~,reo_idx] = sort(cur_idx);
	%	ygt = yg(reo_idx,:);
	%	ytt = ytr(cur_idx);
	%	diff = abs(bsxfun(@minus,ygt,ytt));
	%	cur_errs = sqrt(sum(diff.^2,1 ))./norm(ytt);
	%	cur_avg_abs_errs = mean( diff,1 );
	%	fprintf('%2dM \n',ni/1000000); 
	%	fprintf('  Bw | Erel | Eavg \n'); 
	%	for bi = 1:bbs
	%		fprintf('  %2d | %3.2f | %3.2f\n', bw_ranks(bi),...
	%			cur_errs(bi),cur_avg_abs_errs(bi));
	%	end
	%end
end

fprintf('  bw | avg | med |s: \n')
for bi = 1:bbs
	fprintf(' %2d | %3.2f | %3.2f\n', bw_ranks(bi),...
		mean(avgdistanceNN(:,bi)),median(avgdistanceNN(:,bi)));
end

%fclose(fid);
%if ~issorted(ids)
%    fprintf('Need to sort ids ..\n');
%    [~, reo_idx] = sort(ids);
%    yg = yg(reo_idx);
%end
%diff = abs(bsxfun(@minus,ygt,ytt));
%cur_errs = sqrt(sum(diff.^2,1 ))./norm(ytt);
%cur_avg_abs_errs = mean( diff,1 );
%fprintf('%2dM \n',ni/1000000); 
%fprintf('  Bw | Erel | Eavg \n'); 
%for bi = 1:bbs
%	fprintf('  %2d | %3.2f | %3.2f\n', bw_ranks(bi),...
%		cur_errs(bi),cur_avg_abs_errs(bi));
%end
%
%
%
%% save to knnfiles
%for bw_rank = bw_ranks
%sfile = [knndir, 'nnreg.ps.',num2str(psize),'.nn.',num2str(ntr), ...
%    '.dd.',num2str(dd),'.kk.',num2str(min(nnmax,nns)),'.bw.',num2str(bw_rank),'.bin'];
%fprintf('Saving yg to %s ..\n',sfile);
%fid2 = fopen(sfile,'w');
%fwrite(fid2,yg,'double');
%fclose(fid2);
%end

end
