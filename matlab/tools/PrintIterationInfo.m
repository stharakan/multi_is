function [  ] = PrintIterationInfo( ii,g0,fc,gc,qoi )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here


if nargin == 0
    % print header
    fprintf(' Iter |    f_c    |  gc/g0  |  qoi  |\n');
    fprintf('-------------------------------------\n');
else
    % print actual data
    grel = norm(gc,'fro')/norm(g0,'fro');
    fprintf(' %4d | %-9.4g | %-7.4g | %-5.3g | \n',ii,fc,grel,qoi);
end
end

