%CALIBRATE automatically calibrates the Kinect camera
%
%   To use this function, a 30mm checkerboard pattern should be held in
%   front of the Kinect. When the function is called it will take pictures
%   with the Kinect every second for twenty seconds. During this time the
%   checkerboard should be moved around, preferably rotating and moving
%   towards and away from the camera.
%
%   Toolbox files I've edited:
%       * ima_read_calib
%       * data_calib
%       * click_calib
%       * click_ima_calib
%       * go_calib_optim
%       * go_calib_optim_iter
%       * init_intrinsic_param

clear intrinsics extrinsics
save('temp');
clear all;
addpath([pwd '\RADOCCToolbox'],[pwd '\RADOCCToolbox\CornerFinder']);
display('Starting calibration. Move the pattern around in front of the Kinect until end');
dX = 27;
dY = 27;
for i = 1:20
    tic;
    kinect_take_photo(num2str(i));
    while toc < 0.5
    end
end
display('Imaging complete. Beginning calibration.');
cd 'images'
ima_read_calib;
cd '..'
click_calib;
go_calib_optim;
intrinsics = struct('fc',fc,'cc',cc,'alpha_c',alpha_c,'kc',kc,'err',err_std);
extrinsics = zeros(4,4,n_ima);
for i = 1:n_ima
    eval(['Rc = Rc_' num2str(i) ';']);
    eval(['Tc = Tc_' num2str(i) ';']);
    extrinsics(:,:,i) = [Rc Tc; 0 0 0 1];
end
extrinsics = struct('transformation_matrices',extrinsics);
clearvars -except intrinsics extrinsics
load('temp');
delete('temp.mat');
if exist('data.mat','file')
    save('data','intrinsics','extrinsics','-append');
else
    save('data','intrinsics','extrinsics');
end
