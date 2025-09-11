function [KymographNoPoles, Midzone_Data] = RemovePoles(KymographsOg, Pos_Poles, PoleWidth, PoleOffset)

%% This function extract midzone data from a full kymograph by removing the two bright poles
% 
%% Inputs: 
% KymographsOg: The original kymograph with two bright poles. 
% Pos_Poles:    The pos_peak file of the two poles, in pixels (e.g. pos_cut7_pk).         
% PoleWidth:    Number of pixels at each side from the center of the pole to remove.
%               These pixels will become zero, so that the pole intensities are removed.
%               Default to 5 pixels wide. 
% PoleOffset:   Column index of the brightest pixel of the left pole. (i.e. The distance 
%               from the center of the left pole to the left edge of the kymograph) 
%               Default to 11 pixels from the left edge / column 1. 
%
%% Outputs:     
% KymographNoPoles: The full "modified" kymograph, without any pole intenisty.
% Midzone_Data:     The remaining midzone of the "modified" kymograph, shifted 
%                   to the left edge of the image (start at column 1). 
% 
% CREATED: Bojun Zhou, University of Colorado, Boulder, Jan-29-2025

    if nargin < 4
        PoleOffset = 11;
        if nargin < 3
            PoleWidth = 5;
        end
    end
    
    KymographNoPoles = KymographsOg;
    
    % Peak to peak dist: 
    p2p_vector = squeeze(Pos_Poles(2,:,:) - Pos_Poles(1,:,:));
    p2p_dist_pix = round(sqrt(sum(p2p_vector.^2)))';
    p2p_dist_pix(isnan(p2p_dist_pix)) = 0;

    % Subtracting the left pole
    KymographNoPoles( : ,  PoleOffset-PoleWidth  : PoleOffset+PoleWidth ) = 0;
    Midzone_Data_Mid = KymographNoPoles;
    Midzone_Data_Mid( : ,  1 : PoleOffset-PoleWidth ) = 0;

    % Subtracting the right pole
    for lines = 1 : length(p2p_dist_pix)
        KymographNoPoles( lines ,  p2p_dist_pix(lines)+PoleOffset-PoleWidth : p2p_dist_pix(lines)+PoleOffset+PoleWidth ) = 0;
        Midzone_Data_Mid( lines ,  p2p_dist_pix(lines)+PoleOffset-PoleWidth : end ) = 0;
    end
    
    % Shift the Midzone_Data to the left edge:  
    Midzone_Data = Midzone_Data_Mid(:, 1+PoleOffset+PoleWidth : end);

end
