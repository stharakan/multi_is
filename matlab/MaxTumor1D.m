function [idx] = MaxTumor1D(image,sum_dim,target)

if nargin < 3
    target = 0;
end
    
% im comp to target
if target
    target_image = image == target;
else
    target_image = image ~= target;
end

summed_image = sum(target_image,sum_dim);
[~,idx] = max(summed_image);


end