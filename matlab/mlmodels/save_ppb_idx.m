% Add path to other code
addpath([getenv('MISDIR'),'/matlab/general/']);
brats = getenv('BRATSDIR');
SetPath;
SetVariablesTACC;

% params
nt_frac = 0.25;
max_tumor_pts_allowed = 100

% merge brns
sv_base = ['BRATS.nt',num2str(max_tumor_pts_allowed)];
idxfile = [brats,'/classification/training/models/',sv_base,'.idxs.mat'];
brn_dir = [brats,'/preprocessed/trainingdata/meanrenorm/'];
fprintf('Testing save to %s\n',idxfile)

% Location of brains
lgg_dir = [brats,'/preprocessed/trainingdata/LGG/pre-norm-aff/'];
lggcell = GetBrnList(lgg_dir);
addpath(lgg_dir);
tic;
disp('LGG')
for bi = 1:length(lggcell)
        brain = lggcell{bi};
	fprintf('Processing brain %d out of %d: %s ',bi,length(lggcell),lggcell{bi});
  	[ flair,~,~,~,seg ] = ReadIdxBratsBrain( brn_dir,lggcell{bi} );
	ridx = find(seg(:));	
	num_tp = length(ridx);
	
	if strcmp(brain, 'Brats17_2013_10_1')
		fprintf('Brain %s is being set to 0\n',brain)
 		num_tp = 0;
		ridx = [];
		ridxc_hgg{bi} = ridx;
		continue;
	end
        
	if num_tp > max_tumor_pts_allowed
        ridx_sel = randperm(num_tp,max_tumor_pts_allowed);
        ridx = ridx(ridx_sel);
        num_tp = max_tumor_pts_allowed;
        end
	
	allowed_idx = find(flair);
	num_ntp = round(nt_frac*num_tp);
	num_fp = num_tp - num_ntp;

	[ridx1,num_ntp] = NearTumorIdx(num_ntp,seg,7,allowed_idx);
	fprintf('.');
	[ridx2,num_fp] = FarTumorIdx(num_fp,seg,flair);
	fprintf('.');
	[ridx3] = ridx;
	

	ridx = [ridx1(:);ridx2(:);ridx3(:)];
	ridxc_lgg{bi} = ridx;

	fprintf(' done!\n');
	fprintf('Num tumor pixels: %d\n',num_tp);
end
toc
%ff = load(idxfile);
%ridxc_lgg = ff.ridxc_lgg;

% hgg
hgg_dir = [brats,'/preprocessed/trainingdata/HGG/pre-norm-aff/'];
hggcell = GetBrnList(hgg_dir);
addpath(hgg_dir);
tic;
disp('HGG');
for bi = 1:length(hggcell)
        brain = hggcell{bi};
	
	if strcmp(brain, 'Brats17_2013_10_1')
		fprintf('Brain %s is being set to 0\n',brain)
 		num_tp = 0;
		ridx = [];
		ridxc_hgg{bi} = ridx;
		continue;
	end


	fprintf('Processing brain %d out of %d: %s ',bi,length(hggcell),hggcell{bi});
  	[ flair,~,~,~,seg ] = ReadIdxBratsBrain( brn_dir,hggcell{bi} );
	ridx = find(seg(:));	
	num_tp = length(ridx);
        
	if num_tp > max_tumor_pts_allowed
        ridx_sel = randperm(num_tp,max_tumor_pts_allowed);
        ridx = ridx(ridx_sel);
        num_tp = max_tumor_pts_allowed;
        end
	
	allowed_idx = find(flair);
	num_ntp = round(nt_frac*num_tp);
	num_fp = num_tp - num_ntp;

	[ridx1,num_ntp] = NearTumorIdx(num_ntp,seg,7,allowed_idx);
	fprintf('.');
	[ridx2,num_fp] = FarTumorIdx(num_fp,seg,flair);
	fprintf('.');
	[ridx3] = ridx;

	ridx = [ridx1(:);ridx2(:);ridx3(:)];
	ridxc_hgg{bi} = ridx;
	fprintf(' done!\n');
	fprintf('Num tumor pixels: %d \n',num_tp);
end
toc
% save indices
save(idxfile,'ridxc_lgg','ridxc_hgg','lggcell','hggcell');


% all gg
if 0
agg_dir = [brats,'/preprocessed/trainingdata/all-pre-norm-aff/'];
brncell = GetBrnList(agg_dir);
addpath(agg_dir);
tic;
disp('AGG');
for bi = 1:length(brncell)
	fprintf('Processing brain %d out of %d: %s ',bi,length(brncell),brncell{bi});
  	[ flair,~,~,~,seg ] = ReadIdxBratsBrain( agg_dir,brncell{bi} );
	ridx = find(seg(:));	
	num_tp = length(ridx);

	% adjust num_tp for max tumor points per brain
        if num_tp > max_tumor_pts_allowed
        ridx_sel = randperm(num_tp,max_tumor_pts_allowed);
        ridx = ridx(ridx_sel);
        num_tp = max_tumor_pts_allowed;
        end


	allowed_idx = find(flair);
	num_ntp = round(nt_frac*num_tp);
	num_fp = num_tp - num_ntp;

	[ridx1,num_ntp] = NearTumorIdx(num_ntp,seg,7,allowed_idx);
	fprintf('.');
	[ridx2,num_fp] = FarTumorIdx(num_fp,seg,flair);
	fprintf('.');
	[ridx3] = ridx;

	ridx = [ridx1(:);ridx2(:);ridx3(:)];
	ridxc{bi} = ridx;
	fprintf(' done!\n');
	fprintf('Num tumor pixels: %d \n',num_tp);
end

save(idxfile,'ridxc','brncell');
end
