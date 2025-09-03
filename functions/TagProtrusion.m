function pos_protrusion = TagProtrusion(movie1, movie2, first_frame, last_frame)
     % Make a movie demo of alignment and kymograph making
    movie_path = './protrusion_tagged.mp4';
    vidfile = VideoWriter(movie_path,'MPEG-4');
    vidfile.FrameRate = 10;
    open(vidfile);
    hhh = figure;
    pos_protrusion = zeros(1,2,last_frame);

for frame = first_frame:1:last_frame
    img_red = movie1(:,:,:,frame);
    img_smoothed_red = imgaussfilt3(img_red);
    img_MIP_red = max(img_smoothed_red, [], 3);
    img_MIP_red(img_MIP_red==0) = NaN;
    img_green = movie2(:,:,:,frame);
    img_smoothed_green = imgaussfilt3(img_green);
    img_MIP_green = max(img_smoothed_green, [], 3);
    img_MIP_green(img_MIP_green==0) = NaN;
    
    % % Contrast adjustments so that tagging of SPB are easier
    min_red = min(img_MIP_red(:));
    mid_red = median(img_MIP_red(:),'omitnan');
    max_red = max(img_MIP_red(:));
    min_green = min(img_MIP_green(:));
    mid_green = median(img_MIP_green(:),'omitnan');
    max_green = max(img_MIP_green(:));
    mid_min_diff_green = mid_green - min_green;
    max_mid_diff_green = max_green - mid_green;
    mid_min_diff_red = mid_red - min_red;
    max_mid_diff_red = max_red - mid_red;
    % % Set thresholds for each color
    lo_thres_red = min_red + 0.5*mid_min_diff_red;
    hi_thres_red = mid_red + 0.5*max_mid_diff_red;
    lo_thres_green = min_green + 0.0*mid_min_diff_green;
    hi_thres_green = mid_green + 0.7*max_mid_diff_green;
    % % Contrast adjust the image based on threshold
    img_MIP_red(img_MIP_red(:)<=lo_thres_red)=0;
    img_MIP_red(img_MIP_red(:)>=hi_thres_red)=max_red;
    img_MIP_green(img_MIP_green(:)<=lo_thres_green)=0;
    img_MIP_green(img_MIP_green(:)>=hi_thres_green)=max_green;

    % Display the adjusted image:
    img_merged = imfuse(img_MIP_red, img_MIP_green, 'falsecolor', 'Scaling', 'independent', 'ColorChannels', [1 2 0]);
    imadjust(img_merged,[0.2 0.1 0; .8 .5 1],[]);
    imagesc(img_merged);
    hold on; 
    title(sprintf('Frame = %.0f',frame));
    % Use ginput to get the spot location of current frame:
    spot1=ginput(1);
    pos_protrusion(1,:,frame)=spot1;
    plot(spot1(1), spot1(2), 'ko', 'MarkerSize', 7, LineWidth=1);
    pause(0.1);
    hold off;
    writeVideo(vidfile, getframe(gcf))
end
close(vidfile);
close(hhh);

end