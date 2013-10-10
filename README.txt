This code uses the following toolboxes/sources:
    caltag
    RADOCCToolbox (modified slightly)
    vlfeat
    Peter Corke's MATLAB robotics toolbox
    http://www.mathworks.com.au/matlabcentral/answers/26141 (homography code)

Capturing images
Images may be taken with the Kinect using 'kinect_take_photo'. It takes an optional filename to save the image to in the \images directory and returns the RGB image and depth map.

Colour Calibration
Colour calibration is done using 'colour_target'. First take an image with the colour target in plain view facing the Kinect. Then pass this image (read in to the workspace) to the colourtarget function. Alternately, call it without any arguments and it will capture an image with the Kinect. It will then return the RGB, HSV and YCrCb values of the orange yellow and neutral 6.5 squares respectively.

Camera Calibration
To calibrate the camera, run 'calibrate' and do the calibration dance. It will return the intrinsic and extrinsic structures.

Detection
To find the money in a given image, call 'find_money' and pass it the image (RGB+D) you wish to find money in. It will return the total monetary value and then a matrix with the numbers of each denomination in the following order [5c 10c 20c 50c 1aud 2aud 5aud 10aud 20aud 50aud 100aud].

Localisation and Mapping
To localise the camera and coins, call 'localisation' and pass it the image (RGB+D) with the coins AND the caltag target. It will return the pose of the camera, [xPosition yPosition zPosition Roll Pitch Yaw], and the location of the coins, [xPosition yPosition zPosition]