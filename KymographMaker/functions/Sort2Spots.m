function pos_spots_ordered = Sort2Spots(pos_spots_rough, movie, sort_by)
    
    %% SORTSPOTS 
    % Order the spot index by left-right or up-down.
    % 
    %% Inputs: 
    %  pos_spots_rough  :   An [2 * 2 * frame_number] array including 
    %  the x, y position of the spots in every movie frame. 
    %  
    %  sort_by (x, or y):   Decides to order the spots index either from
    %  left to right (sort_by == 'x') or from down to up (sort_by == 'y').
    %  Defaults are left/right ordering. 
    %  
    %% Outputs: 
    %  pos_spots_ordered  :   An orderd [2 * 2 * frame_number] array, rows
    %  by the user's sorting decision. (i.e. 1st row: position of the spot
    %  at the left/down, 2nd row: position of the spot at the right/up).

    if (nargin == 2)    % Defaults to left/right ordering. 
        sort_by = 'x';
    end

    pos_spots_ordered = pos_spots_rough;
    total_frames = size(pos_spots_rough, 3);

    for frame_number = 1:total_frames
        x1 = pos_spots_rough(1,1,frame_number);
        y1 = pos_spots_rough(1,2,frame_number);
        x2 = pos_spots_rough(2,1,frame_number);
        y2 = pos_spots_rough(2,2,frame_number);

        if sort_by == 'x' || sort_by == 'X'     % Sort by left/right: 
        % looking for x value: smaller x -> left -> 1st spot // bigger x -> right -> 2nd spot
            if x2 < x1
                % swap;
                pos_spots_ordered(1,:,frame_number) = pos_spots_rough(2,:,frame_number);
                pos_spots_ordered(2,:,frame_number) = pos_spots_rough(1,:,frame_number);
            end
        end
        if sort_by == 'y' || sort_by == 'Y'     % Sort by up/down:
        % looking for y value: bigger y -> lower -> 1st spot // smaller y -> upper -> 2nd spot
            if y1 < y2
                % swap;
                pos_spots_ordered(1,:,frame_number) = pos_spots_rough(2,:,frame_number);
                pos_spots_ordered(2,:,frame_number) = pos_spots_rough(1,:,frame_number);
            end
        end
    end

    %% make cut7 detection movies (optional)
%     movie_path = './spots_pos_ordered.mp4';
%     vidfile = VideoWriter(movie_path,'MPEG-4');
%     vidfile.FrameRate = 10;
%     open(vidfile);
%     ccc = figure;
%     for frame_number = 1:total_frames
%         img = movie(:,:,:,frame_number);
%         img_smoothed = imgaussfilt3(img);
%         img_MIP = max(img_smoothed, [], 3);
%         img_MIP( img_MIP == 0 ) = NaN;
%         imagesc(img_MIP); colormap("gray");
%         hold on;
%         plot(pos_spots_ordered(1,1,frame_number),pos_spots_ordered(1,2,frame_number), 'o', color=[0.8, 0, 0], LineWidth=2);
%         plot(pos_spots_ordered(2,1,frame_number),pos_spots_ordered(2,2,frame_number), 'o', color=[0, 0, 0.8], LineWidth=2);
%         hold off;
%         title(sprintf('Frame = %.0f',frame_number));
%         writeVideo(vidfile, getframe(gcf));
%     end     
%     close(vidfile);
%     close(ccc);

end