function threshold = FindThreshold( primg, nnzvx )
tvals = linspace(0.1,.98, 8);
objfun = @(tv) sum(primg(:)>tv)/nnzvx;
lower = 0.015;
upper = 0.15;

for j=1:length(tvals)
  pvals(j) = objfun(tvals(j));
end
idx = find(pvals>=lower & pvals <=upper);
if isempty(idx)
  if pvals(end)<lower, threshold = (1+upper)/2; end
  if pvals(1)>upper, threshold = lower/2; end
else
  threshold = median(tvals(idx));
end
  



% options = optimset('MaxFunEvals',30, 'MaxIter',30, 'Display','iter');
% threshold = fminsearch(objfun, 0.49, options);
