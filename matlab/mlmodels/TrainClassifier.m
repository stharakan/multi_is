%% Training SCRIPT
% labels = 0 (normal), 1 (nonenhancing), 2 (edema), 4 (enhancing)

label = 0;  % this label will be marked as 1 and the other ones
            % will be merged as the background.

%% First define paths  and the 'brats' variable
SetPath; 
SetDirectories;
[save_file = 'mdl.mat';

%% Path to training features
datapath=training_features_dir;

featurefile = [datapath,'BRATS_fix.pb20000.trn.nn.5214772.dd.288.gabor.bin'];  d = single(288);
labelfile = [datapath, 'BRATS_fix.pb20000.trn.nn.5214772.labs.bin'];

% Read points

fprintf('Reading data, points and labels\n');
fid=fopen(featurefile,'r');
X=single(fread(fid,'float32'));
fclose(fid);
X = reshape(X,[],d);
fprintf('Done reading points\n');
fid=fopen(labelfile,'r');
Y=single(fread(fid,'single'));
fclose(fid);
fprintf('Done reading labels\n');

%% Make binary labels and training set
if label == 0, Y=Y>0;
else 
   Y = (Y==label); 
end
            
fprintf('Done preparing labels\n');


%% Ensemble method using LogitBoost

LENS = 1; LSVM=2; LNBA=3;

learner{LENS} = templateEnsemble('LogitBoost',150,templateTree(), 'LearnRate',0.1 );
learner{LSVM} = templateSVM('IterationLimit',10000,'Verbose',1);
learner{LNBA} = templateNaiveBayes();

fprintf('Starting training classifier using random forests\n');
tic;Mdl = fitcecoc(X,Y,'Coding','onevsall','FitPosterior',1,'Learners',learner{LNBA});
t=toc;
fprintf('...completed in %e secs\n',t);

fprintf('Saving model file in %s\n', save_file);
%save(save_file,'Mdl','-v7.3');
fprintf('done\n')

