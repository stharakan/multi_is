function C = confusion_regression(ytrue,yest,num_splits)
% CONFUSION_REGRESSION creates a confusion matrix for 
% the regression output variable yest, given the truth ytrue.

% in case not specified
if nargin == 2
  num_splits = 3;
end

max_true = max(ytrue);
min_true = min(ytrue);
ntr = length(ytrue);
splits = linspace(min_true,max_true,num_splits+1);
splits(1) = -Inf;
splits(end) = Inf;
true_cla = zeros(ntr,1);
gues_cla = zeros(ntr,1);


for si = 1:(length(splits) -1)
  si1 = splits(si);
  si2 = splits(si+1);
  cur_idx = ytrue >= si1 & ytrue < si2;
  true_cla(cur_idx) = si;

  
  cur_idx = yest >= si1 & yest < si2;
  gues_cla(cur_idx) = si;
end

C = confusionmat(true_cla,gues_cla);
end
