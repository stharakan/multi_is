function [] = sample_klris_all_test_coronal(save_full,is_runs,varargin)
data_locations;

% get brain, seg
data = load(data_file);
nb = length(data.tst_list.brain_cell);

% load klr model
klr = build_klr(varargin{:});
fprintf('Loaded klr model..\n');

for bi = 1:nb
    fprintf('--------------------------\nProcessing coronal brain %d of %d\n',bi,nb);
    
    % load brain, pick slice
    brn = data.tst_list.MakeBrain(bi);
    brain_name = brn.bname;
    max_tumor_idx = MaxTumorSliceCoronal(brn);
    seg = brn.ReadSeg();
    seg = permute( seg(:,max_tumor_idx,:),[1,3,2]);
    
    % load brain features
    healthy_feats = brn.ReadTissueFeatures();
    tumor_feats   = brn.ReadTumorFeatures();
    healthy_feats = reshape(healthy_feats(:,max_tumor_idx,:,:),[],size(healthy_feats,4));
    tumor_feats   = reshape(tumor_feats(:,max_tumor_idx,:,:), [], size(tumor_feats,4));
    Xtest = [healthy_feats,tumor_feats];
    fprintf('Loaded data..\n')
    
    
    % Run KLR
    [Y_guess, Y_probs] = klr.predict_proba(Xtest);
    klr_seg = reshape(Y_guess,size(seg,1),size(seg,2));
    klr_seg = remap_klr_seg_to_labels(klr_seg);
    klr_probs = reshape(Y_probs, size(seg,1),size(seg,2), size(Y_probs,2));
    
    % compare to dnn probs
    dnn_probs = brn.ReadTumorProbs();
    dnn_probs = permute( dnn_probs(:,max_tumor_idx,:,:), [1,3,4,2]);
    dnn_seg = brn.ReadTumorSeg();
    dnn_seg = permute( dnn_seg(:,max_tumor_idx,:), [1,3,2]);
    fprintf('Computed klr + dnn probabilities..\n')
    
    
    % run importance sampling
    [is_probs,is_segs] = importance_sample_from_features(Xtest,klr,is_runs);
    fprintf('Computed importance sampling..\n')
    
    % print some stats
    is_seg = reshape( mode(is_segs,2), size(dnn_seg));
    fprintf('--------------------------\nBrain %d (%s) coronal results:\n',bi,brain_name);
    PrintSegmentationStats(klr_seg,seg,'KLR');
    PrintSegmentationStats(dnn_seg,seg,'DNN');
    PrintSegmentationStats(is_seg,seg,'KLR-IS');
    fprintf('--------------------------\n')
    
    % save to file
    brn_file_name = generate_is_results_filename(bi, is_runs, varargin{:});
    results_file = [results_dir,brn_file_name,'.mat'];
    if save_full
        save(results_file,'brain_name','dnn_probs','dnn_seg','max_tumor_idx',...
            'klr_probs','klr_seg','seg','is_probs','is_segs')
    end

    truncated_results_file = [results_dir,brn_file_name,'coronal_trunc.mat'];
    save_truncated_metrics(truncated_results_file, brain_name, dnn_probs, dnn_seg, ...
        max_tumor_idx,klr_probs,klr_seg,seg,is_probs);

end


end
