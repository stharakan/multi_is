function [] = meta_postprocess_func(brn_type,num,section,tot_sections)

addpath([getenv('BRATSREPO'),'/matlab/general/']);
SetPath;
SetVariablesTACC;

switch brn_type
case 'val'
brain_dir = brats17val_original_dir;
save_dir = [getenv('BRATSDIR'),'/classification/metadata_results/validation_results/'];
case 'tst'
brain_dir = brats17tst_original_dir;
save_dir = [getenv('BRATSDIR'),'/classification/metadata_results/augTestData_results/'];
end

brains = GetBrnList(brain_dir);

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

outfile = [getenv('SCRATCH'),'/',brain,'.meta',num2str(num),'.probs.bin'];
% Read in output, written to scratch
fid = fopen(outfile,'r');
meta_probs = fread(fid,Inf,'single');
fclose(fid);

% Save to nii
niiout = nii;
new_img = zeros(size(nii.img));
new_img(brain_mask) = meta_probs;
niiout.img = new_img;
save_untouch_nii( niiout, [save_dir,brain,'.meta',num2str(num),'.WT.nii.gz'] );
end


end
