function debugMovie(movie, pos_spots, first_frame, last_frame, movie_name)
    
    if nargin == 4
        movie_name = './debug_movie.mp4';
    end

    %% make spots detection movies
    movie_path = movie_name;
    vidfile = VideoWriter(movie_path,'MPEG-4');
    vidfile.FrameRate = 10;
    open(vidfile);
    ccc = figure;
    for frame_number = first_frame:last_frame
        img = movie(:,:,:,frame_number);
        img_smoothed = imgaussfilt3(img);
        img_MIP = max(img_smoothed, [], 3);
        imagesc(img_MIP); colormap('gray');
        hold on;
        plot(pos_spots(:,1,frame_number),pos_spots(:,2,frame_number), 'yo', LineWidth=2);
        plot(pos_spots(1,1,frame_number),pos_spots(1,2,frame_number), 'o', color=[0.8, 0, 0], LineWidth=2);
        plot(pos_spots(2,1,frame_number),pos_spots(2,2,frame_number), 'o', color=[0, 0.8, 0], LineWidth=2);
        hold off;
        title(sprintf('Frame = %.0f',frame_number));
        writeVideo(vidfile, getframe(gcf));
    end
    close(vidfile);
    close(ccc);

end
