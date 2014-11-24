#pragma rtGlobals=3		// Use modern global access method.

#include "DataSetOperations"
#include "AddNoteToWave"
#include "wname"

// JMGeneralTextDataLoad by J. Motohisa
// Macros to load/rename/scale general text data

// load data and 
//	- rename data following suffixlist
//	- scale waves with specified column
//
//  ver 0.2a		2013/08/29		rewritten with datafolder
//	ver 0.1d	2013/03/21		Added "quiet" option
// ver 0.1c		2012/12/12		AddNoteToWave added in loading data from files
// ver 0.1b		2012/01/08		JMGeneralDatLoaderInit added
// ver 0.1 2012/01/01	fist version

// create wave name list
Function JMGTDLinit(dsetnm,prefix,suffixlist)
	String dsetnm,prefix,suffixlist

	String savDF = GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	if(DataFolderExists("JMGTDL"))
		SetDataFolder JMGTDL
	else
		NewDataFolder/S JMGTDL
		Make/T/N=0 BaseNamesWave
		String/G g_dsetnm
		String/G g_suffixlist
		Variable/G g_nlwaves0
		String/G g_filename
		String/G g_path
		String/G g_waveNames
		String/G g_baseName
		String/G g_prefix
	endif

	g_dsetnm=dsetnm
	g_prefix=prefix
	g_suffixlist=suffixlist
//	String/g g_nmwave=nmwave
//	Make/T/N=(nwv)/O $nmwave
//	If(strlen(WinList("DatLoaderWnameWave",";","WIN:2"))==0)
//		Edit $nmwave 
//		DoWindow/C DatLoaderWnameWave
//	else
//		DoWindow/F DatLoaderWnameWave
//		AppendToTable $nmwave
//	endif
	
	SetDataFolder savDF
	
	if(strlen(dsetnm)>0)
		DSOinitFunc(dsetnm,prefix,suffixlist)
	endif
End

Function JMGTDLappendwnamelist()
	String savDF = GetDataFolder(1)
	Variable nwaves0
	SetDataFolder root:Packages:JMGTDL
	Wave/T BaseNamesWave
	SVAR g_baseName
	nwaves0=DimSize(BaseNamesWave,0)
	Redimension/N=(nwaves0+1) BaseNamesWave
	BaseNamesWave[nwaves0]=g_baseName
	SetDataFolder savDF
	return(nwaves0+1)
End

//template : after calling JMdatloaderprepare

Function JMGeneralDatLoaderFunc(fname,pname,ftype,bname,suffixlist,scalenum,dispTable,dispGraph,fquiet)
	String fname,pname,ftype,bname,suffixlist
	Variable scalenum,dispTable,dispGraph,fquiet
	
	Variable nlwave0
	nlwave0=JMGTDL_Loader0(fname,pname,ftype)
	if(nlwave0<=0)
		return(-1)
	endif
	
	String savDF = GetDataFolder(1)
	SetDataFolder root:Packages:JMGTDL
	SVAR g_filename
	SVAR g_path
	SVAR g_waveNames
	SVAR g_baseName

	String waveNames=g_waveNames
	fname=g_filename
	pname=g_path
	if(strlen(bname)==0)
		bname=wname(fname)
	endif
	g_baseName=bname
	SetDataFolder savDF

// get scale
	Variable xmin,xmax
	String snm
	if(scalenum>=0)
		snm=StringFromList(scalenum,waveNames,";")
		WaveStats/Q $snm
		xmin=V_min
		xmax=V_max
	endif
	
	if(dispGraph==1)
		Display
	endif
	if(DispTable==1)
		Edit
	Endif

	Variable index=0,index0=0,index1
	String orig,dest,dest0
	
	String suffix
	Variable nummode=0
	do
		orig=StringFromList(index,waveNames,";")
		suffix=StringFromList(index,suffixlist,";")
		if(nummode==1 || strlen(suffix)!=0)
			index1+=1
			if(CmpStr(suffix,"#")==0 || nummode==1)
				nummode=1
				suffix=num2istr(index0)
				index0+=1
			endif
			dest=bname+"_"+suffix
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
	while (index<nlwave0)
	return(index1)
End

Function JMGTDL_Loader0(fname,pname,ftype)
	String fname,pname,ftype
	
	Variable ref
	if (strlen(fName)<=0)
		Open /D/R/P=$pName/T=ftype ref // windows
		fName= S_fileName
		print fname
	endif
	
	LoadWave/J/D/N=$"dummy"/W/P=$pName/Q fName
	if(V_flag==0)
		return(-1)
	endif
	Variable nlwave0=V_flag
	String waveNames=S_waveNames
	
	String savDF = GetDataFolder(1)
	SetDataFolder root:Packages:JMGTDL
	NVAR g_nlwaves0
	SVAR g_filename
	SVAR g_path
	SVAR g_waveNames
	g_nlwaves0=nlwave0
	g_filename=fname
	g_path=pName
	g_waveNames=waveNames
	SetDataFolder savDF

	return(V_flag)
End

Proc JMGeneralDatLoader(fname,pname,bname,suffixlist,scalenum,dispTable,dispGraph,fquiet)
	String fname,pname="home",bname,suffixlist
	Variable scalenum=1,suffix,dispTable=2,dispGraph=2,fquiet=1
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt bname, "base wave name"
	Prompt suffixlist, "suffix list (# for number)"
	Prompt scalenum,"Column No. for scale waves (<0 for without scaling"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	String ftype=".dat"
	JMGeneralDatLoaderFunc(fname,pname,ftype,bname,suffixlist,scalenum,dispTable,dispGraph,fquiet)
End

/// obsolete Proc and funcs

Proc renamer(nmwave,prefix,suffix,num)
	String nmwave,prefix,suffix
	Variable num
	PauseUpdate; silent 1
	
	Variable index,nwv=DimSize($nmwave,0)
	index=0
	String orig,dest
	do
		orig=$nmwave[index]+"_"+num2str(num)
		dest=prefix+$nmwave[index]+"_"+suffix
		Duplicate/O $orig,$dest
		KillWaves/Q $orig
		index+=1
	while(index<nwv)
End

Proc JMDatLoaderPrepare2(nmwave)
	String nmwave=g_nmwave
	PauseUpdate; Silent 1;
	
	String wlist=$nmwave[0]
	Variable n=DimSize($nmwave,0),i
	i=0
	Do
		wlist=wlist+";"+$nmwave[i+1]
		i+=1
	while (i<n)
	JmGeneralDataLodaInit(wns,wlist)
End

Function JMGeneralDatLoaderInit(wns,wlist)
	String wns,wlist

	Variable i=0
	Variable nwv=ItemsInList(wlist)
	Make/N=(nwv)/O/T $wns
	Wave/T wn=$wns

	do
		wn[i]=StringFromList(i,wlist,";")
		i+=1
	while(i<nwv)
End

////////////
// Load multiple data: 
Function JMGTDLmulti0func(prefix,thePath,fNamemask,ftype,suffixlist,scalenum,dispGraph,fquiet)
	String prefix,thePath,fNamemask,ftype,suffixlist
	Variable scalenum,dispGraph,fquiet

	String fileName,fileName0,bname
	Variable fileIndex=0, index=0,gotFile,gotFile2
	String name,nametmp,dsetnm
	Variable wnlength,filenum=0

	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif

// load files
	do
		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path
		fileName0=fileName
		gotFile = CmpStr(fileName, "")
		gotfile2=StringMatch(fileName0,fNameMask)
		if (gotFile && (gotFile2 || strlen(fNameMask)==0))
			if(strlen(prefix)==0)
				bname=wname(fileName)
				print bname, ":", fileName
			else
				bname=prefix+num2istr(index)
				print prefix+num2istr(index), ":", fileName
			endif
			JMGeneralDatLoaderFunc(fileName,thePath,ftype,bname,suffixlist,scalenum,2,2,fquiet)
			JMGTDLappendwnamelist()
//			if(dispGraph==1)
//				JMGTDDisplayAll(g_JMGTD_wname,suffixlist)
//			Endif
			index +=1
		endif
		fileIndex += 1
	while (gotFile)									// until TextFile runs out of files
End

Proc JMGTDL2multi0(prefix,thePath,fNamemask,ftype,suffixlist,scalenum,dispGraph,fquiet)
	String dsname0,fNamemask,thePath="_New Path_",ftype=".dat",prefix,suffixlist
	Variable scalenum,fquiet,dispGraph=2
	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Prompt fNameMask,"mask for file name"
	Prompt ftype, "Extension of file name"
	Prompt prefix,"wave prefix"
	Prompt suffixList,"suffix list of waves"
	Prompt dispGraph,"Display graph ?",popup,"yes;no"
	Prompt scalenum,"Column No. for scale waves (<0 for without scaling"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate;Silent 1
	
	JMGTDL2multi0func(prefix,thePath,fNamemask,ftype,suffixlist,scalenum,dispGraph,fquiet)
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
