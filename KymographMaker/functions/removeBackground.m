% This function removes the background value of an 2D image by subtracting
% the median value from the original image. 

function img_no_bkrg = removeBackground(img)

    img( img == 0 ) = NaN;
    bkrg_value = median(img, "all", "omitnan");
    img_no_bkrg = img - bkrg_value;

end