function pos_spots_correct_full = AutoCorrection(pos_spots_raw, first_frame, last_frame, dev_thres)
    
    if (nargin == 3)    % Defaults to 10 pixels (~1 micron)
        dev_thres = 10;
    end
    
    pos_spots_selected = pos_spots_raw(:,:,first_frame:last_frame);
    pos_spots_correct = pos_spots_selected;
    pos_spots_correct_full = pos_spots_raw;

    % Translate point pairs to length vs. time:
    axis_vector = squeeze(pos_spots_selected(1,:,:) - pos_spots_selected(2,:,:));
    p2p_dist = sqrt(sum((axis_vector.^2), 1))';
    p2p_time = (1:length(p2p_dist))';
    p2p_raw = [p2p_time, p2p_dist];
    p2p_dist = fillmissing(p2p_dist,'linear');
    
    % Plot the raw length vs. time in dark red:
    figure;
    plot(p2p_time, p2p_dist,'.-',Color=[0.75, 0, 0],LineWidth=1);
    legend("raw",Location="northwest");
    pause(1);
    hold on;
    
    % Fit the raw lvt curve with 5th order poly to detect outliers
    fit_func = fit(p2p_time, p2p_dist,'poly5','Robust','Bisquare');
    p2p_fit = [p2p_time, fit_func(p2p_time)];
    % Plot the fitted length vs. time in purple:
    plot(p2p_fit(:,1), p2p_fit(:,2),'.-',Color=[0.5, 0, 0.75],LineWidth=1);
    legend("raw","fitted",Location="northwest");
    pause(1);
    % Outlier detection, using a threshold of 0.5 microns:
    length_diff = abs(p2p_fit(:,2) - p2p_dist);
    % Bad point detection by finding the index of the outliers: 
    bad_pts = find(length_diff > dev_thres);
    % No bad points found! Do nothing
    if isempty(bad_pts)
        disp('Nothing to correct, spots positions are good.');
        % Plot the raw length vs. time again in green:
        plot(p2p_raw(:,1),p2p_raw(:,2),'.-',Color=[0, 0.8, 0],LineWidth=1);
        legend("raw","fitted","all good",Location="northwest");
        % legend box off;
    else
        disp(['Bad spots detected at frame: ', num2str(bad_pts')]);
        disp('Auto-corrections in progress...');
        p2p_filtered = p2p_raw;
        % Removing bad length points
        p2p_filtered(bad_pts, 2)=NaN;
        pos_spots_correct(:,:,bad_pts)=NaN;
        % Plot the filtered bad points with red X:
        plot(p2p_raw(bad_pts,1),p2p_raw(bad_pts,2),'x',Color=[0.5, 0, 0],MarkerSize=10,LineWidth=2);
        legend("raw","fitted","filtered",Location="northwest");
        pause(1);
        % Filling the bad points using linear interpolation of the good points in the neighborhood:
        p2p_filled = p2p_filtered;
        p2p_filled(:,2) = fillmissing(p2p_filtered(:,2),'linear','SamplePoints',p2p_filtered(:,1));
        pos_spots_correct = fillmissing(pos_spots_correct,'linear',3);
        % Plot the filled (fixed) length vs. time in golden yellow:
        plot(p2p_filled(:,1),p2p_filled(:,2),'.-',Color=[0.85, 0.7, 0],LineWidth=1);
        legend("raw","fitted","filtered","correction",Location="northwest");
        % legend box off;
    end
    
    % %% For Demo only (1149_005_G, t70-240)
    % set(gca, "FontName","Arial", "FontSize",18);
    % xlim([0,180]);
    % xticks(0:30:180)
    % xticklabels({'70','100','130','160','190','220','250'});
    % xlabel('Frames','FontName','Arial',"FontSize",18);
    % ylabel('Distance (pixels)','FontName','Arial',"FontSize",18);

    hold off;
    saveas(gcf, "AutoCorrection.png");
    pos_spots_correct_full(:,:,first_frame:last_frame) = pos_spots_correct;

end
