SetPath;
SetVariables;
compute_probabilities = true;

feature_type = feature_types{1};  % 1: int, 2: gabor
modellabels5M={'NOvWT_random_forest_5M', 'ALvED_random_forest_5M'};
modellabels50M={'NOvWT_random_forest_50M', 'NOvWT_naive_bayes_50M'};
modellabel = modellabels5M{1};
classes = {'NO','WT'};
%classes = {'AL','ED'};

% directories
feature_dir = brats17trsa_features_dir;
save_dir = './results/'; % directory where images should be saved to

%%
% Trained model file
modelfile = [modellabel,'.',feature_type,'.mat'];
modelfile = [training_model_dir,modelfile];

% Run on test brain
brains = brats17trsa_lggbrains;
brains = brains(1)

for j=1:length(brains)
  br = brains{j};
	
	labs = zeros(240*240*155,1);

	[~,bb] = system(['cd ',feature_dir,' && ls ./',br,'*idx.bin -1']);
	idx_file = strtrim(bb);
	ff = fopen([feature_dir,idx_file],'r');
	image_idx = fread(ff,Inf,'single');
	fclose(ff);

	[~,bb] = system(['cd ',feature_dir,' && ls ./',br,'*labs.bin -1']);
	labs_file = strtrim(bb);
	ff = fopen([feature_dir,labs_file],'r');
	Ytest = fread(ff,Inf,'single');
	fclose(ff);

	labs(image_idx) = Ytest;
	umask = labs == 2;
	

  fprintf('Processing  brain %2 out of %d subjects, named %s\n',j,length(brains),br);
  if compute_probabilities
    [ Yte,image_idx,probs ] = BinaryPredict( modelfile,feature_type,feature_dir,br,umask );
    
    fprintf('Saving probs');
    SaveProbs(save_dir,br,probs,classes,image_idx,feature_type);
  else

    [ Yte,image_idx] = BinaryPredict( modelfile,feature_type,feature_dir,br,umask );
    fprintf('Saving segmentation\n');
    SaveSeg(save_dir,br,Yte,image_idx,feature_type);
  end
  
  if j==1, modelfile = []; end;

end
