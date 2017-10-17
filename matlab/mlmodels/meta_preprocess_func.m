function [] = meta_preprocess_func(brn_type,num,section,tot_sections) 
addpath([getenv('BRATSREPO'),'/matlab/general/']);
SetPath;
SetVariablesTACC;


% Get Brain name, probtypes, and probdir, braindir
switch brn_type
case 'val'
	[prob_dirs,probtypes] = InitializeValDirs(brats,num);
	brain_dir = brats17val_original_dir;

case 'tst'
	[prob_dirs,probtypes] = InitializeTstDirs(brats,num);
	brain_dir = brats17tst_original_dir;
end

%probtypes = { 'probsAll','segMorph','probsAvg','probsEnt','probsSup'};
%prob_dirs = [getenv('BRATSDIR'),'/combinedclassification/combclass_dnnprob_lgbm_kde_val/']; 

brains = GetBrnList(brain_dir);
dd = length(probtypes);


% get section
brns = length(brains);
section_idx = GetSectionIdx(section,tot_sections,brns);
brains = brains(section_idx);

for j=1:length(brains)
brain = brains{j};
  fprintf('Processing  brain %d out of %d subjects, named %s\n',j,length(brains),brain);

% Load segfile of that brain
flairfile = [brain_dir,brain,'/',brain,'_flair_normaff.nii.gz'];
nii = load_untouch_nii([flairfile]);
brain_mask = find( nii.img(:) );
np = length(brain_mask);

% Create features based on probtypes, save to scratch
feature_mat = LoadCombinedProbsAsFeatures(brain,prob_dirs,probtypes,brain_mask);
outdata = [getenv('SCRATCH'),'/',brain,'.meta.dd.',num2str(dd),'.bin'];
fid = fopen(outdata,'w');
fwrite(fid,feature_mat,'single');
fclose(fid);

end

end
