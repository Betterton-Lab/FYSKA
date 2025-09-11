% This function draw a rectangular mask using the equation of 4 points
% img_org is the original image, m * n array. 
% img_masked is the masked image, pixel values in the rectangle will be
% keeped, everything else will be zero.

function img_masked = getRectRegion(img_org, p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y)

    % get the linear equations of the 4 points
    coef_12 = polyfit([p1x, p2x], [p1y, p2y], 1);
    coef_23 = polyfit([p2x, p3x], [p2y, p3y], 1);
    coef_34 = polyfit([p3x, p4x], [p3y, p4y], 1);
    coef_41 = polyfit([p4x, p1x], [p4y, p1y], 1);

    [max_x, max_y] = size(img_org);
    img_masked = img_org; 

    % making every pixel outside of the boundary condition zero
    for i_x = 1:max_x
    for i_y = 1:max_y
        if i_x > coef_12(1)*i_y + coef_12(2) || i_x < coef_34(1)*i_y + coef_34(2)
            img_masked(i_x, i_y) = 0;
        end
    end
    end
    % there is a chance that in pervious step, all pixel becomes zeros
    % in such case, re-do, using the alternative boundary condition
    if max(img_masked)==0
        img_masked = img_org;
        % alternative boundary condition, flip the sign of the inequalities
        for i_x = 1:max_x
        for i_y = 1:max_y
            if i_x < coef_12(1)*i_y + coef_12(2) || i_x > coef_34(1)*i_y + coef_34(2)
                img_masked(i_x, i_y) = 0;
            end
        end
        end
    end
    
    % img_temp here should be img_orginial but bounded by two parallel lines. 
    img_temp = img_masked;

    % do the same thing for the other two inequalities
    for i_x = 1:max_x
    for i_y = 1:max_y
        if i_x > coef_23(1)*i_y + coef_23(2) || i_x < coef_41(1)*i_y + coef_41(2)
            img_masked(i_x, i_y) = 0;
        end
    end
    end
    % there is a chance that in pervious step, all pixel becomes zeros
    % in such case, re-do, using the alternative boundary condition
    if max(img_masked)==0
        img_masked = img_temp;
        % alternative boundary condition, flip the sign of the inequalities
        for i_x = 1:max_x
        for i_y = 1:max_y
            if i_x < coef_23(1)*i_y + coef_23(2) || i_x > coef_41(1)*i_y + coef_41(2)
                img_masked(i_x, i_y) = 0;
            end
        end
        end
    end

    % Special cases:
    if p1x == p2x || p1y == p2y || p1x == p4x || p1y == p4y
        img_masked = img_org;
        for i_x = 1:max_x
        for i_y = 1:max_y
            % if point 1 and 4 is exactly above / below point 2 and 3: 
            if p1x == p2x && p4x == p3x
                if i_y <= min(p1x, p4x) || i_y >= max(p2x, p3x)
                    img_masked(i_x, i_y) = 0;
                end
            end
            % if point 1 and 2 is exactly above / below point 3 and 4: 
            if p1x == p4x && p2x == p3x
                if i_y <= min(p1x, p2x) || i_y >= max(p3x, p4x)
                    img_masked(i_x, i_y) = 0;
                end
            end
            % if point 1 and 2 is the same level as point 3 and 4:
            if p1y == p4y && p2y == p3y 
                if i_x <= min(p1y, p2y) || i_x >= max(p4y, p3y)
                    img_masked(i_x, i_y) = 0;
                end
            end
            % if point 1 and 4 is the same level as point 2 and 3:
            if p1y == p2y && p3y == p4y 
                if i_x <= min(p1y, p3y) || i_x >= max(p2y, p4y)
                    img_masked(i_x, i_y) = 0;
                end
            end
        end
        end
    end     % end of special condition

end     % end of function
