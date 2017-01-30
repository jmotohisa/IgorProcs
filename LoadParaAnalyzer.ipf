#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// LoadParaAnalyser.ipf
// by J. Motohisa

// 2017/01/16 ver 0.01: first version

#include "wname"
#include "GraphPlot"
#include "JMGraphStyles"
#include "DataSetOperations"

Macro LoadParaAnalyzer(fname,path,wvname)
	String fname,path,wvname
	Variable nmflag=1
	PauseUpdate; silent 1
	
	FLoadParaAnalyzer(fname,path,wvname)
End

Function FLoadParaAnalyzer(fname,path,wvname,nmflag)
	String fname,path,wvname
	Variable nmflag

	String extstr,dum_header,DataNames, units,dim1str,dim2str,str,wdummy,wdummy2
	Variable ref,found,offset,index
	String xwv,ywv
	extstr=".csv"
	
	if (strlen(fname)<=0)
		Open /D/R/P=$path/T=(extstr) ref
		if(strlen(S_filename)<=0)
			return -1
		endif
		fname= S_fileName
		Print fname
		Close ref
	endif
	if(strlen(wvname)<=0)
		wvname=wname(fname)
	endif

	Open /R/P=$path/T=(extstr) ref as fname
	offset=0
	index=0
	Variable start,stop,step
	do
		FReadLine ref,dum_header
		offset+=strlen(dum_header)
		if(strsearch(StringFromList(0,dum_header,","),"TestParameter",0,2)>=0)
			if(strsearch(StringFromList(1,dum_header,","),"Measurement.Primary.Start",0,2)>=0)
				start=str2num(StringFromList(2,dum_header,","))
			elseif(strsearch(StringFromList(1,dum_header,","),"Measurement.Primary.Stop",0,2)>=0)
				stop=str2num(StringFromList(2,dum_header,","))
			elseif(strsearch(StringFromList(1,dum_header,","), "Measurement.Primary.Step",0,2)>=0)
				step=str2num(StringFromList(2,dum_header,","))
			endif
		elseif(GrepString(dum_header,"DataName"))
			DataNames=TrimString(dum_header,"DataName")
			print "DataName =", DataNames
		elseif(GrepString(dum_header,"DataValue"))
			found=1
		elseif(strsearch(StringFromList(0,dum_header,","),"AnalysisSetup",0,2)>=0)
			if(strsearch(StringFromList(1,dum_header,","),"Analysis.Setup.Vector.List.Datum.Unit",0,2)>=0)
				units=TrimString(dum_header,"AnalysisSetup, Analysis.Setup.Vector.List.Datum.Unit")
			endif
		elseif(strsearch(StringFromList(0,dum_header,","),"Dimension1",0,2)>=0)
			dim1str=TrimString(dum_header,"Dimension1")
		elseif(strsearch(StringFromList(0,dum_header,","),"Dimension2",0,2)>=0)
			dim1str=TrimString(dum_header,"Dimension2")
		endif
		index+=1
	while(found==0)
	Close ref

// read data
//	LoadWav0e/J/D/W/K=0 "fname
	LoadWave/J/D/N=dummywave/L={0,(index-1),0,1,0}/P=$path fname
	if(V_flag==0)
		return(-1)
	endif

	index=0
	do
		wdummy=StringFromList(index,S_waveNames)
		if(strlen(wdummy)==0)
			break
		endif
		Wave wvdummy=$wdummy
		SetScale/I x start,stop,StringFromList(0,units,","), wvdummy
		SetScale d 0,0,StringFromList(index,units,","), wvdummy
		if(nmflag==1)
			wdummy2=wvname+"_"+StringFromList(index,DataNames,",")
		else
			wdummy2=wvname+"_"+num2str(index)
		endif			
		Duplicate/O wvdummy,$wdummy2
		index+=1
	while(1)
	
End

Function/s TrimString(str_orig,str)
	String str_orig,str
	return(ReplaceString(" ",RemoveEnding(RemoveFromList(str,str_orig,","),"\r"),""))
End

Macro MultiParaAnalyzerLoad(thePath,which,dsetnm,nmflag)
	String thePath="_New Path_",which="W",dsetnm="data"
	Variable nmflag
	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Prompt which,"wave prefix"
	Prompt dsetnm, "prefix for dataset name"
	Prompt nmflag,"suffix naing scheme",popup,"numeric;dataname"
	PauseUpdate;Silent 1

	Variable/G g_DSOindex
	FMultiParaAnalyzerLoad(thePath, which,dsetnm)
End

Function FMultiParaAnalyzerLoad(thePath, which,dsetnm,nmflag)
	String thePath,which,dsetnm
	Variable nmflag

	String fileName,ftype
	Variable fileIndex=0, gotFile
	String name,nametmp
	Variable wnlength,filenum=0
	NVAR g_DSOindex
	String cmd

// create data set
	FDSOinit0(dsetnm)
	DSOCreate0(0,1)
	dsetnm=dsetnm+num2istr(g_DSOindex-1)
	Wave/T wdsetnm=$dsetnm
	Make/T/N=1/O tmpnm
	
//	Make/N=1/T/O ExpDate; Make/N=2000/D/O Expostime; 

//	ftype=FileTypeStr()
	ftype=".csv"
	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif
	
	DoWindow /F gGraphplot							// make sure Graphplot is front window
	if (V_flag == 0)								// Graphplot does not exist?
		Make/N=2/D/O dummywave0
		Make/N=2/D/O dummywave1
		FGraphPlot("","")									// create it
		DoWindow/C gGraphPlot
	endif

	do
		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path
		gotFile = CmpStr(fileName, "")
		if (gotFile)
			nametmp=wname(fileName)
			wnlength=strlen(nametmp)
			Redimension/N=(fileIndex+1) tmpnm
			tmpnm[fileIndex]=nametmp
			name=which+num2istr(fileIndex)
			print fileName,":",name
//			FSPEload2(name,fileName,thePath,expnml,nmschm,which)
			FLoadParaAnalyzer(filename,thePath,which+num2str(filenum),nmflag)
//			Wave dummy1
			Duplicate/O dummywave1,dummywave0
//			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName
			DoUpdate	// make sure graph updated before printing
			wdsetnm[filenum]=name
			filenum +=1
		endif
		fileIndex += 1
	while (gotFile)									// until TextFile runs out of files

	Redimension/N=(filenum) $dsetnm
	DSODisplayTable(dsetnm)
	Edit tmpnm
End

