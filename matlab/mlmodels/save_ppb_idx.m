% Add path to other code
addpath([getenv('BRATSREPO'),'/matlab/general/']);
SetPath;
SetVariablesTACC;

% params
nt_frac = 0.25;

% merge brns
sv_base = ['BRATS_50M_Meta_agg'];
idxfile = [brats,'/classification/',sv_base,'.idxs.mat'];

fprintf('Testing save to %s\n',idxfile)

% Location of brains
lgg_dir = [brats,'/preprocessed/trainingdata/LGG/pre-norm-aff/'];
lggcell = GetBrnList(lgg_dir);
addpath(lgg_dir);
if 0
tic;
disp('LGG')
for bi = 1:length(lggcell)
	fprintf('Processing brain %d out of %d: %s ',bi,length(lggcell),lggcell{bi});
  	[ flair,~,~,~,seg ] = ReadIdxBratsBrain( lgg_dir,lggcell{bi} );
	ridx = find(seg(:));	
	num_tp = length(ridx);
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
	fprintf('Processing brain %d out of %d: %s ',bi,length(hggcell),hggcell{bi});
  	[ flair,~,~,~,seg ] = ReadIdxBratsBrain( hgg_dir,hggcell{bi} );
	ridx = find(seg(:));	
	num_tp = length(ridx);
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

end

% all gg
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
