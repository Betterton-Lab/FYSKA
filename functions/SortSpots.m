function pos_spots_ordered = SortSpots(pos_spots_rough, sort_by)
    
    %% SORTSPOTS 
    % Order the spot index by left-right or up-down.
    % 
    %% Inputs: 
    %  pos_spots_rough  :   An [N * 2 * frame_number] array including 
    %  the x, y position of the spots in every movie frame. 
    %  
    %  sort_by (x, or y):   Decides to order the spots index either from
    %  left to right (sort_by == 'x') or from down to up (sort_by == 'y').
    %  Defaults are left/right ordering. 
    %  
    %% Outputs: 
    %  pos_spots_ordered  :   An orderd [N * 2 * frame_number] array, rows
    %  by the user's sorting decision. (i.e. 1st row: position of the spot
    %  at the left/down, 2nd row: position of the spot at the right/up).

    if (nargin == 1)    % Defaults to left/right ordering. 
        sort_by = 'x';
    end

    pos_spots_ordered = pos_spots_rough;
    total_frames = size(pos_spots_rough, 3);

    for frame_number = 1:total_frames
        if sort_by == 'x' || sort_by == 'X'     % Sort by left/right: 
            pos_spots_current = pos_spots_rough(:,:,frame_number);
            [pos_sorted,idx] = sort(pos_spots_current(:,1));
            pos_spots_ordered(:,:,frame_number) = pos_spots_current(idx,:);
        end
        if sort_by == 'y' || sort_by == 'Y'     % Sort by up/down: 
            pos_spots_current = pos_spots_rough(:,:,frame_number);
            [pos_sorted,idx] = sort(pos_spots_current(:,2));
            pos_spots_ordered(:,:,frame_number) = pos_spots_current(idx,:);
        end
    end