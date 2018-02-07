function [] = PreprocessForKNN(patch_sizes,ftypes,pstr)

% initialize loop stuff
prdir = [getenv('PRDIR'),'/']; 
prsdir = [getenv('PRDIRSCRATCH'),'/']; 
addpath(genpath( [getenv('MISDIR'),'/matlab/']));
ntrn = 208; ntst = 52;

for pi = 1:length(patch_sizes)
  psize = patch_sizes(pi);
% initialize ps
switch pstr
  case 'nearedema'
    ppb = 4000;
    ps = PointSelector('nearedema',ppb);
  case 'edemanormal'
    ppb = 4000;
    ps = PointSelector('edemanormal',ppb);
  case 'edemadist'
    bperc = 0.02;
    ps = PointSelector('edemadist',bperc,psize);
end
fprintf('Point selector: %s\n',ps.PrintString());


disp('Loading train and test lists..');
trn = BrainPointList.LoadList(prsdir,ps,ntrn);
%trn.PrintListInfo();
tst = BrainPointList.LoadList(prsdir,ps,ntst);
%tst.PrintListInfo();


% loop over sfbs
for fi = 1:length(ftypes)
ftype = ftypes{fi};
  fprintf('Processing psize %d for ftype %s\n',psize,ftype);
  
  % load training data (single prec)
  fprintf(' Loading training  ..\n');
  [ Gsingle,~ ] = GetBlistPatchFeatureData( trn,psize,ftype,prsdir );

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
  sfile = [prsdir,'knntrn',sfile];
  fprintf(' Saving training to file %s ..\n',sfile);
  fid = fopen(sfile,'w');
  fwrite(fid,Gdouble,'double');
  fclose(fid);
  clear Gdouble

  % Load testing 
  fprintf(' Loading testing  ..\n');
  [ Gsingle,~ ] = GetBlistPatchFeatureData( tst,psize,ftype,prsdir );

  % apply means/stds to testing
  Gsingle = bsxfun(@minus,Gsingle,means);
  Gsingle = bsxfun(@rdivide,Gsingle,stds);
  Gdouble = double(Gsingle');
  clear Gsingle

  % save testing
  sfile = tst.MakeFeatureDataString(ftype,psize);
  sfile = [prsdir,'knntst',sfile];
  fprintf('Saving testing to file %s ..\n',sfile);
  fid = fopen(sfile,'w');
  fwrite(fid,Gdouble,'double');
  fclose(fid);
  clear Gdouble

end

end
