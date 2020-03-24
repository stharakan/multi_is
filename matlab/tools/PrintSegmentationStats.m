function [] = PrintSegmentationStats(seg_guess,seg_true,mdl_str)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

[edema_dice, enhancing_dice, wt_dice] = get_all_dice(seg_guess,seg_true);

fprintf('%7s dice results: \nWT:%5.3f\nED:%5.3f\nEN:%5.3f\n',...
    mdl_str,wt_dice,edema_dice,enhancing_dice);

end


