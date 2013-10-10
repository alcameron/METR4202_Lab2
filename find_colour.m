function loc = find_colour(rgb, no)
%FINDCOLOUR attempts to find the given colour square in an image
%
%   Will search through image and find the 15x15 pixel square with the
%   lowest difference in HSV values to the targeted colour.

hsv = rgb2hsv(rgb);
X = size(rgb,2);
Y = size(rgb,1);
if X > 640
    dX = 30;
    dY = 30;
else
    dX = 15;
    dY = 15;
end
wf = [1 0 1];
switch no
    case 6
        target = rgb2hsv(hex2dec(['67'; 'bd'; 'aa'])');
    case 11
        wf = [1 0 2];
        target = rgb2hsv(hex2dec(['9d'; 'bc'; '40'])');
    case 12
        wf = [1 1 5];
        target = rgb2hsv(hex2dec(['e0'; 'a3'; '2e'])');
    case 13
        wf = [1 2 1];
        target = rgb2hsv(hex2dec(['38'; '3d'; '96'])');
    case 15
        target = rgb2hsv(hex2dec(['af'; '36'; '3c'])');
    case 17
        wf = [4 1 1];
        target = rgb2hsv(hex2dec(['bb'; '56'; '95'])');
    case 18
        target = rgb2hsv(hex2dec(['08'; '85'; 'a1'])');
    case 21
        wf = [1 1 1];
        target = rgb2hsv(hex2dec(['a0'; 'a0'; 'a0'])');
    otherwise
        error('Dunno that one');
end
target(1) = max(target(1),0.001);
target(2) = max(target(2),0.001);
target(3) = max(target(3),0.001);

errors = ones(Y, X);
pic = zeros(Y, X, 3);
for i = 1:Y
    for j = 1:X
        h_error = abs(hsv(i,j,1) - target(1))/target(1);
        s_error = abs(hsv(i,j,2) - target(2))/target(2);
        v_error = abs(hsv(i,j,3)*255 - target(3))/target(3);
        errors(i,j) = h_error*wf(1) + s_error*wf(2) + v_error*wf(3);
        h_error = min(h_error,1);
        s_error = min(s_error,1);
        v_error = min(v_error,1);
        pic(i,j,:) = [h_error s_error v_error];
    end
end
if nargout == 0
    figure(2);
    image(pic);
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
    image(rgb);
    hold on
    plot(best(2),best(3),'rx')
    drawnow;
end

loc = [best(2) best(3)];

end

