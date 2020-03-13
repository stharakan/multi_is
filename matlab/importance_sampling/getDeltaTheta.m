function [delta_theta] = getDeltaTheta(mean_theta,klr,Qcell,Dcell)

% sample randomly
nn = length(Qcell);
cc = size( Qcell{1}, 1);
nc = nn*cc;
xi = randn(  nn*(cc-1),1 );
xi_out = zeros(nn*cc,1);

for ni = 1:nn
    cur_idx = (1:cc-1) + (ni-1)*(cc-1);
    cur_idx_out = (1:cc) + (ni-1)*(cc);
    Dhalf = abs(sqrt(Dcell{ni}));
    Q = Qcell{ni};

    % apply d and q
    xi_out(cur_idx_out) = Q * (xi(cur_idx) ./ Dhalf);
end

% reshape
perm_idx = reshape(repmat((1:cc:(nc))',1,cc) + repmat(0:(cc-1),nn,1), nc,1);
xi_out = xi_out(perm_idx);
xi_out = reshape(xi_out, nn, cc);

% apply the nystrom approx
xi_out = klr.KA.SM_INV( klr.KA.BG_SM( xi_out ) );

% add the mean
delta_theta = xi_out + mean_theta;


end

