% Re-organize spots to orders of 1. Far SPB, 2. Middle SPB, 3 Protrusion

function plot1LvT(pos_spots, voxel_size, time_step, first_frame, last_frame)

    % Extract cut7 peak to peak distance
    axis_12 = squeeze(pos_spots(2,:,:) - pos_spots(1,:,:));
    axis_micron12 = axis_12 .* [voxel_size(1); voxel_size(2)];
    p2p_len_micron21 = sqrt(sum((axis_micron12.^2), 1));
    time_array = time_step/60*(first_frame:last_frame);
    
    figure;
    plot(time_array,p2p_len_micron21(first_frame:last_frame), color=[0, 0.9, 0], LineStyle='-', LineWidth=2);
    hold on;
    legend('spindle length', Location='northwest');
    legend boxoff;
    set(gca, "FontName","Arial", "FontSize",20);
    xlabel('Time (minutes)','FontName','Arial','FontSize',20);
    ylabel('Length (\mum)','FontName','Arial','FontSize',20);

end