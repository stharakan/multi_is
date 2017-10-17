function [dice, jaccard] = compute_dice(reference_img, test_img, label)
%function [dice, jaccard] = compute_dice(reference_img, test_img, labels)
% computes dice and jaccard coefficients between two multilabeld images
% INPUT
% reference_img, test_img the two images
% label [1] - is the set of labels to combine
% that is if images have three labels (0,1,2) then
%    label = 1, computes the dice of label 1
%    label =[0,2], combines labels 0,2 into a new label and
%    computes the dice of the new label.
% label is optional. the default value is 1.

% OUTPUT dice coefficent.

if nargin<3, label = 1; end;

n= length(label); assert(n>0);
r= reference_img == label(1);
t= test_img == label(1);

for j=2:n
    r = r | (reference_img == label(j) )
    t = t | (test_img == label(j) )
end


% compute dice score
common = (r & t);
a = sum(common(:));
b = sum(r(:));
c = sum(t(:));

if b>0 | c>0
  dice = 2*a/(b+c); 
  jaccard = a /(b+c-a);
else 
  dice =1;
  jaccard = 1;
end



