function [params] = CrossValParamsReg01(blist,outdir,psize,target,ftype)

% split perc
split_perc = 0.8;

% default params
dparams.kerType = 0;
dparams.rfeC = 1;
dparams.useCBR = 1;
dparams.rfeG = 2^-6;
dparams.rfeE = 0.1;

if strcmp(ftype,'patchgabor')
  switch psize
    case 5
    c = 0.25;
    e = 8;
    otherwise
    c = 0.01;
    e = 10;
  end

  params = dparams;
  params.rfeC = c;
  params.rfeE = e;
  return
elseif strcmp(ftype,'patchgstats')
  switch psize
    case 5
    c = 0.25;
    e = 0.25;
    case 9
    c = 0.25;
    e = 64;
    case 17
    c = 0.25;
    e = 16;
  end
  params = dparams;
  params.rfeC = c;
  params.rfeE = e;
  return
end



% getting features
[ fmat,fcell ] = GetBlistPatchFeatureData( blist,psize,ftype,outdir );
ppvec = GetPatchProbabilities(blist,psize,target,outdir);

nn= size(fmat,1);
CV = cvpartition(nn,'HoldOut',split_perc);

Gtr = (fmat(CV.training(),:));
Ytr = ppvec(CV.training());
Gte = (fmat(CV.test(),:));
Yte = ppvec(CV.test());

% whiten
[Gtr,Gte] = WhitenTrnTst(Gtr,Gte);
Gte = sparse(Gte);
Gtr = sparse(Gtr);


rfePs = -4:-2; rfePs = 10.^rfePs;
rfeCs = -1:3; rfeCs = 10.^rfeCs;
ees = length(rfePs);
ccs = length(rfeCs);
%all_rmse = zeros(ees,ccs);
%all_rsq = zeros(ees,ccs);
all_dice = zeros(ees,ccs);


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
      avg_dice = mean(dices);

      fprintf('  dice: %s\n',num2str(dices(:)'));      

      %all_rmse(ei,ci) = rmse; 
      %all_rsq(ei,ci) = rsq;
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
fprintf([' Largest dice stats:\n rfeP: %f\n ',...
  'rfeC: %f\n dice: %f\n'],rfePs(e_dice),rfeCs(c_dice),...
  max_dice);

disp('------------------------')
all_dice


params.rfeE = rfePs(e_dice);
params.rfeC = rfeCs(c_dice);
params = SetParams(params,dparams);

end
