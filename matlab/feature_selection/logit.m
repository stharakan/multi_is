function lx = logit(x)
%LOGIT calculates the logit of a given vector x, 
% elementwise

% handle edge cases
x(x == 0) = eps;
x(x == 1) = eps;

if any(x > 1 | x < 0)
  error('Input to logit function has values outside [0,1]');
end

lx = log( (x)./(1 - x) );


end
