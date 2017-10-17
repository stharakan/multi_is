function [ Xval,idx ] = LoadValFeatures(val_dir,feature_type,brn_name)
%LOADVALFEATURES loads from val_dir the file [brn_name,'.',feat,'.bin']. This
%should be the feature matrix corresponding to non-zero flair pixels of
%brn_name for the features given in feature_type. 

dd = GetFeatureDimension(feature_type);

% find feats
[~,bb] = system(['cd ',val_dir,' && ls ./',brn_name,'*',...
    feature_type,'.bin -1']);

% load feats
b2 = strtrim(bb);
tst = [val_dir,b2];
[fid,message] = fopen(tst,'r');
Xval = fread(fid,'single');
Xval = reshape(Xval,[],dd);
fclose(fid);

% find idx
[~,bb] = system(['cd ',val_dir,' && ls ./',brn_name,'*idx.bin -1']);
b2 = strtrim(bb);
fid = fopen([val_dir,b2],'r');
idx = fread(fid,'single');
idx = idx(:);
fclose(fid);


end

