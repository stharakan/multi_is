% Add path to other code
clearvars
close all
bdir = ['./../data/trainingdata/'];
addpath(['./../data/trainingdata/']);

% initialize brainlist, ps
ppb = 200;
bperc = 0.02;
psize = 5;
ftype = 'patchstats';
target = 2;
params = [];
outdir = '';
%ps = PointSelector('neartumor',ppb);
%ps = PointSelector('edemanormal',ppb);
%ps = PointSelector('all',ppb);
ps = PointSelector('edemadist',bperc,psize);
blist = BrainPointList(bdir,[],ps,'./');

%AnalyzePatchProbabilities(blist,5,2,'./');
psize = 5;
bi = 4;

[ franks ] = FeatureRankerRegression( blist,ftype,psize,target,params );
if 0

% load brain
curbrn = blist.MakeBrain(bi);

% load image
flair = curbrn.ReadFlair();
seg = curbrn.ReadSeg();

% plot
%ShowBlist3D(flair,blist.pt_inds{bi},psize,[]);
ShowBlist3D(seg,blist.pt_inds{bi},psize,[0 4]);



end

