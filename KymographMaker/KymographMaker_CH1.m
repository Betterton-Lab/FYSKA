%% Add path to accessory functions
addpath(genpath('functions'))

%% Located and load the .ND2 Data (Segmented Cells.mat)
% cell_path = "C:\Research\Data\cls1-36, sid4-mCh, pkl1D, cut7-GFP\Segmented Cells\";
% cell_type = "1392_200Rq2_100G_9Z_25deg";
% cell_number = "007_J";

% cell_path = "C:\Research\Data\cut7-GFP sid4-mCh\MB1302\Segmented Cells\";
% cell_type = "1302_200Rq2_100G_9Z_25deg";
% cell_number = "006_D";

cell_path = "C:\Research\Data\cut7-GFP sid4-mCh\MB1316\Segmented Cells\";
cell_type = "1316_200Rq2_100G_9Z_25deg";
cell_number = "002_C";

data_path = cell_path + cell_type + "_" + cell_number + ".mat";
data_path = convertStringsToChars(data_path);

%% Loading ImageObj and cut7/MT movies
[movie3D_CH1, movie3D_CH2, voxel_size, time_step] = GetMovieInfo(data_path);

%% Fill the even frames of sid4 movie (q2, no data) with previous odd frame
% This is only used when imaging red every alternate frames, to avoid photo-bleaching
movie3D_CH1(:,:,:,2:2:end) = movie3D_CH1(:,:,:,1:2:end-1);
%% Creats directories for saving outputs
CreateSaveDir(cell_path, cell_type, cell_number);

%% Specify the good frames of cut7 to fit spots with Gaussian 2D
disp('Please review the FIJI movie and decide the (valid) frames to track sid4.')
prompt = " First frame to fit? ";
first_frame_spb = input(prompt);
prompt = " Last frame to fit? ";
last_frame_spb = input(prompt);
prompt = " Order all spots by left/right or up/down? (answer with 'x' or 'y')  ";
sort_by = input(prompt, 's');

%% Find the spot (cut7, sid4, anything...)
% Using a lower threshold, find as many spot as can, then veto down to 2: 
pos_sid4_rough_all = FindAllRoughPos(movie3D_CH1, first_frame_spb, last_frame_spb, 1, 3);
pos_sid4_rough_pair = VetoSpots(movie3D_CH1, pos_sid4_rough_all, 2);

% Order the two spots by either left-right or up-down:
pos_sid4_rough = Sort2Spots(pos_sid4_rough_pair, movie3D_CH1, sort_by);

% Try to fit with 2D Gaussian: 
pos_sid4_refined = FindRefinedPos(movie3D_CH1, pos_sid4_rough, first_frame_spb, last_frame_spb);

%% Optionally swap the spot ordering: 
% temp1=pos_spots_final(1,:,100:130);
% temp2=pos_spots_final(3,:,100:130);
% pos_spots_final(3,:,100:130)=temp1;
% pos_spots_final(1,:,100:130)=temp2;

%% Auto Correction:
pos_sid4_corrected = AutoCorrection(pos_sid4_refined, first_frame_spb, last_frame_spb, 5);
% pos_sid4_corrected = AutoCorrection(pos_sid4_refined, first_frame_spb, last_frame_spb, 10);

%% Refit and refine:
pos_sid4_rounded = round(pos_sid4_corrected);
pos_sid4_final = FindRefinedPos(movie3D_CH1, pos_sid4_rounded, first_frame_spb, last_frame_spb);
% debugMovie(movie3D_CH1, pos_sid4_final, first_frame_spb, last_frame_spb,'sid4_loc');
save('pos_sid4_final.mat','pos_sid4_final');

%% Plot the spindle length
plot1LvT(pos_cut7_pk,voxel_size,time_step,first_frame,last_frame);
exportgraphics(gcf,'lvt_plot_full.png');

%% Make kymograph: 
sid4_kymograph = makeKymograph(movie3D_CH1, pos_sid4_final, first_frame_spb, last_frame_spb, voxel_size, time_step, 'sid4');
saveas(gcf,'sid4_kymographs.png');
cut7_kymograph = makeKymograph(movie3D_CH2, pos_sid4_final, first_frame_spb, last_frame_spb, voxel_size, time_step, 'cut7');
saveas(gcf,'cut7_kymographs.png');

%% Combining the two color channels
Kymograph_merged = MergeKymographs(sid4_kymograph(first_frame_spb:last_frame_spb, :), cut7_kymograph(first_frame_spb:last_frame_spb, :));
Kymograph_combined = imadjust(Kymograph_merged,[0.2 0 0; 0.7 0.6 1],[]);
figure;
imshow(Kymograph_combined);
save('Kymograph_combined.mat','Kymograph_combined');
exportgraphics(gcf,'Red-Green-Kymograph.png');
exportgraphics(gcf,'Red-Green-Kymograph.tif');
saveas(gcf,'Red-Green-Kymograph.svg');
saveas(gcf,'Red-Green-Kymograph.fig');
pause(1);
close all;

