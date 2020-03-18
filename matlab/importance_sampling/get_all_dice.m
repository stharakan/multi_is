function [edema_dice, enhancing_dice, wt_dice] = get_all_dice(seg_guess,seg_true)
    edema_dice = ComputeDiceScore(seg_guess,seg_true,2);
    enhancing_dice = ComputeDiceScore(seg_guess,seg_true,4);
    wt_dice = ComputeDiceScore(seg_guess > min(seg_guess(:)),seg_true > 0,1);
end