filename = './data/results/b1_i1000_klr_kOneShot_r4096_b1.mat';
filename = './data/single_brain_results.mat';
filename = './data/results/b1_i100_klr_kDiagNyst_r128_b2.mat'
data_locations;
load(filename);

is_segs = is_segs(:,1:100);
is_probs = is_probs(:,:,1:100);


tumor_klr_probs = sum(klr_probs(:,:,2:end),3);
tumor_dnn_probs = sum(dnn_probs(:,:,1:3),3);
tumor_dnn_probs(tumor_dnn_probs > 1) = 1;
tumor_klr_is_probs =  mean(is_probs,3);
tumor_klr_is_probs = NormalizeClassProbabilities(tumor_klr_is_probs);
tumor_klr_is_probs = sum(tumor_klr_is_probs(:,2:end),2);
is_seg = reshape( mode(is_segs,2), size(dnn_seg));
is_seg = remap_klr_seg_to_labels(is_seg);

my_im = @(x) imresize(x,3,'nearest');

%% summary figure
is_probs = reshape(is_probs, size(seg,1),size(seg,2),size(is_probs,2),size(is_probs,3));
% f = summaryFigure(seg,dnn_seg,klr_seg,is_probs);
% print(f,[image_dir,sprintf('%s_summary',brain_name)],'-dpng')
% 
% [rows,cols] = getTumorBox(dnn_seg);
% f2 = summaryFigure(seg(rows,cols),dnn_seg(rows,cols),klr_seg(rows,cols),is_probs(rows,cols,:,:));
% print(f2,[image_dir,sprintf('%s_zoom',brain_name)],'-dpng')


%% statistics
PrintSegmentationStats(klr_seg,seg,'KLR');
PrintSegmentationStats(dnn_seg,seg,'DNN');
PrintSegmentationStats(is_seg,seg,'KLR-IS');

%% pixel wise histograms

% for true target pixels, 4 categories, correctly identified (TP), incorrectly
% identified (FP), correctly not identified (TN), incorrectly not
% identified (FN). Choose 10 pixels at random, plot in faded g

figure;
ha = tight_subplot(2,2,[.05,.05],[.05,.05],[.05,.05]);
titles = {'WT','NE', 'ED','EN'};

for i = 2:4
    im = seg;
    my_title = titles{i};
    axes(ha(i));
    
    % f xi
    target_idx = seg(:) == (2^i)/4;
    sub_is_probs = reshape(is_probs(:,:,:,i),[],size(is_probs,3));
    sub_is_probs = sub_is_probs(target_idx,:);
    for j = 1:size(sub_is_probs,1)
        [kde,xi] = ksdensity(sub_is_probs(j,:)');
        plot(xi,kde./sum(kde(:)),'Color',[0.9 0.9 0.9],'linewidth',2);
        hold on
    end
    
    % plot
    title(my_title);
    
    
end



%% spectrum plots -- probably over multiple ka types










