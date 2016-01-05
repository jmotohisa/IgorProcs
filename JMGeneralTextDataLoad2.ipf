#pragma rtGlobals=1		// Use modern global access method.
#include "DataSetOperations"
#include "AddNoteToWave"
#include "wname"

// JMGeneralTextDataLoad2 by J. Motohisa
// Macros to load/rename/scale general text data
// based on JMGeneralTextDataLoad
// to work with DataSetOperations

// load data and 
//	- scale waves with specified column
//
//	ver 0.1		2013/06/16	first version
//	ver 0.2		2015/02/28	unit information added

Function/T JMGTDLinit(use_DSO,dsetnm)
	Variable use_DSO
	String dsetnm
	String/G g_JMGTD_wname
	
	String prefix,suffixlist
	Variable index
	if(use_DSO==1)
	// create data set
		FDSOinit0(dsetnm)
//		FDSOinit(dsetnm,prefix,suffixlist)
		index=DSOCreate0(0,1)
		dsetnm=dsetnm+num2istr(FDSO_getIndex()-1)
		DSODisplayTable(dsetnm)
	endif
	return(dsetnm)
End

//! @param fname, pname,extName
//! @return number of waves loaded
Function JMGeneralDatLoaderFunc2(fname,pname,extName,index,prefix,suffixlist,scalenum,xunit,yunit,fquiet)
	String fName,pName,extName,prefix,suffixlist,xunit,yunit
	Variable index,scalenum,fquiet
	
	Variable ref,nlwave0,nlwave,xmin,xmax,index0
	String snm,wvlist0,cmdstr
	SVAR g_JMGTD_wname
	if (strlen(fName)<=0)
		Open /D/R/P=$pName/T=extName ref // windows
		fName= S_fileName
		print fname
	endif
	
	LoadWave/J/D/N=dummy/W/P=$pName/Q fName
	if(V_flag==0)
		return(-1)
	endif
	nlwave=V_flag

// determine scaling	
	if(scalenum>=0)
		snm=StringFromList(scalenum,S_WaveNames,";")
		WaveStats/Q $snm
		xmin=V_min
		xmax=V_max
	else
		snm=""
	endif
	
// sort
	if(strlen(snm)>0)
		index0=0
		Do
			if(index0!=scalenum)
				cmdstr="Sort "+snm+","+StringFromList(index0,S_WaveNames,";")
				Execute cmdstr
			endif
			index0+=1
		while(index0<nlwave)
		cmdstr="Sort "+snm+","+snm
		Execute cmdstr
	Endif
	
	// detemine base wave name : use prefix+index or filename
	Variable suffixindex
	String orig,dest,dest0,destsuffix
	index0=0
	suffixindex=0
	nlwave0=0
	if(strlen(prefix)==0)
		dest0=wname(fname)
	else
		dest0=prefix+num2istr(index)
	endif
	g_JMGTD_wname=dest0
	
	index0=0
	do
		orig=StringFromList(index0,S_WaveNames,";")
		// determine suffix
		if(strlen(suffixlist)==0)
			destsuffix=num2istr(suffixindex)
			suffixindex+=1
		else
			destsuffix=StringFromList(index0,suffixlist,";")
		endif
		
		if(strlen(destsuffix)>0)
			dest=dest0+"_"+destsuffix
			Duplicate/O $orig,$dest
			if(fquiet !=1)
				print dest
			Endif
			AddStdNoteToWave($dest,pname,fname)
			SetScale/I x,xmin,xmax,xunit,$dest
//			if(scalenum>=0)
				if(index0==scalenum)
					SetScale d 0,0,xunit, $dest
				else
					SetScale d 0,0,yunit, $dest
				endif
//			endif
			nlwave0+=1
		endif
		index0+=1
	while (index0<nlwave)
	return(nlwave0)
End

// some sort of skelton
Proc JMGeneralDatLoader2(fname,pname,extName,index,prefix,suffixlist,scalenum,xunit,yunit,fquiet)
	String fName,pName="home",extName=".dat",prefix="T",suffixlist="0;1",xunit="m",yunit="eV"
	Variable index,scalenum,fquiet
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt extName, "Extension of file name"
	Prompt index,"wave index"
	Prompt prefix,"wave prefix"	
	Prompt suffixList,"suffix list of waves"
	Prompt scalenum,"Column No. for scale waves (<0 for without scaling)"
	Prompt xunit,"x-axix unit"
	Prompt yunit,"y-axis unit"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	JMGeneralDatLoaderFunc2(fname,pname,extName,index,prefix,suffixlist,scalenum,xunit,yunit,fquiet)
End

// Load multiple data (assume data set is initialized)
Function JMGTDL2multi0func(dsetnm0,prefix,thePath,fNamemask,ftype,suffixlist,scalenum,dispGraph,xunit,yunit,fquiet)
	String dsetnm0,prefix,thePath,fNamemask,ftype,suffixlist,xunit,yunit
	Variable scalenum,dispGraph,fquiet

	String fileName,fileName0
	Variable fileIndex=0, index=0,gotFile,gotFile2
	String name,nametmp,dsetnm
	Variable wnlength,filenum=0
	SVAR g_JMGTD_wname

// create data set
//	DSOinitFunc(dsname0,prefix,suffixlist)
//	DSOCreate0(dsetindex,1) 
//	dsetnm=dsname0+num2istr(dsetindex)

	Make/T/O/N=1 $dsetnm0
	Wave/T destnm=$dsetnm0
	
	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif
	
//	DoWindow /F Graphplotxy							// make sure Graphplot is front window
//	if (V_flag == 0)								// Graphplot does not exist?
//		Make/N=2/D/O dummyxwave0
//		Make/N=2/D/O dummyywave0
//		Graphplotxy()									// create it
//	endif

// load files
	do
		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path
//		fileName0=wname(fileName)
		fileName0=fileName
		gotFile = CmpStr(fileName, "")
//		gotfile2=GrepString(fileName0,"(?i)"+fNameMask)
		gotfile2=StringMatch(fileName0,fNameMask)
		if (gotFile && (gotFile2 || strlen(fNameMask)==0))
			print prefix+num2istr(index), ":", fileName
			JMGeneralDatLoaderFunc2(fileName,thePath,ftype,index,prefix,suffixlist,scalenum,xunit,yunit,fquiet)
//			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName
//			DoUpdate	// make sure graph updated before printing
//			if (wantToPrint == 1)
//				PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1	// print graph
//			endif
			Redimension/N=(index+1) destnm
			destnm[index]=g_JMGTD_wname
			if(dispGraph==1)
				JMGTDDisplayAll(g_JMGTD_wname,suffixlist)
			Endif
			index +=1
		endif
		fileIndex += 1
	while (gotFile)									// until TextFile runs out of files
End

Proc JMGTDL2multi0(dsetnm0,prefix,thePath,fNamemask,ftype,suffixlist,scalenum,dispGraph,fquiet)
	String dsname0,fNamemask,thePath="_New Path_",ftype=".dat",prefix,suffixlist
	Variable scalenum,fquiet,dispGraph=2
	Prompt dsname0,"data set name"
	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Prompt fNameMask,"mask for file name"
	Prompt ftype, "Extension of file name"
	Prompt prefix,"wave prefix"
	Prompt suffixList,"suffix list of waves"
	Prompt dispGraph,"Display graph ?",popup,"yes;no"
	Prompt scalenum,"Column No. for scale waves (<0 for without scaling"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate;Silent 1
	
	JMGTDL2multi0func(dsetnm0,prefix,thePath,fNamemask,ftype,suffixlist,scalenum,dispGraph,fquiet)
//	JMGTDL2multi0func(dsname0,dsetindex,thePath,fNamemask,ftype,prefix,suffixlist,suffixflg,scalenum,fquiet)
End Macro

Function JMGTDDisplayAll(wv0,suffixlist)
	String wv0,suffixlist
	
	String wv1,suffix
	Variable ind=0,nlist=ItemsInList(suffixlist)
	
	Display
	if(strlen(suffixlist)!=0)
		do
			suffix=StringFromList(ind,suffixlist,";")
			if(strlen(suffix)!=0)
				wv1=wv0+"_"+suffix
				AppendToGraph $wv1
			endif
			ind+=1
		while(ind<nlist)
	else
		do
			wv1=wv0+"_"+num2istr(ind)
			if(WaveExists($wv1))
				AppendToGraph $wv1
			else
				break
			endif
			ind+=1
		while(1)
	endif
End

Function JMGTDDisplay(wv0,suffixlist,nydisp,nxdisp)
	String wv0,suffixlist
	Variable nxdisp,nydisp
	
	String wvx,wvy,xsuffix,ysuffix
	Variable nlist=ItemsInList(suffixlist)
		
	if(strlen(suffixlist)!=0)
		ysuffix=StringFromList(nydisp,suffixlist,";")
		if(nxdisp>=0)
			xsuffix=StringFromList(nxdisp,suffixlist,";")
		else
			xsuffix=""
		endif
	else
		ysuffix=num2istr(nydisp)
		if(nxdisp>=0)
			xsuffix=num2istr(nxdisp)
		else
			xsuffix=""
		endif
	endif

	wvx=wv0+"_"+xsuffix
	wvy=wv0+"_"+ysuffix
	if(strlen(ysuffix)>0)
		if(WaveExists($wvy) && WaveExists($wvx))
			Display $wvy vs $wvx
		endif
	else
		if(WaveExists($wvy))
			Display $wvy
		endif		
	Endif
End

// Obsolete: previous version of JMGeneralDatLoaderFunc
Function JMGeneralDatLoaderFunc(fname,pname,nmwave,suffix,scalenum,dispTable,dispGraph,fquiet)
	String fname,pname,nmwave
	Variable scalenum,suffix,dispTable,dispGraph,fquiet
	
	Variable ref,xmin,xmax
	String snm
	if (strlen(fName)<=0)
		Open /D/R/P=$pName/T=".DAT" ref // windows
		fName= S_fileName
		print fname
	endif
	
	LoadWave/J/D/N=$"dummy"/W/P=$pName/Q fName
	if(V_flag==0)
		return(-1)
	endif

	if(scalenum>=0)
		snm=StringFromList(scalenum,S_WaveNames,";")
		WaveStats/Q $snm
		xmin=V_min
		xmax=V_max
	endif
	
	if(exists(nmwave)==0)
		return(-1)
	endif
	
	Variable index,nwv=DimSize($nmwave,0)
	String orig,dest,dest0
	if(dispGraph==1)
		Display
	endif
	if(DispTable==1)
		Edit
	Endif
	do
		orig=StringFromList(index,S_WaveNames,";")
		Wave/T wv=$nmwave
		dest0=wv[index]
		if(strlen(dest0)>0)
			dest=dest0+"_"+num2str(suffix)
			Duplicate/O $orig,$dest
			if(fquiet !=1)
				print dest
			Endif
			AddStdNoteToWave($dest,pname,fname)
			if(scalenum>=0)
				SetScale/I x,xmin,xmax,"",$dest
			endif
			if(dispGraph==1)
				AppendToGraph $dest
			endif	
			if(dispTable==1)
				AppendToTable $dest
			endif
		endif
		index+=1
	while (index<nwv)
	return(0)
End
