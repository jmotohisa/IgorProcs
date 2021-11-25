#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "wname"
#include "MCAsub"
#include "GraphPlot"
#include "DataSetOperations"

// loadMCA.ipf
//	Macro to load chn data file of MCA8000D
//	16/02/22 ver. 0.01 by J. Motohisa
//
//	revision history
//		16/04/06	ver 0.02	dataset
//		16/02/22	ver 0.01	first version

Macro  MultiMCALoad(thePath,nmschm,prefix,dsetnm,flag,len,timediv,ftype0,wantToPrint)
	String thePath="_New Path_",prefix="C",dsetnm="data"
	Variable nmschm=2
	Variable len=8192,flag=2,timediv=1e-12,ftype0=1
	Variable wantToPrint=2
	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Prompt nmschm,"wave naming scheme"
	Prompt prefix,"wavename prefix"
	Prompt dsetnm, "prefix for dataset name"
	Prompt flag,"swap channel ?",popup,"no;yes"
	Prompt ftype0,"file type ?",popup,"mca;dat"
	Prompt wantToPrint, "Do you want to print graphs?", popup, "Yes;No"
	PauseUpdate; Silent 1
	
	String ftype
	if(ftype0==1)
		ftype=".mca"
	else
		ftype=".dat"
	endif
	FMultiMCALoad(thePath,nmschm,prefix,dsetnm,flag,len,timediv,ftype,wantToPrint)
End

Function FMultiMCALoad(thePath,nmschm,prefix,dsetnm,flag,len,timediv,ftype,wantToPrint)
	String thePath,prefix,dsetnm,ftype
	Variable nmschm
	Variable len,flag,timediv
	Variable wantToPrint
	PauseUpdate;Silent 1
	
	Variable/G g_DSOindex
	// create data set
	FDSOinit0(dsetnm)
	DSOCreate0(0,1)
	dsetnm=dsetnm+num2istr(g_DSOindex-1)
	Wave/T wdsetnm=$dsetnm
	
	if(nmschm==0)
		Make/T/N=1/O tmpnm
	endif

//	String ftype=".mca"
//	String ftype=".dat"
	String fileName
	Variable fileIndex=0, gotFile
	String wvname
	
	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif
	
	DoWindow /F gGraphPlot							// make sure Graphplot is front window
	if (V_flag == 0)								// Graphplot does not exist?
		Make/N=2/D/O dummywave0
		FGraphPlot("V","counts")									// create it
		DoWindow/C gGraphPlot
	endif
	
	Variable wnlength,filenum
	String nametmp,name,name0,cmd
	do
		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path
		gotFile = CmpStr(fileName, "")
		if (gotFile)
//			print fileName,thePath,flag
			nametmp=wname(fileName)
			wnlength=strlen(nametmp)
			if(nmschm==0)
				Redimension/N=(fileIndex+1) tmpnm
				tmpnm[fileIndex]=nametmp
				name=prefix+num2istr(fileIndex)
				print fileName,":",name
			elseif (nmschm <0)
				name=prefix+nametmp
				print fileName, ":",name
			else // conventional naming scheme with
				name=prefix+nametmp[wnlength-nmschm,wnlength-1]
				print fileName
			endif
			name0=name+"_0"
			if(cmpstr(ftype,".mca"))
				wvname=FReadMCA8000D(fileName,thePath,"",flag,len,timediv)
			else
				wvname=FloadMCAdat(fileName,thePath,"",flag,len,timediv)
			endif
			Duplicate/O $wvname,$name0
			//LoadWave/G/P=$thePath/O/N=wave fileName		// load the waves from file
			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName
			DoUpdate		// make sure graph updated before printing
			if (wantToPrint == 1)
				cmd="PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1"	// print graph
			endif
			wdsetnm[filenum]=name
			filenum +=1
		endif
		fileIndex += 1
	while (gotFile)									// until TextFile runs out of files
	
	Redimension/N=(filenum) $dsetnm
	DSODisplayTable(dsetnm)
	if(nmschm==0)
		Edit tmpnm
	Endif

End

Proc MultiMCALoad0(thePath,flag,len,timediv,wantToPrint) //original version, does not use dataset
	String thePath="_New Path_"
	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Variable len=8192,flag=2,timediv=1e-12
	Variable wantToPrint=2
	PauseUpdate;Silent 1
	FMultiMCALoad0(thePath,flag,len,timediv,wantToPrint) 
End

Function  FMultiMCALoad0(thePath,flag,len,timediv,wantToPrint) //original version, does not use dataset
	String thePath
	Variable len,flag,timediv
	Variable wantToPrint
	
	String ftype=".mca"
	String fileName,cmd
	Variable fileIndex=0, gotFile
	
	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif
	
	DoWindow /F gGraphPlot							// make sure Graphplot is front window
	if (V_flag == 0)								// Graphplot does not exist?
		Make/N=2/D/O dummywave0
		FGraphPlot("V","counts")									// create it
		DoWindow/C gGraphPlot
	endif
	
	do
		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path
		gotFile = CmpStr(fileName, "")
		if (gotFile)
			print fileName,thePath,flag
			FReadMCA8000D(fileName,thePath,"",flag,len,timediv)
			//LoadWave/G/P=$thePath/O/N=wave fileName		// load the waves from file
			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName
			DoUpdate		// make sure graph updated before printing
			if (wantToPrint == 1)
				cmd="PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1"	// print graph
				execute cmd
			endif
		endif
		fileIndex += 1
	while (gotFile)									// until TextFile runs out of files
EndMacro

Macro ReadMCA8000D(fileName,pathName,wvName,flag,len,timediv)
	String fileName,pathName="home",wvName
	Variable len=8192,flag=2,timediv=1e-12
	Prompt flag,"swap channel ?",popup,"no;yes"
	Silent 1; PauseUpDate
	
	FReadMCA8000D(fileName,pathName,wvName,flag,len,timediv)
End

Function/S FReadMCA8000D(fileName,pathName,wvName,flag,len,timediv)
	String fileName,pathName,wvName
	Variable len,flag,timediv

	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=".mca" ref
		fileName= S_fileName
	endif
	print fileName

	if (strlen(wvName)<1)
		wvName="chn"+wname(fileName)
	endif

//	LoadWave /N=dummywave/P=$pathName /B=columnInfoStr /C /D /E=editCmd  /F={...} /G /H /J /K=k  /L={...} /M /O   /Q/ /T /U={...} /V={...} /W] fileName
	LoadWave /N=dummywave/P=$pathName/J/D/K=0/L={0,12,len,0,0} filename

	Wave dummywave0
// swap
	if(flag==2)
		Duplicate/O dummywave0,tmpwave
		tmpwave = -x
		Sort tmpwave tmpwave,dummywave0
		KillWaves/Z tmpwave
	endif
	Duplicate/O dummywave0,$wvName
	Return wvName
End

Function/S FloadMCAdat(fileName,pathName,wvName,flag,len,timediv)
	String fileName,pathName,wvName
	Variable len,flag,timediv

	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=".dat" ref
		fileName= S_fileName
	endif
	print fileName

	if (strlen(wvName)<1)
		wvName="C"+wname(fileName)
	endif

//	LoadWave /N=dummywave/P=$pathName /B=columnInfoStr /C /D /E=editCmd  /F={...} /G /H /J /K=k  /L={...} /M /O   /Q/ /T /U={...} /V={...} /W] fileName
	LoadWave /N=dummywave/P=$pathName/J/D/K=0 filename

	Wave dummywave0
	if(timediv>0)
		SetScale/P x,0,timediv,"s"
	endif
// swap
	if(flag==2)
		Reverse dummywave0
	endif
	Duplicate/O dummywave0,$wvName
	Return wvName
End
