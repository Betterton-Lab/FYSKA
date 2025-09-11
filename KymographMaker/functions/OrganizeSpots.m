% Re-organize spots to orders of 1. Far SPB, 2. Middle SPB, 3 Protrusion

function pos_spots_ordered = OrganizeSpots(pos_spots, frame_number)

    % Spot 1 always far SPB, spot 2 always near SPB, spot 3 always protrusion.
    % The key idea is to determine which SPB is closer to the protrusion. 
    % With the existing 'pos_spots_combined' format, spot 3 is always the protrusion. 
    % Hence, we only need to rearrange spot 1 2 and identify the middle SPB. 

    pos_spots_ordered = pos_spots;
    dist_13 = norm(pos_spots(3, :, frame_number) - pos_spots(1, :, frame_number));
    dist_23 = norm(pos_spots(3, :, frame_number) - pos_spots(2, :, frame_number));
    if dist_13 < dist_23        % Swap the spots 
        pos_spots_ordered(1,:,:) = pos_spots(2,:,:);
        pos_spots_ordered(2,:,:) = pos_spots(1,:,:);
    end
    
end