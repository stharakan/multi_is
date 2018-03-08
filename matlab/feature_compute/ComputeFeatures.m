function [] = ComputeFeatures(bdir,outdir,psize,ftype,pstr,ppb)


% Process inputs, set up number of brains (hard-coded to all trn) 
if isempty(outdir)
  outdir = [getenv('PRDIRSCRATCH'),'/'];
end
if isempty(bdir)
  bdir = [getenv('BRATSDIR'),'/preprocessed/trainingdata/meanrenorm/'];
end
addpath(bdir);
bcell = BrainCellAllTrain();
num_brains = length(bcell);
split_perc = 0.8;
trn_bb = round(split_perc*num_brains);
tst_bb = num_brains - trn_bb;

% initialize ps
if strcmp(pstr,'edemadist')
  ps = PointSelector(pstr,ppb,psize);
else
  ps = PointSelector(pstr,ppb);
end
fprintf('Point selector: %s\n',ps.PrintString());

% feature info
fprintf('Feature type: %s\n',ftype);

% Load train/tst lists
disp('Loading train and test lists..');
trn = BrainPointList.LoadList(outdir,ps,trn_bb);
trn.PrintListInfo();
tst = BrainPointList.LoadList(outdir,ps,tst_bb);
tst.PrintListInfo();

% Compute features
disp('Computing training features..')
[ ~,fcell ] = GetBlistPatchFeatureData( trn,psize,ftype,outdir );

disp('Computing testing features..')
[ ~,fcell ] = GetBlistPatchFeatureData( tst,psize,ftype,outdir );
disp('Features computed!');

end
