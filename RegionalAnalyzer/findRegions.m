%% This code find the midzone to pole cut7 ratio vs. time
%% This code loads batches of pos_cut7_pk.mat files and calculates
%  1. specify location of pos_cut7_pk.mat and the cut7 movies
%  2. creates folders that contains cell name (00n_X) and genotpye name
%  3. make midzone-pole movies based on pos_cut7_pk.mat and save outputs into the designated folder

addpath(genpath('functions'));

%% Types of Cut7 Mutant
% mutant_type = "1330_100R_100G_25deg_7.5ng per mL thiamine";
% data_path = "C:\Research\Softwares\Developement\KymographMaker\Saved Data\" + mutant_type + "\";
% data_list = ["001_1","001_3","001_4","001_5","002_7","002_8","002_9",...
%              "007_39","007_40","007_41","007_47","007_48","007_49",...
%              "009_58","009_59","009_60","009_62","009_63","009_64","009_65","009_66","009_68"];
% data_path_mov = "C:\Research\Data\nmt1-cut7 alp4-GBP\Segmented Cells\" + mutant_type + "_" + data_list + ".mat";

% mutant_type = "1273_100R_100G_25deg_7.5ng per mL thiamine";
% data_path = "C:\Research\Softwares\Developement\KymographMaker\Saved Data\" + mutant_type + "\";
% data_list = ["001_1","001_2","001_4","001_5","002_6","002_7","002_8","002_11","002_12","002_13","002_16","003_18",...
%              "006_45","006_46","006_49","006_52","006_53"];
% data_path_mov = "C:\Research\Data\nmt1-cut7\Segmented Cells\" + mutant_type + "_" + data_list + ".mat";

% mutant_type = "1273_100R_100G_25deg_5ug per mL thiamine";
% data_path = "C:\Research\Softwares\Developement\KymographMaker\Saved Data\" + mutant_type + "\";
% data_list = ["001_A","001_B","001_C","001_D","001_E"];
% data_path_mov = "C:\Research\Data\nmt1-cut7\5ug\Segmented Cells\1273_100R_100G_25deg_" + data_list + ".mat";

% mutant_type = "1302_200Rq2_100G_9Z_25deg";
% data_path = "C:\Research\Softwares\Developement\NewAutoSpotFinder\saved data\" + mutant_type + "\";
% data_list = ["006_D","007_C","007_D"];
% data_path_mov = "C:\Research\Data\cut7-GFP sid4-mCh\MB1302\Segmented Cells\1302_200Rq2_100G_9Z_25deg_" + data_list + ".mat";

mutant_type = "1030_100msR_50msG_7Z";
data_path = "C:\Research\Softwares\Developement\cut11-7 analysis\saved data\" + mutant_type + "\";
data_list = "004_A";
data_path_mov = "C:\Research\Data\cut11+ and cut11-7\cut11-7\Segmented Cells\" + mutant_type + "_"+ data_list + ".mat";

% This is the path to cut7_pos_peak.mat
data_path_pos = data_path + data_list + "\pos_sid4_final.mat";

% Make a separate directory to store outputs
if ~exist("Saved Data", 'dir')
    mkdir("Saved Data")
end
cd 'Saved Data'
mkdir(mutant_type);
cd ..

time_step = zeros(length(data_list), 1);
% load pos_cut7_pk.mat and batch make movies
for idx = 1 : length(data_list)
    disp(" ");
    disp(strcat("Currently working on:  ", data_list(idx)));
    % Loading ImageObj and cut7/MT movies
    ImageObj = ImageData.InitializeFromCell(convertStringsToChars(data_path_mov(idx)));
    movie5D = ImageObj.GetImage();   % Both channel = 5D
    % Getting spatial and temporal dimension of the data
    pixel_size = ImageObj.GetSizeVoxels;
    time_step(idx) = ImageObj.GetTimeStep;
    % Getting MT and cut7 channel movie (red/green)
    movie3D_sid4 = double(movie5D(:,:,:,:,1));
    movie3D_cut7 = double(movie5D(:,:,:,:,2));
    clear movie5D;
    clear ImageObj;
    % Loading the cut7 spot location file (pos_cut7_pk.mat)
    load(data_path_pos(idx));

    % First non-zero element in pos_cut7_pk.mat, use it as the first frame for the kymograph
    %     first_frame = (3 + find(pos_sid4_final~=[0 0; 0,0], 1, 'first'))/4;
    %     last_frame = size(pos_sid4_final, 3);
    pos_sid4_final(pos_sid4_final == 0) = NaN;
    has_spb = squeeze(sum(sum(pos_sid4_final(1:2, :, :),1),2));
    first_frame = find(~isnan(has_spb), 1, 'first');
    last_frame = find(~isnan(has_spb), 1, 'last');
    % Save data in the appopriated folder
    cd 'Saved Data\';
    cd(mutant_type);
    mkdir(data_list(idx));
    cd(data_list(idx));
    save("pos_sid4_final.mat", "pos_sid4_final");

    % Make a movie demo of midzone and pole region
    pole1_region = zeros(150, 150);
    pole2_region = zeros(150, 150);
    midzone_region = zeros(150, 150);
    % how big should the pole and midzone region to be? 
    zone_expansion_radius = 4;
    
    % calculating the position for pole and midzone, based on cut7 position
    for frame_number = first_frame:last_frame
        img = movie3D_cut7(:,:,:,frame_number);
        img_smoothed = imgaussfilt3(img);
        img_MIP = max(img_smoothed, [], 3);
        img_MIP_no_bkrg = removeBackground(img_MIP);
        % use SPB position for Cut-7 position and extended position
        pole1_pos = pos_sid4_final(1,:,frame_number);
        pole2_pos = pos_sid4_final(2,:,frame_number);
        % find the spindle orientation and its normal (for drawing the rectangle)
        spindle_vector = pole2_pos - pole1_pos; 
        spindle_vector_norm = spindle_vector / norm(spindle_vector);
        z_norm = [0,0,1];
        expand_dir = cross([spindle_vector_norm, 0], z_norm);
        expand_line = zone_expansion_radius * expand_dir;
        expand_line(3) = [];
        % add extra distance to the spindle pole, along the spindle line
        end_pos1 = pole1_pos - spindle_vector_norm * zone_expansion_radius;
        int_pos1 = pole1_pos + spindle_vector_norm * zone_expansion_radius;
        end_pos2 = pole2_pos + spindle_vector_norm * zone_expansion_radius;
        int_pos2 = pole2_pos - spindle_vector_norm * zone_expansion_radius;
        % plot(end_pos1(1),end_pos1(2),"ro",'MarkerSize',5,'LineWidth',1);
        % plot(end_pos2(1),end_pos2(2),"bo",'MarkerSize',5,'LineWidth',1);
        % find the coordinates of the rectangle's four corners
        rec_1a = end_pos1 + expand_line;
        rec_1b = end_pos1 - expand_line;
        rec_1c = int_pos1 - expand_line;
        rec_1d = int_pos1 + expand_line;
        rec_2a = end_pos2 + expand_line;
        rec_2b = end_pos2 - expand_line;
        rec_2c = int_pos2 - expand_line;
        rec_2d = int_pos2 + expand_line;
        % get the spindle pole and the midzone regions
        pole1_region(:,:,:,frame_number) = getRectRegion(img_MIP_no_bkrg, rec_1a(1), rec_1a(2), ...
        rec_1b(1), rec_1b(2), rec_1c(1), rec_1c(2), rec_1d(1), rec_1d(2));
        pole2_region(:,:,:,frame_number) = getRectRegion(img_MIP_no_bkrg, rec_2a(1), rec_2a(2), ...
        rec_2b(1), rec_2b(2), rec_2c(1), rec_2c(2), rec_2d(1), rec_2d(2));
        midzone_region(:,:,:,frame_number) = getRectRegion(img_MIP_no_bkrg, rec_1c(1), rec_1c(2), ...
        rec_1d(1), rec_1d(2), rec_2d(1), rec_2d(2), rec_2c(1), rec_2c(2));
    end
    
%     makeMovie(movie3D_cut7, first_frame, last_frame, zone_expansion_radius, 'region_movie', pos_sid4_final);
%     makeMovie(pole1_region, first_frame, last_frame, zone_expansion_radius, 'pole1_movie');
%     makeMovie(pole2_region, first_frame, last_frame, zone_expansion_radius, 'pole2_movie');
%     makeMovie(midzone_region, first_frame, last_frame, zone_expansion_radius, 'midzone_movie');

    save('pole1_region.mat', 'pole1_region');
    save('pole2_region.mat', 'pole2_region');
    save('midzone_region.mat', 'midzone_region');

    disp("Movie completed! All respective regions are saved as xxxx_region.mat");
    disp(" ");

end

save('time_step.mat', 'time_step');