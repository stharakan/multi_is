function out = ApplyFunctionToNiiDirectory( indir, outdir, applyfunction)
% function out = ApplyFunctionToNiiDirectory( dirname, applyfunction)
% niiout = applyfunction(niiin);

files = dir([indir,'/*nii.gz']);

for jj=1:length(files)
   fname = files(jj).name;
   nii = load_untouch_nii( [files(jj).folder, '/', fname] );
   nout = applyfunction(nii);
   if ~isempty(outdir)
       save_untouch_nii( nout, [outdir,'/', fname]);
   end
end
   

