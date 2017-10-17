% addpath, variables
addpath([getenv('BRATSREPO'),'/matlab/general/']);
SetPath;
SetVariablesTACC;
myload_nii = @(filename) load_untouch_nii(filename);

% params
sfbs = [0.7,1.0,2.5];
nangs = 8; nfreqs = 3; naf = nangs*nfreqs;
modalities = 4;
scratch_dir = [getenv('SCRATCH'),'/gabor.w4/'];
tot_gabor_features = 288;
mdlstr = 'BRATS_50M_meanrenorm';
patch_sizes = [13,9,5];
Xflag = true;
Yflag = true;

if Xflag
  
  % 50M file -- load
  ff = [brats,'/userbrats/BRATS17tharakan/meanrenorm/',mdlstr,'.dd.',...
    num2str(tot_gabor_features),'.XX.bin'];
  fprintf('Loading 50M data from %s\n',ff);
  fid = fopen(ff);
  gabor50M = fread(fid,Inf,'*single');
  fclose(fid);
  gabor50M = reshape(gabor50M,[],tot_gabor_features);

  % load into big guy
  tot_idx = repmat((1:(nangs*modalities))',1,length(sfbs)) + ...
    repmat((0:(length(sfbs)-1))*(nangs*modalities),nangs*modalities,1)
  tot_idx = tot_idx(:);
  Gtot = gabor50M(:,tot_idx); 
  fname = [scratch_dir,'gabor50M.wv.4.sfb.ALL', ...
    '.dd.', num2str(nangs *modalities * length(sfbs)), '.XX.bin'];
  fprintf('Saving all sfb to %s\n',fname);
  fid = fopen(fname,'w+')
  fwrite(fid,Gtot,'single');
  fclose(fid);
  clear Gtot
  
  % Save the different parts to scratch, then clear
  base_idx = (nfreqs.* (1:nangs) ) - 1;
  for ss = 1:length(sfbs)
    fprintf('Processing sfb %2.1f...\n',sfbs(ss));
    ss_idx = base_idx + (ss - 1)*naf;
    GG = zeros(size(gabor50M,1),nangs*modalities,'single');
    
    for mm = 1:modalities
      ss_mm_idx = ss_idx + (mm - 1)*(naf*length(sfbs));
      gg_mm_idx = (1:length(ss_idx)) + (mm-1)*(length(ss_idx));
      GG(:,gg_mm_idx) = single(gabor50M(:,ss_mm_idx));
    end
    
    % open new file and write
    fname = [scratch_dir,'gabor50M.wv.4.sfb.',num2str(sfbs(ss)), ...
      '.dd.', num2str(nangs *modalities), '.XX.bin'];
    fprintf('Saving sfb %2.1f to %s\n',sfbs(ss),fname);
    fid = fopen(fname,'w+')
    fwrite(fid,GG,'single');
    fclose(fid);
    
  end
  
end

if Yflag

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

      % get probabilities (avg over whole patch --> WT, ED, EN)
      wt_probs = cur_patches; wt_probs(wt_probs ~=0) = 1;
      wt_probs = mean(wt_probs,2);
       
      % load into patch_probs_vec 
      patch_probs_vec(cur_brain_tot_idx,pp) = single(wt_probs);
    end

    % end brain loop
    counter = counter + rr;
  end

  % new loop over patch sizes
  for pp = 1:length(patch_sizes)
    psize = patch_sizes(pp);

     % save each probability vec
    fname = [scratch_dir,'gabor50M.wv.4.sfb.',num2str(sfbs(pp)), ...
      '.yy.bin'];
    fprintf('Saving sfb %2.1f to %s\n',sfbs(pp),fname);
    fid = fopen(fname,'w+');
    fwrite(fid,single(patch_probs_vec(:,pp)),'single');
    fclose(fid);

  end
  
  fname = [scratch_dir,'gabor50M.wv.4.sfb.ALL', ...
    '.yy.bin'];
  fprintf('Saving sfb all to %s\n',fname);
  fid = fopen(fname,'w+');
  fwrite(fid,single(ytot),'single');
  fclose(fid);

  
end

