function [pmat_ncc] = composeW_ncc(probs)

% assume probs is n x c
[nn,cc] = size(probs);

% compute -pi *pj
pi = reshape(probs, 1 , nn*cc);
pi = repmat(pi, cc, 1);
pi = reshape(pi, nn*cc, cc);

pj = repmat(probs', 1, cc);
pj = reshape(pj, nn*cc, cc);
pipj = -pi.*pj;
clear pi pj

% compute pi diag
picell = num2cell(probs,2);
picell = cellfun(@diag, picell,'UniformOutput',false);
pi = vertcat(picell{:});
clear picell

% add together and return 
pmat_ncc = pi + pipj;
end