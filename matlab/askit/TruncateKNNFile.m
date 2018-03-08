function [] = TruncateKNNFile(knnfile,knnfile_out,kcut,ntr)
% Check if new file exists already, return
if exist(knnfile_out,'file')
  fprintf('Knn file %s exists! Not rewriting\n',knnfile_out);
  return;
end

% open old file
fprintf('Loading knn file from %s ..\n',knnfile);
fid = fopen(knnfile,'r');
nns = fread(fid,1,'int32');

% open new file
fprintf('Saving knn file to %s ..\n',knnfile_out);
fid2 = fopen(knnfile_out,'w');
fwrite(fid2,int32(kcut),'int32');

num_doubles = (kcut*2) + 1;

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


end
