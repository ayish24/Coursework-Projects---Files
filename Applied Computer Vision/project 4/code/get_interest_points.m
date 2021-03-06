% Local Feature Stencil Code

% Returns a set of interest points for the input image

% 'image' can be grayscale or color, your choice.
% 'feature_width', in pixels, is the local feature width. It might be
%   useful in this function in order to (a) suppress boundary interest
%   points (where a feature wouldn't fit entirely in the image, anyway)
%   or(b) scale the image filters being used. Or you can ignore it.

% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
% 'confidence' is an nx1 vector indicating the strength of the interest
%   point. You might use this later or not.
% 'scale' and 'orientation' are nx1 vectors indicating the scale and
%   orientation of each interest point. These are OPTIONAL. By default you
%   do not need to make scale and orientation invariant local features.
function [x, y, confidence, scale, orientation] = get_interest_points(image, feature_width)

% Implement the Harris corner detector (See Szeliski 4.1.1) to start with.
% You can create additional interest point detector functions (e.g. MSER)
% for extra credit.

% If you're finding spurious interest point detections near the boundaries,
% it is safe to simply suppress the gradients / corners near the edges of
% the image.

% The lecture slides and textbook are a bit vague on how to do the
% non-maximum suppression once you've thresholded the cornerness score.
% You are free to experiment. Here are some helpful functions:
%  BWLABEL and the newer BWCONNCOMP will find connected components in 
% thresholded binary image. You could, for instance, take the maximum value
% within each component.
%  COLFILT can be used to run a max() operator on each sliding window. You
% could use this to ensure that every interest point is at a local maximum
% of cornerness.

% Placeholder that you can delete. 20 random points
% 1. Compute derivatives using sobel filter
	s = [1, 0, -1; 2, 0, -2; 1, 0, -1];
	dx = imfilter(image, s);
	dy = imfilter(image, s');
	dx2 = imfilter(dx, s);
	dy2 = imfilter(dy, s');
	dxdy = imfilter(dx, s');

	% 2. Filter with large guassian
	g = fspecial('gaussian', 25, 1.5);
	Ix2 = imfilter(dx2, g);
	Iy2 = imfilter(dy2, g);
	axy = imfilter(dxdy, g);

	% 3. Compute harris value
	alpha = 0.06;
	harris = (Ix2 .* Iy2) - axy .^ 2 - alpha .* (Ix2 + Iy2) .^ 2;

	% 4. Suppress features close to edges 
	harris(1 : feature_width, :) = 0;
	harris(end - feature_width : end, :) = 0;
	harris(:, 1 : feature_width) = 0;
	harris(:, end - feature_width : end) = 0;

	% 5a. Find connected components
	CC = bwconncomp(im2bw(harris, graythresh(harris)));

	% 5b. Take the max from each component region
	x = zeros(CC.NumObjects, 1);
	y = zeros(CC.NumObjects, 1);
	for i = 1 : CC.NumObjects
	    region = CC.PixelIdxList{i};
	    [~, ind] = max(harris(region));
	    [y(i), x(i)] = ind2sub(size(harris), region(ind));
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%% EXTRA CREDIT %%%%%%%%%%
    % 6. Scaling
    % Calculate the inverse of the scale
    sum = 0;
    for ii = 1: length(x)
        for jj = 2 : length(x)
        sum = sum + ((x(ii)-x(jj))^2 + (y(ii)-y(jj))^2)^(1/2);
        end
    end
    scale = (length(x) ^ 2) / sum;
end

