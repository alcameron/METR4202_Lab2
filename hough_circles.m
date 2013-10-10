function circles = hough_circles(im, minR, maxR, thresh, delta)
% HOUGHCIRCLES detects multiple disks (coins) in an image using Hough
% Transform. The image contains separating, touching, or overlapping
% disks whose centers may be in or out of the image.
%
% Syntax
%   houghcircles(im, minR, maxR);
%   houghcircles(im, minR, maxR, thresh);
%   houghcircles(im, minR, maxR, thresh, delta);
%   circles = houghcircles(im, minR, maxR);
%   circles = houghcircles(im, minR, maxR, thresh);
%   circles = houghcircles(im, minR, maxR, thresh, delta);
%
% Inputs:
%   - im: input image
%   - minR: minimal radius in pixels
%   - maxR: maximal radius in pixels
%   - thresh (optional): the minimal ratio of the number of detected edge
%         pixels to 0.9 times the calculated circle perimeter (0<thresh<=1,
%         default: 0.33)
%   - delta (optional): the maximal difference between two circles for them
%         to be considered as the same one (default: 12); e.g.,
%         c1=(x1 y1 r1), c2=(x2 y2 r2), delta = |x1-x2|+|y1-y2|+|r1-r2|
%
% Output
%   - circles: n-by-4 array of n circles; each circle is represented by
%        (x y r t), where (x y), r, and t are the center coordinate, radius,
%        and ratio of the detected portion to the circle perimeter,
%        respectively.

% Check input arguments
if nargin==3
  thresh = 0.33;   % One third of the perimeter
  delta = 12;      % Each element in (x y r) may deviate approx. 4 pixels
elseif nargin==4
  delta = 12;
end
if minR<0 || maxR<0 || minR>maxR || thresh<0 || thresh>1 || delta<0
  disp('Input conditions: 0<minR, 0<maxR, minR<=maxR, 0<thresh<=1, 0<delta');
  return;
end

% Turn a color image into gray
origim = im;
if length(size(im))>2
  im = rgb2gray(im);   
end

% Create a 3D Hough array with the first two dimensions specifying the
% coordinates of the circle centers, and the third specifying the radii.
% To accomodate the circles whose centers are out of the image, the first
% two dimensions are extended by 2*maxR.
maxR2 = 2*maxR;
hough = zeros(size(im,1)+maxR2, size(im,2)+maxR2, maxR-minR+1);

% For an edge pixel (ex ey), the locations of its corresponding, possible
% circle centers are within the region [ex-maxR:ex+maxR, ey-maxR:ey+maxR].
% Thus the grid [0:maxR2, 0:maxR2] is first created, and then the distances
% between the center and all the grid points are computed to form a radius
% map (Rmap), followed by clearing out-of-range radii.
[X Y] = meshgrid(0:maxR2, 0:maxR2);
Rmap = round(sqrt((X-maxR).^2 + (Y-maxR).^2));
Rmap(Rmap<minR | Rmap>maxR) = 0;

% Detect edge pixels using Canny edge detector. Adjust the lower and/or
% upper thresholds to balance between the performance and detection quality.
% For each edge pixel, increment the corresponding elements in the Hough
% array. (Ex Ey) are the coordinates of edge pixels and (Cy Cx R) are the
% centers and radii of the corresponding circles.
edgeim = edge(im, 'canny', [0.15 0.2]);
[Ey Ex] = find(edgeim);
[Cy Cx R] = find(Rmap);
for i = 1:length(Ex);
  Index = sub2ind(size(hough), Cy+Ey(i)-1, Cx+Ex(i)-1, R-minR+1);
  hough(Index) = hough(Index)+1;
end

% Collect candidate circles.
% Due to digitization, the number of detectable edge pixels are about 90%
% of the calculated perimeter.
twoPi = 0.9*2*pi;
circles = zeros(0,4);    % Format: (x y r t)
for radius = minR:maxR   % Loop from minimal to maximal radius
  slice = hough(:,:,radius-minR+1);  % Offset by minR
  twoPiR = twoPi*radius;
  slice(slice<twoPiR*thresh) = 0;  % Clear pixel count < 0.9*2*pi*R*thresh
  [y x count] = find(slice);
  circles = [circles; [x-maxR, y-maxR, radius*ones(length(x),1), count/twoPiR]];
end

% Delete similar circles
circles = sortrows(circles,-4);  % Descending sort according to ratio
i = 1;
while i<size(circles,1)
  j = i+1;
  while j<=size(circles,1)
    if sum(abs(circles(i,1:3)-circles(j,1:3))) <= delta
      circles(j,:) = [];
    else
      j = j+1;
    end
  end
  i = i+1;
end

% Delete circles inside other circles
i = 1;
while i <= size(circles,1)
    j = 1;
    while j <= size(circles,1)
        if i == j || circles(j,3) < circles(i,3)
            j = j+1;
            continue;
        end
        x1 = circles(j,2) - circles(j,3);
        x2 = circles(j,2) + circles(j,3);
        y1 = circles(j,1) - circles(j,3);
        y2 = circles(j,1) + circles(j,3);
        o = circles(i,1:2);
        if o(2) < x2 && o(2) > x1 && o(1) < y2 && o(1) > y1
            circles(i,:) = [];
            i = i - 1;
            break;
        end
        j = j+1;
    end
    i = i + 1;
end


