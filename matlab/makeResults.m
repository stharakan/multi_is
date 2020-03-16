function [] = makeResults(tst_brn_idx, is_runs, ka_type, rank, batches)
if nargin < 5
    batches = 1;
end
data_locations;
result_file = generate_is_results_filename(tst_brn_idx, is_runs, ka_type,rank,batches);

load([results_dir,result_file],'seg','dnn_seg','klr_seg','klr_probs','is_segs','is_probs','brain_name');

%postprocessResults(seg,is_segs,is_probs); %TODO - reshape is_segs, is_probs to be 2d + extra dims
is_probs = reshape(is_probs, size(seg,1),size(seg,2),size(is_probs,2),size(is_probs,3));
is_segs = reshape(is_segs, size(seg,1),size(seg,2),size(is_segs,2));
is_seg = mode(is_segs,3);

f = summaryFigure(seg,dnn_seg,klr_seg,is_probs);
print(f,[image_dir,sprintf('%s_summary',result_file)],'-dpng')

[rows,cols] = getTumorBox(dnn_seg);
f2 = summaryFigure(seg(rows,cols),dnn_seg(rows,cols),klr_seg(rows,cols),is_probs(rows,cols,:,:));
print(f2,[image_dir,sprintf('%s_zoom',result_file)],'-dpng')

fprintf('Results for brain %d on %d runs, using %s decomp at rank %d with %d batches\n')
PrintSegmentationStats(klr_seg,seg,'KLR');
PrintSegmentationStats(dnn_seg,seg,'DNN');
PrintSegmentationStats(is_seg,seg,'KLR-IS');

end

