function [ pvec ] = SubplotPosititionVector( buf,pos_x,pos_y,tot_x,tot_y )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

pvec = [(pos_x/tot_x) + buf, (pos_y/tot_y) + buf, ...
    (1/tot_x) - (2*buf), (1/tot_y) - 2*buf];

end

