function [klr] = build_klr(ka_type,rank,batches)

% if batches unspecified, lets specify it
if nargin < 3
    batches = 1;
end

% make filename, get other data
data_locations;
klr_file_name = generate_klr_filename(ka_type,rank,batches);
klr_file = [klr_model_dir,klr_file_name,'.mat'];

if exist(klr_file,'file')
    load(klr_file, 'klr');
    return 
end

% load data
load(data_file,'Xtrain','Ytrain','Xtest','Ytest');

% subsample
[Xtrain,Ytrain] = subsample_data_from_rank(Xtrain, Ytrain,rank); 


% create struct
data = create_data_struct(Xtrain,Ytrain,Xtest,Ytest);

% find sigma
sigma_tol = 0.1;
[sigma,err] = find_sigmas(data.Xtrain,min(1024,rank),sigma_tol);
fprintf('Sigma for %s with tolerance miss of %5.3f is %5.3f\n',data_file,err,sigma );


% find lambda
[lambda,~] = find_lambda(data.Xtrain,data.Ytrain,sigma,rank);
fprintf('Lambda for %s with sigma %5.3f is %5.3f\n',data_file,sigma,lambda );

% get ka
if strcmp(ka_type,'OneShot')
    KA = feval(ka_type,data.Xtrain,data.Ytrain, rank,rank, sigma);
else
    KA = feval(ka_type,data.Xtrain,data.Ytrain, rank,rank, sigma,batches);
end

% Run rklr
options = klr_default_options();
klr = rklr(KA,data,lambda,[],options);
T = klr.AssembleTable();

% Save
save(klr_file,'klr','sigma','lambda','T', '-v7.3');

end

