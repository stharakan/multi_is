function files = DirGetFiles(dirname,label)
% function files = DirGetFiles(dirname,label)
% 
% Returns all the files  terminate with the 'label'
%   default for label = *.nii.gz, so you can omit it. 
% files is a cell array
%
% Remark: return the full path to the file
% use [~, name,ext]=fileparts(files{1}) to get the single
% names. so if files{1} = /var/la.nii.gz
%
% fileparts returns name=la.nii  ext=.gz


files = [];
if nargin<2, label = '*.nii.gz'; end;

ds = dir([dirname,'/',label]);
if isempty(ds), return; end;

n = length(ds);
for j=1:n
   files{j} = [ds(j).folder,'/',ds(j).name];
   fprintf('%s\n',char(files{j}));
end
