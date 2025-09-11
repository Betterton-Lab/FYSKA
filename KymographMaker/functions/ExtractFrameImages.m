function ExtractFrameImages(movie4D, pos_spots, first_frame, last_frame, frame_steps)

    % Extra pixel distance added to one end of the cut7 spot pos
    AbsEndExt = 10;
    voxel_size = [0.1067, 0.1067, 0.500];

    % Extract cut7 peak to peak distance
    axis_vector = squeeze(pos_spots(1,:,:) - pos_spots(2,:,:));
    axis_vector_micron = axis_vector .* [voxel_size(1); voxel_size(2)];
    p2p_len_pix = sqrt(sum((axis_vector.^2), 1));             % p2p distance in pixels
    p2p_len_micron = sqrt(sum((axis_vector_micron.^2), 1));   % p2p distance in microns
    max_p2p_len_pix = ceil(max(p2p_len_pix));                   % Max distance in pixels
    max_p2p_len_micron = max(p2p_len_micron);                   % Max distance in microns
    ratio7_to_max = max_p2p_len_micron ./ p2p_len_micron;       % Ratios of individual spindle length to max length
    interp_step=max_p2p_len_pix + 2*AbsEndExt;

    % Brightness and contrast adjustments for demo: 
    c_min = min(movie4D(movie4D ~= 0), [], 'all', 'omitnan');
    c_med = median(movie4D(movie4D ~= 0), 'omitnan');
    c_max = max(movie4D(movie4D ~= 0), [], 'all', 'omitnan');
    c_low = c_min + 0.5*(c_med-c_min);
    c_upp = c_med + 0.1*(c_max-c_med);

    % Make a movie demo of alignment and kymograph making
    for frame_number = first_frame:frame_steps:last_frame
        img = movie4D(:,:,:,frame_number);
        img_smoothed = imgaussfilt3(img);
        img_MIP = max(img_smoothed, [], 3);
        figure;
        imagesc(img_MIP, [c_low, c_upp]); colormap('gray');
        hold on; 
        % Use SPB position for Cut-7 position and extended position
        spot1_pos = pos_spots(1,:,frame_number);
        spot2_pos = pos_spots(2,:,frame_number);
        end_pos1= spot1_pos - (spot2_pos-spot1_pos)/norm(spot2_pos-spot1_pos)*AbsEndExt;
        end_pos2= spot1_pos + (spot2_pos-spot1_pos)*ratio7_to_max(frame_number)...
            +(spot2_pos-spot1_pos)/norm(spot2_pos-spot1_pos)*AbsEndExt;
        % % % % Fix Center Configuration % % % %
        % Single-line Interoplation: 
        x_list = linspace(end_pos1(1), end_pos2(1), interp_step);
        y_list = linspace(end_pos1(2), end_pos2(2), interp_step);
        % Make Movie Demo
        plot(spot1_pos(1),spot1_pos(2),"ro",'MarkerSize',15,'LineWidth',2);
        plot(spot2_pos(1),spot2_pos(2),"go",'MarkerSize',15,'LineWidth',2);
        % plot(spot1_pos(1),spot1_pos(2),"o",'MarkerSize',15,'LineWidth',2,color=[0.9,0.4,0]);
        % plot(spot2_pos(1),spot2_pos(2),"o",'MarkerSize',15,'LineWidth',2,color=[0,0.7,0.6]);
        plot(x_list, y_list, 'y-', LineWidth = 1.5);
        title(sprintf('Frame = %.0f',frame_number));
        text_overlay = ['Frame ', num2str(frame_number)];
        text(50,40, text_overlay, Color=[1,1,1], FontSize=20, FontWeight="bold");
        hold off;
        img_name = strcat(num2str(frame_number), '_detection.png');
        exportgraphics(gcf,img_name);
    end

end