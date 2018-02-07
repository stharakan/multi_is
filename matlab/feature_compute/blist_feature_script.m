function [] = blist_feature_func(psize,pstr,ftype)

% Add path to other code
addpath(genpath('./../'))
prdir = [getenv('PRDIR'),'/'];
prsdir = [getenv('PRDIRSCRATCH'),'/'];
bdir = [getenv('BRATSDIR'),'/preprocessed/trainingdata/meanrenorm/'];
%bdir = [getenv('BRATSDIR'),'/preprocessed/trainingdata/HGG/pre-norm-aff/'];
addpath(bdir);
bcell = BrainCellAllTrain();
num_brains = 260;
split_perc = 0.8;
psize = 5;

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

% feature info
fprintf('Feature type: %s\n',ftype);


if BrainPointList.CheckForList(prsdir,ps,num_brains)
    disp('Loading blist');
    blist = BrainPointList.LoadList(prsdir,ps,num_brains);
else
    disp('Making blist')
    blist = BrainPointList(bdir,bcell,ps,prsdir);
end
blist.PrintListInfo();

disp('Splitting into train and test..');
rng(2);
[trn,tst] = blist.Split(split_perc);
trn.SaveList(prsdir);
tst.SaveList(prsdir);
disp('Lists saved!');


disp('Computing training features..')
[ ~,fcell ] = GetBlistPatchFeatureData( trn,psize,ftype,prsdir );

disp('Computing testing features..')
[ ~,fcell ] = GetBlistPatchFeatureData( tst,psize,ftype,prsdir );
disp('Features computed!');


%AnalyzePatchProbabilities(blist,5,2,'./');

%disp('Running feature regression');
%target = 2;
%params = [];
%[ franks ] = FeatureRankerRegression( blist,ftype,psize,target,params,prsdir );
%
%disp('Feature ranks');
%disp('');
%fcell(franks)


%AnalyzePatchProbabilities(blist,17,2,prsdir);
%AnalyzePatchProbabilities(blist,17,2,prsdir);



