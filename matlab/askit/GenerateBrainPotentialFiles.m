function [file1s fileyy,filero,filecm] = GenerateBrainPotentialFiles(pfile,bname,ftype,bw)

suffix = ['h.',num2str(bw),'.pot'];
potfile = strrep(pfile,'bin',suffix);
file1s = strrep(potfile,'ppv',[bname,'.',ftype,'.1s']);
fileyy = strrep(potfile,'ppv',[bname,'.',ftype,'.yy']);

filero = strrep(potfile,'ppv',[bname,'.',ftype,'.ro']);
filecm = strrep(potfile,'ppv',[bname,'.',ftype,'.cm']);



end
