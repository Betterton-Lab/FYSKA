function [Kymograph, Full_Lengh, Total_Time] = GetScaleBarInfo(movie4D, pos_spots, first_frame, last_frame, voxel_size, time_step, channelType)

    % Number of steps for interpolation
    interp_step = 100; 
    % If set to 0, interp_step will be set to max spindle pixel length (a variable)
    % else, it will equal to a fixed value (100, 200 etc.)
    use_fixed_interp_step = 0;
    % If set to 1, will use fix center configuration for drawing the alignment axis
    % To use fix end alignment axis, set this to 0
    fix_cntr_alignment = 0;
    
    % Extra pixel distance added to one end of the cut7 spot pos
    AbsEndExt = 10;
    
    % Extract cut7 peak to peak distance
    axis_vector = squeeze(pos_spots(1,:,:) - pos_spots(2,:,:));
    axis_vector_micron = axis_vector .* [voxel_size(1); voxel_size(2)];
    p2p_len_pix = sqrt(sum((axis_vector.^2), 1));             % p2p distance in pixels
    p2p_len_micron = sqrt(sum((axis_vector_micron.^2), 1));   % p2p distance in microns
    max_p2p_len_pix = ceil(max(p2p_len_pix));                   % Max distance in pixels
    max_p2p_len_micron = max(p2p_len_micron);                   % Max distance in microns
    ratio7_to_max = max_p2p_len_micron ./ p2p_len_micron;       % Ratios of individual spindle length to max length
    
    if (use_fixed_interp_step == 0)
        interp_step=max_p2p_len_pix + 2*AbsEndExt;
    end
    
    % Initialize empty matrix to store kymograph & cut7 pos
    Kymograph = zeros( (last_frame - first_frame + 1), interp_step );
    spots_pos_on_kymograph = zeros( (last_frame - first_frame + 1), 3 );

    for frame_number = first_frame:last_frame
        img = movie4D(:,:,:,frame_number);
        img_smoothed = imgaussfilt3(img);
        img_MIP = max(img_smoothed, [], 3);
        % Use SPB position for Cut-7 position and extended position
        spot1_pos = pos_spots(1,:,frame_number);
        spot2_pos = pos_spots(2,:,frame_number);
        spot_pos_cntr = (spot1_pos + spot2_pos) / 2;
        end_pos1= spot1_pos - (spot2_pos-spot1_pos)/norm(spot2_pos-spot1_pos)*AbsEndExt;
        end_pos2= spot1_pos + (spot2_pos-spot1_pos)*ratio7_to_max(frame_number)...
            +(spot2_pos-spot1_pos)/norm(spot2_pos-spot1_pos)*AbsEndExt;
        % % % % Fix Center Configuration % % % %
        if (fix_cntr_alignment == 1)
            end_pos1 = spot_pos_cntr + (spot1_pos - spot_pos_cntr) * ratio7_to_max(frame_number);
            end_pos2 = spot_pos_cntr + (spot2_pos - spot_pos_cntr) * ratio7_to_max(frame_number);
        end
        % % % % Fix Center Configuration % % % %
        % Single-line Interoplation: 
        x_list = linspace(end_pos1(1), end_pos2(1), interp_step);
        y_list = linspace(end_pos1(2), end_pos2(2), interp_step);
        % Store the cut7 peak pos relative to end pos
        spots_pos_on_kymograph(frame_number,1) = norm(spot1_pos-end_pos1)/norm(end_pos2-end_pos1);
        spots_pos_on_kymograph(frame_number,2) = norm(spot2_pos-end_pos1)/norm(end_pos2-end_pos1);
        spots_pos_on_kymograph(frame_number,3) = norm(end_pos2-end_pos1);
        % Interpolate to get intensity of the pixels alone the line in 2D (MIP) and 3D
        Intensity_Line = interp2(img_MIP, x_list, y_list, 'cubic');
        % Combines the Intensity_ValueAloneLine variable by stacking them
        Kymograph(frame_number, :) = Intensity_Line;
    end

    % Plot Kymograph
    figure;
    imagesc(Kymograph(first_frame:last_frame, :)); colormap gray;
    title_name = strcat("Kymograph of ", channelType, " intensity alone the spindle");
	title(title_name);
	xt = get(gca, 'XTick');                                     % Original 'XTick' Values
    yt = get(gca, 'YTick');                                     % Original 'YTick' Values
    xtlbl = round(xt*voxel_size(1), 2);                         % New 'XTickLabel' Vector
    ytlbl = round(time_step*yt/60, 2);                          % New 'YTickLabel' Vector
    set(gca, 'XTick',xt, 'XTickLabel',xtlbl, 'FontSize', 14);
    set(gca, 'YTick',yt, 'YTickLabel',ytlbl, 'FontSize', 14);
    xlabel('Distance along the spindle axis (\mum)');
	ylabel('Time (Minutes)');
    hold on;
    c = colorbar;
    colorbar_name = strcat(channelType, ' intensity (a.u)');
    c.Label.String = colorbar_name;
    c.Label.FontSize = 14;
	% Plot location of SPB1 and SPB2 on top
    times = 1 : (last_frame - first_frame + 1);
	plot(spots_pos_on_kymograph(first_frame:last_frame, 1)*interp_step+1, times, 'r.', 'MarkerSize',10, 'LineWidth',1);
	plot(spots_pos_on_kymograph(first_frame:last_frame, 2)*interp_step, times, 'g.', 'MarkerSize',10, 'LineWidth',1);
    legend('spot1 loc', 'spot2 loc', 'FontSize', 14, 'TextColor', 'white');
    legend boxoff;
    hold off;
    out_filename = strcat(channelType, '_kymographs+dots.png');
    exportgraphics(gcf, out_filename);
    out_filename = strcat(channelType, '_kymographs+dots.fig');
    saveas(gcf,out_filename)
    save('spots_pos_on_kymograph.mat', 'spots_pos_on_kymograph');

    % Calculate Full_Lengh and Total_Time: 
    Full_Lengh = (max(spots_pos_on_kymograph(:,3), [], "omitnan"))*voxel_size(1);
    Total_Time = (last_frame - first_frame + 1)*time_step/60;
    
end


