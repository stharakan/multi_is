function [] = test_figure(tst_brn_idx, is_runs, ka_type, rank, batches,ha,extra_str)

if nargin < 7
    extra_str = '';
end
data_locations;
results_filename = generate_is_results_filename(tst_brn_idx, is_runs, ka_type,rank,batches);

%results_dir = [results_dir(1:end-1),'_m5/']
fname = [results_dir,results_filename,extra_str,'.mat'];
if exist(fname,'file')
    load(fname,'dnn_seg','seg','klr_seg', 'is_probs','brain_name','max_tumor_idx');
    fprintf('loaded %s\n',results_filename);
else
    fprintf('Could not find %s, exiting..\n',results_filename);
    return
end


brn = BrainReader(bdir,brain_name);
fl = brn.ReadFlair();
if strcmp(extra_str,'coronal') 
    fl = fl(:,max_tumor_idx,:);
    fl = permute(fl,[1,3,2]);
else
    fl = fl(:,:,max_tumor_idx);
end
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
if strcmp(extra_str,'coronal')
    t2 = t2(:,max_tumor_idx,:);
    t2 = permute( t2, [1,3,2]);
else
    t2 = t2(:,:,max_tumor_idx);
end
im = t2;
axes(ha(1));
imshow(im,[]);
hold on
h = imshow(rgbidx);
hold off
set(h, 'AlphaData', alpha*I);

summaryFigureDNNOverlay(cur_seg,cur_dnn_seg,cur_klr_seg,cur_is_probs,ha);
