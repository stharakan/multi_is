% Variables
klr_dir = '/Users/stharakan/Documents/rklr/matlab/';
data_file = 'test.mat';
rank = 32;
sigma_tol = [0.1];
save_file = './klr_mdoel.mat';

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
data = load(data_file);

% Select bandwidth
%[sigma,err] = find_sigmas(data.Xtrain,rank,sigma_tol);
%fprintf('Sigma for %s with tolerance miss of %5.3f is %5.3f\n',data_file,err,sigma );
sigma = 0.5;

% Select reg
[lambda,pcorr] = find_lambda(data.Xtrain,data.Ytrain,sigma,rank);
fprintf('Lambda for %s with sigma %5.3f is %5.3f\n',data_file,sigma,lambda );

% Get KA
KA = OneShot(data.Xtrain,data.Ytrain,rank,rank,sigma);
    kerr = KA.matvec_errors(10);
    disp(['Decomp err ', num2str(kerr)]);
    disp('---------------------------------');
    
% Train KLR
klr = rklr(KA,data,lambda,[],options);
T = klr.AssembleTable();

% Save
save(save_file,'klr','sigma','lambda');