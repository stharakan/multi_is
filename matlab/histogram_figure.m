function [] = histogram_figure(tst_brn_idx, is_runs, varargin)
data_locations;
filename = generate_is_results_filename(tst_brn_idx,is_runs,varargin{:});
load([results_dir,filename],'seg','dnn_seg','is_probs');

is_probs = reshape(is_probs, size(seg,1),size(seg,2),size(is_probs,2),size(is_probs,3));

ha = tight_subplot(3,1,[.05,.05],[.05,.05],[.05,.05]);
titles = {'NE', 'ED','EN'};

for i = 1:3
    my_title = titles{i};
    axes(ha(i));
    
    % f xi
    target = (2^i)/2;% 1 2 4
    target_idx = (seg(:) == target) ~= (dnn_seg(:) == target);
    sub_is_probs = reshape(is_probs(:,:,i,:),[],size(is_probs,4));
    sub_is_probs = sub_is_probs(target_idx,:);
    variances = nanstd(sub_is_probs,0,2);
    [~,sort_idx] = sort(variances,'descend');
    sub_is_probs = sub_is_probs(sort_idx(1:10),:);
    bw_tot = 0;
    for j = 1:size(sub_is_probs,1)
        %[kde,xi] = ksdensity(sub_is_probs(j,:)','Bandwidth',0.01);
        [kde,xi,bw] = ksdensity(sub_is_probs(j,:)','Bandwidth',0.1);
        plot(xi,kde./sum(kde(:)),'Color',[0.9 0.9 0.9],'linewidth',2);
        bw_tot = bw_tot + bw;
        hold on
    end
    
    % plot
    title(my_title);
    
    
end


end

