
function imout = CombineLabels(imin, labels)
% function imout = CombineLabels(imin, labels)
% 
% given array with positive integer values (labels), combines the
% values in labels and sets them to one and sets everything else to
% zero.  It makes a multilabeld image to a binary image. 
imout = imin == -100;
for jj=1:length(labels)
    imout = imout | (imin == labels(jj) );
end








