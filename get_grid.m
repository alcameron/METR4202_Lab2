function outImage = get_grid(im)
%GET_GRID Finds the biggest rectangle in the given image
%
%   This function should be used when finding the colourtarget to first
%   crop the image. It will scan through the image and find the biggest
%   rectangle it can find. It will then return a cropped version of the
%   image only showing the contents of the rectangle.

ibw = ~im2bw(im, graythresh(im)); 

ifill = imfill(ibw, 'holes'); 
iarea = bwareaopen(ifill, 100);
ifinal = logical(iarea); 

stat = regionprops(ifinal, 'boundingbox');

if nargout == 0
    figure(1)
    imshow(im); 
    drawnow;
    hold on
end

for count = 1: numel(stat)
    bound(count, :) = stat(count).BoundingBox;
end

startarea = bound(1, 3)*bound(1, 4); 
startcorner = [bound(1,1) bound(1,2)]; 
startwidths = [bound(1, 3) bound(1, 4)];

for i = 1 : size(bound, 1); 
    if(bound(i,3)*bound(i,4) > startarea)
        startarea = bound(i,3)*bound(i,4);
        startcorner = [bound(i,1) bound(i,2)];
        startwidths = [bound(i,3) bound(i,4)];
    end
end

if nargout == 0
    rectangle('position', [startcorner startwidths], 'edgecolor', 'r', 'linewidth', 2);
end
vec = [floor(startcorner(1)) floor(startcorner(1)+startwidths(1)) floor(startcorner(2)) floor(startcorner(2)+startwidths(2))];
outImage = im(vec(3):vec(4), vec(1):vec(2), :); 

end

