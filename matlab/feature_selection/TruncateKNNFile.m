
% load stuff
addpath([getenv('MISDIR'),'/matlab/general/']);
SetPath;
SetVariablesTACC;

% set variables 
kk_trun = 8;
%psize = 33; dd = 120;
psize = 33; dd = 30;
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
fid = fopen(knnfile,'r');
nns = fread(fid,1,'int32');

knnfile_out = [knndir,init_str,'.ps.',num2str(psize), ...
    '.nn.',num2str(ntr),'.dd.',num2str(dd),'.kk.', ...
    num2str(kk_trun),'.bin'];
fprintf('Saving knn file to %s ..\n',knnfile_out);
fid2 = fopen(knnfile_out,'w');
fwrite(fid2,int32(kk_trun),'int32');

num_doubles = (kk_trun*2) + 1;

for ni=1:ntr
	if mod(ni,100000) == 0, fprintf('.'); end
	cur_pt = fread(fid,2*nns + 1,'double');
	cur_pt = cur_pt(:);

	
	fwrite(fid2,cur_pt(1:num_doubles),'double');
	
	if mod(ni,1000000) == 0
		fprintf('%2dM\n  ',ni/1000000); 
	end
end



fclose(fid);
fclose(fid2);



