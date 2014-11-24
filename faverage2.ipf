#pragma rtGlobals=1		// Use modern global access method.

// faverage2: extension of function faverage to 2D wave
// 13/02/19	ver 0.1a by J. Motohisa
//
//	revision history
//		13/02/19	ver 0.1a	first version

Function faverage2(orig0,dest0,flag)
	String orig0,dest0
	Variable flag
	
	Wave orig=$orig0
	Variable nx=DimSize(orig,0),ny=DimSize(orig,1)
	Wave/D tmp_faverage2
	Variable i,nloop
	Duplicate/O/D orig,$dest0
	Wave dest=$dest0
	if(flag==1) // averaging over X
		MatrixTranspose dest
		Redimension/N=(ny) dest
		Make/D/O/N=(nx) tmp_faverage2
		nloop=ny
	else // averaging over y
		Redimension/N=(nx) dest
		Make/D/O/N=(ny) tmp_faverage2
		nloop = nx
	endif
	i=0
	do
		if(flag==1)
			tmp_faverage2[]=orig[p][i]
			dest[i]=faverage(tmp_faverage2)
		else
			tmp_faverage2[]=orig[i][p]
			dest[i]=faverage(tmp_faverage2)
		endif
		i+=1
	while(i<nloop)
	KillWaves tmp_faverage2
End
