function out_mat = ComputeStats(feat_mat)

nn = size(feat_mat,1);
out_mat = zeros(nn,4);
out_mat = cast(out_mat,'like',feat_mat);

% means
out_mat(:,1) = mean(feat_mat,2);

% max
out_mat(:,2) = max(feat_mat,[],2);

% median
out_mat(:,3) = median(feat_mat,2);

% stds
out_mat(:,4) = std(feat_mat,0,2);

end


