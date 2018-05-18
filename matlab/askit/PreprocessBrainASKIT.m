function [] = PreprocessBrainASKIT(bdir,brn_name,outdir,ftype,psize,fkeep,kk,kcut)

% assume data file has been made already for knn
brain = BrainReader(bdir,brn_name);
ntst = brain.GetTotalVoxels();

% old knn file
prefix = ['nntstlist.dd.',num2str(fkeep),'.',ftype,'.ps.',num2str(psize)];
suffix = ['nn.',num2str(ntst),'.kk.',num2str(kk),'.bin'];
nnfile = [outdir,brain.MakeDataString(prefix,suffix)];
 
% new knn file
suffix = ['nn.',num2str(ntst),'.kk.',num2str(kcut),'.bin'];
nnfile_new = [outdir,brain.MakeDataString(prefix,suffix)];

% truncate
TruncateKNNFile(nnfile,nnfile_new,kcut,ntst);




end
