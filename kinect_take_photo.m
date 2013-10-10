function [rgb, depth] = kinect_take_photo(fn, lowres)
%KINECT_TAKE_PHOTO takes a photo using the connected Kinect
%
%   Call this function to take a photo. The rgb image and depth map will be
%   returned in matrix form (units mm). The second, optional argument if
%   specified as true will capture an image in the Kinect's low resolution
%   mode. If this argument is specified as false or left out a high
%   resolution image will be captured.
%
%   The photo will also be saved as a jpg to the .\Images directory with
%   the given filename (minus extension). If no filename given, it will
%   just display the photo. The saved depth information is reduced to 8-bit
%   and will not work for distances beyond two metres. To get the distance
%   from the saved depth image, multiply any value by 8 to get the
%   distance value in mm.
%

if nargout == 2 && lowres
    cfg = 'Config_low.xml';
else
    cfg = 'Config.xml';
end
% Connect to Kinect
h = mxNiCreateContext(cfg);
% Adjust depth coordinates to match color image
option.adjust_view_point = true;
mxNiUpdateContext(h, option);
% Capture image
[rgb depth] = mxNiImage(h);
rgb = flipdim(rgb,2);
depth = flipdim(depth,2) ./ 8;
if nargin == 1
    % Save to file
    warning('off','MATLAB:DELETE:FileNotFound');
    delete(['images\' fn '.jpg']);
    imwrite(rgb, ['images\' fn '.jpg']);
    delete(['images\' fn '_d.jpg']);
    imwrite(uint8(floor(depth)), ['images\' fn '_d.jpg']);
else
    % Otherwise display the captured image and depth map
    figure(1);
    imagesc(rgb);
    axis image off;
    figure(2);
    imagesc(depth);
    colormap gray;
    axis image off;
end
% delete context
mxNiDeleteContext(h);

end