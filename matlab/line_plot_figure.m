function [] = line_plot_figure(dim,tst_brain_idx,is_runs,varargin)
% load
%filename = './data/results/b1_i100_klr_kDiagNyst_r128_b2.mat'
data_locations;
filename = [results_dir,generate_is_results_filename(tst_brain_idx,is_runs,varargin{:}),'.mat']
load(filename);

% get indices, etc. from seg
sum_dim = 3-dim;
idx = MaxTumor1D(seg, sum_dim);
xx = 1:size(seg,sum_dim);
seg_line = get_1D_line(seg,dim,idx);

% prep dnn probs
dnn_probs = permute(dnn_probs,[1,2,4,3]);
dnn_sum = sum(dnn_probs,3);
dnn_sum(dnn_sum == 0) = 1.0;
dnn_probs = bsxfun(@rdivide,dnn_probs,dnn_sum);

% prepare is probs
is_probs_means = mean(is_probs,3);
is_probs_stds  = std(is_probs,0,3);
is_probs_means = reshape(is_probs_means,size(seg,1),size(seg,2),[]);
is_probs_stds = reshape(is_probs_stds,size(seg,1),size(seg,2),[]);
wt_stds = sqrt(sum( is_probs_stds(:,:,2:4).^2,3 )) ;

% initialize figure axes
ha = tight_subplot(3,1,[.05,.01],.05,.05);

% wt figure
yy = seg_line ~= 0;
[dnn_line,klr_line,is_line] = get_all_1D_lines(dim,idx,sum(dnn_probs,3),...
    sum(klr_probs(:,:,2:4),3),sum(is_probs_means(:,:,2:4),3));
plot_1D_lines(xx,yy,dnn_line, klr_line,...
    is_line,ha(1),'Whole tumor')

% edema fig
yy = seg_line == 2;
[dnn_line,klr_line,is_line] = get_all_1D_lines(dim,idx,dnn_probs(:,:,2),...
    klr_probs(:,:,3),is_probs_means(:,:,3));
plot_1D_lines(xx,yy,dnn_line, klr_line,...
    is_line,ha(2),'Edema')

% en fig
yy = seg_line == 4;
[dnn_line,klr_line,is_line] = get_all_1D_lines(dim,idx,dnn_probs(:,:,3),...
    klr_probs(:,:,4),is_probs_means(:,:,4));
plot_1D_lines(xx,yy,dnn_line, klr_line,...
    is_line,ha(3),'Enhancing')


end

function [dnn,klr,is] = get_all_1D_lines(dd,ii,dnn_im,klr_im,is_im)
dnn = get_1D_line(dnn_im,dd,ii);
klr = get_1D_line(klr_im,dd,ii);
is  = get_1D_line(is_im, dd,ii);
end

function [] = plot_1D_lines(xx,yy,dnn_line, klr_line, is_line,ax,title_str)
axes(ax);
area(xx,yy,'FaceColor',[0.95,0.95,0.95]); hold on
plot(dnn_line); hold on
plot(klr_line); hold on
plot(is_line); 
grid on
legend('Truth','DNN','KLR','KLR-IS')
title(title_str)

end

function line = get_1D_line(im, dd,ii)
if dd == 1
    line = im(ii,:);
else
    line = im(:,ii);
end
line = line(:);

end

