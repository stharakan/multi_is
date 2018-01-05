% Add path to other code
bdir = [getenv('HOME'),'/Documents/data/trainingdata/'];
addpath([getenv('HOME'),'/Documents/data/trainingdata/']);

% initialize brainlist, ps
%ps = PointSelector('neartumor');
%ps = PointSelector('edemanormal');
ps = PointSelector('all');
blist = BrainPointList(bdir,[],ps,0,'./');

AnalyzePatchProbabilities(blist,5,2,'./');



