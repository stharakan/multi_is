function [] = PreprocessForASKIT(bdir,outdir,fkeep,stype,psize,ftype,pstr,ppb,target,kk,kcut)

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
sfile = [outdir,'knntrn.dd.',num2str(fkeep),'.',filebase];
fid = fopen(sfile,'r');
Gmat = fread(fid,Inf,'double');
Gmat = reshape(Gmat, fkeep, [])';
fclose(fid);

% find median of 100 random points, save potential bws
med_dist = FindMedianDistance(Gmat); 
fprintf('Median computed distance: %3.3f\n',med_dist);
pfile = trn.MakePPvecFile(psize,target);
pfile = [outdir,pfile];
bwfile = strrep(pfile,'bin',['txt']);
bwfile = strrep(bwfile,'ppv',['cvbws.',ftype]);
all_bws = FindBwsFromMedian(med_dist);
str = num2str(all_bws(1));
for bi = 2:length(all_bws)
  str = sprintf('%s %s',str,num2str(all_bws(bi)));
end

% save bin and mat
fid = fopen(bwfile,'w');
fprintf(fid,'%s',str);
fclose(fid);
bwfile = strrep(bwfile,'txt','mat');
save(bwfile,'all_bws','med_dist');


% truncate
fprintf('Finishing truncation training..\n')
nnfile = [outdir,'nntrnlist.dd.',num2str(fkeep),'.',filebase(1:(end-3)),'kk.',num2str(kk),'.bin'];
nnfile_out = [outdir,'nntrnlist.dd.',num2str(fkeep),'.',filebase(1:(end-3)),'kk.',num2str(kcut),'.bin'];
TruncateKNNFile(nnfile,nnfile_out,kcut,trn.tot_points);


% truncate test list as well
disp('Loading testing list..');
tst = BrainPointList.LoadList(outdir,ps,ntst);
tst.PrintListInfo();
filebase = tst.MakeFeatureDataString(ftype,psize);
nnfile = [outdir,'nntstlist.dd.',num2str(fkeep),'.',filebase(1:(end-3)),'kk.',num2str(kk),'.bin'];
nnfile_out = [outdir,'nntstlist.dd.',num2str(fkeep),'.',filebase(1:(end-3)),'kk.',num2str(kcut),'.bin'];
TruncateKNNFile(nnfile,nnfile_out,kcut,tst.tot_points);



end
