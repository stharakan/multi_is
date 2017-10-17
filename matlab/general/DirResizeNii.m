function DirResizeNii(inputdir,outputdir,reffile)
% function DirResizeNii(inputdir,outputdir,reffile)
%
% Resizes all *nii.gz files in 'inputdir', saves them in the
% 'outputdir'
%
% reffile is path to reference template nii.gz file
% 
% nii hdr file and resize are determined by the reffile, so that
% all files in inputdir will have the resolution in reffile.


refnii   = load_untouch_nii(reffile);

sfiles = DirGetFiles(inputdir);
assert(~isempty(sfiles), 'No *nii.gz files in %s\n', inputdir);

n = length(sfiles);
for jj=1:n
  nii = load_untouch_nii(sfiles{jj});
  newnii = refnii;
  newnii.img = imresize3(nii.img,size(refnii.img),'linear');
  [~,fname,gz] = fileparts(sfiles{jj});
  save_untouch_nii(newnii,[outputdir,'/',fname,gz]);
end
 


