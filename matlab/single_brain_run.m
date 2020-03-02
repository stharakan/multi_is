% variable
klr_file = 'klr_model.mat';
data_file = 'test.mat';
brain_idx = 1;

my_im = @(x) imresize(x,3,'nearest');

% load brain, Get max tumor slice
data = load(data_file);
brn = data.tst_list.MakeBrain(brain_idx);
brn_name = brn.bname;
max_tumor_idx = MaxTumorSlice(brn);
seg = brn.ReadSeg();
seg = seg(:,:,max_tumor_idx);

% load features and slices
healthy_feats = brn.ReadTissueFeatures();
tumor_feats   = brn.ReadTumorFeatures();
healthy_feats = reshape(healthy_feats(:,:,max_tumor_idx,:),[],size(healthy_feats,4));
tumor_feats   = reshape(tumor_feats(:,:,max_tumor_idx,:), [], size(tumor_feats,4));
Xtest = [healthy_feats,tumor_feats];

% Load klr
klr_data = load(klr_file);


% Run KLR 
klr = klr_data.klr;
[Y_guess, Y_probs] = klr.predict_proba(Xtest); 
klr_seg = reshape(Y_guess,size(seg,1),size(seg,2));
klr_probs = reshape(Y_probs, size(seg,1),size(seg,2), size(Y_probs,2));

% compare to dnn probs
dnn_probs = brn.ReadTumorProbs();
dnn_probs = dnn_probs(:,:,max_tumor_idx,:);
dnn_seg = brn.ReadTumorSeg();
dnn_seg = dnn_seg(:,:,max_tumor_idx);

save('final_data.mat','dnn_probs','dnn_seg','max_tumor_idx','brn_name','klr_probs','klr_seg','seg')

% Examine output
if 0
figure; imshow( my_im(seg) ,[] );
figure; imshow( my_im(klr_seg) ,[]);
figure; imshow( my_im(klr_probs(:,:,1)),[] );
figure; imshow( my_im(klr_probs(:,:,2)),[] );
end


