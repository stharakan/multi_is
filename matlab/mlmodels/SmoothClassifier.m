SetPath;
SetVariables;
myload_nii = @(filename) load_untouch_nii(filename);
arr2vec = @(x) x(:);
save_dir = './results_smooth/';

% directory with classifier results: must have _only_ one file per BRAIN
if ~exist('brains'), brains=brats17val_brains; end
if ~exist('original_dir'), original_dir=brats17val_original_dir; end;
if ~exist('classifier_dir'), classifier_dir = './res_val_kde_wt/';  end; 
if exist('whichbrains'), brains = {brains{whichbrains}}; end;

%%
jkbcb = myload_nii(jakob_cb_240_file);   % to remove the cerebellum.
cimb = jkbcb.img;
%%
for bidx=1:length(brains)
  brain = brains{bidx};
  cprintf('Blue', 'Processing  brain %d:  %s\n', bidx, brain);

  clpath = dir( [classifier_dir, brain, '*nii.gz'] );
  fname = [clpath.folder,'/',clpath.name];
  fprintf('Read classifier probabilities\n');
  nii = myload_nii( fname );
  nii.img = single(nii.img);

  niiBM = BasicMorph(nii.img);
  niiSU = SupportAndBB(nii.img);

  if isempty(dir(save_dir)), mkdir(save_dir); end;
  fprintf('Saving files..');
  niiout = nii;
  niiout.img = niiBM .* (1-cimb);
  save_untouch_nii(niiout, [save_dir,'/',brain,'.probBM.nii.gz']);
  niiout.img = niiSU .* (1-cimb);
  save_untouch_nii(niiout, [save_dir,'/',brain,'.probSU.nii.gz']);
  fprintf('..done\n');
end;

