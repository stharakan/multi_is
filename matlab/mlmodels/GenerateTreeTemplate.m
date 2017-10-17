function [ tree ] = GenerateTreeTemplate(  )
%GENERATETREETEMPLATE will create a tree template to pass into matlab
%solvers like fitcecoc. Each git tag will correspond to a different set of
%a parameters for the tree. They will be listed here and in the readme.

tree = templateTree();


end

