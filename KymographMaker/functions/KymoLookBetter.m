% This code takes in the kymograph, and adjust the constrast of kymograph
% The low_thres controls the lower bound for constrast adjustment, anything below will display as 0 (black). 
% The high_thres controls the upper bound for constrast adjustment, anything above will display as 255 (white). 
% lower bound is defined by lower_bound = min_pix_val + low_thres * mid_min_diff;
% upper bound is defined by upper_bound = median_pix_val + high_thres * max_mid_diff;
% last modified: 7-14-2022

function KymoLookBetter(Kymograph, low_thres, high_thres, channelType)

    min_pix_val = min(Kymograph(:));
    max_pix_val = max(Kymograph(:));
    median_pix_val = median(Kymograph(:), 'omitnan');
    mid_min_diff = median_pix_val - min_pix_val; 
    max_mid_diff = max_pix_val - median_pix_val;
    
    % User can choose whether to use relative intensity for image optimization:
    % (Condition: low and high threshold between 0-1)
    % Or use absolute intensity for image optimization: 
    % (e.g. low_thres = min(Kymopgrah(:)), high_thres = max(Kymopgrah(:)))
    if (low_thres>=0 && low_thres<=1)   % relative intensity optimization
        low_val_sp = min_pix_val + low_thres * mid_min_diff; 
    else                                % absolute intensity optimization
        low_val_sp = low_thres;
    end

    if (high_thres>=0 && high_thres<=1) % relative intensity optimization
        hig_val_sp = median_pix_val + high_thres * max_mid_diff;
    else                                % absolute intensity optimization
        hig_val_sp = high_thres;
    end 

    %% Solo optimized figure
    figure;
    SmoothedKymograph = imgaussfilt(Kymograph);
    SmoothedKymograph = imresize(SmoothedKymograph, 1);
    imshow(SmoothedKymograph, [low_val_sp, hig_val_sp]); colormap gray;
    %     out_filename = strcat(channelType, '_KymographOptimized.png');
    %     exportgraphics(gcf, out_filename);
    %     out_filename = strcat(channelType, '_KymographOptimized.fig');
    %     saveas(gcf, out_filename);
    out_filename = strcat(channelType, '_KymographOptimized.tif');
    exportgraphics(gcf, out_filename);
    %% Solo optimized figure

end
