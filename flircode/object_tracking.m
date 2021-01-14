close all; clear all; clc;

% root = 'G:\My Drive\Tuthill Lab Shared\Katie\thermal_experiments\data\12.11.20\SF0020\trial1\';
root = 'C:\Users\sydne\Documents\thermal_experiments\12.11.20\SF0020\trial1\';
file = 'FLIR0103.csq';
root = 'C:\Users\sydne\Documents\thermal_experiments\12.29.20\SF0041\trial1\';
file = 'FLIR0144.csq';

%% 

v = FlirMovieReader([root file]);
v.unit = 'temperatureFactory';
[frame, metadata] = step(v);
frame1 = im2double(frame);
frame2 = imadjust(frame1);
figure, imagesc(frame1);

%% specify circular region of interest 

v = FlirMovieReader([root file]);
v.unit = 'temperatureFactory';
[frame, metadata] = step(v);

figure();
imagesc(frame);
roi = drawcircle('Color','r');
center = roi.Center;
radius = roi.Radius;

%%

figure();
mask = createMask(roi);
imagesc(frame.*mask);

%% background subtraction

v = FlirMovieReader([root file]);
v.unit = 'temperatureFactory';
[I_0, metadata] = step(v);

I_0 = I_0; % initial image
I_bar = mean(I_0(:));
B_0 = I_0; % background
J_0 = I_0 - I_bar - B_0; % background subtracted image

alpha = 0.95; % 0 <= alpha <= 1;
t = 1; % frame

positions = [];
temps = [];

figure; 
imshow(J_0.*mask);

while ~isDone(v)
% while t < 1000
    I_t = step(v); % next frame
    
    I_bar = mean(I_t(:));
    B_t = B_0 * alpha + (1 - alpha)*(I_t - I_bar); % update background image
    J_t = I_t - I_bar - B_t; % background subtracted image
    
    J_t = J_t.*mask; % apply mask
    
    % determine location of max pixel value
    [max_val,idx] = max(J_t(:));
    [row,col] = ind2sub(size(J_t), idx);
    
    % extract temperature
    positions = [positions idx];
    fly_temp =  I_t(row, col);
    temps = [temps fly_temp];
    
    J_tn = J_t / max_val; % normalize image
    
    % display
    imshow(J_t);
    hold on
    viscircles(center, radius);
    scatter(col, row, 'r')
    drawnow;
    hold off
    
    t = t + 1;
    B_0 = B_t;
end 



