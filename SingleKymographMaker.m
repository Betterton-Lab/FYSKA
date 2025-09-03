%% This code find cut7 spots and make kymographs for a single segmented cell. 
%  By Bojun Zhou, last modified: 9-1-2025
%{
% To run this code, you need to: 
%  1. Specify the file path of segmented cell.mat (format: 1***_100R_100G_25_deg_00*_**.mat) in data_path line.
%  2. Defining a intensity threshold and a size limit for picking out cut7 spot,
%  using the function FindRoughPos(movie4D, threshold, spot_size) in this code. 
%  (Code's default: 3 sigma above background, 3 pixel in radius, i.e. FindRoughPos(movie3D_cut7, 3, 3);
%  3. Determining the "valid frames" where both cut7 spots are detected in the movie. 
%  The code will automatically fit a best spot location for both cut7 spots in every "valid frame". 

%  Initial outputs: 
%  1. A movie of the individual cell in all frames, with all possible cut7 spots labeled by a yellow circle.
%  In the movie, the most likely two SPB locations are denoted by a red "x" and a blue "x". 
%  This is the initial movie for the user to review which frame interval are suitable for kymograph creation. 
%  2. A valid frame list that shows all the image frames with two cut7 spots for references. 
%  
%  After the user deciding the good frames interval to make kymograph, this code will output: 
%  1. Two movies of the good frame interval, one for each channel (red/green), with blue and red circle 
%  denoting two cut7 peak position and a yellow line representing the spindle axis. 
%  2. Position of both cut7 peaks, both rough and precise, in .mat format. They will be used for later analysis. 
%  3. Multiple cut7 and MT kymographs. including: 
%  3.1 Individually optimized kymographs for each color channel. 
%  3.2 bkg_subtracted_kymograph, in .mat format. It will be used for later analysis. 
%  3.3 cut7_kymographs and MT_kymographs in .mat format. They can be used for analysis.
%  3.4 cut7_kymographs and MT_kymographs with cut7 peak position labels on top as red and blue dots. 
%  3.5 Optimized paired kymographs for both channels.
%  3.6 A mixed-color (red + green) kymograph for both channels. 
%}

cd C:\Research\Softwares\Developement\KymographMaker\;

%% Add path to accessory functions
addpath(genpath('functions'))

%% Located and load the .ND2 Data (Segmented Cells.mat)
cell_path = "C:\Research\Data\Cut7 Tail Mutants\cut7_FL\pkl1_klp2_WT\Segmented Cells\";
cell_type = "1149_100R_100G_25 deg";
cell_number = "005_G";

% cell_path = "C:\Research\Data\cut7-GFP sid4-mCh\MB1427\Segmented Cells\";
% cell_type = "1427_100R_100G_25deg";
% cell_number = "009_B";

data_path = cell_path + cell_type + "_" + cell_number + ".mat";
data_path = convertStringsToChars(data_path);

%% Loading ImageObj and cut7/MT movies
[movie3D_CH1, movie3D_CH2, voxel_size, time_step] = GetMovieInfo(data_path);

%% Fill the even frames of sid4 movie (q2, no data) with previous odd frame
% movie3D_CH1(:,:,:,2:2:end) = movie3D_CH1(:,:,:,1:2:end-1);

%% Creats directories for saving outputs
CreateSaveDir(cell_path, cell_type, cell_number);

%% Specify the good frames of cut7 to fit spots with Gaussian 2D
disp('Please review the FIJI movie and decide the (valid) frames to track SPBs.')
prompt = " First frame to fit? ";
first_frame = input(prompt);
prompt = " Last frame to fit? ";
last_frame = input(prompt);
prompt = " Order all spots by left/right or up/down? (answer with 'x' or 'y')  ";
sort_by = input(prompt, 's');

%% Find the spot (could be cut7, sid4, anything...)
% pos_cut7_pk_rough = FindRoughPos(movie4D, threshold, spot_size)
pos_cut7_pk_rough = FindRoughPos(movie3D_CH2, first_frame, last_frame, 2, 3);

%% Auto Correction:
pos_cut7_corrected = AutoCorrection(pos_cut7_pk_rough, first_frame, last_frame, 5);
%% Without Auto-Correction: 
% pos_cut7_corrected = pos_cut7_pk_rough;
%% Repeating Auto-Corrections: 
% pos_cut7_corrected = AutoCorrection(pos_cut7_pk, first_frame, last_frame, 10);

%% Refit and refine:
pos_cut7_rounded = round(pos_cut7_corrected);
pos_cut7_pk = FindRefinedPos(movie3D_CH2, pos_cut7_rounded, first_frame, last_frame);

%% Optionally sort/swap/fix the spots, if needed
% pos_cut7_pk(:,:,8) = pos_cut7_pk(:,:,7);
% pos_cut7_pk(:,:,80) = 1/2*(pos_cut7_pk(:,:,79)+pos_cut7_pk(:,:,81));

pos_cut7_pk = Sort2Spots(pos_cut7_pk, movie3D_CH2, sort_by);

% temp1=pos_cut7_pk(1,:,106:127);
% temp2=pos_cut7_pk(2,:,106:127);
% pos_cut7_pk(2,:,106:127)=temp1;
% pos_cut7_pk(1,:,106:127)=temp2;
% 
% temp1=pos_cut7_pk(1,:,:);
% temp2=pos_cut7_pk(2,:,:);
% pos_cut7_pk(2,:,:)=temp1;
% pos_cut7_pk(1,:,:)=temp2;
% 
% pos_cut7_pk(1,:,84) = pos_cut7_pk(1,:,83);
% pos_cut7_pk(1,:,85) = pos_cut7_pk(1,:,86);

save('pos_cut7_pk.mat','pos_cut7_pk');

%% Plot the cut7 peak to peak distance
plot1LvT(pos_cut7_pk,voxel_size,time_step,first_frame,last_frame);
exportgraphics(gcf,'lvt_plot_full.png');

%% Make kymograph of MT and cut7, and optimize
% Automatically make the kymograph (cut7 and MT): 
Kymograph_cut7 = makeKymograph(movie3D_CH2, pos_cut7_pk, first_frame, last_frame, voxel_size, time_step, 'cut7');
% Make the background-subtracted kymograph: 
Kymograph_cut7_bkg_sub = subtractKymoBackground(Kymograph_cut7, movie3D_CH2, first_frame, last_frame);
% Make contrast-optimized kymographs: 
KymoLookBetter(Kymograph_cut7(first_frame:last_frame, :), 0.8, 0.1, 'cut7');
Kymograph_MT = makeKymograph(movie3D_CH1, pos_cut7_pk, first_frame, last_frame, voxel_size, time_step, 'MT');
KymoLookBetter(Kymograph_MT(first_frame:last_frame, :), 200, max(Kymograph_MT(:)), 'MT');

% Kymograph_demo = KymographDemo(movie3D_CH2,pos_cut7_pk,first_frame,last_frame,voxel_size,time_step,3,2,'cut7');
% KymoLookBetter(Kymograph_demo(first_frame:last_frame, :), 0.75, 0.25, 'cut7');

% % Save some snapshots
% ExtractFrameImages(movie3D_CH2, pos_cut7_pk, 210, 240, 1);

%% Combining the two color channels
Kymograph_merged = MergeKymographs(Kymograph_MT(first_frame:last_frame, :), Kymograph_cut7(first_frame:last_frame, :));
Kymograph_combined = imadjust(Kymograph_merged,[0.1 0 0; 0.6 0.6 1],[]);

figure;
imshow(Kymograph_combined);
save('Kymograph_combined.mat','Kymograph_combined');
exportgraphics(gcf,'Red-Green-Kymograph.png');
% exportgraphics(gcf,'Red-Green-Kymograph.tif');
saveas(gcf,'Red-Green-Kymograph.svg');
% saveas(gcf,'Red-Green-Kymograph.fig');

pause(1);
close all;

