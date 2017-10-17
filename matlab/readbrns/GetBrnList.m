function brnlist = GetBrnList(brndir)
% GETBRNLIST returns a cell array of the 
% subfolders of a given directory brndir, after 
% removing the folders that begin with '.'

% get initial list
inlist = dir(brndir);
cc = 1;

% loop and create cell array
for ii = 1:length(inlist)
	% check if it is a dot
	dotflag = strcmp(inlist(ii).name(1),'.');

	% load into brnlist
	if ~dotflag
		brnlist{cc} = inlist(ii).name;
		cc = cc + 1;
	end

end




end
