function [ params ] = SetParams( params,dparams )
%PARAMS sets whatever fields do not exist in params to the field value
%represented in dparams.

if nargin < 2
    % default params
    dparams.kerType = 0;
    dparams.rfeC = 1;
    dparams.useCBR = 1;
    dparams.rfeG = 2^-6;
    dparams.rfeE = 0.1;
end

if ~isfield(params,'kerType')
    params.kerType = dparams.kerType;
end

if ~isfield(params,'rfeC')
    params.rfeC = dparams.rfeC;
end

if ~isfield(params,'useCBR')
    params.useCBR = dparams.useCBR;
end

if ~isfield(params,'rfeG')
    params.rfeG = dparams.rfeG;
end

if ~isfield(params,'rfeE')
    params.rfeE = dparams.rfeE;
end

end

