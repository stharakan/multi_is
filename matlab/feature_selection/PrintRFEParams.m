function [ str ] = PrintRFEParams( params )
%PRINTPARAMS generates a print string for a given param structure params.
%Specifically, it prints out rfeC/rfeE

str = ['C.',num2str(params.rfeC),'.E.',num2str(params.rfeE),...
    '.G.',num2str(params.rfeG)];
end

