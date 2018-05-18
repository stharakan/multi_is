clearvars
close all

% % Testing probability saving/reading
bdir = '~/Documents/data/trainingdata/';
bcell = GetBrnList(bdir);
bcell = bcell(2);
ps = PointSelector('sliceedemamax',1);
blist = BrainPointList(bdir,bcell,ps,'');

brn = blist.MakeBrain(1);
pstr = 'tstprobs.t.2';
pdir = './';
bws = [5 0.2 1];

disp('Creating probs');
Pmat = CreateDummyProbabilities(brn,2,0.3);

disp('Saving probs');
brn.SaveProbs(Pmat,pdir,pstr);

disp('Running crf');
Pf = CRFSingleBrain(brn,pdir,pstr,1/4,bws,'quasi');

% % Testing on toy problem
% sz = 50;nzidx = 20:30;
% bws = [5 0.2 1];
% crfiters = 15;
% 
% % toy prob init
% seg = zeros(sz);
% seg(nzidx,nzidx) = 1;
% im = 2 + randn(sz);
% im(nzidx,nzidx) = 4 + randn(length(nzidx));
% probs = CreateDummyProbabilities(seg,1,0.45);
% unary = [probs(:), 1 - probs(:)];
% 
% % crf obj
% crf = DenseCRFExact(im,bws,[],unary);
% 
% % iterations
% qf = KLMinIterateCRF(crf,crfiters,[],seg);




