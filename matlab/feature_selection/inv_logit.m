function [ ex ] = inv_logit( x )
%INV_LOGIT calulcates the inverse logistic function of a given vector x,
%elementwise

ex = exp(x)./(1 + exp(x));


end

