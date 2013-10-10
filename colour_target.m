function [RGB HSV YCrCb RGB2 HSV2 YCrCb2] = colour_target(img)
%COLOURTARGET obtains the values of the two colour targets from the grid
%
%   For this function, a ColorChecker grid should be held directly in front
%   of the camera. The Kinect will take a picture and find the Orange
%   Yellow (#e0a32e) and the Neutral 6.5 (#a0a0a0). This image can also be
%   taken beforehand and passed to the function. It will then display the
%   found RGB, HSV and YCrCb values as seen by the Kinect.
%

if nargin == 0
    [img, ~] = kinect_take_photo('colour',true);
end
try
    img = get_grid(img);
catch err
    disp('Couldn''t detect colour target outline');
end
[RGB HSV YCrCb] = find_yellow(img);
display('Orange Yellow');
display(['RGB: ' num2str(RGB)]);
display(['HSV: ' num2str(HSV)]);
display(['YCrCb: ' num2str(YCrCb)]);
[RGB2 HSV2 YCrCb2] = find_silver(img);
display('Neutral 6.5');
display(['RGB: ' num2str(RGB2)]);
display(['HSV: ' num2str(HSV2)]);
display(['YCrCb: ' num2str(YCrCb2)]);
if exist('data.mat','file')
    save('data','RGB','HSV','YCrCb','RGB2','HSV2','YCrCb2','-append');
else
    save('data','RGB','HSV','YCrCb','RGB2','HSV2','YCrCb2');
end

end