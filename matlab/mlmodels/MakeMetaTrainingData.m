% addpath, variables
addpath([getenv('BRATSREPO'),'/matlab/general/']);
SetPath;
SetVariablesTACC;
myload_nii = @(filename) load_untouch_nii(filename);

% Select models to use for features
mdl_num = 2;
[prob_dirs,type_dirs] = InitializeTraDirs(brats,mdl_num);
dd = length(type_dirs);

% model file
mdlstr = 'BRATS_50M_Meta';
mdlfile = [training_model_dir,mdlstr,'.idxs.mat'];
mdlstr = [mdlstr,num2str(mdl_num)];
mdlstr = 'BRATS_50M_renorm';
fprintf('Loading model from %s\n',mdlfile);
idxfile = load(mdlfile);
lggs = length(idxfile.lggcell);
hggs = length(idxfile.hggcell);
brn_dir = [brats,'/preprocessed/trainingdata/all-pre-norm-aff/'];

% Find length of training data
nn = sum(cellfun('length',[idxfile.ridxc_lgg(:);idxfile.ridxc_hgg(:)]));
fprintf('Initializing array of size %d by %d\n',nn,dd);
feature_mat = zeros(nn,dd,'single');
labels = zeros(nn,1,'single');
counter = 0;

% Loop over trn brains
tot_idx = 1:(lggs+hggs);
bla_idx = tot_idx;
%bla_idx = randsample(tot_idx,5);
for ii = bla_idx
	% Get idx of points to train on
	if ii <= lggs
		cell_no = ii;
		ridx = idxfile.ridxc_lgg{ii};
		brain = idxfile.lggcell{ii};
		brn_type = 'LGG';
	else
		cell_no = ii - lggs;
		ridx = idxfile.ridxc_hgg{cell_no};
		brain = idxfile.hggcell{cell_no};
		brn_type = 'HGG';
	end
	pts_from_brain = length(ridx);

	if pts_from_brain == 0
		fprintf('Brain %s has %d features to load\n',brain,pts_from_brain);
		continue;
	end
	fprintf('Loading %s no %d (%s), has %d features \n',brn_type,cell_no,brain,pts_from_brain);
	
	% Extract from seg
	segfile = [brn_dir,brain,'/',brain,'_seg_aff.nii.gz'];
	nii = myload_nii([segfile]);
	curseg = single(nii.img(:));
	curidx = (counter+1):(counter + pts_from_brain);
	labels(curidx) = single(curseg(ridx));

	% Loop over directories to get images
	tmp = LoadCombinedProbsAsFeatures(brain,prob_dirs,type_dirs,ridx);
	feature_mat( curidx,: ) = tmp;
	counter = counter + pts_from_brain;
end

% Save matrix to binary 
ff = [brats,'/userbrats/BRATS17shashank/metadata/',mdlstr,'.dd.',num2str(dd),'.XX.bin'];
fprintf('Saving matrix to %s\n',ff);
fid = fopen(ff,'w');
fwrite(fid, feature_mat,'single');
fclose(fid);

% Save labs to binary
ff = [brats,'/userbrats/BRATS17shashank/metadata/',mdlstr,'.dd.',num2str(dd),'.yy.bin'];
fprintf('Saving labels to %s\n',ff);
fid = fopen(ff,'w');
fwrite(fid,labels,'single');
fclose(fid);
