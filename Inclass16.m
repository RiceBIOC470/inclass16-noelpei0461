% Inclass16
%Gb comments
1 100 be careful when redefining your “peak” variable. It can get messy once you lose the first peak definition. 
2 100
3 75 This should really be looped for all possible matching cells between timeframes
overall 92


%The folder in this repository contains code implementing a Tracking
%algorithm to match cells (or anything else) between successive frames. 
% It is an implemenation of the algorithm described in this paper: 
%
% Sbalzarini IF, Koumoutsakos P (2005) Feature point tracking and trajectory analysis 
% for video imaging in cell biology. J Struct Biol 151:182?195.
%
%The main function for the code is called MatchFrames.m and it takes three
%arguments: 
% 1. A cell array of data called peaks. Each entry of peaks is data for a
% different time point. Each row in this data should be a different object
% (i.e. a cell) and the columns should be x-coordinate, y-coordinate,
% object area, tracking index, fluorescence intensities (could be multiple
% columns). The tracking index can be initialized to -1 in every row. It will
% be filled in by MatchFrames so that its value gives the row where the
% data on the same cell can be found in the next frame. 
%2. a frame number (frame). The function will fill in the 4th column of the
% array in peaks{frame-1} with the row number of the corresponding cell in
% peaks{frame} as described above.
%3. A single parameter for the matching (L). In the current implementation of the algorithm, 
% the meaning of this parameter is that objects further than L pixels apart will never be matched. 

% Continue working with the nfkb movie you worked with in hw4. 

% Part 1. Use the first 2 frames of the movie. Segment them any way you
% like and fill the peaks cell array as described above so that each of the two cells 
% has 6 column matrix with x,y,area,-1,chan1 intensity, chan 2 intensity
reader1 = bfGetReader('nfkb_movie1.tif');
index1 = reader1.getIndex(0, 0, 0)+1;
index2 = reader1.getIndex(0, 0, 1)+1;
frame1 = bfGetPlane(reader1, index1);
frame2 = bfGetPlane(reader1, index2);

%segment
mask1 = frame1 > 650;
mask2 = frame2 > 650;
mask_c1 = imopen(mask1, strel('disk', 6));
mask_c2 = imopen(mask2, strel('disk', 6));
stats1 = regionprops(mask_c1, 'Area');
hist([stats1.Area]);
stats2 = regionprops(mask_c2, 'Area');
hist([stats2.Area]);
min_area = 50;
maskf1 = bwareaopen(mask_c1, min_area);
imshow(maskf1);
maskf2= bwareaopen(mask_c2, min_area);
imshow(maskf2);
stats_t1 = regionprops(maskf1, frame1, 'Centroid', 'Area', 'MeanIntensity');
stats_t2 = regionprops(maskf2, frame2, 'Centroid', 'Area', 'MeanIntensity');

index12 = reader1.getIndex(0, 1, 0)+1;
index22 = reader1.getIndex(0, 1, 1)+1;
frame12 = bfGetPlane(reader1, index1);
frame22 = bfGetPlane(reader1, index2);
mask12 = frame12 > 650;
mask22 = frame22 > 650;
mask_c12 = imopen(mask12, strel('disk', 6));
mask_c22 = imopen(mask22, strel('disk', 6));
stats12 = regionprops(mask_c12, 'Area');
hist([stats12.Area]);
stats22 = regionprops(mask_c22, 'Area');
hist([stats22.Area]);
min_area = 50;
frame12' = bwareaopen(mask12, min_area);
frame22' = bwareaopen(mask22, min_area);

stats_t1_c2 = regionprops(frame12', frame12, 'Centroid', 'Area', 'MeanIntensity');
stats_t2_c2 = regionprops(frame22', frame22, 'Centroid', 'Area', 'MeanIntensity');

% show data
a1 = cat(1, stats_t1.Centroid);
b1 = cat(1, stats_t1.Area);
c1 = cat(1, stats_t1.MeanIntensity);
c2 = cat(1, stats_t1_c2.MeanIntensity);
tmp = -1*ones(size(b1));
peaks{1} = [a1, b1, tmp, c1, c2];

a2 = cat(1, stats_t2.Centroid);
b2 = cat(1, stats_t2.Area);
c21 = cat(1, stats_t2.MeanIntensity);
c22 = cat(1, stats_t2_c2.MeanIntensity);
tmp = -1*ones(size(b2));
peaks{2} = [a2, b2, tmp, c21, c22];
% Part 2. Run match frames on this peaks array. ensure that it has filled
% the entries in peaks as described above. 
peaksarray = MatchFrames(peaks, 2,0.1);

% Part 3. Display the image from the second frame. For each cell that was
% matched, plot its position in frame 2 with a blue square, its position in
% frame 1 with a red star, and connect these two with a green line. 
i = reader1.getIndex(0,0,1)+1;
img2 = bfGetPlane(reader1,i);
figure; imshow(img2,[]); hold on;
plot(peaks{1}(:,1),peaks{1}(:,2),'r*');
plot(peaks{2}(:,1),peaks{2}(:,2),'cs');
