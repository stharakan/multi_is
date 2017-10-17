% Add path to other code
addpath([getenv('BRATSREPO'),'/matlab/general/']);
SetPath;
SetVariablesTACC;
disp('Set path and variables')

% Location of brains --> going to set to augtest 
brn_dir = [brats,'/preprocessed/augTestData/meanrenorm/'];
brn_dir = [brats,'/preprocessed/trainingdata/meanrenorm/'];
%brn_dir = [brats,'/preprocessed/validationdata/meanrenorm/'];
brncell = GetBrnList(brn_dir);
%brncell = {'Brats17_2013_10_1'};
brncell = brncell(1);
disp('Got brain list')

% Location of feature output 
feat_dir = [brats,'/userbrats/BRATS17tharakan/meanrenormTrn/']  ;
%feat_dir = [getenv('SCRATCH'),'/meanrenormTrn/'];
%feat_dir = [brats,'/userbrats/BRATS17siddhant/meanrenormVal/']  ;

% brns / features
feature_types = {'gabor'};
feature_types = {'int'};
brns = length(brncell);

for bi = 1:brns
	brnname = brncell{bi};
	brnname = strtrim(brnname);
	disp(['Computing brain ',num2str(bi),' of ', num2str(length(brncell))]);
	disp(['Brain name: ',brnname]);

	% Load brain
	tic;
	%[flair,t1,t1ce,t2,seg] = ReadBratsBrain(brn_dir,brnname);
	[flair,t1,t1ce,t2] = ReadIdxBratsBrain(brn_dir,brnname);
	tt = toc;
	disp(['Loading brain took ',num2str(tt),' seconds']); 

	% nzidx, save
	nzidx = single(find(flair));
	%nzidx = nzidx(1:1500);
	nn = length(nzidx);
	filenm = [feat_dir,brnname,'.nn.',num2str(nn),'.idx.bin'];
	fid = fopen(filenm,'w');
	%fid.Timeout = 1000;
	fwrite(fid,nzidx,'single');
	fclose(fid);
	
	if 0
	fid = fopen(filenm,'r');
	nzidx2 = fread(fid,Inf,'*single');
	fclose(fid);

	after_write = size(nzidx2)
	pre_write = size(nzidx)

	if sum(after_write == pre_write) == 2
		normdiff = norm(nzidx2 - nzidx)/norm(nzidx)
	end
	end

	% Compute features
	for fi = 1:length(feature_types)
		feat = feature_types{fi};
		filenm = [feat_dir,brnname,'.nn.',num2str(nn),'.dd.'];

		switch feat
		case 'int'
			disp('Computing int');
			tic
			GF = GetIntFeatures(flair(nzidx),t1(nzidx),t1ce(nzidx),t2(nzidx));
			filenm = [filenm,'4.int.bin'];
			
		case 'gabor'
			disp('Computing gabor');
			GF = GetGaborFeatures(flair,t1,t1ce,t2);
			GF = GF(nzidx,:);
			filenm = [filenm,'288.gabor.bin'];
		end

		GF = single(GF);

		% save
		fid = fopen(filenm,'w');
		fwrite(fid,GF,'single');
		fclose(fid);
		tt = toc;
		disp(['Took ',num2str(tt),' seconds']);
		
	
		if 0
		fid = fopen(filenm,'r');
		GF2 = fread(fid,Inf,'*single');
		fclose(fid);

		GF2 = reshape(GF2,[],4);
		after_write = size(GF2)
		pre_write = size(GF)

		if sum(after_write == pre_write) == 2
			normdiff = norm(GF2 - GF,'fro')/norm(GF,'fro')
		end
		end

		if 0
		save([filenm,'.mat'],'GF');
		tmp = load([filenm,'.mat']);
		GF3 = tmp.GF;

		after_write = size(GF3)
		pre_write = size(GF)

		if sum(after_write == pre_write) == 2
			normdiff = norm(GF3 - GF,'fro')/norm(GF,'fro')
		end
		end

	end


end

