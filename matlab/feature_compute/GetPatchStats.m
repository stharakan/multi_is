function [ out_mat ] = GetPatchStats( feat_mat )
%GETPATCHSTATS computes statistics for a given patch matrix pmat.

nn = size(feat_mat,1);
out_mat = zeros(nn,4);
out_mat = cast(out_mat,'like',feat_mat);

% means
out_mat(:,1) = mean(feat_mat,2);

% stds
out_mat(:,2) = std(feat_mat,0,2);

% median
out_mat(:,3) = median(feat_mat,2);

% two norm
out_mat(:,4) = sqrt(sum(feat_mat.*feat_mat,2));

end

