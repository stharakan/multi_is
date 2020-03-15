function [xi_fin] = applyRtinv_ncc(Qcell,Dcell, klr,xi)
% sample randomly
nn = length(Qcell);
cc = size( Qcell{1}, 1);
nc = nn*cc;
ss = size(xi,2);
xi_out = zeros(nn*cc,ss);

for ni = 1:nn
    cur_idx = (1:cc-1) + (ni-1)*(cc-1);
    cur_idx_out = (1:cc) + (ni-1)*(cc);
    Dhalf = abs(sqrt(Dcell{ni}));
    Q = Qcell{ni};

    % apply d and q
    xi_out(cur_idx_out,:) = Q * (bsxfun(@rdivide,xi(cur_idx,:), Dhalf) );
end

% reshape
xi_out = permute_to_nbyn(xi_out,nn,cc);
xi_out = reshape(xi_out, nn, cc,ss);

% apply the nystrom approx
xi_fin = zeros(klr.mm , klr.cc, ss);
for si = 1:ss
    xi_fin(:,:,si) = klr.KA.SM_INV( klr.KA.BG_SM( xi_out(:,:,si) ) );
end


end

