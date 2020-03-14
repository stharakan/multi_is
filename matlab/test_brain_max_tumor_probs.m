function [] = test_brain_max_tumor_probs(tst_brn_idx,is_runs,varargin)
data_locations;

% get brain, seg
data = load(data_file);
brn = data.tst_list.MakeBrain(tst_brn_idx);
brain_name = brn.bname;
max_tumor_idx = MaxTumorSlice(brn);
seg = brn.ReadSeg();
seg = seg(:,:,max_tumor_idx);

% load brain features
healthy_feats = brn.ReadTissueFeatures();
tumor_feats   = brn.ReadTumorFeatures();
healthy_feats = reshape(healthy_feats(:,:,max_tumor_idx,:),[],size(healthy_feats,4));
tumor_feats   = reshape(tumor_feats(:,:,max_tumor_idx,:), [], size(tumor_feats,4));
Xtest = [healthy_feats,tumor_feats];
fprintf('Loaded data..\n')

% load klr model
klr = build_klr(varargin{:});
fprintf('Loaded klr model..\n')


% Run KLR
[Y_guess, Y_probs] = klr.predict_proba(Xtest); 
klr_seg = reshape(Y_guess,size(seg,1),size(seg,2));
klr_seg = remap_klr_seg_to_labels(klr_seg);
klr_probs = reshape(Y_probs, size(seg,1),size(seg,2), size(Y_probs,2));

% compare to dnn probs
dnn_probs = brn.ReadTumorProbs();
dnn_probs = dnn_probs(:,:,max_tumor_idx,:);
dnn_seg = brn.ReadTumorSeg();
dnn_seg = dnn_seg(:,:,max_tumor_idx);
fprintf('Computed klr + dnn probabilities..\n')



% run importance sampling
[is_probs,is_segs] = importance_sample_from_features(Xtest,klr,is_runs);
fprintf('Computed importance sampling..\n')


% save to file
brn_file_name = generate_is_results_filename(tst_brn_idx, is_runs, varargin{:});
results_file = [results_dir,brn_file_name,'.mat'];
save(results_file,'brain_name','dnn_probs','dnn_seg','max_tumor_idx',...
    'klr_probs','klr_seg','seg','is_probs','is_segs')


end

