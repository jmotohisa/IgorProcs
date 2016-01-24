#pragma rtGlobals=3		// Use modern global access method.

// MeepProcs by J. Motohisa
// some macros to work with  meep
//
//	ver 0.01	2010/06/21	develepment started 
//	ver 0.02	2012/12/06	removePMLrz added
//	ver 0.02b	2012/12/09	Load_fieldall_meep0, Load_field_meep0,ShowFieldRAll_meep, ShowFieldRAll_meep0, 
//								ShowField_meep, FResizeImage, sMeepFldName added
//	ver 0.02c	2012/12/11	LoadFreqsMeep added
//	ver 0.1a	2013/06/04	loadharminv1 added
//	ver 0.2		2013/08/31	Textdata loader is changed to original JMGeneralTextDataLoad
//	ver 0.2a	2015/11/14	JMGeneralTextDataLoad is changed to JMGeneralTextDataLoad2

#include "MatrixOperations2"
#include "h5procs"
#include "StrRpl"
#include "wname"
#include "AddNoteToWave"
#include "JMGeneralTextDataLoad2" menu=0
#include "3DMatrixOperations"

// some of the functions/macros are common with mpb
#include "MPBProcs" menu=0

// initialization : set path
Macro init_meep(pathname,prefix)
	String pathname="_New Path_",prefix
	Prompt pathname, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Prompt prefix,"prefix for file name"
	PauseUpdate;Silent 1

	if(strlen(prefix)==0)
		prefix="res0"
	endif	
	JMGTDLinit2(1,"data",prefix,"")

	if (CmpStr(pathname, "_New Path_") == 0)		// user selected new path ?
		NewPath/O meep			// this brings up dialog and creates or overwrites path
		pathname = "meep"
	endif

	String savDF = GetDataFolder(1)
	SetDataFolder root:Packages:JMGTDL:
//	SVAR g_path
	String/G g_path,g_prefix
	g_path=pathname
	g_prefix=prefix
	SetDataFolder savDF

//	String wlist
//	String/G g_meepLDOS="meepLDOSName"
//	wlist=";fldos;ldos"
//	DSOInitFunc("data","",wlist)
//	JMGeneralDatLoaderInit(g_meepLDOS,wlist)

End Macro

// file loaders 
// load eps file: default file name is $prefix-eps-000000.00.h5
Function Load_eps_meep()

	String pathname,prefix
		
	String savDF = GetDataFolder(1)
	SetDataFolder root:Packages:JMGTDL
	SVAR g_path,g_prefix
	pathname=g_path
	prefix=g_prefix
	SetDataFolder savDF

	Load_eps_meep0(pathname,prefix,"eps")
End

Function Load_eps_meep0(pathname,prefix,wname)
	String pathname,prefix,wname
	
	String epsfname
	if(strlen(prefix)==0)
		epsfname="eps-000000.00.h5"
	else
		epsfname=prefix+"-eps-000000.00.h5"
	endif
//	g_pathname=pathname
//	g_prefix=prefix
	LoadHDF5Dataset(pathName, epsfname, "eps")
	if(cmpstr(wname,"eps") != 0)
		Wave eps
		Duplicate/O eps,$wname
	endif
End

Function Load_fieldall_meep0(pathname,prefix,suffix,riflag,index)
	String pathname,prefix,suffix
	Variable riflag,index
	
	if (CmpStr(pathname, "_New Path_") == 0)		// user selected new path ?
		NewPath/O meep			// this brings up dialog and creates or overwrites path
		pathname = "meep"
	endif
	
//	DoWindow/F GraphPlot_meep
//	if(V_flag ==0)
//		Make/N=2/D/O $datasetNameBase
//		GraphPlot_meep(datasetNameBase)
//	endif

// load h5 data
	
	Pathinfo $pathname
	if(V_flag !=0) // if path exists
		printf "In folder %s\r",S_path
		//load all possible h5 files
		Load_field_meep0(pathname,prefix,suffix,"ex",riflag,index)
		Load_field_meep0(pathname,prefix,suffix,"ey",riflag,index)
		Load_field_meep0(pathname,prefix,suffix,"ez",riflag,index)
		Load_field_meep0(pathname,prefix,suffix,"er",riflag,index)
		Load_field_meep0(pathname,prefix,suffix,"ep",riflag,index)
		Load_field_meep0(pathname,prefix,suffix,"hx",riflag,index)
		Load_field_meep0(pathname,prefix,suffix,"hy",riflag,index)
		Load_field_meep0(pathname,prefix,suffix,"hz",riflag,index)
		Load_field_meep0(pathname,prefix,suffix,"hr",riflag,index)
		Load_field_meep0(pathname,prefix,suffix,"hp",riflag,index)
		return(0)
	else
		return(-1) // failure
	endif
	
End

Function Load_field_meep0(pathname,prefix,suffix,fldname,riflag,num)
	String pathname,prefix,suffix,fldname
	Variable riflag,num
	
	String fname,dsname
	String wnRe0,wnIm0,wvname
	Variable p,result=0,fileID

	fname=sMeepFldName(fldname,suffix,prefix)

//	HDF5OpenFile /P=$pathName /R /Z fileID as fname
//	if (V_flag != 0)
//		return(-1)
//	endif
	GetFileFolderInfo/Q/Z/P=$pathName fname
	if (V_flag != 0)
		return(-1)
	endif

	if(riflag==1 || riflag==3) // load real part
		dsname=fldname+".r"
		p=LoadHDF5Dataset(pathName, fname, dsname)
		if(p==0) // load sucessful
			wnRe0=fldname+num2str(num)+"_r"
			Duplicate/O $dsname,$wnRe0
			Wave wnRe=$wnRe0
			KillWaves $dsname
			printf "%s:%s loaded as as %s\r",fname,dsname,wnRe0
		else
			result=-1 // load fail
		endif		
	endif
	
	if(riflag==2||riflag==3) // load imaginary part
		dsname=fldname+".i"
		p=LoadHDF5Dataset(pathName, fname, dsname)
		if(p==0)
			wnRe0=fldname+num2str(num)+"_i"
			Duplicate/O $dsname,$wnIm0
			Wave wnIm=$wnIm0
			KillWaves $dsname
			printf "%s:%s loaded as as %s\r",fname,dsname,wnIm0
		else
			result=-1 // load fail
		endif
	endif
	// complex wave
	if(riflag==3 && strlen(wnRe0)!=0 && strlen(wnIm0)!=0 && result==0)
		String wnC0=fldname+num2str(num)+"_c"
		Duplicate/O  wnRe,$wnC0
		Wave/C wnC=$wnC0
		Redimension/C wnC
		wnC=cmplx(wnRe,wnIm)
	endif
	return(result)
End

// load multiple H5 data with the same name of EM fields in a folder
Macro LoadmultipleHDF5meep(pathname,fnamebase,datasetNameBase)
	String pathname="meep",fnamebase,datasetNameBase="ez"
	Prompt pathname, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Prompt fnamebase,"base file name"
	Prompt datasetNameBase,"dataset name"
	PauseUpdate; Silent 1
	
	String fileName,ftype=".h5"
	Variable fileIndex=0,filenum=0,gotFile,gotFile2
	String fname
	
	if (CmpStr(pathname, "_New Path_") == 0)		// user selected new path ?
		NewPath/O meep			// this brings up dialog and creates or overwrites path
		pathname = "meep"
	endif
	
	DoWindow/F GraphPlot_meep
	if(V_flag ==0)
		Make/N=2/D/O $datasetNameBase
		GraphPlot_meep(datasetNameBase)
	endif

// load h5 data
	do
		fileName = IndexedFile($pathname,fileIndex,ftype)			// get name of next file in path
		gotFile = strlen(fileName)
		if (gotFile != 0 && strsearch(filename, fnamebase, 0  ,2)>=0)
			print filename,
			gotfile2=LoadHDF5Dataset(pathName, fileName, datasetNameBase)
			if(gotFile2<0)
				break
			endif
			fname=datasetNameBase+num2str(filenum)
			Duplicate/O $datasetNameBase,$fname
			DoUpdate	// make sure graph updated before printing
//			if (wantToPrint == 1)
//				PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1	// print graph
//			endif
			filenum +=1
		endif
		fileIndex += 1
	while (gotFile)									// until TextFile runs out of files
End

Macro graphplot_meep(wname) : Graph
	String wname
	PauseUpdate; Silent 1		| building window...
	Display /W=(3,41,636,476) $wname
//	Label left "counts"
//	Label bottom "nm"
//	Textbox/N=tb_file/F=0/A=MT/X=-30.00 "File: XR1.L00"
EndMacro

Macro animatetest1(skip)
	Variable Skip=2
	PauseUpdate; Silent 1
	
	String wname="ez",wtmp="ezslice"
	Variable ny,index
	ny=DimSize($wname,1)
	index=0
	do
		$wtmp=$wname[p][index]
		DoUpdate
		index=index+skip
	while(index<ny)
End Macro


/// Create 1D graph Animation based on 2D wave
// using existing graph window
Macro MakeAnimation1DGraph1(gname,wname,tmpwname,mname,skip,showDialog)
	String gname=g_gname,wname=g_wname,tmpwname=g_twname,mname
	Variable skip=1,showDialog=2
	Prompt gname,"Graph name",popup,WinList("*",";","")
	Prompt wname,"X-t wave name",popup,WaveList("*",";","DIMS:2")
	Prompt tmpwname,"temporay wave name"
	Prompt mname,"destination movie name"
	Prompt ShowDialog,"Show Dialog for movie file ?",popup,"yes;no"
	Prompt skip,"number of skips"
	PauseUpdate;Silent 1
	
	Variable nx,ny,index=0
//	String tmpwave=wname+"_tmp"
	
	if(strlen(mname)==0)
		mname=gname+"_movie"
	endif
	print "movie name : ",mname
	if( showDialog==1)
		NewMovie/I/O/Z/P=home as mname
	else
		NewMovie/O/Z/P=home as mname
	endif
	if( V_Flag!=0 )
		print "V_flag = ", V_Flag
		print "canceled for some reason"
		return 0			// probably canceled
	endif

	nx=DimSize($wname,0)
	ny=DimSize($wname,1)
//	Make/O/N=(nx) $tmpwave

	DoWindow/F $wname
	DoUpdate
//	NewMovie/Z/I/O/P=home as "sdhmovie"
	
	do
		$tmpwname=$wname[p][index]
		DoUpdate
		AddMovieFrame
		index=index+skip
	while(index<ny)
	
	CloseMovie
	PlayMovie/P=home as mname

End Macro

Macro InitMakeAnimation1Dgraph(gname,wname,tmpwname)
	String gname,wname,tmpwname
	Prompt gname,"Graph name"
	Prompt wname,"X-t wave name",popup,WaveList("*",";","DIMS:2")
	Prompt tmpwname,"temporay wave name"
	PauseUpdate;Silent 1

	String/g g_gname,g_wname,g_twname
	Variable nx,ny,zmin,zmax
	nx=DimSize($wname,0)
	ny=DimSize($wname,1)
	if(strlen(tmpwname)==0)
		tmpwname=wname+"_tmp"
	endif
	if(strlen(gname)==0)
		gname=wname+"_graph"
	endif
	g_gname=gname
	g_wname=wname
	g_twname=tmpwname
	Make/O/N=(nx) $tmpwname
	$tmpwname=$wname[p][0]
	
	if(strlen(WinList(gname,";",""))==0)
		Display $tmpwname
		DoWindow/C $gname
		zmin=WaveMin($wname)
		zmax=WaveMax($wname)
		SetAxis left zmin,zmax
	else
		DoWindow/F $gname
	endif
	
End


//slices

//Display slices from x-t wave
Macro ShowSlice_meep(wname,destwname,num)
	String wname,destwname
	Variable num
	PauseUpdate; Silent 1
	
	Variable,nx,ny
	nx=DimSize($wname,0)
	ny=DimSize($wname,1)
	if(strlen(destwname)==0)
		destwname=wname+"_slice"
	endif
	Make/O/N=(nx) $destwname
	$destwname=$wname[p][num]
	Display $destwname
End

Macro UpdateSlice_meep(wname,destwname,num)
	String wname,destwname
	Variable num
	PauseUpdate; Silent 1
	$destwname=$wname[p][num]
End
	
Function RemovePMLrz(wvname,resolution,dpml)
	String wvname
	Variable resolution,dpml
	
	Wave wv=$wvname
	Variable nz=DimSize(wv,0)
	Variable nr=DimSize(wv,1)
	Variable t=resolution*dpml
	DeletePoints/M=0 nz-t-1,t,wv
	DeletePoints/M=0 0,t,wv
	DeletePoints/M=1 nr-t-2,t,wv
	DeletePoints/M=1 0,1,wv
End

Function ShowFieldRAll_meep(index,scale,imgsize)
	Variable index,scale,imgsize
	
	// scale=0.01,size=0.1
	if(imgsize<=0)
		imgsize=0.03
	endif
	if(scale<=0)
		scale=0.01
	endif
	
	ShowFieldRAll_meep0("ex",index,scale,imgsize)
	ShowFieldRAll_meep0("ey",index,scale,imgsize)
	ShowFieldRAll_meep0("ez",index,scale,imgsize)
	ShowFieldRAll_meep0("er",index,scale,imgsize)
	ShowFieldRAll_meep0("ep",index,scale,imgsize)
	ShowFieldRAll_meep0("hx",index,scale,imgsize)
	ShowFieldRAll_meep0("hy",index,scale,imgsize)
	ShowFieldRAll_meep0("hz",index,scale,imgsize)
	ShowFieldRAll_meep0("hr",index,scale,imgsize)
	ShowFieldRAll_meep0("hp",index,scale,imgsize)
End

Function ShowFieldRAll_meep0(fldname,index,scale,imgsize)
	String fldname
	Variable index,scale,imgsize

	String wvname=fldname+num2str(index)+"_r"
	if(WaveExists($wvname))
		ShowField_meep(wvname,scale,imgsize)
		TextBox/C/N=text0/F=0/A=MC/X=-41.85/Y=33.66 "\\Z36"+fldname
	endif
End

Function ShowField_meep(wvname,scale,imgsize)
	String wvname
	Variable imgsize,scale
	
	// scale=0.01,size=0.1
	if(imgsize<=0)
		imgsize=0.05*28.3465
	else
		imgsize=imgsize*28.3465
	endif
	if(scale<=0)
		scale=0.01
	endif
	Wave wv=$wvname
	NewImage wv
	ModifyGraph height={Plan,1,left,top}
	ModifyGraph width={perUnit,imgsize,left}
	ModifyImage $wvname ctab= {-scale,scale,RedWhiteBlue,0}
	ModifyGraph noLabel=2,axThick=0
	SetAxis/A left
End

Function FResizeImage(imgsize)
	Variable imgsize

	imgsize=imgsize*28.3465
	ModifyGraph height={Plan,1,left,top}
	ModifyGraph width={perUnit,imgsize,left}
End

Function FRescaleImage(scale)
	Variable scale
	
	String wvname=StringFromList(0,ImageNameList(WinName(0,1),";"),";")
	if(strlen(wvname)!=0)
		ModifyImage $wvname ctab= {-scale,scale,RedWhiteBlue,0}	
	Endif
End

Function/S sMeepFldName(fld,prefix,suffix)
	String fld,prefix,suffix
	String fname
	if(strlen(prefix)==0 && strlen(suffix)==0)
		sprintf fname,"%s.h5",fld
	else
		if(strlen(prefix)==0)
			sprintf fname, "%s-%s.h5",fld,suffix
		else
			if(strlen(suffix)==0)
				sprintf fname,"%s-%s.h5",prefix,fld
			else
				sprintf fname,"%s-%s-%s.h5",prefix,fld,suffix
			endif
		endif
	endif
	return(fname)
End

Macro LoadFreqsMeep(filename,pathName,bname,scalenum0,fconv,dispTable,dispGraph,fquiet)
	String filename,pathName,bname
	Variable scalenum0,dispTable,dispGraph,fquiet
	Variable fconv
	Prompt filename,"file name"
	Prompt pathName,"path name"
	Prompt bname,"base wave name"
	Prompt scalenum0,"scaling wave",popup,"kx;ky;kz"
	Prompt fconv,"unit",popup,"freq:(k/2pi);omega:k"
	prompt dispTable, "display table ?", popup,"yes;no"
	prompt dispGraph, "display Graph ?", popup,"yes;no"
	prompt fquiet, "quiet ?", popup,"yes;no"	
	PauseUpdate; Silent 1
	LoadFreqsMeep0(filename,pathName,bname,scalenum0,fconv,dispTable,dispGraph,fquiet)
End

Function LoadFreqsMeep0(filename,pathName,bname,scalenum0,fconv,dispTable,dispGraph,fquiet)
	String filename,pathName,bname
	Variable scalenum0,dispTable,dispGraph,fquiet
	Variable fconv
	
	Variable ref,result
	String dest

	if(strlen(filename)==0)
		Open /D/R/P=$pathName/T=".DAT" ref // windows
		filename=S_filename
		if(strlen(filename)==0)
			return(-1)
		endif
		print filename
	endif
	if(strlen(bname)==0)
		bname=wname(filename)
	endif

	Variable len,num=-1,num2,numfreqs,lineno=0,ii,numdat
	String buffer,buffer2

	// count maximum number of columns
	Open /R/P=$pathName/T=".dat" ref as fileName
	do
		FReadLine ref,buffer
		len = strlen(buffer)
		if (len == 0)
			break						// No more lines to be read
		endif
		num2=ItemsInList(buffer,",")
		if(num2>num)
			num=num2
		endif
		lineno+=1
	while(1)
	print num,lineno
	num-=2 // kx, ky, kz and freqs
	numfreqs=num-3
	numdat=lineno
	if(numfreqs<=0) // no frequency data
		return(-2)
	endif
	
	// make dummy waves
	ii=0
	do
		Make/O/N=(lineno)/D $("dummy"+num2str(ii))
		ii+=1
	while(ii<num)
	
	// load data
	lineno=0
	Open /R/P=$pathName/T=".dat" ref as fileName
	do
		FReadLine ref,buffer
		len = strlen(buffer)
		if (len == 0)
			break						// No more lines to be read
		endif
		ii=0
		do
			dest="dummy"+num2istr(ii)
			Wave wv=$dest
			buffer2=StringFromList(ii+2,buffer,",")
			if(strlen(buffer2)==0)
				wv[lineno]=NAN
			else
				wv[lineno]=str2num(buffer2)
			endif
			ii+=1
		while (ii<num)
		lineno+=1
	while(1)
	
	// scaling
	String snm="dummy"+num2str(scalenum0-1)
	Variable xmin,xmax
	WaveStats/Q $snm
	xmin=V_min
	xmax=V_max
	ii=0
	do
		dest="dummy"+num2istr(ii)
		Wave wv=$dest
		SetScale/I x,xmin,xmax,"",wv
		ii+=1
	while(ii<num)
	
	// rename and add note
	dest=bname+"_kx"
	Wave dummy0,dummy1,dummy2
	Duplicate/O dummy0,$dest
	AddStdNoteToWave($dest,pathname,filename)
	dest=bname+"_ky"
	Duplicate/O dummy1,$dest
	AddStdNoteToWave($dest,pathname,filename)
	dest=bname+"_kz"
	Duplicate/O dummy2,$dest
	AddStdNoteToWave($dest,pathname,filename)
	ii=0
	do
		dest=bname+"_"+num2str(ii)
		Duplicate/O $("dummy"+num2istr(ii+3)),$dest
		AddStdNoteToWave($dest,pathname,filename)
		ii+=1
	while(ii<numfreqs)

	if(fconv==2)
	// rescale
		ReScaleWavesAll(bname,2*pi,numfreqs) // in mpbprocs
	endif

End

// load harminv data obtained by htoi.pl script (with -s option)
// wavelength  and Q

Function LoadHarminv1(pathname,filename,index)
	String pathname,filename
	Variable index
	
	String suffixlist,prefix=""
	String extName=".dat",bname
	Variable dispTable=2,dispGraph=2,col=-1,fquiet=2
	String xunit="",yunit=""

//	SVAR g_JMGTD_wname
	suffixlist="h_wl;h_Q"
//	JMGeneralDatLoaderFunc(filename,pathname,extName,bname,suffixlist,scalenum0+1,dispTable,dispGraph,fquiet)
//	JMGeneralDatLoaderFunc(filename,pathname,extName,prefix,suffixlist,col,2,2,fquiet)
	JMGeneralDatLoaderFunc2(filename,pathname,extName,index,prefix,suffixlist,col,xunit,yunit,fquiet)

//	if(dispGraph==1)
//		JMGTDDisplay(g_JMGTD_wname,suffixlist,1,0)
//	endif
End

Macro LoadHarmInv1Multi(thePath,fNameMask,dsindex,fquiet)
	Variable dsindex=g_DSO_index,fquiet=1
	String thePath="_New Path_",fNameMask
	Prompt thePath, "Name of path containing LDOS data files", popup PathList("*", ";", "")+"_New Path_"
	Prompt fNameMask,"mask for file name"
	Prompt dsindex,"index for data set"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1;
	
	Variable index,dispGraph=2,col=-1
	String 	suffixlist="h_wl;h_Q"
	String ftype=".dat",dsetnm0

	dsetnm0=g_DSO_name+num2istr(dsindex)
	JMGTDL2multi0func(dsetnm0,"",thePath,fNamemask,ftype,suffixlist,col,dispGraph,fquiet)
	DoWindow/F DataSetTable
	AppendToTable $dsetnm0
	
	g_DSO_index=dsindex+1
End

Function LoadLDOS1(pathname,filename,index)
	String pathname,filename
	Variable index
	
	String suffixlist,prefix=""
	String extName=".dat",xunit="",yunit=""
	Variable dispTable=2,dispGraph=1,col=-1,fquiet=2
	SVAR g_JMGTD_wname

	suffixlist=";fldos;ldos"
//	JMGeneralDatLoaderFunc(filename,pathname,extName,prefix,suffixlist,col,2,2,fquiet)
	JMGeneralDatLoaderFunc2(filename,pathname,extName,index,prefix,suffixlist,col,xunit,yunit,fquiet)
	if(dispGraph==1)
		JMGTDDisplay(g_JMGTD_wname,suffixlist,2,1)
	endif
End

Macro LoadLDOS1Multi(thePath,fNameMask,dsindex,fquiet)
	Variable dsindex=g_DSO_index,fquiet=1
	String thePath="_New Path_",fNameMask
	Prompt thePath, "Name of path containing LDOS data files", popup PathList("*", ";", "")+"_New Path_"
	Prompt fNameMask,"mask for file name"
	Prompt dsindex,"index for data set"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1;
	
	Variable index,dispGraph=2,col=-1
	String suffixlist=";fldos;ldos",ftype=".dat",dsetnm0

	dsetnm0=g_DSO_name+num2istr(dsindex)
	JMGTDL2multi0func(dsetnm0,"",thePath,fNamemask,ftype,suffixlist,col,dispGraph,fquiet)
	DoWindow/F DataSetTable
	AppendToTable $dsetnm0
	
	g_DSO_index=dsindex+1
End






// original version using old version of JMGTDL: left for temporal compatibility
Function LoadHarminv1_orig(pathname,filename,suffix)
	String pathname,filename
	Variable suffix
	
	String wlist
//	String/G g_meepharminv1="meepharminv1Name"
	Variable dispTable=2,dispGraph=2,col=-1,fquiet=1

	SVAR g_meepharminv1
	wlist="wl;Q"
//	JMGeneralDatLoaderInit(g_meepharminv1,wlist)

//	JMGeneralDatLoaderFunc(filename,pathname,g_meepharminv1,suffix,col,dispTable,dispGraph,fquiet)
End

Function LoadLDOS1_orig(pathname,filename,suffix)
	String pathname,filename
	Variable suffix
	
	String wlist
	Variable dispTable=2,dispGraph=2,col=-1,fquiet=1

	SVAR g_meepLDOS
	wlist=";fldos;ldos"
//	JMGeneralDatLoaderFunc(filename,pathname,g_meepLDOS,suffix,col,dispTable,dispGraph,fquiet)
End

Function LoadMeepDispersion(fname,pname,index,prefix,fquiet)
	String fName,pName,prefix
	Variable index,fquiet
	
	String suffixlist,extName=".dat",xunit="",yunit=""
	Variable scalenum=2
	suffixlist=";kred;k;freq;omega;wl;neff;Q"
	JMGeneralDatLoaderFunc2(fname,pname,extName,index,prefix,suffixlist,scalenum,xunit,yunit,fquiet)
End