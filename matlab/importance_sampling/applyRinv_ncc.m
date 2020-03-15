function [xi_out] = applyRinv_ncc(Qcell,Dcell,klr,xi)
% sample randomly
nn = length(Qcell);
cc = size( Qcell{1}, 1);
nc = nn*cc;
ss = size(xi,3); % should be mm x cc x ss
xi_out = zeros(nn*(cc-1),ss);

% Apply U L^-1/2
xi_tmp = zeros(nn,cc,ss);
for si = 1:ss
    xi_tmp(:,:,si) = klr.KA.SM_BG(xi(:,:,si));
end
xi = reshape(xi_tmp, nn*cc,ss);
clear xi_tmp

% permute
xi = permute_to_cbyc(xi,nn,cc);
xi = reshape(xi,[],ss);

% loop and multiply V^-1/2 Q^T
for ni = 1:nn
    cur_idx_out = (1:cc-1) + (ni-1)*(cc-1);
    cur_idx = (1:cc) + (ni-1)*(cc);
    Dhalf = abs(sqrt(Dcell{ni}));
    Q = Qcell{ni};

    % apply d and q
    xi_out(cur_idx_out,:) = bsxfun(@rdivide, Q' * xi(cur_idx,:), Dhalf);
end

end

