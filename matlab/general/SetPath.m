% set paths for BRATS17 data (brats), brats matlab scripts, and NIfTI14

bratsmatlabpath = [getenv('BRATSREPO'), '/matlab'];
if isempty(bratsmatlabpath)
    warning('Need to set env variable BRATSREPO'); 
end
addpath(  genpath( bratsmatlabpath ) );   

brats = getenv('BRATSDIR'); 
if isempty(brats)
    warning('Need to set env variable BRATSDIR'); 
    fprintf('On ICES machines:/org/groups/padas/lula_data/medical_images/brain/BRATS17\n');
    fprintf('On TACC machines:/work/00921/biros/BRATS17\n');
end

nifti = getenv('NIFTIDIR');
if isempty(nifti)
    warning('Need to set env variable NIFTIDIR');
    fprintf('On ICES machines:/org/group/padas/lula_packages/matlab/NIfTI14\n');
    fprintf('On TACC machines:$BRATSDIR/external/NIfTI14\n');
end
addpath( nifti );   
                                 

