% addpath, variables
addpath([getenv('MISDIR'),'/matlab/general/']);
SetPath;
SetVariablesTACC;
myload_nii = @(filename) load_untouch_nii(filename);
brats = getenv('BRATSDIR');

% params
sfbs = [0.7,1.0,2.5];
nangs = 8; nfreqs = 3; naf = nangs*nfreqs;
modalities = 4;
%scratch_dir = [getenv('SCRATCH'),'/gabor.w4/'];
scratch_dir = [getenv('SCRATCH'),'/training_matrices/'];
tot_gabor_features = 160;
mdlstr = 'BRATS_50M_meanrenorm';
patch_sizes = [33];
Xflag = false;
Yflag = true;

% index file/ brain lists
idxstr = 'BRATS_50M_Meta';
idxfile = [training_model_dir,idxstr,'.idxs.mat'];
fprintf('Loading indices from %s\n',idxfile);
idxfile = load(idxfile);
lggs = length(idxfile.lggcell);
hggs = length(idxfile.hggcell);
brn_dir = [brats,'/preprocessed/trainingdata/meanrenorm/'];
brncell = GetBrnList(brn_dir);

% load full y vec for checking purposes
ff = [brats,'/userbrats/BRATS17tharakan/meanrenorm/',mdlstr,'.dd.',...
  num2str(tot_gabor_features),'.yy.bin'];
ff = [scratch_dir,'gabor50M.ps.33.seg.bin'];
fid = fopen(ff);
true_labs = fread(fid,Inf,'*single');
fclose(fid);


% initialize patch probs vec storage
patch_probs_vec = zeros(length(true_labs),length(patch_sizes),'single');

% Loop over brains
bla_idx = 1:(length(brncell));
counter = 0; ytot = [];
for ii = bla_idx
  brain = brncell{ii};
  
  % Get idx of points to train on
  if ii <= lggs
    cell_no = ii;
    ridx = idxfile.ridxc_lgg{ii};
    brain2 = idxfile.lggcell{ii};
    brn_type = 'LGG';
  else
    cell_no = ii - lggs;
    ridx = idxfile.ridxc_hgg{cell_no};
    brain2 = idxfile.hggcell{cell_no};
    brn_type = 'HGG';
  end
  %if ~strcmp(brain,brain2)
  %  fprintf('brncell: %s | idxfile: %s\n',brain,brain2);
  %end
  pts_from_brain = length(ridx);
  brain = brain2;
  
  if pts_from_brain == 0
    fprintf('Brain %s has %d features to load\n',brain,pts_from_brain);
    continue
  end
  
  if strcmp(brain, 'Brats17_2013_10_1')
    fprintf('Brain %s is being skipped\n',brain)
    continue
  end
  fprintf('Loading %s no %d (%s), has %d features \n',brn_type,cell_no,brain,pts_from_brain);
  
  % Load seg file
  file_base = [brats,'/userbrats/BRATS17shashank/trainingdata/meanrenorm/',brain,'/',brain];
  str1 = myload_nii([file_base,'_seg_aff.nii.gz']);
  seg_my = str1.img;
  [vert,horz,slc_per_brn] = size(seg_my);
  brns = 1;
  
  % check that we're the same
  rr = length(ridx);
  cur_brain_tot_idx = (counter+1):(counter+rr);
  tr_nnz = true_labs(cur_brain_tot_idx ) ;
  my_nnz = seg_my(ridx);
  tr_my = norm(double(tr_nnz(:)) - double(my_nnz(:)))/norm(double(tr_nnz));
  fprintf('Truth to myload: %3.1f\n',tr_my);
  
  % ytot
  yupd = single(my_nnz(:) ~=0);
  ytot = [ytot;yupd(:)];
  
  % Loop over patch sizes
  for pp = 1:length(patch_sizes)
    psize = patch_sizes(pp);

    % extract patch at this size
    [ ~,feat_idx ] = PatchIdx( psize,vert,horz,slc_per_brn,brns,ridx );
    cur_patches = seg_my(feat_idx);
    [ flair,t1,t1ce,t2] = ReadIdxBratsBrain( brn_dir,brain )
    

    % get patches
    flair_patch = flair(feat_idx);
    t1_patch = t1(feat_idx);
    t1ce_patch = t1ce(feat_idx);
    t2_patch = t2(feat_idx);
     
    % load into patch_matrices 
    patch_probs_vec(cur_brain_tot_idx,pp) = single(wt_probs);
  end

  % end brain loop
  counter = counter + rr;
end

% new loop over patch sizes
for pp = 1:length(patch_sizes)
  psize = patch_sizes(pp);

   % save each probability vec
  fname = [scratch_dir,'gabor50M.ps.',num2str(psize), ...
    '.yy.bin'];
  fprintf('Saving psize %2.1f to %s\n',psize,fname);
  fid = fopen(fname,'w+');
  fwrite(fid,single(patch_probs_vec(:,pp)),'single');
  fclose(fid);

end

%fname = [scratch_dir,'gabor50M.ps.ALL', ...
%  '.yy.bin'];
%fprintf('Saving sfb all to %s\n',fname);
%fid = fopen(fname,'w+');
%fwrite(fid,single(ytot),'single');
%fclose(fid);


end
