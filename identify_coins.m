function [total_money_value, num] = identify_coins(img, depth, coins)
%IDENTIFY_COINS identifies the given coins as Australian currency
%
%   Given an image, depth map, and array of detected coins, this function
%   will attempt to determine what denomination each coin is. Coins must
%   first be detected using detect_coins and then they may be passed to
%   this function.
%

if exist('data.mat','file')
    load('data','intrinsics');
end
if exist('intrinsics','var')
    fc = mean(intrinsics.fc);
else
    error('Please run calibrate.m first');
end
% Load depth
depth = double(depth) * 8;
depth(depth==0) = NaN;
depth = imresize(depth, [1024 1280]);
% Diameters of coins (in mm), take 1mm as it seems to underestimate radius
d2 = 20.5 - 1;
d1 = 25 - 1;
d50 = 31.51 - 1;
d20 = 28.52 - 1;
d10 = 23.6 - 1;
d5 = 19.41 - 1;
% For each detected coin, determine which size it is closest to
if nargout == 0
    figure(1);clf;imagesc(img);axis image off;
end
d = zeros(size(coins,1),1);
delta = zeros(size(coins,1),6);
% determine diameter of each coin and likely value
coins = [coins zeros(size(coins,1),1)];
for i = 1:size(coins,1)
    c = coins(i,:);
    ix = size(img,2);
    iy = size(img,1);
    r = c(3);
    [x,y] = meshgrid(-(c(1)-1):(ix-c(1)), -(c(2)-1):(iy-c(2)));
    [row col] = find((x.^2+y.^2) <= r^2);
    dist = 0;
    count = 0;
    for j = 1:length(row)
        if ~isnan(depth(row(j),col(j)))
            dist = dist + depth(row(j),col(j));
            count = count + 1;
        end
    end
    dist = dist / count;
    if isnan(dist)
        dist = nanmean(nanmean(depth));
    end
    d(i) = c(3)*2 * dist / fc;
    if c(4) == 1 %gold
        delta(i,:) = abs([d2-d(i) d1-d(i) inf inf inf inf]);
    else %silver
        delta(i,:) = abs([inf inf d50-d(i) d20-d(i) d10-d(i) d5-d(i)]);
    end
    [smallest,coins(i,5)] = min(delta(i,:));
    if smallest > 7.5
        coins(i,6) = 0; % not a coin
    end
    if nargout == 0
        x = c(1)-c(3);
        y = c(2)-c(3);
        w = 2*c(3);
        rectangle('Position', [x y w w], 'EdgeColor', 'red', 'Curvature', [1 1]);
        if c(4)
            text(c(1),c(2),num2str(d(i),'%.1f'),'Color','y','FontSize',8,'BackgroundColor','k');
        else
            text(c(1),c(2),num2str(d(i),'%.1f'),'Color',[0.5 0.5 0.5],'FontSize',8,'BackgroundColor','k');
        end
    end
end

for i = 1:size(coins,1)
    % check for multiple gold coins
    if  coins(i,5) == 1
        for j = 1:size(coins,1)
            if (coins(j,4) == 1) && (d(i) <= d(j) - 2)
                coins(i,5) = 1; % small is 2d
                coins(j,5) = 2; % big is 1d
            end
        end
    end
    % check for multiple silver coins
    if coins(i,4) == 0
        for j = size(coins,1)
            if (coins(j,4) == 0) && (d(i) <= d(j) - 1)
                % assume closest number is correct
                if (min(delta(i,:)) < min(delta(j,:))) && coins(i,5) ~= 3
                    coins(j,5) = coins(i,5) - 1;
                elseif (min(delta(j,:)) < min(delta(i,:))) && coins(j,5) ~= 6
                    coins(i,5) = coins(j,5) + 1;
                end
            end
        end
    end
end

coins = coins(:,5);
num = [length(find(coins==1)),length(find(coins==2)),length(find(coins==3)),length(find(coins==4)),length(find(coins==5)),length(find(coins==6))];
total_money_value = 2*num(1) + num(2) + 0.5*num(3) + 0.2*num(4) + 0.1*num(5) + 0.05*num(6);

display(['$0.05: ' num2str(num(6)) '  $0.10: ' num2str(num(5)) '  $0.20: ' num2str(num(4)) '  $0.50: ' num2str(num(3)) '  $1.00: ' num2str(num(2)) '  $2.00: ' num2str(num(1))]);

end