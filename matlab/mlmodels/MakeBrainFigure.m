% Script to make brain figures
% 
SetPath;
addpath('./../readbrns/');
brains = {'Brats17_CBICA_AAM_1','Brats17_CBICA_ABT_1', ...
	'Brats17_TCIA_646_1','Brats17_UAB_3446_1'};

%% Choose brain, features and relevant slices
feature_type = 'gabor'; 
print_dir = [brats,'/tmp/tumor_seg_figs/'];
slc_idx = 55:80;
buf = 0;

%% Set path, get dirs
if strcmp(brains{1}(1:4),'Brat')
	% Brats brain
	brain_dir = [brats,'/preprocessed/validationdata/bratsvalidation_240x240x155/pre-norm-aff/'];

	% directory where WT probs are
	wt_probs_dir = [brats,'/tmp/jul23_glistr/240res/'];
else
	% penn brain
	brain_dir = [brats,'/preprocessed/PennValidationImagesPreprocessed/pre-norm-aff/'];
		
	% directory where WT probs are
	wt_probs_dir = [brats,'/tmp/jul20_glistr/'];
end


for bi = 1:length(brains)
	brain = brains{bi};

%% Load brain images
cur_brn = brain;
save_dir =[wt_probs_dir, brain,'/'  ];
[flair,~,t1ce] = ReadAffineBratsBrain(brain_dir,brain);
flair = rot90(flair,1);
t1ce = rot90(t1ce,1);


%% Load probability maps
	
% load WT probs
fprintf('WT probs ...\n');
WTfile = [save_dir,cur_brn,'.glistr0.probs.WT.nii.gz'];
WTnii = load_untouch_nii(WTfile);
WTprobs = WTnii.img;
brn_size = size(WTprobs);
WTprobs = rot90(WTprobs,-1);
WTprobs = WTprobs(:);

% Load ED probs
fprintf('EDi probs ...\n');
EDfile = [save_dir,cur_brn,'.',feature_type,'.glistr0.probs.ED.nii.gz'];
EDnii = load_untouch_nii(EDfile);
EDprobs = EDnii.img;
EDprobs = rot90(EDprobs,-1);

% Load EN probs
fprintf('EN probs ...\n');
ENfile = [save_dir,cur_brn,'.',feature_type,'.glistr0.probs.EN.nii.gz'];
ENnii = load_untouch_nii(ENfile);
ENprobs = ENnii.img;
ENprobs = rot90(ENprobs,-1);

% Load NE probs
fprintf('NE probs ...\n');
NEfile = [save_dir,cur_brn,'.',feature_type,'.glistr0.probs.NE.nii.gz'];
NEnii = load_untouch_nii(NEfile);
NEprobs = NEnii.img;
NEprobs = rot90(NEprobs,-1);

% Combine for probs 
Ptot = [ (1-WTprobs), EDprobs(:), ENprobs(:), NEprobs(:)];
[cstrength, cidx] = max(Ptot,[],2);
WTmask = cidx ~= 1;
cidx = reshape(cidx, brn_size);
WTmask = reshape(WTmask,brn_size);

RGBtrips = [0 0 0;
		0 1 1;
		1 0 1;
		1 1 0];

%% Make figure for slices
for ii = 1:(length(slc_idx))
  fprintf('Processing %d th out of %d slices\n',ii,length(slc_idx));
	slc = slc_idx(ii);

	% pick flair, t1ce
	fl = flair(:,:,slc);
	tt = t1ce(:,:,slc);

	% pick out WTmask,cidx
	c_cur = cidx(:,:,slc);
	WT_cur = WTmask(:,:,slc);

	% Turn cidx into image
	rgbidx = ind2rgb(double(c_cur),RGBtrips);

	% plot figure
	fcur = figure;
	subplot('position',[buf, buf, 0.25 - (2*buf), 1 - 2*buf]);
	imshow(fl)

	subplot('position',[0.25 + buf, buf, 0.25 - (2*buf), 1 - 2*buf]);
	imshow(tt)

	subplot('position',[0.5 + buf, buf, 0.25 - (2*buf), 1 - 2*buf]);
	imshow(WT_cur)

	subplot('position',[0.75 + buf, buf, 0.25 - (2*buf), 1 - 2*buf]);
	imshow(rgbidx)

	% print figure 
	fname = [print_dir,brain,'/',brain,'.',feature_type,'.slice.',num2str(slc)];
	print(fcur,[fname,'.eps'],'-depsc');
	print(fcur,[fname,'.pdf'],'-dpdf');
end


end

