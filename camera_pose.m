function [extrinsics, homography] = camera_pose(img, dX) 
%CAMERA_POSE finds the pose of the camera in a given image with respect to
%a caltag target
%
%   This function will attempt to find a caltag target (characterised by
%   caltag.mat) in the given image and localise the camera with respect to
%   the target origin. The extrinsic matrix will be returned as a 4x4
%   transformation matrix. The homography to convert between image and
%   world coordinates is also returned as a 3x3 matrix.
%
%   The square width of the caltag target can be entered in mm as a second
%   argument, otherwise it is assume to be one inch or 24.5mm.
%

addpath([pwd '\caltag-master'],[pwd '\RADOCCToolbox'],[pwd '\RADOCCToolbox\CornerFinder']);
if exist('data.mat','file')
    load('data','intrinsics');
end
if ~exist('intrinsics','var')
    error('First run calibrate.m');
end
if ~exist('caltag.mat','file')
    error('Can''t find caltag.mat');
end

try
    [wPt, iPt] = caltag(img, 'caltag.mat');
catch err
    error('Couldn''t find caltag target in image');
end
 
if nargout == 0
    figure(1)
    imagesc(img); axis image off;
    hold on;
    for coords = iPt'
        plot(coords(2), coords(1), '*');
    end
end
if nargin == 1
    dX = 24.5;
end
x_kk = iPt'; 
X_kk = [wPt zeros(size(wPt, 1), 1)]'*dX;
X_kk(2,:) = dX*5 - X_kk(2,:);
thresh_cond = 1e6;
[omckk,Tckk] = compute_extrinsic_init(x_kk,X_kk, intrinsics.fc,intrinsics.cc,intrinsics.kc,intrinsics.alpha_c);
[~,Tckk,Rckk,~] = compute_extrinsic_refine(omckk,Tckk,x_kk,X_kk,intrinsics.fc,intrinsics.cc,intrinsics.kc,intrinsics.alpha_c,20,thresh_cond);
extrinsics = [Rckk Tckk; 0 0 0 1] * [1 0 0 0;0 1 0 0;0 0 -1 0;0 0 0 1];
homography = homography_solve(x_kk,X_kk(1:2,:));

if nargout == 0
    display_pose(extrinsics, intrinsics);
end

end 

