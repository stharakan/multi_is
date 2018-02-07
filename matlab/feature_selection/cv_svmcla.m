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
num_trn_brains = num_brains*split_perc;
psize = 5;
target = 2;
num_divs = 4;

% initialize ps
ppb = 4000;
ps = PointSelector('nearedema',ppb);

%ppb = 4000;
%ps = PointSelector('edemanormal',ppb);
%
bperc = 0.02;
ps = PointSelector('edemadist',bperc,psize);
fprintf('Point selector: %s\n',ps.PrintString());

% feature info
ftype = 'patchstats';
fprintf('Feature type: %s\n',ftype);


disp('Loading blist');
blist = BrainPointList.LoadList(prsdir,ps,num_trn_brains);
blist.PrintListInfo();


disp('Getting training features and probs..')
[ fmat,fcell ] = GetBlistPatchFeatureData( blist,psize,ftype,prsdir );
ppvec = GetPatchProbabilities(blist,psize,target,prsdir);

%disp('Getting testing features..')
%[ ~,fcell ] = GetBlistPatchFeatureData( tst,psize,ftype,prsdir );
%disp('Features computed!');

nn= size(fmat,1);
CV = cvpartition(nn,'HoldOut',split_perc);

Gtr = sparse(fmat(CV.training(),:));
[ counts,cell_labels,labels,inds ] = BucketCounterNoEnds( ppvec,num_divs );
Ytr = labels(CV.training());
Gte = sparse(fmat(CV.test(),:));
Yte = labels(CV.test());



rfeEs = -10:-1; rfeEs = 2.^rfeEs;
rfeCs = -10:10; rfeCs = 2.^rfeCs;
ees = length(rfeEs);
ccs = length(rfeCs);
all_accs = zeros(ees,ccs);
all_tums = all_accs;

disp('Beginning CV loop..')
disp('------------------------')
for ei = 1:ees
    for ci = 1:ccs
      rfeC = rfeCs(ci);
      rfeE = rfeEs(ei);
      fprintf(' Current Model P: %f C: %f\n',rfeE,rfeC);      

      mdl_string = sprintf('-s 2 -c %f -e %f -q',rfeC,rfeE);
      model = train(Ytr,Gtr,mdl_string);
      [predict_label, accuracy,probs] = predict(Yte,Gte,model);

      accs = accuracy(1);
      c = confusionmat(predict_label,Yte);
      dices = diag(c)./( sum(c,1)' + sum(c,2) - diag(c));

      fprintf('  accs: %f\n  dice: %s\n',accs,num2str(dices(:)'));      

      all_accs(ei,ci) = accs; 
      all_tums(ei,ci) = dices(end); 
      disp('------------------------')
  end
end

% process accs
[max_accs,accs_idx] = max(all_accs(:));
[e_accs,c_accs] = ind2sub([ees ccs],accs_idx);
fprintf([' Best accs stats:\n rfeE: %f\n ',...
  'rfeC: %f\n Acc: %f\n'],rfeEs(e_accs),rfeCs(c_accs),max_accs);

% process dices
[max_tums,tums_idx] = max(all_tums(:));
[e_tums,c_tums] = ind2sub([ees ccs],tums_idx);
fprintf([' Best tumor stats:\n rfeE: %f\n ',...
  'rfeC: %f\n Acc: %f\n'],rfeEs(e_tums),rfeCs(c_tums),max_tums);

disp('------------------------')
all_accs 
all_tums

%[predict_label, accuracy, prob_estimates] = predict(Yte,Gte,model,'-b 1');





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



