function [] = PrintSegmentationStats(seg_guess,seg_true,mdl_str)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

[edema_dice, enhancing_dice, wt_dice] = get_dice(seg_guess,seg_true);

fprintf('%7s dice results: \nWT:%5.3f\nED:%5.3f\nEN:%5.3f\n',...
    mdl_str,wt_dice,edema_dice,enhancing_dice);

end



function [edema_dice, enhancing_dice, wt_dice] = get_dice(seg_guess,seg_true)
    edema_dice = ComputeDiceScore(seg_guess,seg_true,2);
    enhancing_dice = ComputeDiceScore(seg_guess,seg_true,4);
    wt_dice = ComputeDiceScore(seg_guess > min(seg_guess(:)),seg_true > 0,1);
end
