function imgout = BasicMorph(imgin, erode_value, threshold_value)
% function imgout = FourStepMorph(imgin, erode_value, threshold_value)
%
%
% This function performs, erosion, followed by dilation, smoothing,
% normalizatoin (so that max = 1)
% and thresholding. It uses the cubic structured element
% 
% INPUT
% imgin - input image (3D array)
% erode_value [3]- size of erosion (will be used in dilation too)  
%                      optional, default value is 3
% threshold_value - [1] img ( img >= threshold_value ) =1  
%                      optional, if not defined, no thresholding
%                      and normalization take place
% 
%
% OUTPUT
% imgout - out image (3D array)
%
%
% smoothing is gaussian with the same sigma as the
% erode/sidlate parameters
% 
% example imgout = FourStepMorph( imgin );

if ~exist('erode_value'), erode_value = 3; end
if ~exist('threshold_value'), threshold_value = []; end

use_equispaced = true;

% Resizing the image to avoid anisotropic effects. This doesn't
% guarantee that this resolves the problem since the grid spacing
% (which is unknown here). NIfTI14's reslice_nii() could be used to
% do this correctly but it messes up the orientations. Not really important.
if use_equispaced
    [nx,ny,nz] = size(imgin);
    n = max([nx,ny,nz]);
    imgout = imresize3(imgin,[n,n,n]);
else
    imgout = imgin;
end

cube_se = strel( 'cube', erode_value); 

imgout = imerode( imgout, cube_se);
imgout = imdilate( imgout, cube_se);
imgout = imgaussfilt3( single(imgout), erode_value);  

if ~isempty(threshold_value)
    imgout = imgout / max(imgout(:));
    imgout ( imgout >= threshold_value)  = 1;
end

if use_equispaced
    imgout = imresize3( imgout, [nx, ny, nz]);
end


