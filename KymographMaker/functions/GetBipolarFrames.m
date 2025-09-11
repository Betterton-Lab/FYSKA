function bipolar_frames= GetBipolarFrames(pos_cut7_pk_rough)

    % Change zero values to NaN (no spot found!)
    pos_cut7_pk_rough( pos_cut7_pk_rough == 0 ) = NaN;

    % Combine the locations of two spots to eliminate NaNs
    combined_pos = zeros(1, 2, size(pos_cut7_pk_rough,3));
    bipolar_frames = zeros(size(pos_cut7_pk_rough,3), 1);
    
    for frame_number = 1:size(pos_cut7_pk_rough,3)
        combined_pos(1,:,frame_number) = sum(pos_cut7_pk_rough(:,:,frame_number), 1);
        if isnan(combined_pos(1,:,frame_number))
            disp("No spot found!  Frame = " + num2str(frame_number))
        else
            bipolar_frames(frame_number) = frame_number;
            disp(num2str(frame_number));
        end
    end
    bipolar_frames( bipolar_frames == 0 ) = NaN;

    writematrix(bipolar_frames, 'bipolar_frame_info.txt');
    % % save('valid_frame_info.txt', 'valid_frame', '-ascii');
    
    % Change NaN values to 0 (no spot found!)
    % pos_cut7_pk_rough( isnan(pos_cut7_pk_rough) ) = 0;

end



