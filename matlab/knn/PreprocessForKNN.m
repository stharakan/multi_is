function [] = PreprocessForKNN(bdir,outdir,fkeep,stype,psize,ftype,pstr,ppb,target)
%function [] = PreprocessForKNN(patch_sizes,ftypes,pstr)

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
disp('Loading train and test lists..');
trn = BrainPointList.LoadList(outdir,ps,ntrn);
trn.PrintListInfo();
tst = BrainPointList.LoadList(outdir,ps,ntst);
tst.PrintListInfo();


% load training data (single prec)
fprintf(' Loading training data and franks ..\n');
[ Gsingle,~ ] = GetBlistPatchFeatureData( trn,psize,ftype,outdir );
dd = size(Gsingle,2);
fkeep= min(fkeep,dd);

% load franks, truncate to fkeep
[~,ftOrder,AvgPos] = LoadFtRanks(trn,stype,ftype,psize,target,outdir);
Gsingle = Gsingle(:,ftOrder(1:fkeep));

% get means, stds
fprintf(' Computing training means/stds ..\n');
means = mean(Gsingle);
stds = std(Gsingle);

% apply to training data
Gsingle = bsxfun(@minus,Gsingle,means);
Gsingle = bsxfun(@rdivide,Gsingle,stds);
Gdouble = double(Gsingle');
clear Gsingle

% save new training
sfile = trn.MakeFeatureDataString(ftype,psize);
sfile = [outdir,'knntrn.dd.',num2str(fkeep),'.',sfile];
fprintf(' Saving training to file %s ..\n',sfile);
fid = fopen(sfile,'w');
fwrite(fid,Gdouble,'double');
fclose(fid);
clear Gdouble

% Load testing , truncate
fprintf(' Loading testing  ..\n');
[ Gsingle,~ ] = GetBlistPatchFeatureData( tst,psize,ftype,outdir );
Gsingle = Gsingle(:,ftOrder(1:fkeep));

% apply means/stds to testing
Gsingle = bsxfun(@minus,Gsingle,means);
Gsingle = bsxfun(@rdivide,Gsingle,stds);
Gdouble = double(Gsingle');
clear Gsingle

% save testing
sfile = tst.MakeFeatureDataString(ftype,psize);
sfile = [outdir,'knntst.dd.',num2str(fkeep),'.',sfile];
fprintf('Saving testing to file %s ..\n',sfile);
fid = fopen(sfile,'w');
fwrite(fid,Gdouble,'double');
fclose(fid);
clear Gdouble


end
