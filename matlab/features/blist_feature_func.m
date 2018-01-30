function [] = blist_feature_func(psizes,pstr,ftype)


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

for pi= 1:length(psizes)
psize = psizes(pi);

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



disp('Loading train and test lists..');
trn = BrainPointList.LoadList(prsdir,ps,num_brains*split_perc);
trn.PrintListInfo();
tst = BrainPointList.LoadList(prsdir,ps,num_brains*(1-split_perc));
tst.PrintListInfo();


%disp('Computing training features..')
[ ~,fcell ] = GetBlistPatchFeatureData( trn,psize,ftype,prsdir );

%disp('Computing testing features..')
%[ ~,fcell ] = GetBlistPatchFeatureData( tst,psize,ftype,prsdir );
%disp('Features computed!');


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

end
end
