function [] = save_truncated_metrics(truncated_results_file, brain_name, ... 
        dnn_probs, dnn_seg, max_tumor_idx,klr_probs,klr_seg,seg,is_probs_all)

% basic 
s1 = size(seg,1);
s2 = size(seg,2);
classes = size(is_probs_all,2);
samples = size(is_probs_all,3);

% this is now seg1, seg2, classes, samples
is_probs_all = reshape(is_probs_all,s1,s2,classes,samples);

% compute is probs mean -> into is probs
is_probs = nanmean(is_probs_all,4);

% compute is probs var
is_vars = nanvar(is_probs_all,0,4);

% compute is entropy over classes
is_entropy = sum( - is_probs .* log(is_probs) , 3);

% compute covariances??
is_covariances = zeros(s1,s2,classes,classes);
is_aleatorics= zeros(s1,s2,classes,classes);
for ii = 1:s1
    for jj = 1:s2
        sub_mat = is_probs_all(ii,jj,:,:);
        sub_mat = permute(sub_mat,[4,3,2,1]);
        is_covariances(ii,jj,:,:) = cov(sub_mat);

        cross_cors = sub_mat' * sub_mat;
        diag_cors = diag( sum(sub_mat,1) );
        is_aleatorics(ii,jj,:,:) = (diag_cors - cross_cors  )./samples;

    end
end


% save to file
save(truncated_results_file,'brain_name','dnn_probs','dnn_seg', ...
    'max_tumor_idx','klr_probs','klr_seg','seg','is_probs', ...
    'is_vars', 'is_entropy','is_covariances','is_aleatorics');

end
