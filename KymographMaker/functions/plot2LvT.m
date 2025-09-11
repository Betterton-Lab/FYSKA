% Re-organize spots to orders of 1. Far SPB, 2. Middle SPB, 3 Protrusion

function plot2LvT(pos_3_spots, voxel_size, time_step, first_frame, last_frame)

    % Extract cut7 peak to peak distance
    axis_12 = squeeze(pos_3_spots(2,:,:) - pos_3_spots(1,:,:));
    axis_23 = squeeze(pos_3_spots(3,:,:) - pos_3_spots(2,:,:));
    axis_micron12 = axis_12 .* [voxel_size(1); voxel_size(2)];
    axis_micron23 = axis_23 .* [voxel_size(1); voxel_size(2)];
    p2p_len_micron21 = sqrt(sum((axis_micron12.^2), 1));
    p2p_len_micron23 = sqrt(sum((axis_micron23.^2), 1));
    p2p_len_micron32 = p2p_len_micron23;
    p2p_len_micron32(isnan(p2p_len_micron23))=0;
    p2p_len_micron31 = p2p_len_micron32 + p2p_len_micron21;
    time_array = time_step/60*(first_frame:last_frame);
    
    figure;
    plot(time_array,p2p_len_micron21(first_frame:last_frame), color=[0.9, 0, 0], LineStyle='-', LineWidth=2);
    hold on;
    plot(time_array,p2p_len_micron23(first_frame:last_frame), color=[0, 0.8, 0], LineStyle='-', LineWidth=2);
    plot(time_array,p2p_len_micron31(first_frame:last_frame), color=[1, 0.7, 0], LineStyle='-', LineWidth=2);
    plot(time_array,p2p_len_micron21(first_frame:last_frame), color=[0.9, 0, 0], LineStyle='-', LineWidth=1);
    legend('spindle length', 'protrusion length', 'combined length', Location='northwest');
    legend boxoff;
    set(gca, "FontName","Arial", "FontSize",14);
    xlabel('Time (minutes)','FontName','Arial','FontSize',14);
    ylabel('Length (\mum)','FontName','Arial','FontSize',14);

end