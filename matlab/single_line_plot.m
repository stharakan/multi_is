filename = './data/results/b1_i100_klr_kDiagNyst_r128_b2.mat'
data_locations;
load(filename);

% inputs
%idx = 120;
dim = 1;
sum_dim = 3-dim;
idx = MaxTumor1D(seg, sum_dim)
xx = 1:size(seg,sum_dim);
seg_line = seg(idx,:);


%slkdjfksj
test = 4;
dnn_probs = permute(dnn_probs,[1,2,4,3]);
dnn_sum = sum(dnn_probs,3);
dnn_sum(dnn_sum == 0) = 1.0;
dnn_probs = bsxfun(@rdivide,dnn_probs,dnn_sum);

% prepare is probs
is_probs_means = mean(is_probs,3);
is_probs_stds  = std(is_probs,0,3);
is_probs_means = reshape(is_probs_means,240,240,[]);
is_probs_stds = reshape(is_probs_stds,240,240,[]);
wt_stds = sqrt(sum( is_probs(:,:,2:4).^2,3 )) ;


% wt figure
figure;
%cur_dnn_probs = sum(dnn_probs,3);
%plot(cur_dnn_probs(idx,:));hold on

yy = seg_line ~= 0;
area(xx,yy,'FaceColor',[0.95,0.95,0.95]); hold on
cur_dnn_probs = sum(dnn_probs,3);
cur_klr_probs = sum(klr_probs(:,:,2:4),3);
cur_is_probs  = sum(is_probs_means(:,:,2:4),3);
plot(cur_dnn_probs(idx,:));hold on
plot(cur_klr_probs(idx,:));hold on
%plot(cur_is_probs(idx,:));
errorbar(cur_is_probs(idx,:),wt_stds(:)');
legend('Truth','DNN','KLR','KLR-IS')
grid on
title('Whole tumor')

% make other plots
figure;
yy = seg_line == 2;
area(xx,yy,'FaceColor',[0.95,0.95,0.95]); hold on
cur_dnn_probs = dnn_probs(:,:,2);
cur_klr_probs = klr_probs(:,:,3);
cur_is_probs = is_probs_means(:,:,3);
plot(cur_dnn_probs(idx,:));hold on
plot(cur_klr_probs(idx,:));hold on
plot(cur_is_probs(idx,:));
legend('Truth','DNN','KLR','KLR-IS')
grid on
title('Edema')


% make other plots
figure;
yy = seg_line == 4;
area(xx,yy,'FaceColor',[0.95,0.95,0.95]); hold on
cur_dnn_probs = dnn_probs(:,:,3);
cur_klr_probs = klr_probs(:,:,4);
cur_is_probs = is_probs_means(:,:,4);
plot(cur_dnn_probs(idx,:));hold on
plot(cur_klr_probs(idx,:));hold on
plot(cur_is_probs(idx,:));
legend('Truth','DNN','KLR','KLR-IS')
grid on
title('Enhancing')

