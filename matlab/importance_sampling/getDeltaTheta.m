function [delta_theta] = getDeltaTheta(mean_theta,klr,Qcell,Dcell)

% sample randomly
nn = length(Qcell);
cc = size( Qcell{1}, 1);
xi = randn(  nn*cc,1 );

% scale by d
Dhalf = abs(sqrt(cell2mat(Dcell)));
xi = xi ./ Dhalf;

% Apply the q
xi = (blkdiag(Qcell{:})) * xi;
xi = reshape(xi, nn, cc);

% apply the nystrom approx
xi = klr.KA.SM_INV( klr.KA.BG_SM( xi ) );

% add the mean
delta_theta = xi + mean_theta;


end

