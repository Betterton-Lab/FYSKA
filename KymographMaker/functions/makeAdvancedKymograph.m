function Kymograph = makeAdvancedKymograph(movie4D, pos_spots, voxel_size, time_step, channelType)

    %% Extra pixel distance added to one end of the spot pos
    AbsEndExt = 10;

    %% Determining the first and last frames of SPB and protrusions
    has_spb = squeeze(sum(sum(pos_spots(1:2, :, :),1),2));
    has_prot = squeeze(sum(sum(pos_spots(3, :, :),1),2));
    has_prot_mask = ~isnan(has_prot);
    first_frame_spb = find(~isnan(has_spb), 1, 'first');
    last_frame_spb = find(~isnan(has_spb), 1, 'last');
    first_frame_prot = find(has_prot_mask, 1, 'first');
    last_frame_prot = find(has_prot_mask, 1, 'last');
    
    %% Extract cut7 peak to peak distance
    axis_21 = squeeze(pos_spots(2,:,:) - pos_spots(1,:,:));
    axis_23 = squeeze(pos_spots(2,:,:) - pos_spots(3,:,:));
    axis_micron21 = axis_21 .* [voxel_size(1); voxel_size(2)];
    axis_micron23 = axis_23 .* [voxel_size(1); voxel_size(2)];
    p2p_len_pix21 = sqrt(sum((axis_21.^2), 1));
    p2p_len_pix23 = sqrt(sum((axis_23.^2), 1));
    p2p_len_micron21 = sqrt(sum((axis_micron21.^2), 1));
    p2p_len_micron23 = sqrt(sum((axis_micron23.^2), 1));
    max_p2p_len_pix21 = ceil(max(p2p_len_pix21));
    max_p2p_len_pix23 = ceil(max(p2p_len_pix23));
    max_p2p_len_micron21 = max(p2p_len_micron21);
    max_p2p_len_micron23 = max(p2p_len_micron23);
    ratio7_to_max21 = max_p2p_len_micron21 ./ p2p_len_micron21;
    ratio7_to_max23 = max_p2p_len_micron23 ./ p2p_len_micron23;
    %% Number of steps for interpolation, depending on the length of spindle
    interp_step21 = max_p2p_len_pix21 + AbsEndExt;
    interp_step23 = max_p2p_len_pix23 + AbsEndExt;

    % Initialize empty matrix to store kymograph & cut7 pos
    Kymograph = zeros( (last_frame_spb - first_frame_spb + 1), interp_step21 + interp_step23 );
    spots_pos_on_kymograph = zeros( (last_frame_spb - first_frame_spb + 1), 3 );

    % Make a movie demo of alignment and kymograph making
    movie_path = strcat('./', channelType, '_movie.mp4');
    vidfile = VideoWriter(movie_path,'MPEG-4');
    vidfile.FrameRate = 10;
    open(vidfile);
    hhh = figure;
    for frame_number = first_frame_spb:last_frame_spb
        img = movie4D(:,:,:,frame_number);
        img_smoothed = imgaussfilt3(img);
        img_MIP = max(img_smoothed, [], 3);
        % Use SPB position for Cut-7 position and extended position
        spot1_pos = pos_spots(1,:,frame_number);
        spot2_pos = pos_spots(2,:,frame_number);
        spot3_pos = pos_spots(3,:,frame_number);
        end_pos1 = spot2_pos + (spot1_pos-spot2_pos)*ratio7_to_max21(frame_number)...
                +(spot1_pos-spot2_pos)/norm(spot1_pos-spot2_pos)*AbsEndExt;
        end_pos2 = spot2_pos;
        if frame_number >= first_frame_prot && frame_number <= last_frame_prot && has_prot_mask(frame_number)
            end_pos3 = spot2_pos + (spot3_pos-spot2_pos)*ratio7_to_max23(frame_number)...
                +(spot3_pos-spot2_pos)/norm(spot3_pos-spot2_pos)*AbsEndExt;
        else
            end_pos3 = spot2_pos - (spot1_pos-spot2_pos)/norm(spot1_pos-spot2_pos)*(max_p2p_len_pix23+AbsEndExt);
        end
        % Single-line Interoplation: 
        x_list21 = linspace(end_pos2(1), end_pos1(1), interp_step21);
        y_list21 = linspace(end_pos2(2), end_pos1(2), interp_step21);
        x_list23 = linspace(end_pos2(1), end_pos3(1), interp_step23);
        y_list23 = linspace(end_pos2(2), end_pos3(2), interp_step23);

        % Store the cut7 peak pos relative to end pos
        spots_pos_on_kymograph(frame_number,1) = norm(spot1_pos-end_pos1)/(norm(end_pos1-end_pos2)+norm(end_pos3-end_pos2));
        spots_pos_on_kymograph(frame_number,2) = norm(spot2_pos-end_pos1)/(norm(end_pos1-end_pos2)+norm(end_pos3-end_pos2));
        spots_pos_on_kymograph(frame_number,3) = (norm(spot3_pos-end_pos2)+norm(end_pos2-end_pos1))/(norm(end_pos1-end_pos2)+norm(end_pos3-end_pos2));

        % Interpolate to get intensity of the pixels alone the line in 2D (MIP) and 3D
        Intensity_Line21 = interp2(img_MIP, x_list21, y_list21, 'cubic');
        Intensity_Line23 = interp2(img_MIP, x_list23, y_list23, 'cubic');
        % Combines the Intensity_ValueAloneLine variable by stacking them
        Kymograph(frame_number, :) = [flip(Intensity_Line21), Intensity_Line23];
        % Make Movie Demo
        img_MIP_double = mat2gray(img_MIP);
        img_MIP_enhanced = imadjust(img_MIP_double, [0.1, 0.7]);
        imagesc(img_MIP_enhanced); colormap('gray');
        hold on; 
        plot(spot1_pos(1),spot1_pos(2),"ro",'MarkerSize',7,'LineWidth',1);
        plot(spot2_pos(1),spot2_pos(2),"go",'MarkerSize',7,'LineWidth',1);
        plot(spot3_pos(1),spot3_pos(2),"bo",'MarkerSize',7,'LineWidth',1);
        plot(end_pos1(1),end_pos1(2),"rx",'MarkerSize',7,'LineWidth',2);
        plot(end_pos2(1),end_pos2(2),"go",'MarkerSize',7,'LineWidth',1);
        plot(end_pos3(1),end_pos3(2),"bx",'MarkerSize',7,'LineWidth',2);
        plot(x_list21, y_list21, 'y-', LineWidth = 0.4);
        plot(x_list23, y_list23, 'y-', LineWidth = 0.4);
        hold off;
        title(sprintf('Frame = %.0f',frame_number));
        writeVideo(vidfile, getframe(gcf))
    end
    close(vidfile);
    close(hhh);
    out_filename = strcat(channelType, '_kymographs.mat');
    save(out_filename,'Kymograph');
    % Plot Kymograph
    figure;
    imagesc(Kymograph(first_frame_spb:last_frame_spb, :)); colormap gray;
    title_name = strcat("Kymograph of ", channelType, " intensity alone the spindle");
	title(title_name);
	xt = get(gca, 'XTick');
    yt = get(gca, 'YTick');
    xtlbl = round(xt*(max_p2p_len_micron21+max_p2p_len_micron23)/(interp_step21+interp_step23), 2);
    ytlbl = round(time_step*yt/60, 2);
    set(gca, 'XTick',xt, 'XTickLabel',xtlbl);
    set(gca, 'YTick',yt, 'YTickLabel',ytlbl);
    xlabel('Distance along the spindle axis (\mum)');
	ylabel('Time (Minutes)');
    hold on;
    c = colorbar;
    colorbar_name = strcat(channelType, ' intensity (a.u)');
    c.Label.String = colorbar_name;
	% Plot location of SPB1 and SPB2 on top
    times = 1 : (last_frame_spb - first_frame_spb + 1);
	plot(spots_pos_on_kymograph(first_frame_spb:last_frame_spb, 1)*(interp_step21+interp_step23+2), times, 'r.', 'LineWidth',1);
	plot(spots_pos_on_kymograph(first_frame_spb:last_frame_spb, 2)*(interp_step21+interp_step23+2), times, 'g.', 'LineWidth',1);
    plot(spots_pos_on_kymograph(first_frame_spb:last_frame_spb, 3)*(interp_step21+interp_step23+1), times, 'b.', 'LineWidth',1);
    legend('spot1', 'spot2', 'spot3', Location='northeast');
    hold off;
    out_filename = strcat(channelType, '_kymographs+dots.png');
    exportgraphics(gcf, out_filename);
    out_filename = strcat(channelType, '_kymographs+dots.fig');
    saveas(gcf,out_filename)
    
end



    

