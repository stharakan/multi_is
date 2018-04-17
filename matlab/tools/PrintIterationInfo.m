function [  ] = PrintIterationInfo( ii,f0,g0,fc,gc,qoi )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here


if nargin == 0
    % print header
    fprintf(' Iter |  fc - f0  |  gc/g0  |  qoi  |\n');
    fprintf('-------------------------------------\n');
else
    % print actual data
    grel = norm(gc,'fro')/norm(g0,'fro');
    fprintf(' %4d | %-9.4g | %-7.4g | %-5.3g | \n',ii,fc - f0,grel,qoi);
end
end

