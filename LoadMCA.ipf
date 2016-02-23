#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "wname"
#include "MCAsub"
#include "GraphPlot"

// loadMCA.ipf
//	Macro to load chn data file of MCA8000D
//	16/02/22 ver. 0.01 by J. Motohisa
//
//	revision history
//		16/02/22	ver 0.01	first version

Macro MultiMCALoad(thePath,flag,len,timediv,wantToPrint)
	String thePath="_New Path_"
	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Variable len=8192,flag=2,timediv=1e-12
	Prompt flag,"swap channel ?",popup,"no;yes"
	Variable wantToPrint=2
	Prompt wantToPrint, "Do you want to print graphs?", popup, "Yes;No"
	PauseUpdate;Silent 1
	
	String ftype=".mca"
	String fileName
	Variable fileIndex=0, gotFile
	
	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif
	
	DoWindow /F Graphplot							// make sure Graphplot is front window
	if (V_flag == 0)								// Graphplot does not exist?
		Make/N=2/D/O dummywave0
		Graphplot()									// create it
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
				PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1	// print graph
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
	
	FReadMCA8000D(fileName,pathName,wvName,flag,timediv)
End

Function/S FReadMCA8000D(fileName,pathName,wvName,flag,len,timediv)
	String fileName,pathName,wvName
	Variable len,flag,timediv

	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=".mca.MCA" ref
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