#pragma rtGlobals=1		// Use modern global access method.
#include "wname"

// LoadImageSXMResults
// by J. Motohisa
// load analysis results of  "ImageSXM" program
//
// requires: "wname"

// 2012/1/30 ver 0.01: first version

Macro LoadImageSXMParticleAnalysis(pathname,filename,prefix,hexflag)
	String pathname,filename,prefix
	Variable hexflag
	PauseUpdate;Silent 1
			
	Variable ref
	Variable i=0
	String wvnm0,wvnm1
	
	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=".DAT" ref // windows
		fileName= S_fileName
		print filename
	endif

	if(strlen(prefix)==0)
		prefix=wname(filename)
	endif
	LoadWave/J/D/W/A/K=0/P=$pathName/Q fileName
//	LoadWave/G/D/W/P=$pathName/Q fileName
	if(V_flag==0)
		return
	endif
	wvnm0=StringFromList(0,S_wavenames,";")

	print "Waves ", S_wavenames, " loaded with prefix", prefix
	print "number of particles = ", DimSize($wvnm0,0)-1
	
	do
		wvnm0=StringFromList(i,S_wavenames,";")
		if(strlen(wvnm0)==0)
			break
		endif
		wvnm1=prefix+"_"+wvnm0
		if(i!=0) // the first column is particle number
			DeletePoints 0,1,$wvnm0 // the first column is blank
			Duplicate/O $wvnm0,$wvnm1
			WaveStats/Q $wvnm1
			Print wvnm1," avergae =",V_avg
		endif
		KillWaves $wvnm0
		i+=1
	while(1)
	if(hexflag==1)
		if(MakeHexSizeFromArea(prefix)==1)
			wvnm1=prefix+"_HexSize"
			WaveStats/Q $wvnm1
			Print wvnm1," avergae =",V_avg
		endif
	endif
End

Function MakeHexSizeFromArea(prefix)
	String prefix
	
	String wvnm1,wvnm2
	wvnm1=prefix+"_AreaW"
	if(WaveExists($wvnm1))
		wvnm2=prefix+"_HexSize"
		Duplicate/O $wvnm1,$wvnm2
		Wave wv1=$wvnm1
		Wave wv2=$wvnm2
		wv2=AreaToHexSize(wv1)
		return(1)
	else
		return(0)
	endif
		
End

// particle size to hex side to side distance
//ss=6 * (d/2*(d/2)/sqrt(3)*2/2)
Function/D AreaToHexSize(ss)
	Variable ss
	
	return(sqrt(ss*2/sqrt(3)))
End
	
