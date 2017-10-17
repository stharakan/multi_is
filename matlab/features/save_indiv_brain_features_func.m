function [] = save_indiv_brain_features_func(section,tot_sections) 
% Designed to be called from multiple run files: each job should 
% pass the same second argument, but a different first argument. 
% They would then complete each section.

% Add path to other code
addpath([getenv('BRATSREPO'),'/matlab/general/']);
SetPath;
SetVariablesTACC;
disp('Set path and variables')

% Location of brains --> going to set to augtest 
brn_dir = [brats,'/preprocessed/augTestData/meanrenorm/'];
%brn_dir = [brats,'/preprocessed/trainingdata/meanrenorm/'];
%brn_dir = [brats,'/preprocessed/validationdata/meanrenorm/'];
brncell = GetBrnList(brn_dir);
%brncell = {'Brats17_2013_10_1'};
%brncell = brncell(1:2);
disp('Got brain list')

% Location of feature output 
feat_dir = [brats,'/userbrats/BRATS17rmoza/meanrenormTrn/']  ;
feat_dir = [brats,'/userbrats/BRATS17rmoza/meanrenormTst/']  ;
%feat_dir = [getenv('SCRATCH'),'/meanrenormTrn/'];
%feat_dir = [brats,'/userbrats/BRATS17siddhant/meanrenormVal/']  ;

% brns / features
feature_types = {'int','gabor'};
%feature_types = {'gabor'};
%feature_types = {'int'};
brns = length(brncell);
bpsect = floor(brns/tot_sections);
section_idx = GetSectionIdx(section,tot_sections,brns);
brncell = brncell(section_idx);

disp('updated brain list..')

for bi = 1:length(brncell)

	brain = brncell{bi};
	if strcmp(brain, 'Brats17_2013_10_1')
		fprintf('Brain %s is being skipped\n',brain)
		continue
	end

	fprintf('Loading %d out of %d (%s)\n',bi,length(brncell),brain);
	
	% Load brain
	tic;
	[flair,t1,t1ce,t2] = ReadIdxBratsBrain(brn_dir,brain);
	tt = toc;
	fprintf(' \n',num2str(tt)); 

	% nzidx, save
	nzidx = single(find(flair));
	nn = length(nzidx);
	filenm = [feat_dir,brain,'.nn.',num2str(nn),'.idx.bin'];
	fid = fopen(filenm,'w');
	fwrite(fid,nzidx,'single');
	fclose(fid);

	if 0
	fid = fopen(filenm,'r');
	nzidx2 = fread(fid,Inf,'single');
	fclose(fid);

	after_write = size(nzidx2)
	pre_write = size(nzidx)

	if sum(after_write == pre_write) == 2
		normdiff = norm(nzidx2 - nzidx)/norm(nzidx)
	end
	end



	fprintf(' Brain %s has %d nonzero features to compute\n',brain,nn);

	% Compute features
	for fi = 1:length(feature_types)
		feat = feature_types{fi};
		filenm = [feat_dir,brain,'.nn.',num2str(nn),'.dd.'];

		switch feat
		case 'int'
			%disp(' Computing int');
			tic
			GF = GetIntFeatures(flair(nzidx),t1(nzidx),t1ce(nzidx),t2(nzidx));
			filenm = [filenm,'4.int.bin'];
			
		case 'gabor'
			%disp(' Computing gabor');
			GF = GetGaborFeatures(flair,t1,t1ce,t2);
			GF = GF(nzidx,:);
			filenm = [filenm,'288.gabor.bin'];
		otherwise
			disp(' No features to compute')

		end

		% save
		GF = single(GF);
		fid = fopen(filenm,'w');
		fwrite(fid,GF,'single');
		fclose(fid);
		tt = toc;
		fprintf(' Saved brain %s %s features (%d by %d) in %d secs\n',brain,feat,size(GF,1),size(GF,2),tt);


		if 0
		fid = fopen(filenm,'r');
		GF2 = fread(fid,Inf,'single');
		fclose(fid);

		GF2 = reshape(GF2,[],4);
		after_write = size(GF2)
		pre_write = size(GF)

		if sum(after_write == pre_write) == 2
			normdiff = norm(GF2 - GF,'fro')/norm(GF,'fro')
		end
		end
		clear GF
	end


end

