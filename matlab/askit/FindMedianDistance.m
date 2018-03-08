function med = FindMedianDistance( G )

nn = size(G,1);
nsub = min(nn,100);
idx = randperm(nn,nsub);

Gsub = G(idx,:);
dists = repmat( sum(Gsub .* Gsub,2)', nn, 1) + ...
  repmat( sum(G .* G,2), 1, nsub) - 2.*G * Gsub';
med = median(dists(:));
med = round(med,2);
end
