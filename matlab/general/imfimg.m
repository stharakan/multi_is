function imfimg(pausetime,varargin)
% function imfimg(pausetime,varargin)
% loops over slices of 3D arrays and fuse them. 
%
% pausetime - time in seconds for pausing. if =[], then manual pause
% varargin - images to visualize
%
 % if MATLAB contributed package "tight_subplot" is in the path, the
% function will use it. 
% 
clf;
nim = length(varargin);
img = varargin;
% download tight_subplot from mathworks. less white space than subplot
has_tight_subplot = exist('tight_subplot');  
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
  ha = tight_subplot(1,nim-1,[.001,.001],[.001,.001],[.001,.001]);
end

prepim = @(x) flip(x');

for jj=1:n
    if slice_norms(jj) < 0.01, continue; end;
    im1 = prepim(img{1}(:,:,jj));    
    for ii=2:nim
        if has_tight_subplot
          axes(ha(ii-1));
        else
          subplot(1, nim, ii),
        end
	im2 = prepim(img{ii}(:,:,jj));
	imshowpair(im1,im2,...
		   'falsecolor','Scaling','joint','ColorChannels',[1,2,0]);
    end
    title( sprintf('Slice %d', jj),  'FontSize', 18);
    if isempty(pausetime)
        pause;
    else
        pause( pausetime );
    end
end

 
