function pos_gauss_fit = FindRefinedPos(movie4D, pos_spots_rough, first_frame, last_frame)
    
    if (nargin == 2)    % No frame specified
        first_frame = 1;
        last_frame = size(pos_spots_rough, 3);
    end

    data_dimension = size(movie4D);
    total_frames = data_dimension(4);
    pos_gauss_fit = zeros(size(pos_spots_rough, 1),2,total_frames);
    pos_gauss_fit(pos_gauss_fit == 0) = NaN;
    movie_path = './refined_pos.mp4';
    vidfile = VideoWriter(movie_path,'MPEG-4');
    vidfile.FrameRate = 10;
    open(vidfile);
    fff = figure;
    for frame_number = first_frame:last_frame
        img = movie4D(:,:,:,frame_number);
        img_smoothed = imgaussfilt3(img);
        img_MIP = max(img_smoothed, [], 3);
        img_MIP( img_MIP == 0 ) = NaN;
        img_MIP( isnan(img_MIP) ) = 0;
        % Get the rough position of cut7
        for spot_idx = 1:size(pos_spots_rough, 1)
            pos_rough_x = pos_spots_rough(spot_idx,1,frame_number);
            pos_rough_y = pos_spots_rough(spot_idx,2,frame_number);
            has_spot = pos_rough_x + pos_rough_y;
            % Fit with Gaussian2D Function and find the refined position
            if ~isnan(has_spot)
                [pos_ref_x, pos_ref_y] = fit2DGaussian(img_MIP, pos_rough_x, pos_rough_y, 3);
                pos_gauss_fit(spot_idx,1,frame_number) = pos_ref_x;
                pos_gauss_fit(spot_idx,2,frame_number) = pos_ref_y;
            end
        end
        % Display Detection
        imagesc(img_MIP); colormap("gray");
        hold on;
        plot(pos_gauss_fit(1,1,frame_number),pos_gauss_fit(1,2,frame_number), 'ro', LineWidth=2);
        if size(pos_spots_rough, 1) >= 2
            plot(pos_gauss_fit(2,1,frame_number),pos_gauss_fit(2,2,frame_number), 'go', LineWidth=2);
        elseif size(pos_spots_rough, 1) >= 3
            plot(pos_gauss_fit(3,1,frame_number),pos_gauss_fit(3,2,frame_number), 'bo', LineWidth=2);
        end
        hold off;
        title(sprintf('Frame = %.0f',frame_number));
        % writeVideo(vidfile, getframe(gcf));
    end
    close(vidfile);
    close(fff);

end 