%% This function merges two kymographs into a Red-Green composit and display them in pair
% Last Modified: l0-10-2022


function Kymograph_colored_merge = MergeKymographs(Kymograph1, Kymograph2)
        
        Kymographs_sidebyside = imfuse(Kymograph1, Kymograph2, 'montage', 'Scaling','independent'); 
        Kymographs_sidebyside = imresize(Kymographs_sidebyside, 1);
        figure;
        imshow(Kymographs_sidebyside);    
        Kymograph_colored_merge = imfuse(Kymograph1, Kymograph2, 'falsecolor', 'Scaling','independent', 'ColorChannels', [1 2 0]);
        Kymograph_colored_merge = imresize(Kymograph_colored_merge, 1);
        figure;
        imshow(Kymograph_colored_merge);

end