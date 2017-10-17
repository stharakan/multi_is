function [means,vars,medians,skews,kurts] = PatchStats(pmat)
%PATCHSTATS computes patch stats of the patches, defined as the rows
% of the matrix pmat. For each row, means, vars are automatically 
% computed. Each additional argument is costly, and therefore only 
% computed if asked for

nn = size(pmat,1);

% mean
means = sum(pmat,2)./nn;

% var
temp = bsxfun(@minus,pmat,means).^2;
vars = sum(temp,2)./(nn - 1);

if nargout > 2
	medians = median(pmat,2);
end

if nargout > 3
	skews = skewness(pmat,0,2);
end

if nargout > 4
	kurts = kurtosis(pmat,0,2);
end

end
