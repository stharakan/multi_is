function [pyy,p1s,pcm,pro] = ReadBrainPotentialFiles(pfile,bname,ftype,bw)

[fyy,f1s,fcm,fro] = GenerateBrainPotentialFiles(pfile,bname,ftype,bw);

% yy
fid = fopen(fyy); % assumes outdir is contained w/in pfile
pyy = fread(fyy,Inf,'double');
fclose(fid);
pyy = pyy(:);

% 1s
fid = fopen(f1s); % assumes outdir is contained w/in pfile
p1s = fread(f1s,Inf,'double');
fclose(fid);
p1s = p1s(:);

% ro
fid = fopen(fro); % assumes outdir is contained w/in pfile
pcm = fread(fro,Inf,'double');
fclose(fid);
pro = pro(:);

% cm
fid = fopen(fcm); % assumes outdir is contained w/in pfile
pcm = fread(fcm,Inf,'double');
fclose(fid);
pcm = pcm(:);




end
