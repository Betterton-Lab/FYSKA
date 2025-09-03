% Extract all bright spots from the movie. 
% Exclude all bright spots
% Find the background value (median) with bright spots masked out
% Return new movie with background subtracted (movie_sub)

function kymograph_sub = subtractKymoBackground(kymograph, movie, first_frame, last_frame)
    
    % Mask out all the pixel values in the neighborhood of bright spot
    % region_size = rectangle area around bright spot to take out
    region_size = 5;
    % how many stdev about the median is a bright spot? 
    threshold_sigma = 3;
    % Background value with and without exclusion:
    bkg_value_0 = zeros(last_frame - first_frame + 1, 1);
    bkg_value_exc = zeros(last_frame - first_frame + 1, 1);

    % Create a copy of movie (movie_sub), the background subtracted movie:
    kymograph_sub = kymograph;
    
    % Processing background subtraction frame by frame: 
    for frame_number = first_frame : last_frame
        img = movie(:,:,:,frame_number);
        img_smoothed = imgaussfilt3(img);
        img_MIP = max(img_smoothed, [], 3);
        img_MIP( img_MIP == 0 ) = NaN;
        bkg_value_0(frame_number) = median(img_MIP(:), 'omitnan');
        % set exclusion zone: 
        spot_thres = bkg_value_0(frame_number) + threshold_sigma * std(img_MIP(:), 'omitnan');
        spot_locs = FindAllSpots(img_MIP, spot_thres, 3);

        if  size(spot_locs, 1) < 1
            % No spot found, nothing to exclude. 
            bkg_value_exc(frame_number) = bkg_value_0(frame_number); 
        else
            img_MIP_exc = img_MIP; 
            for pts = 1 : size(spot_locs, 1)
                x_lo = spot_locs(pts, 1) - region_size;
                x_hi = spot_locs(pts, 1) + region_size;
                y_lo = spot_locs(pts, 2) - region_size;
                y_hi = spot_locs(pts, 2) + region_size;
                img_MIP_exc((y_lo:y_hi),(x_lo:x_hi)) = NaN;
            end
            bkg_value_exc(frame_number) = median(img_MIP_exc(:), 'omitnan');
        end
        kymograph_sub(frame_number, :) = kymograph(frame_number, :) - bkg_value_exc(frame_number);
    end
    save("bkg_subtracted_kymograph.mat", "kymograph_sub");

end