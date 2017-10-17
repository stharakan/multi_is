% Get Brain name, probtypes, and probdir, braindir
brain = 'Brats17_UAB_3456_1';
probtypes = { 'probsAll','segMorph',...
	'probsAvg','probsEnt','probsSup'};
prob_dir = [getenv('BRATSDIR'),'/combinedclassification/combclass_dnnprob_lgbm_kde_val/']; 
brain_dir = brats17val_original_dir;
save_dir = [getenv('BRATSDIR'),'/classification/metadata_results/'];

% Load segfile of that brain
flairfile = [brain_dir,brain,'/',brain,'_flair_normaff.nii.gz'];
nii = myload_nii([flairfile]);
brain_mask = find( nii.img(:) );
np = length(brain_mask);

% Create features based on probtypes, save to scratch
feature_mat = LoadCombinedProbsAsFeatures(brain,prob_dir,probtypes,brain_mask);
outdata = [getenv('SCRATCH'),'/',brain,'.meta.XX.out'];
fid = fopen(outdata,'w');
fwrite(fid,feature_mat,'single');
fclose(fid);

% Call python, save to scratch
% TODO write python func
outfile = [getenv('SCRATCH'),'/',brain,'.meta.out'];
%[~,ff] = system(['python LgbmEval ',outdata,' ',outfile,' ',num2str(np)]);
fid = fopen(outfile,'w');
fwrite(fid,single(ones(np,1)),'single');
fclose(fid);


% Read in output, written to scratch
fid = fopen(outfile,'r');
meta_probs = fread(fid,Inf,'single');
fclose(fid);

% Save to nii
niiout = nii;
new_img = zeros(size(nii.img));
new_img(brain_mask) = meta_probs;
niiout.img = new_img;
save_untouch_nii( niiout, [save_dir,brain,'.meta.WT.nii.gz'] );


