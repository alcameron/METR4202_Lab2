function [total_money_value, num] = find_money(img, depth)
%FIND_MONEY determines the amount of money in an image
%
%   Given an image and depth, this function will attempt to detect money
%   and will return the total value it finds as well as the number of each
%   denomination it finds in the following order: [5c 10c 20c 50c 1aud 2aud
%   5aud 10aud 20aud 50aud 100aud]
%

if exist('data.mat','file')
    load('data','intrinsics'); 
end
if ~exist('intrinsics','var')
    error('Please run calibrate.m first');
end
% Detect coins in the image
coins = detect_coins(img, depth);
[total_money_value, num] = identify_coins(img, depth, coins);
% Detect notes in the image
% [five ten twenty fifty hundred] = find_notes(img);
% Return
% total_money_value = total_money_value + 5*five + 10*ten + 20*twenty + 50*fifty + 100*hundred;
% num = [num five ten twenty fifty hundred];
% save('data','total_money_value','num','coins','-append');

end