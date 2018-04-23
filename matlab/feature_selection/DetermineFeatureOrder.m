function [ftOrder,ftAvgPos] = DetermineFeatureOrder(franks)




[~,feat_importances] = sort(franks);
ftAvgPos = mean(feat_importances,2);
[~ ,ftOrder ] = sort(ftAvgPos);





end
