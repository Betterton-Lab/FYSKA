function Kymograph = KymographDemo(movie4D, pos_spots, first_frame, last_frame, voxel_size, time_step, sp_exp_width, n_exp, channelType)

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
    KymoDemo = zeros( (last_frame - first_frame + 1), interp_step );
    spots_pos_on_kymograph = zeros( (last_frame - first_frame + 1), 3 );

    % Brightness and contrast adjustments for demo: 
    c_min = min(movie4D(movie4D ~= 0), [], 'all', 'omitnan');
    c_med = median(movie4D(movie4D ~= 0), 'omitnan');
    c_max = max(movie4D(movie4D ~= 0), [], 'all', 'omitnan');
    c_low = c_min + 0.5*(c_med-c_min);
    c_upp = c_med + 0.2*(c_max-c_med);

    % Make a movie demo of alignment and kymograph making
    movie_path = strcat('./', channelType, '_kymograph_demo.mp4');
    vidfile = VideoWriter(movie_path,'MPEG-4');
    vidfile.FrameRate = 10;
    open(vidfile);
    hhh = figure;
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
        % Expand the Spindle Line:
        end_pos1(3) = 0;
        end_pos2(3) = 0;
        [end_pos1_mod, end_pos2_mod] = ExpandSpindleLine(end_pos1, end_pos2, n_exp, sp_exp_width);
        % Initialize matrix to store the interpolation results
        x_mat = zeros(length(end_pos1_mod),interp_step);
        y_mat = zeros(length(end_pos1_mod),interp_step);
        z_mat = zeros(length(end_pos1_mod),interp_step);
        for current_points = 1: length(end_pos1_mod)
            x_mat(current_points,:) = linspace(end_pos1_mod(current_points,1), end_pos2_mod(current_points,1), interp_step);
            y_mat(current_points,:) = linspace(end_pos1_mod(current_points,2), end_pos2_mod(current_points,2), interp_step);
            z_mat(current_points,:) = linspace(end_pos1_mod(current_points,3), end_pos2_mod(current_points,3), interp_step);
        end
        x_mat = x_mat.';
        y_mat = y_mat.';
        % Interpolate the matrix directly
        IntensityArea = interp2(img_MIP, x_mat, y_mat, 'cubic');
        % Sum along the horizontal direction
        IntensityAreaLine = squeeze( sum(IntensityArea, 2, 'omitnan') )';
        Kymograph(frame_number, :) = IntensityAreaLine;
        KymoDemo(frame_number - first_frame + 1, :) = IntensityAreaLine;

        % Store the cut7 peak pos relative to end pos
        spots_pos_on_kymograph(frame_number,1) = norm(spot1_pos-end_pos1(1:2))/norm(end_pos2(1:2)-end_pos1(1:2));
        spots_pos_on_kymograph(frame_number,2) = norm(spot2_pos-end_pos1(1:2))/norm(end_pos2(1:2)-end_pos1(1:2));
        spots_pos_on_kymograph(frame_number,3) = norm(end_pos2(1:2)-end_pos1(1:2));
        
        % Make Movie Demo
        set(gcf, "Units", "centimeters", "Position", [6, 6, 40, 14]);
        subplot(1,2,1);
        imagesc(img_MIP, [c_low, c_upp]); colormap('gray');
        hold on;
        plot(spot1_pos(1),spot1_pos(2),"ro",'MarkerSize',10,'LineWidth',1);
        plot(spot2_pos(1),spot2_pos(2),"go",'MarkerSize',10,'LineWidth',1);
        plot(end_pos1(1),end_pos1(2),"rx",'MarkerSize',10,'LineWidth',1);
        plot(end_pos2(1),end_pos2(2),"gx",'MarkerSize',10,'LineWidth',1);
        plot(x_mat(:,1), y_mat(:,1), 'w-', LineWidth = 0.1);
        plot(x_mat(:,2*n_exp+1), y_mat(:,2*n_exp+1), 'w-', LineWidth = 0.1);
        title(sprintf('Frame = %.0f',frame_number));
        hold off;
        subplot(1,2,2);
        imagesc(KymoDemo); colormap gray;
        title(sprintf('Frame = %.0f',frame_number));
        writeVideo(vidfile, getframe(gcf))
    end
    close(vidfile);
    close(hhh);
    out_filename = strcat(channelType, '_kymographs.mat');
    save(out_filename,'Kymograph');

    % Plot Kymograph
    figure;
    imagesc(Kymograph(first_frame:last_frame, :)); colormap gray;
    title_name = strcat("Kymograph of ", channelType, " intensity alone the spindle");
	title(title_name);
	xt = get(gca, 'XTick');                                     % Original 'XTick' Values
    yt = get(gca, 'YTick');                                     % Original 'YTick' Values
    xtlbl = round(xt*max_p2p_len_micron/interp_step, 2);        % New 'XTickLabel' Vector
    ytlbl = round(time_step*yt/60, 2);                          % New 'YTickLabel' Vector
    % ytlbl = round(yt+first_frame-1, 2);                       % New 'YTickLabel' Vector
    set(gca, 'XTick',xt, 'XTickLabel',xtlbl);
    set(gca, 'YTick',yt, 'YTickLabel',ytlbl);
    xlabel('Distance along the spindle axis (\mum)');
	ylabel('Time (Minutes)');
    hold on;
    c = colorbar;
    colorbar_name = strcat(channelType, ' intensity (a.u)');
    c.Label.String = colorbar_name;
	% Plot location of SPB1 and SPB2 on top
    times = 1 : (last_frame - first_frame + 1);
	plot(spots_pos_on_kymograph(first_frame:last_frame, 1)*interp_step+1, times, 'r.', 'LineWidth',1);
	plot(spots_pos_on_kymograph(first_frame:last_frame, 2)*interp_step, times, 'g.', 'LineWidth',1);
    legend('spot1 loc', 'spot2 loc');
    hold off;
    out_filename = strcat(channelType, '_kymographs+dots.png');
    exportgraphics(gcf, out_filename);
    out_filename = strcat(channelType, '_kymographs+dots.fig');
    saveas(gcf,out_filename)
    
end



