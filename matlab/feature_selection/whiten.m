function [XX,means,stds] = whiten(XX,means,stds)
% WHITEN whitens training data, saving the means and 
% stds to be used to whiten testing data. 

if nargin == 1
  means = mean(XX);
  stds = std(XX);
end

XX = bsxfun(@minus,XX, means);
XX = bsxfun(@rdivide,XX,stds);


end




