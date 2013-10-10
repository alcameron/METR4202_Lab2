function [five ten twenty fifty hundred] = find_notes(img)
%FIND_NOTES attempts to find notes in an image
%
%   Uses SIFT matching to compare the given image to pictures in the
%   'notes' folder. It will then return the number of each respective note.
%   If there are multiple notes of the same type and laying on the same
%   side then they will only be detected as a single note.
%

addpath(genpath([pwd '\vlfeat']));
notes = {imread('notes\five.jpg'), imread('notes\ten.jpg'), imread('notes\twenty.jpg'), imread('notes\fifty.jpg'), imread('notes\hundred.jpg')};
five = 0;
ten = 0;
twenty = 0;
fifty = 0;
hundred = 0;
%% SIFT Matching tp find notes
for i = 1:5
    Ib = cell2mat(notes(i));
    Ia = single(rgb2gray(img));
    Ib = single(rgb2gray(Ib));
    Ib = imresize(Ib,[size(Ia,1) size(Ib,2)*size(Ia,1)/size(Ib,1)]);
    [fa, da] = vl_sift(Ia,'PeakThresh',3) ;
    [fb, db] = vl_sift(Ib,'PeakThresh',0) ;
    [matches, scores] = vl_ubcmatch(da, db) ;
    [~, perm] = sort(scores, 'descend') ;
    matches = matches(:, perm) ;
    xa = fa(1,matches(1,:)) ;
    xb = fb(1,matches(2,:)) + size(Ia,2) ;
    ya = fa(2,matches(1,:)) ;
    yb = fb(2,matches(2,:)) ;
    if nargout == 0
        figure(1) ; clf ;
        imagesc(cat(2, Ia, Ib)) ;
        hold on ;
        h = line([xa ; xb], [ya ; yb]) ;
        set(h,'linewidth', 1, 'color', 'b') ;
        vl_plotframe(fa(:,matches(1,:))) ;
        fb(1,:) = fb(1,:) + size(Ia,2) ;
        vl_plotframe(fb(:,matches(2,:))) ;
        axis image off ;
        vl_demo_print('sift_match_2', 1) ;
        colormap gray;
        drawnow;
    end
    % Figure out if it's that note
    midpoint = size(Ib,1)/2;
    front = [];
    back = [];
    for j = 1:length(matches(2,:))
        f = fb(:,matches(2,j));
        if f(3) < 5
            if nargout == 0
                text(f(1)+10,f(2),'x','Color','r','BackgroundColor','k');
            end
        else
            if nargout == 0
                text(f(1)+10,f(2),'$','Color','g','BackgroundColor','k');
            end
            if f(2) < midpoint
                front = [front; j]; %#ok<AGROW>
            else
                back = [back; j]; %#ok<AGROW>
            end
        end
    end
    if length(back) > 20 || length(front) > 20
        switch(i)
            case 1
                five = five + 1*((length(back) > 20) + (length(front) > 20));
            case 2
                ten = ten + 1*(length(back) > 20 + length(front) > 20);
            case 3
                twenty = twenty + 1*(length(back) > 20 + length(front) > 20);
            case 4
                fifty = fifty + 1*(length(back) > 20 + length(front) > 20);
            case 5
                hundred = hundred + 1*(length(back) > 20 + length(front) > 20);
            otherwise
                error('Loop iterator does not have expected value');
        end
    end
end

display(['$5: ' num2str(five) '  $10: ' num2str(ten) '  $20: ' num2str(twenty) '  $50: ' num2str(fifty) '  $100: ' num2str(hundred)]);

end