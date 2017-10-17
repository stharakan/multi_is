% addpath, variables
addpath([getenv('BRATSREPO'),'/matlab/general/']);
SetPath;
SetVariablesTACC;
myload_nii = @(filename) load_untouch_nii(filename);

% index file
mdlstr = 'BRATS_50M_meanrenorm';
idxstr = 'BRATS_50M_Meta';
idxfile = [training_model_dir,idxstr,'.idxs.mat'];
fprintf('Loading indices from %s\n',idxfile);
idxfile = load(idxfile);
lggs = length(idxfile.lggcell);
hggs = length(idxfile.hggcell);
brn_dir = [brats,'/preprocessed/trainingdata/meanrenorm/'];
brncell = GetBrnList(brn_dir);
feat_dir = [brats,'/userbrats/BRATS17shashank/meanrenorm/'];

% Find length of training data
dd = 288;
nn = sum(cellfun('length',[idxfile.ridxc_lgg(:);idxfile.ridxc_hgg(:)]));
fprintf('Initializing array of size %d by %d\n',nn,dd);
feature_mat = zeros(nn,dd,'single');
labels = zeros(nn,1,'single');
counter = 0;

% Loop over trn brains
tot_idx = 1:(lggs+hggs);
bla_idx = 1:(length(brncell));
for ii = bla_idx
	brain = brncell{ii};
	% Get idx of points to train on
	if ii <= lggs
		cell_no = ii;
		ridx = idxfile.ridxc_lgg{ii};
		brain2 = idxfile.lggcell{ii};
		brn_type = 'LGG';
	else
		cell_no = ii - lggs;
		ridx = idxfile.ridxc_hgg{cell_no};
		brain2 = idxfile.hggcell{cell_no};
		brn_type = 'HGG';
	end
	%if ~strcmp(brain,brain2)
	%	fprintf('brncell: %s | idxfile: %s',brain,brain2);
	%end
	pts_from_brain = length(ridx);
	brain = brain2;
	
	if pts_from_brain == 0
		fprintf('Brain %s has %d features to load\n',brain,pts_from_brain);
		continue
	end

	if strcmp(brain, 'Brats17_2013_10_1')
		fprintf('Brain %s is being skipped\n',brain)
		continue
	end
	fprintf('Loading %s no %d (%s), has %d features \n',brn_type,cell_no,brain,pts_from_brain);
	

	% Get data
	fileinfo = dir([feat_dir,brain,'*gabor*']);
	filenm = [feat_dir,fileinfo.name];
	fid = fopen(filenm,'r');
	GF = single(fread(fid,Inf,'single')); 
	GF = reshape(GF,[],dd);
	cur_nn = size(GF,1);
	fclose(fid);
	cur_idx = (counter + 1):(counter + cur_nn );
	feature_mat( cur_idx,:) = GF;
	
	%mm = mean(feature_mat(cur_idx,:),2);
	%fprintf(' FM Max mean: %5.2f\n FM Min mean: %5.2f\n',max(mm),min(mm));
	
	% Get labs
	fileinfo = dir([feat_dir,brain,'*labs*']);
	filenm = [feat_dir,fileinfo.name];
	fid = fopen(filenm,'r');
	LL = single(fread(fid,Inf,'single')); 
	labels(cur_idx) = LL;
	fclose(fid);

	counter = counter + pts_from_brain;
	%healthy = sum(labels(1:counter) == 0);
	%tumor = sum(labels(1:counter) ~= 0);
	%edema = sum(labels(1:counter) == 1);
	%enhance = sum(labels(1:counter) == 4);
	%fprintf(' NHealthy: %d, NTumor: %d\n NEdema: %d, NEnhance: %d ',healthy,tumor,edema,enhance);  
	%fprintf(' Counter ed: %d\n',counter );

end

feature_mat = feature_mat(1:counter,:);
labels = labels(1:counter);
mm = mean(feature_mat,2);
fprintf(' Max mean: %5.2f\n Min mean: %5.2f\n',max(mm),min(mm));
fprintf(' Squared Norm of FM: %3.1f\n',norm(feature_mat(:))^2 );

% Save matrix to binary 
ff = [brats,'/userbrats/BRATS17tharakan/meanrenorm/',mdlstr,'.dd.',num2str(dd),'.XX.bin'];
fprintf('Saving matrix to %s\n',ff);
fid = fopen(ff,'w');
fwrite(fid, feature_mat,'single');
fclose(fid);

% Save labs to binary
ff = [brats,'/userbrats/BRATS17tharakan/meanrenorm/',mdlstr,'.dd.',num2str(dd),'.yy.bin'];
fprintf('Saving labels to %s\n',ff);
fid = fopen(ff,'w');
fwrite(fid,labels,'single');
fclose(fid);
