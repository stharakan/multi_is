function plotimg(pausetime,varargin)
% function plotimg(pausetime,varargin)
% loops over slices of 3D arrays and plots them side by side
%
% pausetime - time in seconds for pausing. if =[], then manual pause
% varargin - images to visualize
%
% if MATLAB contributed package "tight_subplot" is in the path, the
% function will use it. 
% 
% example:   Im1=rand(32,32,32); Im2=Im1;   plotimg(0.2, Im1, Im2, Im1); 
clf;
nim = length(varargin);
img = varargin;
has_tight_subplot = exist('tight_subplot');  % downlaod tight_subplot from mathworks. less white space. 
[nx,ny,n] = size(img{1});


for jj=1:n
    slice_norms(jj) = norm(single(img{1}(:,:,jj)),'fro');
end
slice_norms = slice_norms / max(slice_norms);

maxv=[];
for ii=1:nim
    maxv(ii) = max(img{ii}(:));
end

if has_tight_subplot
  ha = tight_subplot(1,nim,[.001,.001],[.001,.001],[.001,.001]);
end
for jj=1:n
    if slice_norms(jj) < 0.01, continue; end;
    for ii=1:nim
        if has_tight_subplot
          axes(ha(ii));
        else
          subplot(1, nim, ii),
        end
        imshow(img{ii}(:,:,jj)' );
        %view(2), shading interp, colormap bone; axis equal; caxis([0,maxv(ii)]); axis off; 
    end
    title( sprintf('Slice %d', jj),  'FontSize', 18);
    if isempty(pausetime)
        pause;ed
    else
        pause( pausetime );
    end
end

 
