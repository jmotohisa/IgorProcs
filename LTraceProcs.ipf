#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "wname"

Macro LoadLTraceIVAll(pathName,fpol,wantToDisp)
	String pathName="_New Path_"
	Variable fpol,wantToDisp
	Prompt pathname,"path name",popup PathList("*", ";", "")+"_New Path_"
	Prompt fpol,"swap polarity ?",popup,"yes;no"
	Prompt wantToDisp,"Display graph?",popup,"yes;no"	
	PauseUpdate; Silent 1

	FLoadLTraceIVAll(pathName,fpol,wantToDisp)

End

Function FLoadLTraceIVAll(pathName,fpol,wantToDisp)
	String pathName
	Variable fpol,wantToDisp
	
	String fileName,wvname,wvs,ftype=".ivc"
	Variable index

// dataset operation
//	if(fdso==1)
//		FDSOinit0(dsetnm)
//		DSOCreate0(0,1)
//		dsetnm=dsetnm+num2istr(g_DSOindex-1)
//		Wave/T wdsetnm=$dsetnm
//	endif

	if (CmpStr(PathName, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		PathName = "data"
	endif
	
	do
		fileName = IndexedFile($pathName,index,ftype)
		if(strlen(fileName)==0)
			break
		endif
		Print "loding file ",filename
		wvname=wname(filename)
		wvs=FLoadLTraceIV(wvname,fileName,pathName,fpol,wantToDisp)
		index+=1
//		if(fdso==1)
//			index2=0
//			do
//				wvs0=StringFromList(index2,wvs,";")
//				if(strlen(wvs0)<=0)
//					break
//				endif
//				wdsetnm[index3]=wvs0
//				index2+=1
//				index3+=1
//			while(1)
//		endif			
	while(1)
	
	if(Exists("temporaryPath"))
		KillPath temporaryPath
	endif
//	Redimension/N=(index3) wdsetnm
End

Macro LoadLTraceIV(wvname,fileName,pathName,fpol,wantToDisp)
	String wvname,fileName,pathName
	Variable fpol=1,wantToDisp=1
	Prompt wvname,"Wave name"
	Prompt filename,"File name"
	Prompt pathname,"Path name"
	Prompt fpol,"swap polarity ?",popup,"yes;no"
	Prompt wantToDisp,"Display graph?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	FLoadLTraceIV(wvname,filename,pathname,fpol,wantToDisp)
End

Function/S FLoadLTraceIV(wvname,fileName,pathName,fpol,wantToDisp)
	String wvname,fileName,pathName
	Variable fpol,wantToDisp

	String extstr=".ivc"
	Variable index,ix,iy

	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=(extstr) ref
		fileName= S_fileName
	endif
	
	if(strlen(wvname)==0)
		wvname=wname(fileName)
	endif
	
	LoadWave/Q/P=$pathname/J/D/A=dummywave/K=0/L={0,1,0,0,0} filename
	if(V_flag==0)
		return ""
	endif
	print "file=", fileName,", ", V_flag, " waves loaded"

	index=0
	String wn_xorig,wn_yorig,wdest
	Variable xmin,xmax

	if(wantToDisp==1)
		Display
	Endif
	do
		wn_xorig=StringFromList(index*2,  S_wavenames,";")
		wn_yorig=StringFromList(index*2+1,S_wavenames,";")
		if(strlen(wn_xorig)==0 || strlen(wn_yorig)==0)
			break
		endif
		Wave xwv=$wn_xorig
		Wave ywv=$wn_yorig
		WaveStats/Q xwv
		if(fpol==1) // change polarity
			xmin=-V_max
			xmax=-V_min
			Sort/R xwv,xwv,ywv
			ywv*=-1e-9
		else
			xmin=V_min
			xmax=V_max
			Sort xwv,xwv,ywv
			ywv*=1e-9
		endif
		SetScale/I x xmin,xmax,"V", ywv
		SetScale d 0,0,"A", ywv
		wdest=wvname+"_"+num2istr(index)
		
		Duplicate/O ywv,$wdest;KillWaves xwv,ywv
		if(wantToDisp==1)
			AppendToGraph $wdest
		endif
		index +=1
	while(1)
	
	return wvname
end

Macro loadLTraceImageTxt(wvname,fileName,pathName,fpol,iextstr,wantToDisp,imgsize)
	Variable wantToDisp,fpol,iextstr=1,imgsize=0.02
	String wvname,filename,pathname
	Prompt wvname,"wave name"
	Prompt filename,"file name"
	Prompt pathname,"path name"
	Prompt fpol,"Transpose?",popup,"yes;no"
	Prompt iextstr,"extension",popup,"iqt;ici"
	Prompt wantToDisp,"display graph?",popup,"yes;no"
	Prompt imgsize,"image size"
	PauseUpdate ; Silent 1

	FLoadLtraceImageTxt(wvname,fileName,pathName,fpol,iextstr,wantToDisp,imgsize)
End

Function FLoadLtraceImageTxt(wvname,fileName,pathName,fpol,iextstr,wantToDisp,imgsize)
	Variable wantToDisp,fpol,iextstr,imgsize
	String wvname,filename,pathname
	
	String extstr,units
	Variable xdim,scale
	
	if(iextstr==2) // current image
		extstr=".ici"
		units="A"
		scale=1e-9
	else // AFM image
		extstr=".iqt"
		units="m"
		scale=1e-9
	endif
	
	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=(extstr) ref
		fileName= S_fileName
	endif
	print fileName
	
	if(strlen(wvname)==0)
		wvname=wname(fileName)
	endif

	LoadWave/P=$pathname/J/M/D/A=dummywave/K=0/L={0,2,0,0,0} filename
	String orig=StringFromList(0,S_wavenames,";")
	Duplicate/O $orig,$wvname; KillWaves $orig
	Wave wvdest=$wvname
	xdim=DimSize(wvdest,1)
	DeletePoints/M=1 xdim-1,1, wvdest
	SetScale d 0,0,units, wvdest
	wvdest*=scale
	MatrixTranspose wvdest
	
	if(wantToDisp==1)
		FShowImage(wvname,imgsize)
		ModifyImage $wvname ctab= {*,*,YellowHot,0}
		ColorScale/C/N=text0/F=0/A=MC image=$wvname
	Endif
	
End

Function FShowImage(wvname,imgsize)
	String wvname
	Variable imgsize
	
	Variable imgsize2
	NewImage $wvname
	imgsize2=imgsize*28.3465
//	ModifyGraph width={perUnit,(imgsize2),bottom},height={perUnit,(imgsize2),left}
//	Execute("JEG_AddColorLegend(wvname)")
End
