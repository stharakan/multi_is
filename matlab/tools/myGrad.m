function [grad, err] = myGrad(fun, x0, hInit)

dim = length(x0);
if length(hInit) == 1
    hInit = hInit * ones(dim, 1);
end

grad = zeros(dim, 1);
err = zeros(dim, 1);
I = eye(dim);

for i = 1 : dim
    e_i = I(:, i);
    [grad(i), err(i)] = myDerivative(fun, x0, hInit(i) * e_i);
end


end
