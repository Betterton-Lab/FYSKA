% Kymograph Expansion Code
% 4-14-2022
% Abstract: 
% This code takes an spindle line as input, 
% and output a spindle region expansion
% 
% Procedure: 
% 1. Take in the two un-modded end_pos as input
% end_pos need to be in format of [x, y, 0]  (2d)
% end_pos need to be in format of [x, y, z]  (3d)
%
% 2. Draw the spindel line by connecting the two end_pos
% 3. Define z_normal as [0,0,1]
% 4. Find the expansion direction using cross product 
% exp_dir = cross(spindle_dir_norm, z_normal)
%
% 5. Expand n points in the direction of expansion, with width = w
% 6. Save the coordinates of n expansion points as outputs


function [end_pos1_mod, end_pos2_mod] = ExpandSpindleLine(end_pos1, end_pos2, np, width)

    spindle_vector = end_pos2 - end_pos1; 
    spindle_vector_norm = spindle_vector / norm(spindle_vector);
    z_norm = [0,0,1];
    expand_dir = cross(spindle_vector_norm, z_norm);
    expand_line = width * expand_dir;
    expand_step = expand_line / np;
    total_steps = -np : np;
	end_pos1_mod = zeros(length(total_steps), 3);
    end_pos2_mod = zeros(length(total_steps), 3);
    
    for count_idx = 1 : length(total_steps)
        real_idx = total_steps(count_idx);
        end_pos1_mod(count_idx, :) = end_pos1 + expand_step * real_idx;
        end_pos2_mod(count_idx, :) = end_pos2 + expand_step * real_idx;
    end

end
% Kymograph Expansion Code