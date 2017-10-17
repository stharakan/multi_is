function [ Yte,idx,probs ] = BinaryPredict( mdl_file,feature_type, ...
                                            feature_dir,target_brain_name,cl_mask )
% function [ Yte,idx,probs ] = BinaryPredict(
%..  mdl_file,feature_type,feature_dir,target_brain_name,cl_mask )
%
% INPUT
% mdl_file - machine learning model file. It loads the model file in a
%        persistent variable. If you want to avoid loading the same model
%        (e.g., when classifying a series of brain images), then set
%        mdl_file = [] in subsequent calls and the predictor will use the
%        persistent model. 
% feature_type - one of {'int','gabor','window'}sy
% feature_dir - directory that has the features for brain we want
%           to classify
% target_brain_name - name of the brain we want to classify
% cl_mask - binary mask of points to classify (should have same 
%				number of elements as full image.
%
% OUTPUT
% Yte - Classification labels
% idx - Index of global voxel ids for each label
% probs - probabilities for each class (Nte-by-2 array)

persistent mdl
if ~isempty(mdl_file)
  %clear('mdl');
  fprintf('Reading machine learning model (file:%s) ...', mdl_file);
  tmp = load(mdl_file);
  mdl = tmp.Mdl;
  clear('tmp');
  fprintf('done\n');
end

fprintf('Loading features and indices files for brain %s...', target_brain_name);
[Xte,idx] = LoadValFeatures(feature_dir,feature_type,target_brain_name);
if exist('cl_mask')
	% get sub idx
	sub_mask = cl_mask(idx);
	
	% submatrix, adjust index
	Xte = Xte(sub_mask,:);
	idx = idx(sub_mask);
end
fprintf('done\n');


% PREDICTION
fprintf('Running prediction');
if nargout>2
  fprintf(' with probabilities...');
  [Yte,~,~,probs] = mdl.predict(Xte);
else
  fprintf(' without probabilities...');
  Yte = mdl.predict(Xte);
end
fprintf('done\n');

