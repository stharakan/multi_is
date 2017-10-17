% Add path to other code
addpath('../features/');
addpath('../readbrns/');
p = genpath('../external');
addpath(p); % add load_nii

% params
ppb = 0;

% Location of brains
lgg_dir = '/org/groups/padas/lula_data/medical_images/brain/BRATS17/preprocessed/trainingdata/LGG/pre-norm-aff/';
lgg_struct = dir(lgg_dir);
lggcell = GetBrnList(lgg_dir);
addpath(lgg_dir);

% hgg
hgg_dir = '/org/groups/padas/lula_data/medical_images/brain/BRATS17/preprocessed/trainingdata/HGG/pre-norm-aff/';
hgg_struct = dir(hgg_dir);
hggcell = GetBrnList(hgg_dir);
addpath(hgg_dir);

% merge brns
idx_lgg = 4:length(lgg_struct);
idx_hgg = 3:length(hgg_struct);
sv_base = ['BRATS_ALL.pb',num2str(ppb)];
idxfile = ['./',sv_base,'.idxs.mat'];
if exist(idxfile,'file')
	disp('Loading from old indices ..')
	load(idxfile,'ridxc_lgg','ridxc_hgg');
end

% Location of features
feat_dir = '/org/groups/padas/lula_data/medical_images/brain/askit_files/';
addpath(feat_dir);

% brns / features
feats = {'int','diff'};
%feats = {'gabor'};
%feats = {'int','intdiff','window'};


for fi = 1:length(feats)
	feat_select = feats{fi};
	disp(['Features: ',feat_select]);

	tic;
	if ~exist('ridxc_lgg','var')
		[GF_lgg,ridxc_lgg,y_lgg] = ExtractAllClassFeatures(ppb,feat_select,lgg_dir,[],lggcell{:});
		[GF_hgg,ridxc_hgg,y_hgg] = ExtractAllClassFeatures(ppb,feat_select,hgg_dir,[],hggcell{:});
		save(idxfile,'ridxc_lgg','ridxc_hgg');
	else
		[GF_lgg,ridxc_lgg,y_lgg] = ExtractAllClassFeatures(ppb,feat_select,lgg_dir,ridxc_lgg,lggcell{:});
		[GF_hgg,ridxc_hgg,y_hgg] = ExtractAllClassFeatures(ppb,feat_select,hgg_dir,ridxc_hgg,hggcell{:});
	end

	GFtr = [GF_lgg;GF_hgg];
	ytr = [y_lgg;y_hgg];

	feat_time = toc;
	disp(['Features took ',num2str(feat_time)]);

	% Save
	[nn,dd] = size(GFtr);
	sv_trn = [sv_base,'.trn.nn.',num2str(nn),'.dd.',num2str(dd),'.',feat_select,'.bin'];
	sv_trl = [sv_base,'.trn.nn.',num2str(nn),'.labs.bin'];
	

	filenm = [feat_dir,sv_trn];
	fid = fopen(filenm,'w');
	fwrite(fid,single(GFtr),'single');
	fclose(fid);

	
	filenm = [feat_dir,sv_trl];
	fid = fopen(filenm,'w');
	fwrite(fid,single(ytr),'single');
	fclose(fid);
	disp('--------------------------');


	%nte = size(GFte,1);
	%sv_tsl = [sv_base,'.tst.nn.',num2str(nte),'.','.labs.bin'];
	%sv_tst = [sv_base,'.tst.nn.',num2str(nte),'.dd.',num2str(dd),'.','.bin'];
	%filenm = [feat_dir,sv_tst];
	%fid = fopen(filenm,'w');
	%fwrite(fid,double(GFte),'double');
	%fclose(fid);

	%filenm = [feat_dir,sv_tsl];
	%fid = fopen(filenm,'w');
	%fwrite(fid,double(yte),'double');
	%fclose(fid);
end

