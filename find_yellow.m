function [RGB HSV YCrCb] = find_yellow(img)
%FIND_YELLOW returns the value of the  yellow square in the colourtarget
%
%   Searches through given image to find the yellow square in the
%   colourtarget. It will do so by locating the surrounding squares and
%   then attempting to find the yellow square within the expected area.

loc6 = find_colour(img,6);
loc11 = find_colour(img,11);
loc17 = find_colour(img,17);
width = min(abs(loc6(1) - loc11(1)), abs(loc6(1) - loc17(1)));
cropped = img;
x1 = max(loc6(1) - width, 1);
x2 = min(loc6(1) + width, size(cropped,2));
y1 = min([loc6(2) loc17(2)]);
y1 = max(y1, 1);
y2 = max(loc6(2), loc17(2));
y2 = min(y2, size(cropped,1));
cropped = cropped(y1:y2,x1:x2,:);

if nargout == 0
    clf;
    image(cropped);
    drawnow;
end

loc = find_colour(cropped, 12);
RGB = reshape(cropped(loc(2),loc(1),:),1,3);
HSV = rgb2hsv(RGB);
YCrCb(1) = 16 + 65.481*RGB(1)/255 + 128.553*RGB(2)/255 + 24.966*RGB(3)/255;
YCrCb(2) = 128 - 37.797*RGB(1)/255 - 74.203*RGB(2)/255 + 112.0*RGB(3)/255;
YCrCb(3) = 128 + 112.0*RGB(1)/255 - 93.786*RGB(2)/255 - 18.214*RGB(3)/255;

end

