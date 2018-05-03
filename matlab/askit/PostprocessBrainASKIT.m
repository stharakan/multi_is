function [] = PostprocessBrainASKIT(bdir,bname,outdir,pstr,ppb,ftype,psize,fkeep,kk,kcut,target)

% initialize
if isempty(outdir)
  outdir = [getenv('PRDIRSCRATCH'),'/'];
end
ntrn = 208; ntst = 52;

% initialize ps
if strcmp(pstr,'edemadist')
  ps = PointSelector(pstr,ppb,psize);
else
  ps = PointSelector(pstr,ppb);
end

% load list, make pfile
fprintf('Loading train list..\n');
trn = BrainPointList.LoadList(outdir,ps,ntrn);
trn.PrintListInfo();
pfile = trn.MakePPvecFile(psize,target); %TODO separate this from blist??
fprintf('Ftype: %s\nTarget: %d\nFkeep: %d',ftype,target,fkeep);

% load ppv
pfile = [outdir,pfile];
fid = fopen(pfile,'r');
ppv = fread(fid,Inf,'single');
ppv = double(ppv(:));
fclose(fid);

% make brain/potential files
brain = BrainReader(bdir,bname);
bw = BwRegLookup(ftype,psize); 
[pyy,p1s,pcm,pro] = ReadBrainPotentialFiles(pfile,bname,ftype,bw);

% patch regression 
yy_guess = (pyy - ppv)./(p1s - 1);
yy_truth = GetBrainPatchProbabilities(brain,psize,target); 

% pixel-classification values
cm_guess = round(pcm);
cm_truth = brain.ReadSeg();
cm_truth = double(cm_truth(:) == target);

% rounded patch classification (ro)
ro_guess = round(pro);
ro_truth = round(yy_truth);

% Print results
fprintf('Results for brain %s\n\n ------------------ \n',bname);
fprintf('Patch regression (psize %d)\n',psize);
PrintRegressionAccuracy(yy_truth,yy_guess); 
PrintClassificationAccuracy(cm_truth,cm_guess); 
PrintClassificationAccuracy(ro_truth,ro_guess);


end
~
