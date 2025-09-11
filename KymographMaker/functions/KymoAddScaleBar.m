% Automatically drawing scalebars to kymograph

function KymoAddScaleBar(Kymograph, low_thres, high_thres, total_length, total_time, channelType)
    
    unit_length = 3;            % Micrometers
    unit_time = 3;              % Minutes
    edge_dist_ini = 7;          % How far to draw the scale bar from the edge (default: TR corner)
    bar_thickness_ini = 5;      % Marker size of scale bar, in pixel on the kymograph
    resize_factor = 3;          % Using imresize bicubic interpolation to mimic ImageJ smoothing.
    edge_dist = edge_dist_ini * resize_factor;
    bar_thickness = bar_thickness_ini * resize_factor;


    % Vertical and Horizontal dimension of kymograph
    [kymo_sz_vert, kymo_sz_horz] = size(Kymograph);
    scale_bar_length = round(resize_factor * unit_length / total_length * kymo_sz_horz);
    scale_bar_height = round(resize_factor * unit_time / total_time * kymo_sz_vert);

    % Brightness and contrast adjustments
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
    SmoothedKymograph = imgaussfilt(Kymograph);
    SmoothedKymograph = imresize(SmoothedKymograph, resize_factor);
    
    %% Draw the scale bar on KymographSC:
    KymographSC = SmoothedKymograph;
    % Use max_pix_val as 100% white pixel for scalebar: 
    % Horizontal scale-bar: 
    KymographSC(edge_dist+1 : edge_dist+bar_thickness, resize_factor*kymo_sz_horz-edge_dist-scale_bar_length+1 : resize_factor*kymo_sz_horz-edge_dist) = max_pix_val;
    % Vertical scale-bar:
    KymographSC(edge_dist+1 : edge_dist+scale_bar_height, resize_factor*kymo_sz_horz-edge_dist-bar_thickness+1 : resize_factor*kymo_sz_horz-edge_dist) = max_pix_val;
    figure;
    imshow(KymographSC, [low_val_sp, hig_val_sp]); colormap gray;

    %   out_filename = strcat(channelType, '_KymographScaleBar.png');
    %   exportgraphics(gcf, out_filename);
    out_filename = strcat(channelType, '_Kymo+ScBar.fig');
    saveas(gcf, out_filename);
    out_filename = strcat(channelType, '_Kymo+ScBar.tif');
    exportgraphics(gcf, out_filename);
    %% Solo optimized figure

end
