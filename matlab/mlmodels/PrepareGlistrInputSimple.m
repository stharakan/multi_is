  SetPath;
  myload_nii = @(filename) load_untouch_nii(filename);

  allbrains = {'AAAC', 'AAMH', 'AAAN', 'AAMP', 'AAQD', 'AAWI', 'AAXN' };
  atlases = {'0093Y01',  '0097Y01',  '0002Y01',  '0390Y01',  '0094Y01',  '0099Y01',  '0386Y01',...
  '0392Y01',  '0098Y01',  '0095Y01',  '0100Y01',  '0004Y01',  '0102Y01',  '0096Y01'};
  %atlases = atlases{1:5};
  %%
  for bidx=1:length(allbrains)
  %bidx = 2; 
  brain = allbrains{bidx};

  fprintf('Processing %s\n', brain);

  %% These are the original MRI images.
  fprintf('Reading original MRI images \n');
  originaldir=[brats,'/preprocessed/PennValidationImagesPreprocessed/pre-norm-aff/',brain];
  tmp=dir([originaldir,'/*normaff*gz']);
  for jj=1:length(tmp)
    mri{jj}=myload_nii([originaldir,'/',tmp(jj).name]);
  end

  nnzero_voxels = mri{1}.img>0;
  zero_voxels = mri{1}.img==0;
  nnzquantile = @(img,value) quantile(  img(nnzero_voxels(:)), value);

%% CLAIRE images
fprintf('Reading CLAIRE registration to atlases\n');
atlasesdir = [brats,'/preprocessed/diff_registered_to_atlases/PennValidationImages/claire/betav=5E-3/',brain,'/'];
atlases = {'0002Y01', '0004Y01','0093Y01'}; 
loa = length(atlases);
for jj=1:loa
dirpath = [atlasesdir,atlases{jj},'/'];
res0{jj} = myload_nii( [dirpath,atlases{jj},'_to_',brain,'_residual-t=0.nii.gz'] ); 
res1{jj} = myload_nii( [dirpath,atlases{jj},'_to_',brain,'_residual-t=1.nii.gz'] );
aseg{jj} = myload_nii( [dirpath,atlases{jj},'_to_',brain,'_segmented.nii.gz'] );
r3(jj) = norm(res1{jj}.img(:))/norm(res0{jj}.img(:));   % r3: relative residual; this is a global metric not voxelwize.

nres1{jj} = res1{jj};
arr = res0{jj}.img(:); arr = arr( nnzero_voxels(:) ); r0 = quantile(arr,0.8);
nres1{jj}.img = res1{jj}.img / r0;
end
fprintf('Done reading CLAIRE images\n');

%% DEMONS images
fprintf('Reading DEMONS registration to atlases\n');
conf= 'exp-symmetric-iter-10x5x2-nx-256x256x256-sigmaU-0.0-sigmaD-3.5/';
atlasesdir = [brats,'/preprocessed/diff_registered_to_atlases/PennValidationImages/demons/',conf,brain,'/'];
atlases = {'0002Y01', '0004Y01','0093Y01'};
for jj=1:loa
dirpath = [atlasesdir,atlases{jj},'/'];
res0{jj+loa} = myload_nii( [dirpath,atlases{jj},'_to_',brain,'_residual-t=0.nii.gz'] );
res1{jj+loa} = myload_nii( [dirpath,atlases{jj},'_to_',brain,'_residual-t=1.nii.gz'] );
aseg{jj+loa} = myload_nii( [dirpath,atlases{jj},'_to_',brain,'_segmented.nii.gz'] );
r3(jj+loa) = norm(res1{jj+loa}.img(:))/norm(res0{jj+loa}.img(:)); 

nres1{jj+loa} = res1{jj+loa};
arr = res0{jj+loa}.img(:); arr = arr( nnzero_voxels(:) ); r0 = quantile(arr,0.8);
nres1{jj+loa}.img = res1{jj+loa}.img / r0;
end
fprintf('Done reading DEMONS images\n');

%% combine votes
fprintf('Atlas voting\n')
w=1./r3;
w = w/sum(w);
labels = [10, 50, 150, 250]; 
labelnames = {'CS','VE', 'GM', 'WM', 'BG'};

for la = 1:length(labels)
atlaspr{la} = zeros*aseg{1}.img;
for jj=1:2*loa
      imj = (aseg{jj}.img == labels(la)) .*  w(jj);
      atlaspr{la} = atlaspr{la} + imj;
  end
end
fprintf('Done ATLAS voting\n');

%% normalize probabilities
tmp=zeros*aseg{1}.img;
for la=1:length(labels)
    tmp = tmp + atlaspr{la};
end
tmp = 1./tmp;
tmp(tmp==inf)=0;
for la=1:length(labels)
  atlaspr{la} = atlaspr{la}.*tmp;
end

%% Read jacob to remove cerebellum
jcb = myload_nii([brats,'/atlas_data/jakob/jakob_prob_cb_256x256x256.nii.gz']);
  

%% load segmentations and probabilities
fprintf('Creating tumor probabilities using machine learning results\n');
novwtdir = [brats,'/classification/penndata_results/NOvWTPenn/'];
alveddir = [brats,'/classification/penndata_results/ALvEDPenn/'];
wmgp = myload_nii([novwtdir,brain,'.gabor.probs.WT.nii.gz']);
wmip = myload_nii([novwtdir,brain,'.int.probs.WT.nii.gz']);
wmgs = myload_nii([novwtdir,brain,'.gabor.seg.nii.gz']);
wmis = myload_nii([novwtdir, brain,'.int.seg.nii.gz']);
%%
edgp = myload_nii([alveddir,brain,'.gabor.probs.ED.nii.gz']);
edip = myload_nii([alveddir,brain,'.int.probs.ED.nii.gz']);
edgs = myload_nii([alveddir,brain,'.gabor.seg.nii.gz']);
edis = myload_nii([alveddir, brain,'.int.seg.nii.gz']);
%% simple combination of machine learning results
% taking voting segmentation (since we only have two schemes now), and then
% multiply probabilities (assuming independence, which is not true of
% course, but what can we do?

wtprob = mri{1};
img  = wmgs.img .* wmis.img .* wmgp.img .* wmip.img;   % KEY LINE TO COMPTUE PROBABILITY
wtprob.img = img .* (1-jcb.img);  % tumors are unlikely in cerebullum

edprob = mri{1};
img  = edgs.img .* edis.img .* edgp.img .* edip.img;   % KEY LINE TO COMPTUE PROBABILITY
edprob.img = img;

%%
% Processing to define bounding box;
sphere_se = strel('sphere',3);
cube_se = strel('cube',3);
close all;

%thresholding edema

%% One image based on edema classification
edtv = nnzquantile(edprob.img(:),0.95); %tv: threshold value
edprob.img = edprob.img .* edprob.img>edtv;
edprob.img = imerode(edprob.img, cube_se);
edprob.img = imdilate(edprob.img, cube_se);
%view_nii(edprob)

%% thresholding and eroding segmenations
%wter = wmis; wter.img = wmis.img .* wmgs.img;
% wter.img = imerode( imerode(wmis.img, cube_se), cube_se);
% wter.img = imdilate( imdilate(wter.img, cube_se), cube_se);
% wter.img = wmis.img .*wmgs.img .* wter.img;
%view_nii(wter);
k
%% Another image based on smoothing tumor probabilities
smwt = wtprob;
smwt.img = imerode(smwt.img,cube_se);
smwt.img = imgaussfilt3(wtprob.img,6);
smwt95tv = nnzquantile(smwt.img(:),0.95);
smwt99tv = nnzquantile(smwt.img(:),0.99);
smwt99 = smwt;
smwt95 = smwt;
smwt99.img = smwt.img .* (smwt.img > smwt99tv);
smwt95.img = smwt.img .* (smwt.img > smwt95tv);
%view_nii(smwt);



%% then define the probability of tissue as 1-wtprob.img
for la=1:length(labels)
  noprob{la}=mri{1};
  noprob{la}.img = double(atlaspr{la}.* (1-wtprob.img));
  noprob{la}.hdr.dime.bitpix = 64;
  noprob{la}.hdr.dime.datatype = 64;
end
noprob{la+1}=noprob{la};
noprob{la+1}.img = double(zero_voxels);  % setup background
wtprob.img = double(wtprob.img);
wtprob.hdr.dime.bitpix = 64;
wtprob.hdr.dime.datatype = 64;

%Combine  CSF and VE
noprob{2}.img = noprob{1}.img + noprob{2}.img;

% normalize probabilities.
tot = wtprob.img;
for la=2:length(labels) % we're starting from label 2 because we have combined the probabilites
  tot = tot + noprob{la}.img;
end
tot = 1./tot;  tot(tot==inf)=0;
wtpob.img = wtprob.img .* tot;
for la=2:length(labels)
   noprob{la}.img = noprob{la}.img .* tot;
end


%% save files
fprintf('Saving files\n');
save_untouch_nii( wtprob, [brain, '.glistr0.probs.WT.nii.gz']);
for la=2:length(labels)+1
  save_untouch_nii( noprob{la}, [brain,'.glistr0.probs.',labelnames{la},'.nii.gz']);
end
save_untouch_nii( smwt95, [brain,'.glistr0.BB.WT95.nii.gz']);
save_untouch_nii( smwt99, [brain,'.glistr0.BB.WT99.nii.gz']);
save_untouch_nii( edprob, [brain,'.glistr0.BB.ED.nii.gz']);
fprintf('Done saving files\n');

end



