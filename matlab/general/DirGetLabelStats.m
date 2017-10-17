function [stats] = DirGetLabelStats(directory,labels)
% function [stats] = DirGetLabelStats(directory,labels)
%
% stats.number_of_nonzeros(:)
% stats.number_of_voxels_per_label(,:,)
% stats.number_of_voxels_per_image(:)
% stats.filenames{:}
%
%
% Computes segmentation statistics for a directory with labeled nii.gz
%

nz=[];
nlab=[];
nim=[];
fnames=[];
nl = 0;
if ~isempty(labels), nl=length(labels); end;

cnt=1;
function emt = applyfun(nii);
   img = nii.img(:);
   fnames{cnt} = nii.fileprefix;
   nim(cnt)=length(img);
   nz(cnt) = sum(img>0);
   for jj=1:nl
       nlab(cnt,jj)= sum( img==labels(jj) );
   end
   cnt = cnt+1;
   emt = [];
end

ApplyFunctionToNiiDirectory( directory, [], @applyfun);

stats.number_of_nonzeros = nz(:);
stats.number_of_voxels_per_label = nlab;
stats.number_of_voxels_per_image = nim(:);
stats.filenames = fnames;

end
