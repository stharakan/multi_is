clear all; clear globals;
SetPath;
SetAtlasVariables;
SetVariablesTACC;

hist_ref = dir([jakob_dir,'/jakob_t1_240x240x155_meanrenorm.nii.gz']);
ref = load_untouch_nii([jakob_dir,hist_ref(1).name]); 
original_dir = atlas20_meanrenorm_dir;  
brains = {'0010Y01','0010Y02'};
new_dir = [brats,'/userbrats/BRATS17naveen15/temp_histmatch_to_jakob/atlases/'];
[status, msg, msgid] = mkdir(new_dir);
 
save_files = true;
seg_save_files = false;
patient = false;

for bidx=1:length(brains)
  brain = brains{bidx};
  cprintf('Blue', 'Processing  brain %d:  %s\n', bidx, brain);
  if save_files, [status, msg, msgid] = mkdir([new_dir,brain]); disp([new_dir,brain]); end;
  
  if seg_save_files
    gtr=dir([original_dir,brain,'/*segmented*gz']);
    if ~isempty(gtr), system(sprintf('ln -s %s %s',[original_dir,brain,'/',gtr.name],[new_dir,brain,'/',gtr.name])); end;
  end 

  if patient
  	tmp=dir([original_dir,brain,'/*_t1_*normaff*gz']);
  else
	tmp=dir([original_dir,brain,'/*_cbq_*nii.gz']);
  end
  for jj=1:length(tmp)
    mri = load_untouch_nii([original_dir,brain,'/',tmp(jj).name]);
    newmri = mri;
    newmri.img = imhistmatchn(mri.img, ref.img,255);
    if save_files
        save_untouch_nii(newmri, [new_dir,brain,'/',tmp(jj).name]);
    end

  end
  
end
