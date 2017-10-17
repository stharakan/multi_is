function [yte,probs] = TestTreeModel(X,mdl)


if isa('mdl','file');
	tmp = load(mdl);
	mdl = tmp.Mdl;
end

[yte, ~ , ~ , probs] = mdl.predict(X);



end
