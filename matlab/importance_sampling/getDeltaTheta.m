function [delta_theta] = getDeltaTheta(mean_theta,klr,Qcell,Dcell)

% sample randomly
nn = length(Qcell);
cc = size( Qcell{1}, 1);
nc = nn*cc;
xi = randn( nn*(cc-1),1 );
xi_out = zeros(nn*cc,1);

% apply r^T inverse
xi_out = applyRtinv_ncc(Qcell,Dcell, klr,xi);

% add the mean
delta_theta = xi_out + mean_theta;


end

