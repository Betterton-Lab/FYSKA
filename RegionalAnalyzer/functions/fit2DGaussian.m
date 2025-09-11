% This code use fitSymmetric2DGauss function to fit a 2D Gaussian to an image
% Input Guessed parameters - format: 
% [gaussian amplitude, x y center position, stdev, +const]
% gaussian_param = [amp, x0, y0, sigma, overall const];
% Gaussian Function: 
% G(x,y) = Const + Amp * exp [ -((xi-x0)^2/(2*sigma) + (yi-y0)^2/(2*sigma)) ]

% This function takes in a rough location of spot, within some region size
% It returns a more precised location of spots, employing Gaussian 2D fit

%%
function [pos_ref_x, pos_ref_y] = fit2DGaussian(img, pos_rough_x, pos_rough_y, region_size)
    % img is img_mip, draw a square subregion    
    x_lo = pos_rough_x - region_size; 
    x_hi = pos_rough_x + region_size; 
    y_lo = pos_rough_y - region_size; 
    y_hi = pos_rough_y + region_size; 
    subregion = img( (y_lo:y_hi), (x_lo:x_hi) );
    fit_param = fit2DGaussianFunc(subregion);
    x_max = fit_param(2);
    y_max = fit_param(3);
    % xy_std = fit_param1(4);
    pos_ref_x = x_lo + x_max - 1; 
    pos_ref_y = y_lo + y_max - 1;
end

%%
function fit_Param = fit2DGaussianFunc(img_data)
    psf = 1.2;  % This is our guessed sigma
    Amp = max(img_data(:)) - median(img_data(:));
    Bkrg = median(img_data(:));
    [pk_pos, pk_val] = max(img_data,[],'all','linear');
    [y0_max, x0_max]=ind2sub(size(img_data), pk_val);    
    guess_param = [Amp, x0_max, y0_max, psf, Bkrg];

    % Generates the Grid Coordinate System
    n_size = size(img_data,1);
    [X,Y] = meshgrid(1 : n_size);
    coord = zeros(n_size,n_size,2);
    coord(:,:,1) = X;
    coord(:,:,2) = Y;
    
    [fit_Param,resnorm,residual,exitflag] = lsqcurvefit(@fitSymmetric2DGauss,guess_param,coord,img_data);
end

%% 
function FSG = fitSymmetric2DGauss(FitParam, xycoord)
 FSG = FitParam(5) + FitParam(1)*exp(   -((xycoord(:,:,1)-FitParam(2)).^2/(2*FitParam(4)^2) + (xycoord(:,:,2)-FitParam(3)).^2/(2*FitParam(4)^2) )  );
end


