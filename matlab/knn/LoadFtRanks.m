function [franks,ftOrder,AvgPos] = LoadFtRanks(blist,frstr,ftype,psize,target,outdir)

% get initial file string
[sfile] =blist.MakeFRString(frstr,ftype,psize,target);

% check directory
files = dir([outdir,sfile,'*']);
if length(files) > 1
  wstr = sprintf('%s\n','Found multiple FtRank files, using first one. Here is a list:');
  for fi = 1:length(files)
    wstr = sprintf('%s%s\n',wstr,files(fi).name);
  end
  
  warning(wstr);
elseif length(files) == 0
  error('Feature selection file not found!!');
end

% open ftranks
sfile = [outdir,files(1).name];
fid = fopen(sfile,'r');
franks = fread(fid,Inf,'single');
fclose(fid);

% set up franks
dd = length(blist.FeatureCell(ftype,psize));
franks = reshape(franks,dd,[]);

if nargout > 1
% get appropriate order
[ftOrder,AvgPos] = DetermineFeatureOrder(franks);
end

end


