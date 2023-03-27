close all
clear

img = imread('test3.png');
subplot(1,2,1);
imshow(img);
%% gaussian
level = graythresh(img);
img = imgaussfilt(img,level);

%% RGB colour
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

%% HSV channels
HSV=rgb2hsv(img);
H=HSV(:,:,1);   %Hue
S=HSV(:,:,2);   %Saturation
V=HSV(:,:,3);   %Value: the value of light

%% get green
% according to Bayer pattern, there are 2 red pixels and 2 blue pixels
% around a green pixel, so this line of code is used to tell the differnece
% between the green and the average of red and blue, this difference can
% reflect if this pixel is more like green or red and blue, so this can
% give the green's distribution in this image.
green = G - (R + B)/2;
% imshow(green)
% title("green in image")

%% convert green to gray image
grayGreen = mat2gray(green);
% imshow(grayGreen)
% title("gray green image")

%% threshold value space of image based on greeness
% threshold = grayGreen<=0.18;
V(grayGreen<=0.18)=0; % make image is black except the plant
grayGreen(grayGreen<=0.18)=0;
% imshow(V);
% title("binary V");

%% otsu threshold to get binary images
% level=graythresh(grayGreen);
bw1=imbinarize(grayGreen, 0.2);     % use 0.2 will perform better on shadow
level=graythresh(V);
bw2=imbinarize(V, level);
% imshow(bw1)
% title("Binarized Image")

%% only save the biggest one object in the image
bw1 = bwareafilt(bw1,1);
bw2 = bwareafilt(bw2,1);
% subplot(1,2,1);
% imshow(bw1);
% title("bw1");
% subplot(1,2,2);
% imshow(bw2);
% title("bw2");

%% Method one: (use bw1)
%     % use mask
%     % the boundary is not smooth
%     bw1_mask = bw1==0;% nevagation(mask)
%     grayGreen(bw1_mask)=0;
%     %median filt to Reduce the effect of shadows cast by light
%     grayGreen=medfilt2(grayGreen, [7 7]);
%     % imshow(bw1);
%     %change the image after mask into binary image
%     seg1=imbinarize(grayGreen,0.08);
%     % imshow(seg1);
%     % Binary image processing: close(dilate and erode)
%     se = strel('disk',1);
%     seg1 = imopen(seg1, se);



%% Method two: (use bw2)
%     %% create mask and use it to get the plant in V
%     background_mask = bw2==0;
%     V(background_mask)=0;
%     % imshow(V);
%     % title("new V")
% 
%     %% edge detection using canny
%     V=medfilt2(V, [7 7]);   % reduce useless edge
%     canny=edge(grayGreen, "Canny", [0.2 0.5]);
%     % imshow(canny);
%     % title("canny edge")
% 
%     %% masking to add the edges onto the binarize image
%     edge_mask = canny==1;
%     bw2(edge_mask)=0;
%     % imshow(bw);
%     % title("Canny masked to BW")
%     
%     %% try open operation to reduce useless noise
%     se = strel('disk',1);   % many edge is only 1 pixel
%     bw2 = imopen(bw2,se);
%     % imshow(bw);
%     % title("Image Opening to remove pixels")
%     
%     % actually, at this step this image is good, but use watershed will
%     % make edge more clear
%     
%     %% watershed segmentation
%     bw_mask = bw2==0;    % Bright pixels represent higher places, dark pixels represent lower places
%     distance = -bwdist(bw_mask);    %The distance between the pixel and the nearest non-zero pixel
%     % imshow(distance,[])   
%     fianl_mask = imextendedmin(distance,1);
%     % imshow(mask);     
%     distance2 = imimposemin(distance,fianl_mask);
%     % imshow(distance2,[]) 
%     segment = watershed(distance2);
%     % imshow(segment,[])
%     bw2(segment == 0) = 0;
%     seg2 = bw2;


 %% Final Method:
    % use mask
    % the boundary is not smooth
    % Binary image processing: erode
    se = strel('disk',1);
    bw1 = imerode(bw1, se);
    
    bw1_mask = bw1==0;% nevagation(mask)
    grayGreen(bw1_mask)=0;

    %median filt to Reduce the effect of shadows cast by light
    grayGreen=medfilt2(grayGreen, [3 3]);
    level = graythresh(grayGreen);
    grayGreen = imgaussfilt(grayGreen,level);
    %change the image after mask into binary image
    bw1=imbinarize(grayGreen,0.1);
    % imshow(bw1);
    
    %% create mask and use it to get the plant in V
    bw2_mask = bw2==0;
    V(bw2_mask)=0;
    % imshow(V);
    % title("new V")

    %% edge detection using canny
    V=medfilt2(V, [7 7]);   % reduce useless edge
    canny=edge(grayGreen, "canny", [0.2 0.5]);
    % imshow(canny);
    % title("canny edge")

    %% add edges on binarize images
    edge_mask = canny==1;
    bw1(edge_mask)=0;
    % imshow(bw1);
    % title("Canny on bw1")
    
    %% try open operation to reduce useless pixels
    se = strel('disk',1);   % many edge is only 1 pixel
    bw1 = imopen(bw1,se);
    % imshow(bw1);
    % title("open bw1")
    
    % actually, at this step this image is good, but use watershed will
    % make edge more clear
    
    %% watershed segmentation
    bw_mask = bw1==0;    % Bright pixels represent higher places, dark pixels represent lower places
    distance = -bwdist(bw_mask);    %The distance between the pixel and the nearest non-zero pixel
    % imshow(distance,[])     
    mask = imextendedmin(distance,1);
    % imshow(mask);
    distance2 = imimposemin(distance,mask);
    % imshow(distance2,[])
    segment = watershed(distance2);
    % imshow(segment,[])
    bw1(segment == 0) = 0;
    seg3 = bw1;
    se = strel('disk',1);
    seg3 = imopen(seg3, se);

%% show images   
% subplot(1,3,1);
% imshow(seg1);
% title("Method 1");
% subplot(1,3,2);
% imshow(seg2);
% title("Method 2");
% subplot(1,3,3);
subplot(1,2,2);
imshow(seg3);
title("Final");


