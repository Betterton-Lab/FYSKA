function pos_all_spots = FindAllRoughPos(movie4D, first_frame, last_frame, threshold, spot_size)
    
    if (nargin == 3 || nargin == 4)
        threshold = 2;
        spot_size = 3;
    end
    
    data_dimension = size(movie4D);
    total_frames = data_dimension(4);
    pos_all_spots = zeros(2,2,total_frames);
    pos_all_spots(pos_all_spots == 0) = NaN;

    %% make cut7 detection movies
    movie_path = './all_spots_detection.mp4';
    vidfile = VideoWriter(movie_path,'MPEG-4');
    vidfile.FrameRate = 10;
    open(vidfile);
    ccc = figure;
    for frame_number = first_frame:last_frame
        img = movie4D(:,:,:,frame_number);
        img_smoothed = imgaussfilt3(img);
        img_MIP = max(img_smoothed, [], 3);
        img_MIP( img_MIP == 0 ) = NaN;
        % Use median - stdev relation to find pixel threshold: 
        med_pix_value = median(img_MIP(:),'omitnan');
        intensity_threshold = med_pix_value + threshold * std(img_MIP(:),'omitnan');
        all_spots = FindAllSpots(img_MIP, intensity_threshold, spot_size);
        if ~isempty(all_spots)
            pos_all_spots(1:size(all_spots,1),:,frame_number) = all_spots;
        end
        % Display Detection
        imagesc(img_MIP); colormap("gray");
        hold on;
        if ~isempty(all_spots)
            plot(all_spots(:,1),all_spots(:,2), 'yo');
        end
        hold off;
        title(sprintf('Frame = %.0f',frame_number));
        % writeVideo(vidfile, getframe(gcf));
    end     
    close(vidfile);
    close(ccc);

    pos_all_spots(pos_all_spots == 0) = NaN;


end


