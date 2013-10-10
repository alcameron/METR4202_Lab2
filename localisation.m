function [camera coin_locs] = localisation(img, depth)
%LOCALISATION performs localisation and mapping on the image
%
%   The function requires an image  with the coins and the caltag target
%   visible. It will return the pose of the camera, [xPosition yPosition
%   zPosition Roll Pitch Yaw], and the location of the coins, [xPosition
%   yPosition zPosition]
%

if exist('data.mat','file')
    load('data','intrinsics','coins');
end
if ~exist('intrinsics','var') || ~exist('coins','var')
    error('First run calibrate.m and find_money');
end

% Find target
[transform, homography] = camera_pose(img);
% Return camera pose
Rc = transform(1:3,1:3);
Tc = transform(1:3,4);
pos = -Rc' * Tc;
rpy = tr2rpy(transform, 'deg');
camera = [pos' rpy];
% Find coin locations relative to targte
coin_locs = zeros(size(coins,1),3); %#ok<NODEF>
depth = double(depth) * 8;
depth(depth==0) = NaN;
depth = imresize(depth, [1024 1280]);
for i = 1:size(coins,1)
    c = coins(i,:);
    % Get coordinate
    coin_locs(i,1:2) = homography_transform([c(2);c(1)],homography)';
    coin_locs(i,3) = 0;
end

end