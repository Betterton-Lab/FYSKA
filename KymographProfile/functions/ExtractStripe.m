% This function takes in a cut7_p2p info file and a kymograph
% It segments the kymograph around the neighboorhood of a user defined p2p_dist (in pixles) 
% p2p_range is the width of the neighborhood (in pixels or microns)
% p2p_dist is the center of the neighborhood (in pixels or microns)
% Finally, the code returns a stripe segment of the kymograph

function Stripe = ExtractStripe(pos_cut7_pk, Kymograph, p2p_dist, p2p_range)
    
    p2p_vector = squeeze(pos_cut7_pk(2,:,:) - pos_cut7_pk(1,:,:));
    p2p_length_pix = sqrt(sum(p2p_vector.^2));
    p2p_length_micron = 0.1067 * p2p_length_pix;
    desired_rows = find ( p2p_length_micron > (p2p_dist - p2p_range)  &  p2p_length_micron < (p2p_dist + p2p_range) );
    Stripe( 1:length(desired_rows) , 1:size(Kymograph,2) ) = Kymograph( desired_rows , : ); 

% % % % For Debugs Only:     
% %     for r = 1:length(p2p_length_micron)
% %         if p2p_length_micron(r) > (p2p_dist - p2p_range)  &&  p2p_length_micron(r) < (p2p_dist + p2p_range)
% %             disp(p2p_length_micron(r));
% %         end
% %     end
end