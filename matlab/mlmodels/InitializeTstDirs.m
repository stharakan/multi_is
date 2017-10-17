function [prob_dirs,type_dirs] = InitializeTstDirs(brats,num)
% initializes prob_dirs and probtypes to include whatever 
% we like. Cases:
%
% 1: Everything but knn
% 2: Everything with knn
SetVariablesTACC;

kde_dir = kde_tst_probs_dir;
lgbm_dir = lgbm_tst_probs_dir;
dnn_dir = dnn_tst_probs_dir;
med5_dir = med5_tst_probs_dir;
comb5_dir = comb5_tst_probs_dir;
sibia_dir = sibia_tst_probs_dir;

switch num
case 1

prob_dirs = {kde_dir,lgbm_dir,dnn_dir,comb5_dir,med5_dir,sibia_dir};
type_dirs = {kde_prob_types(:);...
	lgbm_prob_types(:);...
	dnn_prob_types(:); ...
	comb5_prob_types(:) ;...
	med5_prob_types(:); ...
	sibia_prob_types(:)};
[prob_dirs,type_dirs] = AlignProbTypeCells(prob_dirs,type_dirs);


case 2
knn_dir = knn_tst_probs_dir;
prob_dirs = {kde_dir,lgbm_dir,dnn_dir,comb5_dir,med5_dir,sibia_dir,knn_dir};
type_dirs = {kde_prob_types(:);...
	lgbm_prob_types(:);...
	dnn_prob_types(:); ...
	comb5_prob_types(:) ;...
	med5_prob_types(:); ...
	sibia_prob_types(:); ...
	knn_prob_types(:)};
[prob_dirs,type_dirs] = AlignProbTypeCells(prob_dirs,type_dirs);


end




end


