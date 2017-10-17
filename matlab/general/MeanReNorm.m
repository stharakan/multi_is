clear all; clear globals;
SetPath;
SetVariables;

original_dir = brats17tra_original_dir;
brains=GetBrnList(original_dir);    
new_dir = [brats,'/preprocessed/trainingdata/meanrenorm/'];
mkdir(new_dir);

save_files = false;
plot_histogram = true;

%%

figure(1); clf;hold on;
figure(2); clf;hold on;
for bidx=1:length(brains)
  brain = brains{bidx};
  cprintf('Blue', 'Processing  brain %d:  %s\n', bidx, brain);
  if save_files, mkdir([new_dir,brain]); end;
  
  if save_files
    gtr=dir([original_dir,brain,'/*seg_aff*gz']);
    if ~isempty(gtr), system(sprintf('cp %s %s',[original_dir,brain,'/',gtr.name],[new_dir,brain,'/',gtr.name])); end;
  end

  tmp=dir([original_dir,brain,'/*normaff*gz']);
  for jj=1:length(tmp)
    mri = load_untouch_nii([original_dir,brain,'/',tmp(jj).name]);
    oi = mri.img;
    va=nnzquantile(oi,[0.05,0.95]); 
    lo=va(1); 
    up=va(2);
    mu = mean( oi ( oi > lo & oi < up ) );
    ni = oi / mu;
    newmri = mri;
    newmri.img = ni;
    if save_files
        save_untouch_nii(newmri, [new_dir,brain,'/',tmp(jj).name]);
    end

    if plot_histogram
        if jj==1
            figure(1);
            histogram(ni(ni>0 & ni<4),20);  % new histogram.
            figure(2);
            histogram(oi(oi>0),20);  % new histogram.
        end
    end
  end
  
end
