% This function finds the midzone to pole cut7 ratio
% width is the width of the cut7 pole (in pixel) on kymograph, 3 by default

function [ratio, error] = getRatio(Stripe_Collection, p2p_dist, width)

    % get the number of rows with kymograph data
    valid_rows = sum(~isnan(Stripe_Collection(:,11)));
    % get the correct pole to pole distance in pixel
    p2p_dist_pix = round(p2p_dist/0.1067);
    pole1_center_pix = 11;                                  % center position of the first cut7 peak, in pixel
    pole1_LB = pole1_center_pix - width;                    % left boundary of the first pole, in pixel
    pole1_RB = pole1_center_pix + width;                    % right boundary of the first pole, in pixel
    pole2_LB = pole1_center_pix + p2p_dist_pix - width;     % left boundary of the second pole, in pixel
    pole2_RB = pole1_center_pix + p2p_dist_pix + width;     % right boundary of the second pole, in pixel
    
% %     % display the corresponding region, making sure the region is valid:
% %     figure;
% %     imagesc(Stripe_Collection);
% %     title('Everything');
% %     pause(1);
% %     figure;
% %     imagesc(Stripe_Collection(1:valid_rows, pole1_LB:pole1_RB));
% %     title('pole-1');
% %     pause(1);
% %     figure;
% %     imagesc(Stripe_Collection(1:valid_rows, pole2_LB:pole2_RB));
% %     title('pole-2');
% %     pause(1);
% %     figure;
% %     imagesc(Stripe_Collection(1:valid_rows, pole1_RB:pole2_LB));
% %     title('midzone');
% %     % close the figures, if they looks good. Else, debug
% %     pause(1);
% %     close all;

    % sum the line-scan intensity at each corresponding region (pole/midzone)
    pole1_intensities = sum(Stripe_Collection(1:valid_rows, pole1_LB:pole1_RB), 2, "omitnan");
    pole2_intensities = sum(Stripe_Collection(1:valid_rows, pole2_LB:pole2_RB), 2, "omitnan");
    midzone_intensities = sum(Stripe_Collection(1:valid_rows, pole1_RB:pole2_LB), 2, "omitnan");

    % get the average and standard deviation of intensity at each corresponding region (pole/midzone)
    pole1_average = sum(pole1_intensities)/valid_rows;
    pole1_error = std(pole1_intensities);
    pole2_average = sum(pole2_intensities)/valid_rows;
    pole2_error = std(pole2_intensities);
    midzone_average = sum(midzone_intensities)/valid_rows;
    midzone_error = std(midzone_intensities);
    total_pole_error = sqrt(pole1_error^2 + pole2_error^2);

    % calculate the ratio of cut7-GFP, 2 poles vs. midzone, 
    % and standard error using error propagation rules
    % error is standard deviation of the mean, 1/root(N)
    ratio = midzone_average./(pole1_average + pole2_average);
    std_error = ratio * sqrt((total_pole_error/(pole1_average + pole2_average))^2 + (midzone_error/midzone_average)^2);
    error = std_error / sqrt(valid_rows);

end