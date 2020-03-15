function [vec_out] = permute_to_cbyc(vec,nn,cc)
nc = nn*cc;
perm_idx = reshape(repmat((1:cc:(nc))',1,cc) + repmat(0:(cc-1),nn,1), nc,1);
vec_out = vec(perm_idx,:);
end