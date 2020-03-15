function [vec_out] = permute_to_nbyn(vec,nn,cc)
nc = nn*cc;
perm_idx = reshape(repmat((1:nn:(nc))',1,nn) + repmat(0:(nn-1),cc,1), nc,1);

vec_out = vec(perm_idx,:);
end

