function [theta_mean] = klr_hessian_inverse(klr_obj,Q,D)

% get gradient, size mc
[~,g] = klr_obj.KLR_Obj();

% Hessian is L^1/2 U^T Q D Q^T U L ^1/2
% lets invert it
% Inverse is L-1/2 U^T Q D-1 Q^T U L^-1/2

% This computes U L ^-1/2
g_upd = klr_obj.KA.SM_BG(g);

% Applies Q D-1 Q with permutation
g_upd = applyW_ncc(g_upd,Q,D,true);

% Applies L^-1 * L^1/2 * U^T
theta_mean = klr_obj.KA.SM_INV( klr_obj.KA.BG_SM(g_upd) );


end

