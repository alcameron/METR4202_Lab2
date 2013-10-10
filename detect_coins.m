function coins = detect_coins(img, depth)
%DETECT_COINS finds the location of coins in the given image
%
%   Given an image, this function performs image processing using the
%   hough_circles function and vlfeat toolbox to attempt to find coins in
%   the image. The image should be well-lit for optimal detection.
%
%   The detected coins will be returned in a Nx4 matrix. The columns
%   represent (x y r g), where (x y), r, and t are the center coordinate,
%   radius,  and gold(1)/silver(0) respectively.
%
%   img = 1024x1280x3 uint8 of the image
%   depth = 480x640 uin8 depth map corresponding to image
%   

if exist('data.mat','file')
    load('data','intrinsics');
end
addpath(genpath([pwd '\vlfeat']));
depth = double(depth) * 8;
depth(depth==0) = NaN;
depth = imresize(depth, [1024 1280]);

%% First try a hough_circles run
if size(img,1) == 480
    error('This function requires high resolution setting images (1280x1024)');
end
dist = nanmean(nanmean(depth));
if exist('intrinsics','var')
    fc = mean(intrinsics.fc);
else
    error('Please run calibrate.m first');
end
r1 = fc * 14 / dist; % 50c,20c,1d
r2 = fc * 10 / dist; % 2d,10c,5c
big=hough_circles(img,floor(r1-5),ceil(r1+5),0.3);
small=hough_circles(img,floor(r2-5),ceil(r2+5),0.3);
circles = [big;small];
if nargout == 0
    %     figure(9);imagesc(depth);colormap gray;
    figure(1), clf, imagesc(img), hold on;axis image off;
    for c = [big; small]'
        x = c(1)-c(3);
        y = c(2)-c(3);
        w = 2*c(3);
        rectangle('Position', [x y w w], 'EdgeColor', 'red', 'Curvature', [1 1]);
        text(x,y,num2str(w),'Color','r');
        title('Detected circles');
    end
    hold off;
end
%% Get rid of non-circles
mask = zeros(size(img,1),size(img,2));
for c = circles'
    ix = size(mask,2);
    iy = size(mask,1);
    r = c(3);
    [x,y] = meshgrid(-(c(1)-1):(ix-c(1)), -(c(2)-1):(iy-c(2)));
    mask = mask + ((x.^2+y.^2) <= r^2);
end
mask(mask>0) = 1;
img2 = uint8(zeros(size(img)));
for r = 1:size(img,1)
    for c = 1:size(img,2)
        img2(r,c,:) = img(r,c,:) * mask(r,c);
    end
end
if nargout == 0
    figure(2);clf;imagesc(img2);axis image off;
    title('Non-circles discarded');
end
%% do a SIFT mask
im = single(rgb2gray(img2));
f = vl_sift(im, 'PeakThresh', 4) ;
img3 = uint8(zeros(size(img2)));
for i = 1:size(f,2)
    origin = f(1:2,i);
    radius = f(3,i)*2;
    for r = max(ceil(origin(2)-radius),1):min(floor(origin(2)+radius),size(img2,1))
        for c = max(ceil(origin(1)-radius),1):min(floor(origin(1)+radius),size(img2,2))
            img3(r,c,:) = img2(r,c,:);
        end
    end
end
if nargout == 0
    figure(2);clf;
    imagesc(img3);
    axis image off;
    drawnow;
    title('Non-circles discarded and with SIFT mask');
end
%% throw out circles of the wrong colour
coins = [];
colour = kmeans_filter(img3, 10);
if nargout == 0
    figure(2); clf; imagesc(colour);axis image off;
    title('Masked and wrong-colour circles discarded');
end
for c = circles'
    ix = size(img,2);
    iy = size(img,1);
    r = c(3);
    [x,y] = meshgrid(-(c(1)-1):(ix-c(1)), -(c(2)-1):(iy-c(2)));
    [row col] = find((x.^2+y.^2) <= r^2);
    count = 0;
    RGB = zeros(length(row),3);
    gold = 0;
    silver = 0;
    for j = 1:length(row)
        px = double(reshape(img3(row(j),col(j),:),1,3));
        if sum(px) == 0
            count = count + 1;
        end
        RGB(j,:) = reshape(colour(row(j),col(j),:),1,3);
        if sum(RGB(j,:)==hsv2rgb([38/360 0.31 0.98])) == 3 || sum(RGB(j,:)==[0.717 0.573 0.368]) == 3
            gold = gold + 1;
        elseif sum(RGB(j,:)==hsv2rgb([40/360 0.01 0.91])) == 3 || sum(RGB(j,:)==[0.607 0.531 0.498]) >= 2
            silver = silver + 1;
        end
    end
    if count/length(row) > 0.1
        if nargout == 0
            text(c(1),c(2),'x','Color','r','FontSize',8,'BackgroundColor','k');
        end
        continue;
    end
    if nargout == 0
        x = c(1)-c(3);
        y = c(2)-c(3);
        w = 2*c(3);
        rectangle('Position', [x y w w], 'EdgeColor', 'red', 'Curvature', [1 1]);
    end
    gold = gold / length(row);
    silver = silver / length(row);
    RGB = mode(RGB);
    HSV = rgb2hsv(RGB*255);
    if gold > 0.3
        coins = [coins; c(1:3)' 1]; %#ok<AGROW>
        if nargout == 0
            text(c(1),c(2),'g','Color','y','FontSize',8,'BackgroundColor','k');
        end
    elseif silver > 0.1 && HSV(2) < 0.2
        coins = [coins; c(1:3)' 0]; %#ok<AGROW>
        if nargout == 0
            text(c(1),c(2),'s','Color',[0.5 0.5 0.5],'FontSize',8,'BackgroundColor','k');
        end
    else
        if nargout == 0
            text(c(1),c(2),'x','Color','r','FontSize',8,'BackgroundColor','k');
        end
    end
end
%% throw out circles not surrounded by the void
bad = [];
for i = 1:size(coins,1)
    circle = coins(i,:);
    o = circle(1:2);
    r = circle(3);
    h = size(img3,1);
    w = size(img3,2);
    rd = 3;
    p1 = reshape(img3(min(o(2)+r+rd,h),min(o(1)+r+rd,w),:),1,3);
    p2 = reshape(img3(min(o(2)+r+rd,h),o(1),:),1,3);
    p3 = reshape(img3(min(o(2)+r+rd,h),max(o(1)-r-rd,1),:),1,3);
    p4 = reshape(img3(o(2),min(o(1)+r+rd,w),:),1,3);
    p5 = reshape(img3(o(2),max(o(1)-r-rd,1),:),1,3);
    p6 = reshape(img3(max(o(2)-r-rd,1),min(o(1)+r+rd,w),:),1,3);
    p7 = reshape(img3(max(o(2)-r-rd,1),o(1),:),1,3);
    p8 = reshape(img3(max(o(2)-r-rd,1),max(o(1)-r-rd,1),:),1,3);
    if sum((mean(p1)>0.05) + (mean(p2)>0.05)+(mean(p3)>0.05)+(mean(p4)>0.05)+(mean(p5)>0.05)+(mean(p6)>0.05)+(mean(p7)>0.05)+(mean(p8)>0.05)) > 4
        bad = [bad i]; %#ok<AGROW>
        continue;
    end
end
coins(bad,:) = [];
if nargout == 0
    figure(3);clf;imagesc(img3);hold on;axis image off;
    for c = coins'
        x = c(1)-c(3);
        y = c(2)-c(3);
        w = 2*c(3);
        rectangle('Position', [x y w w], 'EdgeColor', 'red', 'Curvature', [1 1]);
    end
    hold off;
    title('Circles touching each other discarded');
end
%% throw out circles not on edges
edges = edge(rgb2gray(img), 'canny', [0.15 0.2]);
bad = [];
for i = 1:size(coins,1)
    c = coins(i,:);
    edgecount = 0;
    for theta = 1:360
        x = round(c(1) + c(3)*sind(theta));
        x = min(max(x,1),size(img,2));
        y = round(c(2) + c(3)*cosd(theta));
        y = min(max(y,1),size(img,1));
        edgecount = edgecount + edges(y,x);
    end
    if edgecount < 100
        bad = [bad; i]; %#ok<AGROW>
    end
end
coins(bad,:) = [];
%% Delete circles inside other circles
i = 1;
while i <= size(coins,1)
    j = 1;
    while j <= size(coins,1)
        if i == j || coins(j,3) < coins(i,3)
            j = j+1;
            continue;
        end
        x1 = coins(j,2) - coins(j,3);
        x2 = coins(j,2) + coins(j,3);
        y1 = coins(j,1) - coins(j,3);
        y2 = coins(j,1) + coins(j,3);
        o = coins(i,1:2);
        if o(2) < x2 && o(2) > x1 && o(1) < y2 && o(1) > y1
            coins(i,:) = []; %#ok<AGROW>
            i = i - 1;
            break;
        end
        j = j+1;
    end
    i = i + 1;
end
if nargout == 0
    figure(4);clf;imagesc(img3);hold on;axis image off;
    for c = coins'
        x = c(1)-c(3);
        y = c(2)-c(3);
        w = 2*c(3);
        rectangle('Position', [x y w w], 'EdgeColor', 'red', 'Curvature', [1 1]);
    end
    hold off;
    title('Circles not on edges or inside other circles discarded');
end

end