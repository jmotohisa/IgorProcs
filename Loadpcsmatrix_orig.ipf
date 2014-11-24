#pragma rtGlobals=1		// Use modern global access method.

#include "MatrixOperations2"
#include "3DMatrixOperations"
#include "GizmoXYZSliceProc"
#include "RefractiveIndex"
#include "wname"

Macro Loadpcsmatrix_single0(wvName,fileName,pathName,dataname,xscale,wantToDisp)
	String wvname,filename,pathname="home",
	Variable dataname=1,wantToDisp=2,xscale=1
	Prompt wvname,"wave name to store"
	Prompt filename,"file name"
	Prompt pathname,"path name"
	Prompt dataname,"Choose Data",popup,"reflectivity_all;reflectivity_TE;reflectivity_TM;transmittance_all;transmittance_TE;transmittance_TM"
	Prompt xscale,"x-scale",popup,"energy;wavelength;wavelenght(nonequal spacing)"
	Prompt wantToDisp, "Do you want to display graphs?", popup, "Yes;No"
	Silent 1; PauseUpDate
	
	Variable ref,xmin,xmax,xscale0
	String xtmp="x_tmp"
//	Variable index,index1,index2
	
	if (strlen(fileName)<=0)
		if(CmpStr(IgorInfo(2), "Macintosh") == 0)
//			Open /D/R/P=$pathName/T="sGBWTEXT" ref // MacOS
			Open /D/R/P=$pathName/T=".DAT" ref // windows
		else
			Open /D/R/P=$pathName/T=".DAT" ref // windows
		endif
		fileName= S_fileName
		print filename
	endif

	if(strlen(wvName)==0)
		wvName=wname(fileName)
	endif
	if(xscale==3)
		xtmp="wl_"+wvName
	endif
	
	LoadColumnDataToMatrix(wvName,fileName,pathName,dataname+3,1,2)

// load scale for x
	if(xscale==3)
		xscale0=2
	else
		xscale0=xscale
	endif
	LoadColumnDataToMatrix(xtmp,fileName,pathName,xscale0,1,2)
	xmin=$xtmp[0]
	xmax=$xtmp[numpnts($xtmp)-1]
//	WaveStats/Q $xtmp
//	xmin=V_min
//	xmax=V_max
	if(xscale==1)
		SetScale x,xmin,xmax,"eV",$wvName
	else
		SetScale x,xmin,xmax,"m",$wvName
	endif
	if(xscale==1 || xscale==2)
		KillWaves $xtmp
	else
		SetScale d 0,0,"m", $xtmp
	endif
		
	if(wantToDisp==1)
		Display /W=(3,41,636,476)
		if(xscal==1 || xscale==2)
			AppendToGraph $wvName
		else
			AppendToGraph $wvName vs $xtmp
		endif
	endif

End Macro

Macro Loadpcsmatrix_matrix0(wvName,fileName,pathName,dataname,numdat,xscale,wantToDisp,appendColorLegend)
	String wvname,filename,pathname="home"
	Variable dataname=1,wantToDisp=1,numdat=101,appendColorLegend=1,xscale=1
	Prompt wvname,"wave name to store"
	Prompt filename,"file name"
	Prompt pathname,"path name"
	Prompt dataname,"Choose Data",popup,"reflectivity_all;reflectivity_TE;reflectivity_TM;transmittance_all;transmittance_TE;transmittance_TM"
	prompt numdat,"number of data"
	Prompt xscale,"x-scale",popup,"energy;wavelength;wavelenght(nonequal spacing)"
	Prompt wantToDisp, "Do you want to display graphs?", popup, "Yes;No"
	Prompt appendColorLegend, "Do you want to append ColorLegend?", popup, "Yes;No"
	Silent 1; PauseUpDate
	
//	String dwname,xwname,ywname,destw,destw0,wnames,cmdstr,buffer
	Variable ref,xmin,xmax
	String xtmp="x_tmp",xtmp2="x_tmp2"
//	Variable index,index1,index2
	
	if (strlen(fileName)<=0)
		if(CmpStr(IgorInfo(2), "Macintosh") == 0)
//			Open /D/R/P=$pathName/T="sGBWTEXT" ref // MacOS
			Open /D/R/P=$pathName/T=".DAT" ref // windows
		else
			Open /D/R/P=$pathName/T=".DAT" ref // windows
		endif
		fileName= S_fileName
		print filename
	endif
	
	if(strlen(wvName)==0)
		wvName=wname(fileName)
	endif
	if(xscale==3)
		xtmp2="wl_"+wvName
	endif
	
// as of pcsmarix-0.3a4
	if(numdat>1)
		LoadColumnDataToMatrix(wvName,fileName,pathName,dataname+3,numdat,2)
	else
		LoadColumnDataToMatrix(wvname,filename,pathName,dataname+3,1,2)
	endif

// load scale for x
	if(xscale==3)
		xscale0=2
	else
		xscale0=xscale
	endif
	
	LoadWave/J/D/O/K=0/V={"\t, "," $",0,0}/N=dummy/L={0,0,0,icol,1}/Q/P=$pathName fileName
//	LoadColumnDataToMatrix(xtmp,fileName,pathName,xscale0,1,2)
	String wn=StringFromList(0,S_waveNames,";")
	Duplicate/O $wn,$xtmp0
	xmin=$xtmp[0]
	xmax=$xtmp[numpnts($xtmp)-1]
	if(xscale==1)
		SetScale x,xmin,xmax,"eV",$wvName
	else
		SetScale x,xmin,xmax,"m",$wvName
	endif
	if(xscale==1 || xscale==2)
		KillWaves $xtmp
	else
		SetScale d 0,0,"m", $xtmp
	endif

	if(wantToDisp==1)
		Display /W=(3,41,636,476)
		if(xscale==1 || xscale==2)
			AppendImage $wvName
		else
			MakeMeshDataFunc(xtmp,xtmp2)
			AppendImage $wvName vs $xtmp2
		endif
		if(appendColorLegend==1)
			JEG_AddColorLegend(wvname)
		endif
	endif
End Macro
