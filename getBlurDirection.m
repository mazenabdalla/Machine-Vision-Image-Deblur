function theta = getBlurDirection(imageLocation)

    img_input = double(im2gray(imread(imageLocation)))./255;
    resizeRatio = 2000/max(size(img_input));
    img_input = imresize(img_input, resizeRatio);

%     % HPF
%     img_input = double(im2gray(locallapfilt(imread(imageLocation), 0.4, 0.5)))./255;
%     resizeRatio = 2000/max(size(img_input));
%     img_input = imresize(img_input, resizeRatio);
% 
%     % NR
%     net = denoisingNetwork('DnCNN');
%     img_input = denoiseImage(img_input,net);
    
    % Filter gen
    g2a = @(x, y) 0.921*(2*x^2-1)*exp(-1*(x^2+y^2));
    g2b = @(x, y) 1.843*x*y*exp(-1*(x^2+y^2));
    g2c = @(x, y) 0.921*(2*y^2-1)*exp(-1*(x^2+y^2));
    
    ka = @(theta) cos(theta)^2;
    kb = @(theta) -2*cos(theta)*sin(theta);
    kc = @(theta) sin(theta)^2;
    
    rg = @(x, y, theta) ka(theta)*g2a(x, y) + kb(theta)*g2b(x,y) + kc(theta)*g2c(x,y);
    
    filterSize = 11;
    res = 1;
    filter = zeros(filterSize, filterSize, 180);
    
    % Generate a filter for each possible angle
    for theta = 1:180
    
        for x=ceil(-filterSize/2):floor(filterSize/2)
    
            for y=ceil(-filterSize/2):floor(filterSize/2)
    
                filter(x+floor(filterSize/2)+1, y+floor(filterSize/2)+1, theta) = rg(x/res, y/res, theta*pi/180);
    
            end
    
        end
    
    end
    
    % FFT and prep
    img_input_f = abs(fftshift(fft2(img_input,1*size(img_input,1),1*size(img_input,2))));
    img_input_f = imgaussfilt(img_input_f, 5);
    l2_norm = zeros(1, 180);
    
    [h,w] = size(img_input_f);
    heightRange = floor(0.4*h):floor(0.6*h);
    widthRange = floor(0.4*w):floor(0.6*w);

    % Index of vertical blackout bars, used to isolate the blur from the
    % image detail when finding the L2 norm
    filterSize=0;
    blackoutRangeColumn = floor((w+filterSize-1)/2)-25:ceil((w+filterSize-1)/2)+25;
    blackoutRangeRow = floor((h+filterSize-1)/2)-25:ceil((h+filterSize-1)/2)+25;
    
    % Filter and store the norm
    for theta=1:180
    
        temp = conv2(img_input_f, filter(:,:,theta));
        temp(:, blackoutRangeColumn) = 0;
        temp(blackoutRangeRow, :) = 0;
%         imshow(temp);
        l2_norm(theta) = norm(temp(heightRange,widthRange));
%         fprintf("theta: %i\n", theta);
    
    end
    
    % Return the theta that gives the largest response
    [~, theta] = max(l2_norm);

end