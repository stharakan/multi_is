clearvars
close all

% % Testing probability saving/reading
outdir = getenv('PRDIRSCRATCH');
bdir = [getenv('BRATSDIR'),'/preprocessed/trainingdata/meanrenorm/'];
bcell = GetBrnList(bdir);
bcell = bcell(2);
bcell = {'Brats17_TCIA_621_1'};
ps = PointSelector('sliceedemamax',1);
blist = BrainPointList(bdir,bcell,ps,'');

brn = blist.MakeBrain(1);
pstr = 'tstprobs.t.2';
pdir = './';
bws = [5 0.2 1];
slice = 59;
conf = 0.75; err = 0.13;
errs = [0,0.1,0.2,0.3,0.4];
errs = linspace(0.1,0.2,11);
flair = brn.ReadFlair();
flair = flair(:,:,slice);
seg = brn.ReadSeg();
seg = seg(:,:,slice);
t2 = seg == 2;
t2 = t2(:);
fprintf('----------------------------\n');

for err = errs
  %disp('Creating probs');
  fprintf(' Sig: %4.2f\n Conf: %4.2f\n\n',err,conf);
  [Pmat] = CreateDummyProbabilities(brn,2,err,conf);
  Pmat = Pmat(:,:,slice); Pmat = round(Pmat(:));
  inter = sum( Pmat == t2 ) ;
  acc = inter./length(Pmat);
  inter = sum( Pmat == 1 & t2 == 1);
  dice = 2*inter/(sum(Pmat == 1) + sum(t2 == 1));
  fprintf(' Acc: %4.2f\n Dice: %4.2f\n',acc,dice);
  fprintf('----------------------------\n');
end
