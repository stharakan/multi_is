function [] = test_figure(tst_brn_idx, is_runs, ka_type, rank, batches,ha)

if nargin < 5
    batches = 1;
end
data_locations;
results_filename = generate_is_results_filename(tst_brn_idx, is_runs, ka_type,rank,batches);

%results_dir = [results_dir(1:end-1),'_m5/']

if exist([results_dir,results_filename,'.mat'],'file')
    load(results_filename,'dnn_seg','seg','klr_seg', 'is_probs','brain_name','max_tumor_idx');
    fprintf('loaded %s\n',results_filename);
else
    return
end


brn = BrainReader(bdir,brain_name);
fl = brn.ReadFlair();
fl = fl(:,:,max_tumor_idx);
nzidx = fl ~= 0;

is_probs(~nzidx, 2:end,:) = 0;
is_probs(~nzidx, 1, :) = 1.0;

scaling_probs = [0.9/0.5,0.04/0.25,0.03/0.15,0.02/0.1]; scaling_probs = scaling_probs./sum(scaling_probs);
scaling_probs = [0.92,0.02,0.02,0.01]; scaling_probs = scaling_probs./sum(scaling_probs);
is_probs = bsxfun(@times,is_probs,scaling_probs);
rescale = sum(is_probs,2);
is_probs = bsxfun(@rdivide,is_probs,rescale);


is_probs = reshape(is_probs, size(seg,1),size(seg,2),size(is_probs,2),size(is_probs,3));
[rows,cols] = getTumorBox(dnn_seg);
cur_seg = seg(rows,cols);
cur_dnn_seg = dnn_seg(rows,cols);
cur_klr_seg = klr_seg(rows,cols);
cur_is_probs = is_probs(rows,cols,:,:);

test_dnn = dnn_seg;
test_dnn(dnn_seg ~= 4) = dnn_seg( dnn_seg~=4) + 1;
I = dnn_seg ~= 0;
RGBtrips = [0 0 0;
		0 1 1;
		1 0 1;
		1 1 0];
rgbidx = ind2rgb(single(test_dnn),RGBtrips);
alpha = 0.25;

t2 = brn.ReadT2();
t2 = t2(:,:,max_tumor_idx);
im = t2;
axes(ha(1));
imshow(im,[]);
hold on
h = imshow(rgbidx);
hold off
set(h, 'AlphaData', alpha*I);

summaryFigureDNNOverlay(cur_seg,cur_dnn_seg,cur_klr_seg,cur_is_probs,ha);

%print(f2,[image_dir,sprintf('color_%s',results_filename)],'-dpng')

%pause(5)
%close(f2);


if 0
figure;
ha = tight_subplot(1,2,[.001,.001],[.001,.001],[.001,.001]);


dnn_seg(dnn_seg ~= 4) = dnn_seg( dnn_seg~=4) + 1;
unique(dnn_seg)
I = dnn_seg ~= 1;

RGBtrips = [0 0 0;
		0 1 1;
		1 0 1;
		1 1 0];

rgbidx = ind2rgb(single(dnn_seg),RGBtrips);
my_im = @(x) imresize(x,3,'nearest');

axes(ha(1));
imshow( seg, []);
hold on
h = imshow(rgbidx);
hold off
set(h, 'AlphaData', 0.4*I);


axes(ha(2));
imshow( klr_seg, []);
hold on
h2 = imshow(rgbidx);
hold off
set(h2, 'AlphaData', 0.4*I);



% set up new plot!
is_probs = reshape(is_probs, size(seg,1),size(seg,2),size(is_probs,2),size(is_probs,3));
wt_cols = permute(sum(is_probs(:,:,2:end,:),3),[1,2,4,3]);
wt_var = var( wt_cols, 0, 3);
wt_cols = mean(wt_cols, 3);


figure;
ha = tight_subplot(1,2,[.001,.001],[.001,.001],[.001,.001]);

hi_prob_idx = wt_cols > 0.4;
min_var = min(wt_var(hi_prob_idx));
max_var = max(wt_var(hi_prob_idx));
wt_var(~hi_prob_idx) = min_var;
axes(ha(1));
imshow(wt_var,[min_var,max_var]);
hold on
green = cat(3, zeros(size(seg)),ones(size(seg)), ones(size(seg))); 
hold on 
h = imshow(green);
reds = cat(3, ones(size(seg)),zeros(size(seg)), ones(size(seg)));
hr = imshow(reds);
hold off

set(hr, 'AlphaData', 0.4*((I - (seg ~= 0)) ~= 0) )
set(h, 'AlphaData', 0.4*(wt_var > mean([min_var,max_var])) )
end



