function [params] = CrossValParamsCla(blist,outdir,psize,target,ftype)

% set vals 
split_perc = 0.8;
num_divs = 4;

% default params
dparams.kerType = 0;
dparams.rfeC = 1;
dparams.useCBR = 1;
dparams.rfeG = 2^-6;
dparams.rfeE = 0.1;

disp('Getting training features and probs..')
[ fmat,fcell ] = GetBlistPatchFeatureData( blist,psize,ftype,outdir );
ppvec = GetPatchProbabilities(blist,psize,target,outdir);

nn= size(fmat,1);
CV = cvpartition(nn,'HoldOut',split_perc);

% Get data
Gtr = fmat(CV.training(),:);
[ counts,cell_labels,labels,inds ] = BucketCounterNoEnds( ppvec,num_divs );
Ytr = labels(CV.training());
Gte = fmat(CV.test(),:);
Yte = labels(CV.test());

% whiten, sparsify
[Gtr,Gte] = WhitenTrnTst(Gtr,Gte);
Gte = sparse(Gte);
Gtr = sparse(Gtr);

rfeEs = -10:-1; rfeEs = 2.^rfeEs;
rfeCs = -10:10; rfeCs = 2.^rfeCs;
ees = length(rfeEs);
ccs = length(rfeCs);

%all_rmse = zeros(ees,ccs);
%all_rsq = zeros(ees,ccs);
all_dice = zeros(ees,ccs);


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
      avg_dice = mean(dices);

      fprintf('  accs: %f\n  dice: %s\n',accs,num2str(dices(:)'));      




      all_dice(ei,ci) = avg_dice;
 
      disp('------------------------')
  end
end

%% process rmse
%[min_rmse,rmse_idx] = min(all_rmse(:));
%[e_rmse,c_rmse] = ind2sub([ees ccs],rmse_idx);
%fprintf([' Smallest rmse stats:\n rfeP: %f\n ',...
%  'rfeC: %f\n RMSE: %f\n R^2: %f\n'],rfePs(e_rmse),rfeCs(c_rmse),...
%  min_rmse,all_rsq(rmse_idx));
%
%
%% process rsq
%[max_rsq,rsq_idx] = max(all_rsq(:));
%[e_rsq,c_rsq] = ind2sub([ees ccs],rsq_idx);
%fprintf([' Largest rsq stats:\n rfeP: %f\n ',...
%  'rfeC: %f\n RMSE: %f\n R^2: %f\n'],rfePs(e_rsq),rfeCs(c_rsq),...
%  all_rmse(rsq_idx),max_rsq);


% process dices
[max_dice,dice_idx] = max(all_dice(:));
[e_dice,c_dice] = ind2sub([ees ccs],dice_idx);
fprintf([' Largest dice stats:\n rfeE: %f\n ',...
  'rfeC: %f\n dice: %f\n'],rfeEs(e_dice),rfeCs(c_dice),...
  max_dice);

disp('------------------------')
all_dice


params.rfeE = rfeEs(e_dice);
params.rfeC = rfeCs(c_dice);
params = SetParams(params,dparams);

end
