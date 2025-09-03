function pos_out = FindAllSpots(img, thres, sp_size)

%% This code finds all the local maxima in an image to pixel level accuracy.
% 
% The output of this code provides a rough estimate of particle's position
% on the image. This rought position can be used as a guess-input for a
% more precise Gaussian 2D fitting algorithm, which can track the particle's 
% position to sub-pixel accuracy in the later steps. 
% 
%% Inputs: 
% img:          The original image to look for spots
% thres:        Intensity threshold, any pixel above thres are picked out.
% sp_size:      The rough size of the spots. In this code, sp_size specifies 
%               the sp_radius, which is floor(sp_size/2), or half of sp_size. 
%               If not specified, the default size is 3 pixel. 
%               The code will only find one spot within each sp_size,
%               excluding regions sp_radius away from the image boarder.
% 
%% Outputs:     
% pos_out:      The [x (col), y (row)] array for all the spots found. If 
%               multiple spots were found, the output array will be a list 
%               of each spot's (x, y) on the image. 
%
% CREATED: Bojun Zhou, University of Colorado, Boulder, July-20-2024
% LAST MODIFIED: Bojun Zhou, July-2024 - Optimized veto procedure based on spot size. 

    if nargin == 2
        sp_size = 3;
    end
    
    sp_radius = floor((sp_size)/2);
    if sp_radius < 1
        sp_radius = 1;
    end
    
    %% Find the spots on the image: 
    [img_row, img_col] = size(img);
    sp_idx = find(img > thres);
    
    %% If no spot detected, end the code right away!
    n_detect = length(sp_idx);
    if n_detect == 0
        pos_out = [];
        disp('Nothing found above the threshold!');
        return;
    else
        % Convert index from a raw number to column and row (XY) on the image: 
        % Note that row-index is the y-coordinates and column-index is the
        % x-coordinates on the image. Be careful! 
        spot_xy = [floor(sp_idx/img_row)+1, mod(sp_idx,img_row)];
        spot_selected = spot_xy;
        % Remove spots within sp_size from the image boundary (spots on the edge)
        sp_idx = find( spot_selected(:,1) > sp_size & spot_selected(:,1) < (img_col-sp_size) ...
                    & spot_selected(:,2) > sp_size & spot_selected(:,2) < (img_row-sp_size) );
        spot_selected = spot_selected(sp_idx,:);
        % Select and only keep the brightest spot in the neighborhood of sp_size 
        % for each spots. This is equivalent to veto the spot if it isn't the
        % brightest spot in its field (i.e. exist some other spots in the same 
        % field brighter than the spot at the EXACT CENTER of the field). If
        % the spot at the EXACT CENTER of the field isn't the brightest, get its 
        % index from spot_selected and remove it from spot_selected. 
        n_spots = size(spot_selected, 1);
        veto_id = [];
        for i = 1 : n_spots
            % spot region on the image: 
            img_roi = img( (spot_selected(i,2)-sp_radius):(spot_selected(i,2)+sp_radius) , ...
                (spot_selected(i,1)-sp_radius):(spot_selected(i,1)+sp_radius) ) ;
            % Find the max in each spot roi and veto if max isn't at the center: 
            [~, max_idx] = max(img_roi, [], 'all');
            center_idx = ((2*sp_radius+1)^2+1)/2;
            if max_idx ~= center_idx
                veto_id = [veto_id, i];
            end
        end
        spot_selected(veto_id,:) = [];
        pos_out = spot_selected;
    end

end