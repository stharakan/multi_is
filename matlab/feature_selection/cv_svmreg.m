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

% initialize ps
ppb = 4000;
ps = PointSelector('nearedema',ppb);

bperc = 0.02;
ps = PointSelector('edemadist',bperc,psize);

% feature info
ftype = 'patchgabor';


% start!
diary(sprintf('./%s.%s.ps.%d.out',ps.PrintString(),ftype,psize));
fprintf('Point selector: %s\n',ps.PrintString());
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
Ytr = ppvec(CV.training());
Gte = sparse(fmat(CV.test(),:));
Yte = ppvec(CV.test());



rfePs = -8:-1; rfePs = 2.^rfePs;
rfeCs = -3:8; rfeCs = 2.^rfeCs;
ees = length(rfePs);
ccs = length(rfeCs);
all_rmse = zeros(ees,ccs);
all_rsq = zeros(ees,ccs);


disp('Beginning CV loop..')
disp('------------------------')
for ei = 1:ees
    for ci = 1:ccs
      rfeC = rfeCs(ci);
      rfeP = rfePs(ei);
      fprintf(' Current Model P: %f C: %f\n',rfeP,rfeC);      

      mdl_string = sprintf('-s 11 -c %f -p %f -e 0.00001 -q',rfeC,rfeP);
      model = train(Ytr,Gtr,mdl_string);
      [predict_label, accuracy,probs] = predict(Yte,Gte,model);

      rmse = accuracy(2);
      rsq = accuracy(3);

      fprintf('  rmse: %f\n  rsq: %f\n',rmse,rsq);      
      c = confusion_regression(Yte,predict_label)
      dices = diag(c)./( sum(c,1)' + sum(c,2) - diag(c));

      fprintf('  dice: %s\n',num2str(dices(:)'));      

      all_rmse(ei,ci) = rmse; 
      all_rsq(ei,ci) = rsq;
      disp('------------------------')
  end
end

% process rmse
[min_rmse,rmse_idx] = min(all_rmse(:));
[e_rmse,c_rmse] = ind2sub([ees ccs],rmse_idx);
fprintf([' Smallest rmse stats:\n rfeP: %f\n ',...
  'rfeC: %f\n RMSE: %f\n R^2: %f\n'],rfePs(e_rmse),rfeCs(c_rmse),...
  min_rmse,all_rsq(rmse_idx));


% process rsq
[max_rsq,rsq_idx] = max(all_rsq(:));
[e_rsq,c_rsq] = ind2sub([ees ccs],rsq_idx);
fprintf([' Largest rsq stats:\n rfeP: %f\n ',...
  'rfeC: %f\n RMSE: %f\n R^2: %f\n'],rfePs(e_rsq),rfeCs(c_rsq),...
  all_rmse(rsq_idx),max_rsq);



disp('------------------------')
all_rmse 

all_rsq
diary off
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



