% load stuff
addpath([getenv('MISDIR'),'/matlab/general/']);
SetPath;
SetVariablesTACC;


% set variables 
bw_rank = 30;
psize = 33; dd = 120;
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

% load knn
knnfile = [knndir,init_str,'.ps.',num2str(psize), ...
    '.nn.',num2str(ntr),'.dd.',num2str(dd),'.kk.', ...
    num2str(kk),'.bin'];
fprintf('Loading knn file from %s ..\n',knnfile);
tic;[ nns,ids,nn_ids,nn_dists ] = KNNReaderLoop( knnfile,ntr ); kntime = toc;
fprintf('Took %d4.1f secs\n',kntime);
if nnmax < nns
    nn_ids = nn_ids(:,1:nnmax);
    nn_dists = nn_dists(:,1:nnmax);
end
    
% scale distances
fprintf('\nComputing scaled distances at rank %d ..\n',bw_rank);
nn_dists_scale = NNDistanceScaleToRank(nn_dists,bw_rank);
clear nn_dists

% exponential to get potentials
potentials = exp( -0.5 .* (nn_dists_scale).^2 );

% load ytrn
yfile = [prdir,init_str,'.ps.',num2str(psize),'.nn.', ...
    num2str(ntr),'.yy.trn.bin'];
fid = fopen(ytr,'r');
ytr = fread(fid,Inf);
fclose(fid);

% reorder ytr by nn_ids for a multiply
pt_weights = ytr(nn_ids);
clear nn_ids

% final yguess
fprintf('Computing final yg ..\n');
yg = sum(potentials .*pt_weights );
yg = yg(ids);

rel_error = norm(ytr - yg)/norm(ytr)
abs_errors = abs(ytr - yg);
avg_abs_error = mean(abs_errors)

% save to knnfiles
sfile = [knndir, 'nntrn.ps.',num2str(psize),'.nn.',num2str(ntr), ...
    '.kk.',num2str(min(nnmax,nns)),'.bw.',num2str(bw_rank),'.bin'];
fid = fopen(sfile);
fwrite(fid,yg,'double');
fclose(fid);



