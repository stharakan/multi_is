% addpath, variables
addpath([getenv('BRATSREPO'),'/matlab/general/']);
SetPath;
SetVariablesTACC;
myload_nii = @(filename) load_untouch_nii(filename);

if 1
% large guy
mdlstr = 'BRATS_50M_meanrenorm.dd.288';
ff = [brats,'/userbrats/BRATS17tharakan/meanrenorm/',mdlstr,'.yy.bin'];
fid = fopen(ff);
bla = fread(fid,Inf,'single');
fclose(fid);

cNO = sum(bla(:) == 0)
cWT = sum(bla(:) ~= 0)
dd = 288;

ff = [brats,'/userbrats/BRATS17tharakan/meanrenorm/',mdlstr,'.XX.bin'];
fid = fopen(ff);
XX = fread(fid,Inf,'single');
fclose(fid);
XX = reshape(XX,[],dd);
m1 = mean(XX,2);

clear XX
fprintf('Max mean m1: %5.5f\n', max(m1));
fprintf('Min mean m1: %5.5f\n', min(m1));


else

kde_dir = kde_tra_probs_dir;
lgbm_dir = lgbm_tra_probs_dir;
dnn_dir = dnn_tra_probs_dir;
med5_dir = med5_tra_probs_dir;

prob_dirs = {kde_dir,lgbm_dir,dnn_dir,med5_dir}
type_dirs = {kde_prob_types(:);...
	lgbm_prob_types(:);...
	dnn_prob_types(:);...
	med5_prob_types(:)}
[prob_dirs,type_dirs] = AlignProbTypeCells(prob_dirs,type_dirs);

prob_dirs

type_dirs
end

