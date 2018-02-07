function out_mat = GaborToStats(feat_mat,nangs)

if nargin == 1
    nangs = 8;
end

num_stats = 6;
cur_ind = 0;
nn = size(feat_mat,1);
dd = size(feat_mat,2);
dd_noangs = dd/nangs;
out_mat = zeros(nn,dd_noangs*num_stats);
out_mat = cast(out_mat,'like',feat_mat);

for di = 1:dd_noangs
    cur_ind = (di-1)*num_stats;
    
    % means
    out_mat(:,cur_ind + 1) = mean(feat_mat,2);
    
    % max
    out_mat(:,cur_ind + 2) = max(feat_mat,[],2);
    
    % median
    out_mat(:,cur_ind + 3) = median(feat_mat,2);
    
    % stds
    out_mat(:,cur_ind + 4) = std(feat_mat,0,2);
    
    % two norm
    out_mat(:,cur_ind + 5) = sqrt(sum(feat_mat.*feat_mat,2));
    
    % one norm
    out_mat(:,cur_ind + 6) = sum(abs(feat_mat),2);
end

end


