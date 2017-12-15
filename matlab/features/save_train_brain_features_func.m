function [] = save_train_brain_features_func(section,tot_sections) 
% Designed to be called from multiple run files: each job should 
% pass the same second argument, but a different first argument. 
% They would then complete each section.

% Add path to other code
addpath([getenv('MISDIR'),'/matlab/general/']);
SetPath;
SetVariablesTACC;
disp('Set path and variables')

% Location of brains --> going to set to augtest 
%brn_dir = [brats,'/preprocessed/validationdata/bratsvalidation_240x240x155/pre-norm-aff/'];
brn_dir = [brats,'/preprocessed/trainingdata/meanrenorm/'];
%brn_dir = [brats,'/preprocessed/validationdata/meanrenorm/'];
%brn_dir = [brats,'/preprocessed/augTestData/meanrenorm/'];
brncell = GetBrnList(brn_dir);
disp('Got brain list')

% load index file
idxstr = 'BRATS_50M_Meta';
idxfile = [training_model_dir,idxstr,'.idxs.mat'];
fprintf('Loading indices from %s\n',idxfile);
idxfile = load(idxfile);
lggs = length(idxfile.lggcell);
hggs = length(idxfile.hggcell);

% Location of feature output 
%feat_dir = [brats,'/classification/Brats17TrainingDataSample/'];
%feat_dir = [brats,'/userbrats/BRATS17shashank/meanrenorm_val/']  ;

bw = 2;
no = 8; 
ang_max = 180 - ( (180)/no );
angles = linspace(0,ang_max,no);
for gi = 1:5
    wv = 2^gi;
    if wv < (bw * pi / sqrt(log(2)/2 ) )
        gi_idx = (1:length(angles) ) + length(angles) * (gi-1);
	gaborfilts(gi_idx) = gabor(wv,angles,'SpatialFrequencyBandwidth',...
      	    GetSFBFromOthers(wv,bw),'SpatialAspectRatio',1.0);
    end

end

dd = length(gaborfilts)
feat_dir = [getenv('SCRATCH'),'/training_features/b',num2str(bw),'/']  ;
mkdir(feat_dir);

% brns / features
feature_types = {'window'};
brns = length(brncell);
bpsect = floor(brns/tot_sections);

section_idx = GetSectionIdx(section,tot_sections,brns);
brncell = brncell(section_idx);
psize = bw*2 + 1
disp('updated brain list..')
brncell;

for bi = 1:length(brncell)
	ii = section_idx(bi);
	% Get idx of points to train on
	if ii <= lggs
		cell_no = ii;
		ridx = idxfile.ridxc_lgg{ii};
		brn_type = 'LGG';
		brain = idxfile.lggcell{ii};
	else
		cell_no = ii - lggs;
		ridx = idxfile.ridxc_hgg{cell_no};
		brain = idxfile.hggcell{cell_no};
		brn_type = 'HGG';
	end
	pts_from_brain = length(ridx);
	
	if pts_from_brain == 0
		fprintf('Brain %s has %d features to load\n',brain,pts_from_brain);
		continue
	end

	if strcmp(brain, 'Brats17_2013_10_1')
		fprintf('Brain %s is being skipped\n',brain)
		continue
	end

	fprintf('Loading %s no %d (%s), has %d features \n',brn_type,cell_no,brain,pts_from_brain);
	
	brnname = brain;
	

	% Load brain
	tic;
	%[flair,t1,t1ce,t2,seg] = ReadBratsBrain(brn_dir,brnname);
	%[flair,t1,t1ce,t2] = ReadAffineBratsBrain(brn_dir,brnname);
	[flair,t1,t1ce,t2,seg] = ReadIdxBratsBrain(brn_dir,brnname);
	tt = toc;
	disp(['Loading brain took ',num2str(tt),' seconds']); 
	fprintf('Brain %s has %d features to load\n',brain,pts_from_brain);

	% nzidx, save
	nzidx = find(flair);
	nn = length(nzidx);
	filenm = [feat_dir,brnname,'.nn.',num2str(nn),'.idx.bin'];
	fid = fopen(filenm,'w');
	fwrite(fid,single(nzidx),'single');
	fclose(fid);

	% Save output labels?
	if exist('seg','var') 
		%filenm = [feat_dir,brnname,'.nn.',num2str(nn),'.labs.bin'];
		filenm = [feat_dir,brnname,'.nn.',num2str(pts_from_brain),'.labs.bin'];
		fid = fopen(filenm,'w');
		fwrite(fid,single(seg(ridx)),'single');
		%fwrite(fid,single(seg(nzidx)),'single');
		fclose(fid);
	end

	% Compute features
	for fi = 1:length(feature_types)
		feat = feature_types{fi};
		%filenm = [feat_dir,brnname,'.nn.',num2str(nn),'.dd.'];
		filenm = [feat_dir,brnname,'.nn.',num2str(pts_from_brain),'.dd.'];

		switch feat
		case 'window'
			disp('Computing window');
			tic
			GF = Get2DWindowFeatures(psize,ridx,flair,t1,t1ce,t2);
			dd = size(GF,2);
			filenm = [filenm,num2str(dd),'.window.bin'];
		case 'int'
			disp('Computing int');
			tic
			GF = GetIntFeatures(flair(nzidx),t1(nzidx),t1ce(nzidx),t2(nzidx));
			filenm = [filenm,'4.int.bin'];
			
		case 'gabor'
			disp('Computing gabor');
			GF = GetSpecificGaborFeatures(gaborfilts, flair,t1,t1ce,t2);
			%GF = GF(nzidx,:);
			GF = GF(ridx,:);
			%fprintf('Norm of gabor features: %3.1f',norm(GF(:)));
			filenm = [filenm,num2str(dd*4),'.gabor.bin'];
		otherwise
			disp('No features to compute')

		end

		% save
		fid = fopen(filenm,'w');
		fwrite(fid,single(GF),'single');
		fclose(fid);
		tt = toc;
		disp(['Took ',num2str(tt),' seconds']);
	end


end

