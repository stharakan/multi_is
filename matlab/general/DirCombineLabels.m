function DirCombineLabels(indir,outdir, labels)
% function DirCombineLabels(indir,outdir, labels)
% 
% given a directory with segmented images wiht multiple labels, it
% creates new nii files and puts them in outdir, all labels in
% "labels" get assigned to 1 and all others to 0. 
% 
% Example 
% DirCombineLabels( 'input_dir', 'output_dir', [2,3,4,5]);
%   will set labels [2,3,4,5] to label 1, and all other labels to 0.
%   the files in the output_dir will be named exactly the same way
%   as in the input_dir

function niiout = appfun( nii)
    img = CombineLabels(nii.img, labels);
    niiout = nii;
    niiout.img = img;
end    
    
ApplyFunctionToNiiDirectory( indir, outdir, @appfun );    

end
