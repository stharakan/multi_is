function [d, err] = myDerivative(fun, x0, hInit)
%inspired by Numerical Recipes in C++, Press et. al.
%all credit to them
    nTab = 10;
    factor = 1.4;
    factorSq = factor * factor;
    safe = 2.0;

    big = 1e14;

    a = zeros(nTab);

    h = hInit;
    a(1, 1) = (fun(x0 + h) - fun(x0 - h)) / (2 * norm(h));
    err = big;

    for j = 2 : nTab
        %loop over columns
        %this corresponds to reducing h by a factor
        %con everytime
        h = h / factor;
        a(1, j) = (fun(x0 + h) - fun(x0 - h)) / (2 * norm(h));
        coeff = factorSq;
        for i = 2 : j
            a(i, j)  = (coeff * a(i - 1, j) - a(i - 1, j - 1)) / (coeff - 1);
            coeff = factorSq * coeff;
            %errt is iteration error
            errt = max(abs(a(i, j) - a(i - 1, j)), abs(a(i, j) - a(i - 1, j - 1)));

            if errt < err
                err = errt;
                d = a(i, j);
            end
        end

        if (abs(a(i, i) - a(i - 1, i - 1)) > safe * err)
            break;
        end
    end
end

