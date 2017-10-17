% script to combine binary classifiers. it has been tested only with WT but it should be easy to modify for arbitrary binary classificaiton. 
%clear all; clear globals;
SetPath;
SetVariables;
myload_nii = @(filename) load_untouch_nii(filename);
arr2vec = @(x) x(:);
save_dir = './results_comb/'; %
%save_dir = [];


% The 3 lines below need to be consistent
if 0
brains = {brats17trsa_hggbrains{1:19}};
original_dir = brats17trsa_originalhgg_dir;
classifier_dirs = {'./results_light/','./results_dnn_wt/', ...
                   './results_kde/', './results_5M_gabor/'};
end
if 1
    if ~exist('whichbrains')
        brains = brats17val_brains;
    else
        brains = {brats17val_brains{whichbrains}};
    end
    %brains = brats17val_brains;
    original_dir = brats17val_original_dir;
    classifier_dirs = {'./res_val_dnn_wt/','./res_val_lgbm_wt/','./res_val_kde_wt/'};
end

%%
for bidx=1:length(brains)
  brain = brains{bidx};
  cprintf('Blue', 'Processing  brain %d:  %s\n', bidx, brain);

  %% These are the original MRI images.
  T2dir=dir([original_dir,brain,'/*t2_*.nii.gz']);
  T2=myload_nii([original_dir,brain,'/',T2dir.name]);
  nnzvx = sum(T2.img(:)>0);  % number of nonzerovoxels
  gtr=dir([original_dir,brain,'/*seg_aff.nii.gz']);  
  hasgtr=~isempty(gtr);
  if hasgtr
    gtr = myload_nii([original_dir,brain,'/',gtr.name]);
    gtrnovwt = gtr.img>0;  
    if sum(gtrnovwt(:))  < 1, warning('Ground truth labels is empty, something is wrong witht he file\n'); end
  end
  
   %% load segmentations and probabilities
   numcl = length(classifier_dirs);
   for clidx =1:numcl
       clpath = dir( [classifier_dirs{ clidx }, brain, '*nii.gz'] );
       fname = [clpath.folder,'/',clpath.name];
       fprintf(' Read class%d', clidx);
       nii = myload_nii( fname ); nii.img = single(nii.img);
       s=BinEntropy(nii.img); if any(isnan(s(:))), warning('nan'); end;
       segW = BasicMorph(nii.img) .* max(0,(1-s));
       seg_tv=FindThreshold(nii.img,nnzvx);
       seg = nii.img > seg_tv;
       sbm=BasicMorph(nii.img);
       seg_tv = FindThreshold(sbm, nnzvx)
       segBM=   sbm > seg_tv;
       segSU=  SupportAndBB(nii.img);
       tmporig(:,:,:,clidx)  = nii.img;
       avg(:,:,:,clidx)   = nii.img;
       tmp(:,:,:,clidx)   = seg;
       tmpBM(:,:,:,clidx) = segBM;
       tmpSU(:,:,:,clidx) = segSU;
       tmpW(:,:,:,clidx)  = abs(segW);
       if hasgtr
         dice(bidx,clidx) = compute_dice( gtrnovwt, seg ); 
         confmat(bidx,clidx,:) = arr2vec( confusionmat( gtrnovwt(:), seg(:)));
         diceBM(bidx,clidx) = compute_dice( gtrnovwt, segBM ); 
         confmatBM(bidx,clidx,:) = arr2vec( confusionmat( gtrnovwt(:), segBM(:)));
       end
   end

   %COMBINE labels
   combA{bidx} = mean(avg,4);
   comb{bidx} = mode(single(tmp),4);  
   combBM{bidx} = mode(single(tmpBM),4);
   combW{bidx} = mean(tmpW,4);
   maxW = max(combW{bidx}(:)); if maxW>10e3*eps, combW{bidx}=combW{bidx}/maxW; end;

   combSU{bidx} = mean(single(tmpSU),4);
   combAll{bidx} = imdilate((combBM{bidx}+combW{bidx}+combSU{bidx})/3,strel('cube',3));
   
   for clidx=1:-numcl
    fprintf('%d, red is groundrth orig,thr,BM,SU,EN\n',clidx);
    maxW = max(tmpW(:,:,:,clidx)); maxW=max(maxW(:));
    imfimg(0.01, gtrnovwt,tmporig(:,:,:,clidx),tmp(:,:,:,clidx),tmpBM(:,:,:,clidx),tmpSU(:,:,:,clidx),tmpW(:,:,:,clidx)/maxW );
    pause;
   end
   %imfimg(0.03, gtrnovwt, combW{bidx}>0.4,comb{bidx},combBM{bidx},combSU{bidx});
   
   
   
   if hasgtr
     dice(bidx,clidx+1) = compute_dice( gtrnovwt, comb{bidx} );
     %confmat(bidx,clidx+1,:) = arr2vec( confusionmat( gtrnovwt(:), comb{bidx}(:) ) );
     diceBM(bidx,clidx+1) = compute_dice( gtrnovwt, combBM{bidx} );
     %confmatBM(bidx,clidx+1,:) = arr2vec( confusionmat( gtrnovwt(:), combBM{bidx}(:) ) );
     diceNew(bidx,1) = compute_dice(gtrnovwt, combW{bidx}>0.4);
     diceNew(bidx,2) = compute_dice(gtrnovwt, combSU{bidx});
     diceNew(bidx,3) = compute_dice(gtrnovwt, combAll{bidx}>0.4);
     [bd,bdi] = max( dice(bidx,1:end-1) );
     bmcomb = BasicMorph(single(combBM{bidx})) > seg_tv;
     bmdice = compute_dice(gtrnovwt, bmcomb);
     if bidx==1
       fprintf('\nBest | Comb |BMComb | BestBM | CombBM | Best Class --- BestBM class \n');
     end
     fprintf('%.2f | %.2f | %.2f |  ', bd, dice(bidx,end), bmdice);
     [bd,bdiBM] = max( diceBM(bidx,1:end-1) );
     fprintf(' %.2f  | %.2f   | %15s  ---  %15s \t', bd, diceBM(bidx,end),classifier_dirs{bdi}, classifier_dirs{bdiBM});
     cprintf('Blue', 'brain %3d:  %s', bidx, brain);
     cprintf('Red', 'Prob dice %.2f\n', compute_dice(gtrnovwt, primg>0.4));
   end

 


   if ~isempty(save_dir)
     if isempty(dir(save_dir)), mkdir(save_dir); end;
     fprintf('Saving files');
     niiout = nii;
     niiout.img = combBM{bidx};   
     save_untouch_nii(niiout, [save_dir,'/',brain,'.segMorph.WT.nii.gz']);
     niiout.img = combA{bidx};   
     save_untouch_nii(niiout, [save_dir,'/',brain,'.probsAvg.WT.nii.gz']);
     niiout.img = combSU{bidx};   
     save_untouch_nii(niiout, [save_dir,'/',brain,'.probsSup.WT.nii.gz']);
     niiout.img = combW{bidx};   
     save_untouch_nii(niiout, [save_dir,'/',brain,'.probsEnt.WT.nii.gz']);     
     fprintf('.done\n');
     niiout.img = combAll{bidx};   
     save_untouch_nii(niiout, [save_dir,'/',brain,'.probsAll.WT.nii.gz']);     
     fprintf('.done\n');
   end

end
 

