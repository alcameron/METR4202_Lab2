function clustered = kmeans_filter(img, clusters)
%KMEANS_FILTER Implementation of a kmeans algorithm for image processing
%
%   Takes the image and picks clusters no. of starting seeds. Then uses a
%   kmeans algorithm based on the difference in HSV to form groups. Once
%   the algorithm either converges or times out the function will return
%   the original image with each cluster assigned the cluster's average
%   colour.
%
%   example:
%       img = imread('test_coins\12.png');
%       clustered = kmeans_filter(img, 30);
%       imagesc(clustered);

tic
timeout = 30;
scale = 4;
origsize = size(img);
img = imresize(img,1/scale);
img = rgb2hsv(img);
img1 = img(:,:,1);
img2 = img(:,:,2);
img3 = img(:,:,3);
img = hsv2rgb(img);
% Start with a random seed (leaving four bins for gold and silver)
centres = rand(clusters-4,2);
centres(:,1) = floor(centres(:,1) * size(img,1));
centres(:,2) = floor(centres(:,2) * size(img,2));
centres(centres==0) = 1;
bin = zeros(size(img,1),size(img,2));
for i = 1:clusters-4
    while sum(img(centres(i,1),centres(i,2),:)) == 0
        centres(i,1) = floor(rand(1)*size(img,1));
        centres(i,2) = floor(rand(1)*size(img,2));
        centres(centres==0) = 1;
    end
    bin(centres(i,1),centres(i,2)) = i;
end
for r = 1:size(img,1)
    for c = 1:size(img,2)
        if sum(img(r,c,:)) == 0
            bin(r,c) = clusters+1;
        end
    end
end
% run until convergence
converged = false;
iter = 0;
while ~converged && toc < timeout
    iter = iter + 1;
    converged = true;
    % compute centroids
    colours = zeros(clusters,3);
    for i = 1:clusters-4
        colours(i,1) = mean(img1(bin==i));
        colours(i,2) = mean(img2(bin==i));
        colours(i,3) = mean(img3(bin==i));
    end
    colours(clusters,:) = [38/360 0.31 0.98]; % gold coin 1
    colours(clusters-1,:) = rgb2hsv([0.717 0.573 0.368]); % gold coin 2
    colours(clusters-2,:) = [40/360 0.01 0.91]; % silver coin 1
    colours(clusters-3,:) = rgb2hsv([0.607 0.531 0.498]); % silver coin 2
    % reassign each pixel to bins
    for r = 1:size(img,1)
        for c = 1:size(img,2)
            if bin(r,c) == clusters+1
                continue
            end
            delta = zeros(clusters,3);
            for i = 1:clusters
                delta(i,1) = abs(img1(r,c)-colours(i,1));
                delta(i,2) = abs(img2(r,c)-colours(i,2));
                delta(i,3) = abs(img3(r,c)-colours(i,3));
            end
            delta = sqrt(delta(:,1).^2 + delta(:,2).^2 + delta(:,3).^2);
            [~, best] = min(delta);
            if bin(r,c) ~= best
                bin(r,c) = best;
                converged = false;
            end
        end
    end
%     figure(1);
%     imagesc(bin); colormap hsv;
%     drawnow; 
%     figure(2);
%     binsize = zeros(clusters,1);
%     for i = 1:clusters
%         binsize(i) = size(find(bin==i),1);
%     end
%     bar(1:clusters,binsize)
%     drawnow;
end
bin = imresize(bin,[origsize(1) origsize(2)],'nearest');
clustered = zeros(size(bin,1), size(bin,2), 3);
colours = hsv2rgb(colours);
colours(clusters+1,:) = [0 0 0];
for r = 1:origsize(1)
    for c = 1:origsize(2)
        clustered(r,c,:) = colours(bin(r,c),:);
    end
end

end