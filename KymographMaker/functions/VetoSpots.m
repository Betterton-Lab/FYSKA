function pos_spots_rough = VetoSpots(movie, all_spots, max_spots)
   
    %% VETOSPOTS 
    % Remove all dim spots from a list of detected spots in a movie.
    % 
    %% Inputs: 
    %  movie  :   the movie with or without spots in each frame, 
    %  any above median plus some threshold pixels can be considered as spots.
    % 
    %  all_spots:   the position of all spots detected in each frame, 
    %  in forms of (x, y, frames). In case of multiple spots per frame,
    %  (x_i, y_i, frames), with max(i) = number of spots detected in that frame. 
    %   
    %  max_spots:   the number of remaining spots after veto. default = 2
    %  if not specified. 
    %  
    %% Outputs: 
    %  A [max_spots * 2 * frame_number] array including only the position of
    %  the 2 (or "max_spots" number of) brightest spots in every movie frame. 
    %

    if (nargin == 2)
        max_spots = 2;
    end
    
    % How big to draw the subregion square box that includes the spot.
    % box_length = 2 * box_radius + 1, centered at the spot location.
    box_radius = 3; 
    
    data_dimension = size(movie);
    total_frames = data_dimension(4);
    pos_spots_rough = zeros(max_spots,2,total_frames);
    pos_spots_rough(pos_spots_rough == 0) = NaN;

% %     %% make a detection movies
% %     movie_path = './spot_pos_rough.mp4';
% %     vidfile = VideoWriter(movie_path,'MPEG-4');
% %     vidfile.FrameRate = 10;
% %     open(vidfile);
% %     ccc = figure;
    for frame_number = 1:total_frames
        img = movie(:,:,:,frame_number);
        img_smoothed = imgaussfilt3(img);
        img_MIP = max(img_smoothed, [], 3);
        img_MIP( img_MIP == 0 ) = NaN;
        % Draw subregion in image, centered at each spot's position
        total_spots = sum(~isnan(all_spots(:,:,frame_number)), 1);
        total_spots = total_spots(1);
        disp(['Frame = ', num2str(frame_number), ', number of spots found: ', num2str(total_spots)]);
        % Only a single spot detected, save to pos_spots_rough right away: 
        if total_spots < 2
            pos_spots_rough(1,:,frame_number) = all_spots(1,:,frame_number);
            spot_picked = 0;
        else
            sub_box = zeros(2*box_radius+1, 2*box_radius+1, total_spots);
            for spot_ID = 1:total_spots
                x_lo = all_spots(spot_ID,1,frame_number) - box_radius;
                x_hi = all_spots(spot_ID,1,frame_number) + box_radius;
                y_lo = all_spots(spot_ID,2,frame_number) - box_radius;
                y_hi = all_spots(spot_ID,2,frame_number) + box_radius;
                % Boundary condition: 
                if x_lo <= 1
                    x_lo = 1;
                    x_hi = x_lo + 2*box_radius;
                end
                if y_lo <= 1
                    y_lo = 1;
                    y_hi = y_lo + 2*box_radius;
                end
                sub_box(:,:,spot_ID) = img_MIP(y_lo:y_hi, x_lo:x_hi);
            end
            sum_box_intensity = squeeze(sum(sum(sub_box,'omitnan'),'omitnan'));
            
            % keep only the brightest two spots and find their index: 
            sorted_total = sort(unique(sum_box_intensity), 'descend');
            brightest_1_idx = (sum_box_intensity == sorted_total(1));
            brightest_2_idx = (sum_box_intensity == sorted_total(2));
            % User forced single spot detection, save the brightest: 
            if max_spots == 1
                pos_spots_rough(1,:,frame_number) = all_spots(brightest_1_idx,:,frame_number);
                spot_picked = 1;
            elseif max_spots >= 2
                pos_spots_rough(1,:,frame_number) = all_spots(brightest_1_idx,:,frame_number);
                pos_spots_rough(2,:,frame_number) = all_spots(brightest_2_idx,:,frame_number);
                spot_picked = 2;
            end
            if total_spots > 2 && max_spots > 2
                pos_spots_rough(1,:,frame_number) = all_spots(brightest_1_idx,:,frame_number);
                pos_spots_rough(2,:,frame_number) = all_spots(brightest_2_idx,:,frame_number);
                brightest_3_idx = (sum_box_intensity == sorted_total(3));
                pos_spots_rough(3,:,frame_number) = all_spots(brightest_3_idx,:,frame_number);
                spot_picked = 3;
            end
        end
        
% %         % Display Detection
% %         imagesc(img_MIP); colormap("gray"); colorbar;
% %         hold on;
% %         plot(all_spots(:,1,frame_number),all_spots(:,2,frame_number), 'y.', LineWidth=0.1);
% %         plot(pos_spots_rough(:,1,frame_number),pos_spots_rough(:,2,frame_number), 'wo', LineWidth=2);
% %         
% %         if spot_picked > 1
% %             plot(pos_spots_rough(1,1,frame_number),pos_spots_rough(1,2,frame_number), 'o', color=[0.8, 0, 0], LineWidth=2);
% %             plot(pos_spots_rough(2,1,frame_number),pos_spots_rough(2,2,frame_number), 'o', color=[0, 0.8, 0], LineWidth=2);
% %             if spot_picked > 2
% %                 plot(pos_spots_rough(3,1,frame_number),pos_spots_rough(3,2,frame_number), 'o', color=[0, 0.5, 1], LineWidth=2);
% %             end
% %         end
% % 
% %         hold off;
% %         title(sprintf('Frame = %.0f',frame_number));
% %         writeVideo(vidfile, getframe(gcf));
% %         title(sprintf('Frame = %.0f',frame_number));
% %         writeVideo(vidfile, getframe(gcf));

    end     
% %     close(vidfile);
% %     close(ccc);

end
