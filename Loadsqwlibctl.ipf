#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Loadsqwlictl.ipf
// by J. Motohisa
// load calculated results of pcsmatrix

//	2015/02/17	initial version

#include "JMGeneralTextDataLoad2"

// xscale:
// 1: uniform mesh
// 2: non-uniform mesh
Function/S Loadsqw_1Dsub1(fileName,pathName,wvname0,numdat,datpos,xscale)
	String filename,pathname,wvname0
	Variable numdat,datpos,xscale
	
	String wvName
	Variable ref,xmin,xmax,xscale0
	String xtmp="x_tmp"
	
	if (strlen(fileName)<=0)
		if(CmpStr(IgorInfo(2), "Macintosh") == 0)
			Open /D/R/P=$pathName/T=".DAT" ref // windows
		else
			Open /D/R/P=$pathName/T=".DAT" ref // windows
		endif
		fileName= S_fileName
		print filename
	endif
	
	if(strlen(wvname0)==0)
		wvName=wname(fileName)
	else
		wvName=wvname0
	endif
	xtmp=wvName+"_x"
	
	String cmd
	if(numdat>1)
//		FLoadColumnDataToMatrix(wvName,fileName,pathName,datpos,numdat,2)
	else
//		FLoadColumnDataToMatrix(wvName,fileName,pathName,datpos,1,2)
		numdat=DimSize($wvName,0)
	endif

// load scale for x
	switch(xscale)
		case 1:
		case 2:
			xscale0=xscale
			break
		default:
			xscale0=1
			break
	endswitch
		
//	FLoadColumnDataToMatrix(xtmp,fileName,pathName,xscale0,1,2)
	Wave xtmpwv=$xtmp
	xmin=xtmpwv[0]
	xmax=xtmpwv[numpnts(xtmpwv)-1]
	switch(xscale)
		case 1:
		case 2:
			SetScale/I x,xmin,xmax,"m",$wvName
			break
		default:
			break
	endswitch
	
	if(xscale!=3)
		KillWaves xtmpwv
	else
		Redimension/N=(numdat) xtmpwv
		SetScale d 0,0,"m", xtmpwv
	endif	

	return wvName
End
