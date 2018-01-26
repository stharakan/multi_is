function [ franks ] = FeatureRankerRegression( blist,ftype,psize,target,params,outdir )
%FEATURERANKERREGRESSION ranks the feature data generated by blist, ftype,
%and psize (combined with the ppvec generated by blist and psize) and
%outputs it in franks. There is no subsampling done here

% default params
dparams.kerType = 0;
dparams.rfeC = 1;
dparams.useCBR = 1;
dparams.rfeG = 2^-6;
dparams.rfeE = 0.1;

% handle missing params/default
if nargin < 5 
    params = SetParams(params,dparams);
elseif isempty(params)
    params = SetParams(params,dparams);
end
runs = 1;

% set outdir
if nargin < 6
    outdir = '';
else
    sfile = blist.MakeFRString('reg01',ftype,psize,target,params);
    if ~isempty(outdir) & exist([outdir,sfile],'file')
        sfile = [outdir,sfile];
        fid = fopen(sfile,'r');
        franks = fread(fid,Inf,'single');
        fclose(fid);
        
        % set up franks
        dd = length(blist.FeatureCell(ftype,psize));
        franks = reshape(franks,dd,[]);
        return
    end
end

% Get data (assume this is only training)
[ fmat ] = GetBlistPatchFeatureData( blist,psize,ftype,outdir );

% Get outputs (assume only training)
ppvec = GetPatchProbabilities(blist,psize,target,outdir);

% Whiten training
fmat = whiten(fmat);

% loop over runs
feats = size(fmat,2);
franks = zeros(feats,runs,'single');
for ri = 1:runs
    % Run svmrfe
    [frank] = ftSel_SVMRFECBR_lin(fmat,ppvec,params);
    %frank = randperm(feats);
    
    % add in
    franks(:,ri) = single(frank(:));
    
end

if ~isempty(outdir)
    % save this file
    sfile = blist.MakeFRString('reg01',ftype,psize,target,params);
    sfile = [outdir,sfile];
    
    fid = fopen(sfile,'w');
    fwrite(fid,franks,'single');
    fclose(fid);
    
end
    

end

