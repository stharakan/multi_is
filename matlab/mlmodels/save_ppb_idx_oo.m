% Add path to other code
addpath(genpath('./../'))
prdir = [getenv('PRDIR'),'/'];
prsdir = [getenv('PRDIRSCRATCH'),'/'];
bdir = [getenv('BRATSDIR'),'/preprocessed/trainingdata/meanrenorm/'];
%bdir = [getenv('BRATSDIR'),'/preprocessed/trainingdata/HGG/pre-norm-aff/'];
addpath(bdir);
bcell = BrainCellAllTrain();

% initialize brainlist, ps
num_brains = 260;
split_perc = 0.8;
ppb = 200;
bperc = 0.02;
psize = 9;
ftype = 'patchstats';
target = 2;
params = [];
outdir = '';
%ps = PointSelector('neartumor',ppb);
%ps = PointSelector('edemanormal',ppb);
%ps = PointSelector('all',ppb);
ps = PointSelector('edemadist',bperc,psize);

if BrainPointList.CheckForList(prsdir,ps,num_brains)
    disp('Loading blist');
    blist = BrainPointList.LoadList(prsdir,ps,num_brains);
else
    disp('Making blist')
    blist = BrainPointList(bdir,bcell,ps,prsdir);
end
blist.PrintListInfo();

disp('Splitting into train and test..');
[trn,tst] = blist.Split(split_perc); % TODO add rounding func
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
%[ franks ] = FeatureRankerRegression( blist,ftype,psize,target,params,prsdir );
%
%disp('Feature ranks');
%disp('');
%fcell(franks)


%AnalyzePatchProbabilities(blist,17,2,prsdir);
%AnalyzePatchProbabilities(blist,17,2,prsdir);



