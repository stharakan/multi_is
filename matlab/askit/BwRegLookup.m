function bw = BwRegLookup(ftype,psize)

switch ftype
	case 'patchgabor'
		switch psize
			case 5
				bw = 1.47;
			case 9 
				bw = 1.16;
			case 17
				bw = 1.18;
			otherwise
				error('Patch size not recognized in bw lookup');
		end
	case 'patchstats'
		switch psize
			case 5
				bw = 1.99;
			case 9 
				bw = 1.91;
			case 17
				bw = 1.59;
			otherwise
				error('Patch size not recognized in bw lookup');
		end
	case 'patchgstats'
		switch psize
			case 5
				bw = 0.63;
			case 9 
				bw = 1.31;
			case 17
				bw = 1.81;
			otherwise
				error('Patch size not recognized in bw lookup');
		end
	otherwise 
		error('Feature type not recognized in bw lookup');
end



end
