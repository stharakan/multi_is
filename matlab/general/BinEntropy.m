function s = BinEntropy(p)

p =single(p);
if ((p<0) | (p>1)), warning('BinEntropy: input not a probability\n');  end;

function q=zo(z)
  q= max(0,z); 
  q= min(1,q);
end

p = zo(p);

s = 0*p;
idx = p>0 & p<1;
q=p(idx);
s(idx) = -q .* log2(q) - (1-q) .* log2(zo(1-q));

s=zo(s);
end