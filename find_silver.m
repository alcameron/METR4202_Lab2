function [RGB HSV YCrCb] = find_silver(img)
%FIND_SILVER returns the value of the silver square in the colourtarget
%
%   Searches through given image to find the silver square in the
%   colourtarget. It will do so by locating the surrounding squares and
%   then attempting to find the silver square within the expected area.

loc13 = find_colour(img,13);
loc15 = find_colour(img,15);

width = abs(loc13(1) - loc15(1)) / 2;
cropped = img;
x1 = round(max(loc15(1) - width, 1));
x2 = round(min(loc15(1) + width, size(cropped,2)));
y1 = round(max(loc15(2), 1));
y2 = round(min(loc15(2) + 2*width, size(cropped,1)));
cropped = cropped(y1:y2,x1:x2,:);

if nargout == 0
    figure(1);
    clf;
    image(cropped);
    drawnow;
end

target = hex2dec(['a0'; 'a0'; 'a0'])';
rgb = cast(cropped,'double');
X = size(rgb,2);
Y = size(rgb,1);
dX = 15;
dY = 15;
wf = [1 1 1];
errors = ones(Y, X);
pic = zeros(Y, X, 3);
for i = 1:Y
    for j = 1:X
        r_error = abs(rgb(i,j,1) - target(1))/target(1);
        g_error = abs(rgb(i,j,2) - target(2))/target(2);
        b_error = abs(rgb(i,j,3) - target(3))/target(3);
        errors(i,j) = r_error*wf(1) + g_error*wf(2) + b_error*wf(3);
        r_error = min(r_error,1);
        g_error = min(g_error,1);
        b_error = min(b_error,1);
        pic(i,j,:) = [r_error g_error b_error];
    end
end

best = inf;
for x = 1:X
    for y = 1:Y
        if (y+dY < Y) && (y-dY > 0) && (x-dX > 0) && (x+dX < X)
            out = mean(mean(errors((y-dY):(y+dY),(x-dX):(x+dX))), 2);
            if out < best(1)
                best = [out x y];
            end
        end
    end
end
if nargout == 0
    figure(1);
    clf;
    image(cast(rgb,'uint8'));
    hold on
    plot(best(2),best(3),'rx')
    drawnow;
end

RGB = reshape(cropped(best(3),best(2),:),1,3);
HSV = rgb2hsv(RGB);
YCrCb(1) = 16 + 65.481*RGB(1)/255 + 128.553*RGB(2)/255 + 24.966*RGB(3)/255;
YCrCb(2) = 128 - 37.797*RGB(1)/255 - 74.203*RGB(2)/255 + 112.0*RGB(3)/255;
YCrCb(3) = 128 + 112.0*RGB(1)/255 - 93.786*RGB(2)/255 - 18.214*RGB(3)/255;
end

