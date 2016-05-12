#pragma rtGlobals=1		// Use modern global access method.

// loadGeneralTextData.ipf
//	Macro to load general text data file
//	09/07/19 ver. 0.1 by J. Motohisa
//
//	revision history
//		09/07/19		ver 0.1:	first version
//		09/09/17		ver 0.11: "rename" operation is replaced by "duplicate" and "KillWaves"
//		16/04/29        ver 0.12: arggument added for FGraphPlot

// To Do: 

#include "wname"
#include "GraphPlot"
#include "JMGraphStyles"
#include "DataSetOperations"

Macro LoadGeneralTextData(wn,fileName,pathName,suffix,flag,n_xcol,n_ycol)
	String fileName, pathName="home", wn,suffix="txt"
	Variable ncol=3,flag=1,n_xcol=1,n_ycol=2
	Prompt wn,"wave name"
	Prompt filename,"file name"
	Prompt pathName,"path name"
	Prompt suffix,"suffix",popup,"txt;dat"
	Prompt flag,"equal spacing ?",popup,"yes;no"
	Prompt n_xcol,"column # for x ?" 
	Prompt n_ycol,"column # for y ?" 
	Silent 1; PauseUpDate

	String extstr,wn_orig,wn_dest,xwv,ywvs,cmd
	Variable ref,index
	
	extstr="."+suffix
	// extstr="sGBWTEXT"
	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=(extstr) ref
		fileName= S_fileName
	endif
	
	LoadWave/G/D/A/W/Q/P=$pathName fileName
	if(V_flag==0)
		return
	endif
	print "file=", fileName,", ", V_flag, " waves loaded"

	index=0
	ywvs=""
	if(strlen(wn)==0)
		wn=wname(filename)
	endif
	do
		wn_orig=StringFromList(index,S_wavenames,";")
		if(strlen(wn_orig)==0)
			break
		endif
		if(index==n_xcol-1)
			wn_dest=wn+"_x"
			xwv=wn_dest
		else
			wn_dest=wn+"_"+num2istr(index+1)
			ywvs=ywvs+","+wn_dest
		endif
		Duplicate/O $wn_orig,$wn_dest;KillWaves $wn_orig
		index +=1
	while(1)

	if (flag==1)
		cmd="Sort "+xwv+","+xwv+ywvs
		execute(cmd) // sort waves
		WaveStats/Q  $xwv
		cmd="SetScale/I x,V_min,V_max,\"\""+","+xwv+ywvs
		execute(cmd) // set scale
	endif
	
	ywvs=wn+"_"+num2istr(n_ycol)
	
	Duplicate/O $xwv,dummyxwave0
	Duplicate/O $ywvs,dummyywave0		
End Macro

Macro MultiLoadGeneralTextData(thePath, suffix,wnprefix,dsetnm,fnamewv,flag,n_xcol,n_ycol)
	String thePath="_New Path_",wnprefix="W",dsetnm="data",fnamewv="filenamewave",suffix="txt"
	Variable flag=1,n_xcol=1,n_ycol=2
	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Prompt wnprefix,"prefix for wave names"  // if blanck, file name is used
	Prompt dsetnm,"data set name"
	Prompt fnamewv,"wave  name to store file names"
	Prompt suffix, "suffix", popup,"txt;dat"
	Prompt flag,"equal spacing ?",popup,"yes;no"
	Prompt n_xcol,"column # for x ?" 
	Prompt n_ycol,"column # for y ?" 
	Silent 1;PauseUpdate
	
	String fileName,ftype,nametemp,name,tmpfnamewv
	Variable fileIndex=0, gotFile,filenum,i
	
	// create data set
	InitDataSetOperations(dsetnm)
	CreateDataSet0(0,1)
	dsetnm=dsetnm+num2istr(g_dsetindex-1)
	
	ftype="."+suffix
	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif
	if(strlen(fnamewv)==0)
		Pathinfo $thePath
		i=0
		do
			fnamewv=StringFromList(i,S_path,":")
			if(strlen(fnamewv)<=0)
				break
			endif
			i+=1
		while(1)
		fnamewv=wnprefix+"_"+StringFromList(i-1,S_path,":")
	endif
	Make/T/N=1/O $fnamewv
	Edit $fnamewv
	
	DoWindow /F gGraphPlotxy							// make sure Graphplot is front window
	if (V_flag == 0)								// Graphplot does not exist?
		Make/N=2/D/O dummyxwave0
		Make/N=2/D/O dummyywave0
		FGraphplotxy("xunit","yunit")									// create it
		DoWindow/C gGraphPlotxy
	endif

// load general text data
	fileindex=0
	filenum=0
	do
		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path
		gotFile = CmpStr(fileName, "")
		if (gotFile)
			nametemp=wname(filename)
//			wnlength=strlen(nametmp)
			Redimension/N=(fileIndex+1) $fnamewv
			$fnamewv[fileIndex]=nametemp+ftype
			if(strlen(wnprefix)>0)
				name=wnprefix+num2istr(fileIndex)
			else
				name=nametemp
			endif
			LoadGeneralTextData(name,fileName,thePath,suffix,flag,n_xcol,n_ycol)
			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName
			DoUpdate		// make sure graph updated before printing
//			if (wantToPrint == 1)
//				PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1	| print graph
//			endif
			$dsetnm[filenum]=name
			filenum+=1
		endif
		fileIndex += 1
	while (gotFile)									// until TextFile runs out of files
	Redimension/N=(filenum) $dsetnm
	DisplayDataSetTable(dsetnm)

EndMacro

