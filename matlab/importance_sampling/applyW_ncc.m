function [vec_out] = applyW_ncc(vec,Qcell,Dcell,invert)

% Q is nc x c
cc = size(Qcell{1},1);
nn = length(Qcell);
nc = nn * cc;

% confirm vec is nn x cc
n1 = size(vec,1);
if n1 ~= nn
    error('shapes do not match in apply W')
end

% vec 
vec = reshape(vec,nc,[]);

% permute input
perm_idx = reshape(repmat((1:cc:(nc))',1,cc) + repmat(0:(cc-1),nn,1), nc,1);
vec = vec( perm_idx, :);

% compute multiplication
Q = blkdiag(Qcell{:});
D = cell2mat(Dcell);
if invert
    vec_out = Q * ( (Q' * vec) ./D );
else
    vec_out = Q * ( D .* (Q' * vec) );
end

% permute output and reshape
vec_out = vec_out(perm_idx,:);
vec_out = reshape(vec_out,nn, cc, []);

end

