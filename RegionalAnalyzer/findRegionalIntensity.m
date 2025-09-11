% This code batch calculate the Midzone/Pole ratio
% It utilitz the masked region from step 1 (masked_region.mat)

%% Cut7 Truncation Mutants - Kinesin 14 WT
% mutant_type = "1330_100R_100G_25deg_7.5ng per mL thiamine";
% data_path = "C:\Research\Softwares\Developement\IntensityAnalyzer\Saved Data\" + mutant_type + "\";
% data_list = ["001_1","001_3","001_4","001_5","002_7","002_8","002_9",...
%              "007_39","007_40","007_41","007_47","007_48","007_49",...
%              "009_58","009_59","009_60","009_62","009_63","009_64","009_65","009_66","009_68"];

% mutant_type = "1273_100R_100G_25deg_7.5ng per mL thiamine";
% data_path = "C:\Research\Softwares\Developement\IntensityAnalyzer\Saved Data\" + mutant_type + "\";
% data_list = ["001_1","001_2","001_4","001_5","002_6","002_7","002_8","002_11","002_12","002_13","002_16","003_18",...
%              "006_45","006_46","006_49","006_52","006_53"];

% mutant_type = "1273_100R_100G_25deg_5ug per mL thiamine";
% data_path = "C:\Research\Softwares\Developement\IntensityAnalyzer\Saved Data\" + mutant_type + "\";
% data_list = ["001_A","001_B","001_C","001_D","001_E"];

% mutant_type = "1302_200Rq2_100G_9Z_25deg";
% data_path = "C:\Research\Softwares\Developement\IntensityAnalyzer\Saved Data\" + mutant_type + "\";
% data_list = ["006_D","007_C","007_D"];

mutant_type = "1030_100msR_50msG_7Z";
data_path = "C:\Research\Softwares\FYSKA\RegionalAnalyzer\Saved Data\" + mutant_type + "\";
data_list = "004_A";

% Initialize a signle GRAND matrix to save all mutants length vs. ratio
GRAND_length_v_ratio = zeros(0,2);

for idx = 1 : length(data_list)

    cd (data_path + data_list(idx));
    % This is the path to pos_spot.mat and the regional data
    load pos_sid4_final.mat;
    load midzone_region.mat;
    load pole1_region.mat;
    load pole2_region.mat;
    load time_step.mat;

    % First non-zero element in pos_cut7_pk.mat, use it as the first frame for the kymograph
    has_spb = squeeze(sum(sum(pos_sid4_final(1:2, :, :),1),2));
    first_frame = find(~isnan(has_spb), 1, 'first');
    last_frame = find(~isnan(has_spb), 1, 'last');
    pole1_intensity = zeros(last_frame, 1);
    pole2_intensity = zeros(last_frame, 1);
    midzone_intensity = zeros(last_frame, 1);
    spindle_length = zeros(last_frame,1);
    mid_pole_ratio = zeros(last_frame,1);
    length_v_ratio = zeros(last_frame,2);
    time_array = time_step/60*(1:last_frame-first_frame+1);

    for frame_number = first_frame : last_frame
        pole1_intensity(frame_number) = sum(pole1_region(:,:,:,frame_number), "all", "omitnan");
        pole2_intensity(frame_number) = sum(pole2_region(:,:,:,frame_number), "all", "omitnan");
        midzone_intensity(frame_number) = sum(midzone_region(:,:,:,frame_number), "all", "omitnan");
        spindle_length(frame_number) = 0.1067*sqrt((pos_sid4_final(2,1,frame_number)-pos_sid4_final(1,1,frame_number)).^2 + ...
                                                   (pos_sid4_final(2,2,frame_number)-pos_sid4_final(1,2,frame_number)).^2);
        % When spindle poles are within 1 micron (too close), enforcing 0 midzone!
        if spindle_length(frame_number) < 0.9
            midzone_intensity(frame_number) = NaN;
            pole2_intensity(frame_number) = NaN;
        end
        length_v_ratio(frame_number, 1) = spindle_length(frame_number);
        mid_pole_ratio(frame_number) = midzone_intensity(frame_number)/(pole1_intensity(frame_number)+pole2_intensity(frame_number));
        length_v_ratio(frame_number, 2) = mid_pole_ratio(frame_number);
    end
    
    % save the results to folder:
    save('pole1_intensity.mat', 'pole1_intensity');
    save('pole2_intensity.mat', 'pole2_intensity');
    save('midzone_intensity.mat', 'midzone_intensity');
    save('mid_pole_ratio.mat', 'mid_pole_ratio');
    save('length_v_ratio.mat', 'length_v_ratio');

    GRAND_length_v_ratio = vertcat(GRAND_length_v_ratio, length_v_ratio);

    % Regional intensity plot: 
    figure;
    plot(time_array, pole1_intensity(first_frame:last_frame), '-', "Color", [0.8, 0.0, 0], "LineWidth", 1.5);
    hold on;
    plot(time_array, midzone_intensity(first_frame:last_frame), '-', "Color", [1, 0.7, 0], "LineWidth", 1.5);
    plot(time_array, pole2_intensity(first_frame:last_frame), '-', "Color", [0.0, 0.7, 0], "LineWidth", 1.5);
%   plot(time_array, pole1_intensity(first_frame:last_frame), '-', "Color", [0.5, 0.5, 0.5], "LineWidth", 1.5);
%   hold on;
%   plot(time_array, pole2_intensity(first_frame:last_frame), '-', "Color", [0.5, 0.5, 0.5], "LineWidth", 1.5);
%   plot(time_array, midzone_intensity(first_frame:last_frame), '-', "Color", [0.5, 0.5, 0.5], "LineWidth", 1.5);
%   xlim([0,20]);
%   ylim([0,20000]);
    legend("initial pole","midzone","second pole","Location","best","FontSize", 18);
    legend box off;
    set(gca, "FontName", "Arial", "FontSize", 18);
    xlabel("Time (minutes)");
    ylabel("Cut7 intensity (a.u.)");
    hold off;
    out_filename = "pole12_midzone_" + data_list(idx) + ".png";
    exportgraphics(gcf, out_filename);
    cd ..;
    exportgraphics(gcf, out_filename);
    cd (data_path + data_list(idx));
    
%     % Ratio plot:
%     figure;
%     plot(time_array, mid_pole_ratio(first_frame:last_frame), "LineWidth", 2, 'Color', [0, 0, 0]);
%     hold on;
%     set(gca, "FontName", "Arial", "FontSize", 14);
%     xlabel("Time (minutes)");
%     ylabel("Cut7 midzone pole ratio");
%     hold off;
%     out_filename = "mid_pole_ratio_" + data_list(idx) + ".png";
%     exportgraphics(gcf, out_filename);
%     cd ..;
%     exportgraphics(gcf, out_filename);
%     cd (data_path + data_list(idx));

%     pause(2);
%     close all;

end

% This is the ratio vs length data for the entire mutant!
cd (data_path)
save('GRAND_length_v_ratio.mat', 'GRAND_length_v_ratio');

