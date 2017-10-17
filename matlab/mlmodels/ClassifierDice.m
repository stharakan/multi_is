SetPath;
SetVariables;
myload_nii = @(filename) load_untouch_nii(filename);

seg_tv = 0.2;  % segmentation threhshold value

%brains
%original_dir = brats17rsa_originalhgg_dir;  % PATH to origianal MRI
%classifier_dir = './res_sample_kde_wt/';  

% THIS IS THE DIRECTORY THAT HAS THE CLASIFICATION  RESULTS.
% it should have one         one *nii.gz file per brain
% make sure you hav


%%
for bidx=1:length(brains)
  brain = brains{bidx};
  cprintf('Blue', 'Processing  brain %d:  %s\n', bidx, brain);
  %% Load ground truth
  gtr=dir(['./seg_tra/',brain,'/*seg_aff.nii.gz']);  
  hasgtr=~isempty(gtr);
  if hasgtr
    fprintf('Read gr-truth.');
    gtr = myload_nii([original_dir,brain,'/',gtr.name]);
    gtrnovwt = gtr.img>0;  
    if sum(gtrnovwt(:))  < 1, warning('Ground truth labels is empty, something   wrong witht he file\n'); end
  end
  
  %% load probability
  clpath = dir( [classifier_dir, brain, '*.nii.gz'] );
  fname = [clpath.folder,'/',clpath.name];
  fprintf('Read classifiier. ');
  nii = myload_nii( fname );
  seg = nii.img > seg_tv;
  dice(bidx) = compute_dice( gtrnovwt, seg ); 
  cprintf('*Blue', 'Dice = %.2f\n', dice(bidx) );
end
 

