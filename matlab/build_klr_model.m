% Variables
data_locations;
rank = 1024 
sigma = 68.7
lambda = 9.0E-7
batches = 4
sigma_tol = [0.1];

% klr options
options.tol_meth = 'tst';
options.grd_tol = 0.0001;
options.inv_meth = 'lpcg';
options.pr_flag = true;
options.ws = 4;
options.outer_its = 5;

% add klr path
addpath(genpath(klr_dir));

% Load training data
load(data_file);
clear trn_list val_list tst_list 
data.Xtrain = Xtrain;
data.Ytrain = Ytrain;
data.Xtest = Xtest;
data.Ytest = Ytest;

% Select bandwidth
size(data.Xtrain)
size(data.Xtest)
%[sigma,err] = find_sigmas(data.Xtrain,512,sigma_tol);
%fprintf('Sigma for %s with tolerance miss of %5.3f is %5.3f\n',data_file,err,sigma );

% Select reg
%[lambda,pcorr] = find_lambda(data.Xtrain,data.Ytrain,sigma,rank);
%fprintf('Lambda for %s with sigma %5.3f is %5.3f\n',data_file,sigma,lambda );

% Get KA
%KA = OneShot(data.Xtrain,data.Ytrain,rank,rank,sigma);
KA = EnsNyst(data.Xtrain,data.Ytrain,rank,rank,sigma,batches);
    kerr = KA.matvec_errors(10);
    disp(['Decomp err ', num2str(kerr)]);
    disp('---------------------------------');
    
% Train KLR
klr = rklr(KA,data,lambda,[],options);
T = klr.AssembleTable();

% Save
save(klr_file,'klr','sigma','lambda','T', '-v7.3');
