%% Training SCRIPT
% labels = 0 (normal), 1 (nonenhancing), 2 (edema), 4 (enhancing)

label = 0;  % this label will be marked as 1 and the other ones
            % will be merged as the background.

%% First define paths  and the 'brats' variable
SetPath; 

%% nload data
datapath=[brats,'/classification/training/'];

featurefile{1} = [datapath, 'BRATS_TUMORONLY.trn.nn.25363034.dd.288.gabor.bin']; d=single(288);
featurefile{2} = [datapath, 'BRATS_25M_NONTUMOR.trn.nn.25363034.dd.288.gabor.bin'];
labelfile{1} = [datapath, 'BRATS_TUMORONLY.trn.nn.25363034.labs.bin'];
labelfile{2} = [datapath, 'BRATS_25M_NONTUMOR.trn.nn.25363034.labs.bin'];

% TRAINING OPTIONS

save_file = 'mdlgabor50M.mat';
                                              

for jj=1:2
    fprintf('Reading data, points and labels\n');
    fid=fopen(featurefile{jj},'r');
    XF{jj}=single(fread(fid,'float32'));
    fclose(fid);
    fprintf('Done reading points\n');
    fid=fopen(labelfile{jj},'r');
    YF{jj}=single(fread(fid,'single'));
    fclose(fid);
    fprintf('Done reading labels\n');

    
    XF{jj}=reshape(XF{jj},[],d);
    fprintf('Done reshaping points\n');
end
X = [XF{1};XF{2}]; clear('XF');
Y = [YF{1};YF{2}]; clear('YF');

%% Make binary labels and training set
if label == 0, Y=Y>0;
else 
   Y = (Y==label); 
end
            
fprintf('Done preparing labels\n');



%% Ensemble method using LogitBoost
learner = templateEnsemble('LogitBoost',150,templateTree(), 'LearnRate',0.1 );
fprintf('Starting training classifier using random forests\n');
tic;Mdl = fitcecoc(X,Y,'Coding','onevsall','FitPosterior',1,'Learners',learner);
t=toc;
fprintf('...completed in %e secs\n',t);

fprintf('Saving model file in %s\n', save_file);
save(save_file,'Mdl','-v7.3');
fprintf('done\n')

