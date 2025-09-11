function pos_spot_rough = FindRoughPos(movie4D, first_frame, last_frame, threshold, spot_size)
    
    if (nargin == 3 || nargin == 4)
        threshold = 2;
        spot_size = 3;
    end
    
    data_dimension = size(movie4D);
    total_frames = data_dimension(4);
    pos_spot_rough = zeros(2,2,total_frames);
    pos_spot_rough(pos_spot_rough == 0) = NaN;
    
    %% make cut7 detection movies
    movie_path = './rough_position.mp4';
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
        
        % Only get the two maximally-distant points
        PD = squareform(pdist(all_spots));
        [~,idxMax] = max(PD(:));
        [idx1, idx2] = ind2sub(size(PD), idxMax);
        spots_pair = all_spots([idx1,idx2],:);
        
        % Display Detection
        imagesc(img_MIP); colormap("gray");
        hold on;
        if isempty(all_spots)
            continue
        elseif size(all_spots,1) == 1
            pos_spot_rough(1,:,frame_number) = all_spots;
            plot(all_spots(1,1),all_spots(1,2), 'rx');
        else
            pos_spot_rough(:,:,frame_number) = spots_pair;
            plot(spots_pair(1,1),spots_pair(1,2), 'rx');
            plot(spots_pair(2,1),spots_pair(2,2), 'gx');
            plot(all_spots(:,1),all_spots(:,2), 'yo');
        end
        hold off;
        title(sprintf('Frame = %.0f',frame_number));
        writeVideo(vidfile, getframe(gcf));
    end
    close(vidfile);
    close(ccc);

    % Open file for writing, for data reproductions
    fid = fopen('spots threshold info.txt', 'a');
    % Write content
    fprintf(fid, 'First frame = %d\n', first_frame);
    fprintf(fid, 'Last frame = %d\n', last_frame);
    fprintf(fid, 'Threshold = %.1f std\n', threshold);
    fprintf(fid, 'Spot size = %d pix\n\n', spot_size);
    % Close file
    fclose(fid);
    fprintf('Threholding params saved to spots threshold info.txt\n');

end


