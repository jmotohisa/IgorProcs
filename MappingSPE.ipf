#pragma rtGlobals=1		// Use modern global access method.// MappingSPE.ipf//	Macro to load and analyze SPE mapping data file (version 1.7)  (SPE file with extention of "SPE")//	07/10/09 ver. 0.2c by J. Motohisa////	revision history//		?/?/?		ver 0.01	preliminary version//		06/01/29	ver 0.1	modified to comply with DataSetOperations//		06/04/07	ver 0.2	wave dimension for1D scan is set two-dimensinoal and not requires Slicer//		06/04/08	ver 0.2a	add JoinMappingData procedure//		07/08/23	ver 0.2b	add "image lie profile" and "JEG Profiler" procedures//		07/10/09	ver 0.2c	add procedures for image of wavelength in maximum intensity and spectrally integrated images//		08/04/20	ver 0.2c1	rewriting some procedures using 3DMatrixOperations2.ipf//		08/09/17	ver 0.3a	with gizmo support//		08/09/22	ver 0.3a1	DuplicateSliceImage and DuplicateSpecrum added//		11/03/20	ver 0.4a0	rewritten with "GizmoXYZsliceProc.ipf", Most of "Proc" is converted to "Function",//									ModifySlicer is outedated, so removed//		11/06/10	ver 0.4a1	some bugs fixed#include "3DMatrixOperations"#include "wname"//#include "datatype"#include "LoadSPEsub"#include <Image Line Profile>#include "JEG Profiler"#include "JEG Color Legend"#include "GizmoXYZsliceProc"Menu "Macros"	"Show Image at CursorA/1",CsrASlicer()	"Integrate spectra between cursor/2", ImageIntegrateCsr()	"-"	"Show spectrum at cursorA/3",PlotSpectrumAtCsr()	"-"	"Show Image Line Progfile/4",WMCreateImageLineProfileGraph()	"-"	"Load SPE mapping data/9",SPEloadMul()	"Initialize Slicer/0",InitSlicerSPE()	"-"	"Duplicate Spectrum",DuplicateSpecrum()	"Duplicate Slicer Image",DuplicateSliceImage()	"-"EndProc SPEloadMul(name,file,path,expnml,nx,ny,sizex,sizey)	String name,file	String path="home"	Variable expnml=1,nx=1,ny=1,sizex=6e-6,sizey=6e-6	Prompt name,"wave name"	Prompt file,"file name"	Prompt path,"path name"	Prompt expnml,"normalize with exptime ?",popup,"yes;no"	Prompt nx,"nx"	Prompt ny,"ny"	PauseUpdate; Silent 1	SPEloadMulFunc(name,file,path,expnml,nx,ny,sizex,sizey)End// Load SPE data of mapping dataFunction SPEloadMulFunc(name,file,path,expnml,nx,ny,sizex,sizey)	String name,file	String path	Variable expnml,nx,ny,sizex,sizey		Variable /D ref,npoint,datatype,n_poly,dtype,skip,xmin,xmax	Variable ROIinfo,startx,endx,groupx,starty,endy,groupy,exp_sec	Variable noscan,lnoscan,NumFrames	Variable nbyte	String xname,extstr	Variable IgorVersion	Variable wnlength	Variable ix,iy,ixy	String tmpname,tmpname2	//	open file dialogue to load data//	extstr = FileTypeStr()	extstr=".spe"//	print extstr	if (strlen(file)<=0)		Open /D/R/P=$path/T=(extstr) ref		file= S_fileName	endif	print file//	print path// read data header	Open /R/P=$path/T=(extstr) ref as file	FsetPos ref,10	FBinRead/B=3/F=4 ref,exp_sec	FsetPos ref, 34	FBinRead/B=3/F=2 ref,noscan	FsetPos ref,42	FBinRead /B=3/F=2/U ref,npoint	FsetPos ref,108	FBinRead /B=3/F=2 ref,datatype	FsetPos ref,664	FBinRead /B=3/F=3 ref,lnoscan		FsetPos ref,1446	FBinRead/B=3/F=3 ref,NumFrames	FsetPos ref,1510	FBinRead/B=3/F=2 ref,ROIinfo	if(ROIinfo==0)		ROIinfo=1	endif	FSetPos ref,1512+(ROIinfo-1)*12	FBinRead /B=3/F=2/U ref,startx	FBinRead /B=3/F=2/U ref,endx	FBinRead /B=3/F=2/U ref,groupx	FBinRead /B=3/F=2/U ref,starty	FBinRead /B=3/F=2/U ref,endy	FBinRead /B=3/F=2/U ref,groupy	FSetPos ref,3101	FBinRead /B/F=1 ref,n_poly	Close ref	print exp_sec,npoint,datatype,n_poly//	print ROIinfo,startx,endx,groupx,starty,endy,groupy//	print noscan,lnoscan,NumFrames		//	print datatype,dtype,exp_sec,nbyte	if(NumFrames != nx*ny)		print NumFrames,nx,ny		print "Number of frames does not much with specified Nx and Ny"	endif	if (strlen(name)<1)		tmpname=wname(file)	endif	name="M"+tmpname	xname="L"+tmpname	Make/O/D/N=(npoint) $xname	// load calibration data//	GBLoadWave/Q/N=$"coef"/T={4,4}/B/U=6/S=3263/W=1/P=$path file	GBLoadWave/Q/N=$"coef"/T={4,4}/B/U=6/S=3263/W=1 file	Wave xnm=$xname	xnm=poly(coef0, x)	String cmd// load spectrum	if(nx==1)		SPELoadMulSub1(file,name,xname,ny,npoint,datatype,sizey)	else		if(ny==1)			SPELoadMulSub1(file,name,xname,nx,npoint,datatype,sizex)		else			SPELoadMulSub2(file,name,xname,nx,ny,npoint,datatype,sizex,sizey)		endif	endif		Wave nm=$name	if(expnml==1)		nm/=exp_sec	endif//	print "InitSlicer("+$name+")"EndFunction SPEloadMulSub2(file,name,xname,nx,ny,npoint,datatype,sizex,sizey)	String file,name,xname	Variable nx,ny,npoint,datatype,sizex,sizey	PauseUpdate;Silent 1		Variable ix,iy,ixy,skip,dtype,nbyte	Make/O/D/N=(nx,ny,npoint) $name	dtype=fdatatype(datatype)	nbyte=DataByteLength(datatype)		ix=0	iy=0	ixy=0	Wave nm=$name,dummyywave0	do		ix=0		do			ixy=ix+iy*nx//			print ixy			skip=4100+npoint*ixy*nbyte//			GBLoadWave/Q /N=$"dummyywave"/T={(dtype),4}/B/U=(npoint)/S=(skip)/W=1/P=$path file			GBLoadWave/Q /N=$"dummyywave"/T={(dtype),4}/B/U=(npoint)/S=(skip)/W=1 file			nm[ix][iy][]=dummyywave0[r]			ix+=1		while(ix<nx)		iy+=1	while(iy<ny)	SetScale/I x 0,sizex,"m", nm	SetScale/I y 0,sizey,"m", nmEnd ProcFunction SPEloadMulSub1(file,name,xname,nx,npoint,datatype,sizex)	String file,name,xname	Variable nx,npoint,datatype,sizex	PauseUpdate;Silent 1		Variable ix,skip,dtype,nbyte,xmin,xmax	Make/O/D/N=(npoint,nx) $name	dtype=fdatatype(datatype)	nbyte=DataByteLength(datatype)		ix=0	Wave nm=$name,dummyywave0	do//		print ixy		skip=4100+npoint*ix*nbyte//		GBLoadWave/Q /N=$"dummyywave"/T={(dtype),4}/B/U=(npoint)/S=(skip)/W=1/P=$path file		GBLoadWave/Q /N=$"dummyywave"/T={(dtype),4}/B/U=(npoint)/S=(skip)/W=1 file		nm[][ix]=dummyywave0[p]		ix+=1	while(ix<nx)	SetScale/I y 0,sizex,"m", $name	Wavestats/Q $xname	xmin=V_min	xmax=V_max	SetScale/I x xmin,xmax,"nm", $nameEnd// initialize slicerProc InitSlicerSPE(name)	String name	Prompt name,"wave name for slice",popup,wavelist("M*",";","DIMS:3")	PauseUpdate;Silent 1	String/G g_name,g_xname,g_IntgWin,g_IntgSpct,g_aSpct,g_aSpctWin	String/G g_SliceWin, g_SliceImage,g_GizmoSlice	Variable/G g_nx,g_ny,g_nl	InitSlicerSPEFunc(name)EndFunction InitSlicerSPEFunc(name)	String name		SVAR g_name,g_xname,g_IntgWin,g_IntgSpct,g_aSpct,g_aSpctWin	SVAR g_SliceWin, g_SliceImage,g_GizmoSlice	NVAR g_nx,g_ny,g_nl	Variable namelen		namelen=strlen(name)	g_name=name	g_xname="L"+name[1,namelen-1]	g_IntgWin=name+"IntgWin"	g_IntgSpct=name+"_IntgSpct"	g_aSpctWin=name+"aSpctWin"	g_aSpct=name+"_aSpct"	g_SliceWin=name+"SliceImage"	g_SliceImage=name+"_Slice"	g_GizmoSlice = name+"_Gizmo"		g_nx=DimSize($name,0)	g_ny=DimSize($name,1)	g_nl=DimSize($name,2)		if(exists("NewGizmo")!=4)		DoAlert 0, "Gizmo XOP must be installed"		return -1	else		JMGizmoShowXYZSlice(name,"")		JM_GizmoXYZSlicePanel()	endif		String cmd	if(strlen(WinList(g_intgWin,";",""))==0)		SpacialIntegrationFunc(name,g_IntgSpct)		Display /W=(7,352,286,729) $g_IntgSpct vs $g_xname		DoWindow/C $g_IntgWin		ShowInfo	else		DoWindow/F $g_intgWin	endif	cmd="PlotSpectrum0(0,0)"	Execute cmd	ShowInfo		cmd="SlicerImages(name,0,g_SliceWin,g_SliceImage)"	Execute cmdEnd// plot a single spectrumFunction PlotSpectrum0(xpos,ypos)	Variable xpos,ypos	SVAR g_name, g_xname,g_aSpctWin,g_aSpct		PlotSpectrumFunc(g_name,g_xname,xpos,ypos,g_aSpctWin,g_aSpct)EndMacro PlotSpectrumAtCsr()	PauseUpdate; Silent 1	PlotSpectrum(g_name,g_xname,pcsr(a),qcsr(a),g_aSpctWin,g_aSpct)End MacroMacro AllSpectPlayer()	PauseUpdate;Silent 1	Variable ix,iy	iy=0	Do		ix=0		do			PlotSpectrum0(ix,iy)			DoUpdate			Sleep/S 0.2			ix+=1		while(ix<g_nx)		iy+=1	while(iy<g_ny)EndProc PlotSpectrum(name,xname,xpos,ypos,WindowName,Wname)	String name=g_name,xname=g_xname,WindowName=g_aSpctWin,Wname=g_aSpct	Variable xpos,ypos	PauseUpdate;Silent 1	PlotSpectrumFunc(name,xname,xpos,ypos,WindowName,Wname)EndFunction PlotSpectrumFunc(name,xname,xpos,ypos,WindowName,Wname)	String name,xname,WindowName,Wname	Variable xpos,ypos		Variable nx,ny,nl,xx,yy,namelen	String lbl	String cmd		SVAR g_name,g_xname,g_aSpctWin,g_aSpct	g_name=name	g_xname=xname	g_aSpctWin=WindowName	g_aSpct=wname	nx=DimSize($name,0)	ny=DimSize($name,1)	nl=DimSize($name,2)	if(WaveExists($wname)==0)		Make/D/N=(nl) $wname	else		Redimension/N=(nl) $wname	endif		if(strlen(WinList(WindowName,";",""))==0)		Display /W=(287,352,586,718) $wname vs $xname		DoWindow/C $WindowName	else		DoWindow/F $WindowName	endif	Wave wn=$wname,nm=$name	wn=nm[xpos][ypos][p]	lbl="(x,y)=("+num2istr(xpos)+","+num2istr(ypos)+")"	if(strSearch(AnnotationList(WindowName),"lbl0",0)==0)		TextBox/C/N=lbl0/F=0 lbl	else		TextBox/C/N=lbl0 lbl	Endif	print xpos,ypos	sprintf cmd,"ModifyGizmo ModifyObject=%s property={ plane,%d}","Surface_x",xpos	Execute cmd	sprintf cmd,"ModifyGizmo ModifyObject=%s property={ plane,%d}","Surface_y",ypos	Execute cmdEnd//DIsplay a slice imageFunction SlicedImage0(num)	Variable num	SVAR g_name,g_SliceWin,g_SliceImage	SlicerImages(g_name,num,g_SliceWin,g_SliceImage)End MacroFunction CsrASlicer()	Variable zz,num	String cmd	SVAR g_name//	DoWindow/F $WindowName	num=pcsr(A)	SlicedImage0(num)	//	zz=1-num/DimSize($g_name,2)//	print zz	print num	sprintf cmd,"ModifyGizmo ModifyObject=%s property={ plane,%d}","Surface_z",num	Execute cmdEndFunction SlicerImages(name,num,WindowName,wname)	String name,WindowName,wname	Variable num	Variable zz,namelen,nx,ny,nl	String xname		SVAR g_name, g_SliceWin,g_SliceImage	g_name=name	g_SliceWin=WindowName	g_SliceImage=wname	namelen=strlen(name)	nx=DimSize($name,0)	ny=DimSize($name,1)	nl=DimSize($name,2)	Wave wn=$wname	if(WaveExists(wn)==0)		Make/D/N=(nx,ny) $wname	else		Redimension/N=(nx,ny) wn	endif	xname="L"+name[1,strlen(name)-1]	Wave xn=$xname	print xn[num]		if(strlen(WinList(WindowName,";",""))==0)		Display /W=(588,192,1039,622)		AppendImage wn		ModifyGraph height={Aspect,1}		DoWindow/C $WindowName	else		DoWindow/F $WindowName	endif//	GetSlicer SliceList//	zz=round((1-W_Slice_Info[2][1])*nl)//	print zz/nl		Wave nm=$name	wn=nm[p][q][num]EndProc SlicerImages2(name,num,WindowName,wname)	String name=g_name,WindowName=g_SliceWin,wname=g_SliceImage	Variable num	PauseUpdate;Silent 1	Variable zz,namelen,nx,ny,nl	String xname		g_name=name	g_SliceWin=WindowName	g_SliceImage=wname	namelen=strlen(name)	xname="L"+name[1,strlen(name)-1]	print $xname[num]	Slice3DMatrixWave(name,3,num,WindowName,wname)End// plot a spectrumProc PlotSpectraFromSlice(name)	String name=g_name	PauseUpdate;Silent 1	PlotSpectraFromSliceFunc(name)EndFunction PlotSpectraFromSliceFunc(name)	String name		Variable nx,ny,nl,xx,yy,namelen	String sname="dummy",wname="SliceWindow"	String xname	Variable xpos,ypos	SVAR g_name	g_name=name	namelen=strlen(name)	xname="L"+name[1,namelen-1]	nx=DimSize($name,0)	ny=DimSize($name,1)	nl=DimSize($name,2)	if(WaveExists($sname)==0)		Make/D/N=(nl) $sname	else		Redimension/N=(nl) $sname	endif		if(strlen(WinList(wname,";",""))==0)		Display $sname vs $xname		DoWindow/C $wname	else		DoWindow/F $wname	endif		Variable pos=0,pos2	SVAR g_GizmoSlice	String recMacro=WinRecreation(g_GizmoSlice, 0),planeStr	pos=strsearch(recMacro,"Surface_x",pos)	pos=strsearch(recMacro,"property={ plane",pos)	if(pos>-1)		pos2=strsearch(recMacro,"}",pos)		planeStr=recMacro[pos+17,pos2-1]		sscanf planeStr,"%d",xpos	else		xpos=0	endif	pos=strsearch(recMacro,"Surface_y",pos)	pos=strsearch(recMacro,"property={ plane",pos)	if(pos>-1)		pos2=strsearch(recMacro,"}",pos)		planeStr=recMacro[pos+17,pos2-1]		sscanf planeStr,"%d",ypos	else		ypos=0	endif	print xx,yy,xpos,ypos	Wave sn=$sname,nm=$name	sn=nm[xpos][ypos][p]EndMacro DoImageScan(start,stop,skip)	Variable start=0,stop=g_nl,skip=10	PauseUpdate;Silent 1	Variable nx,ny,index	nx=DimSize($g_name,0)	ny=DimSize($g_name,1)//	nl=DimSize($name,2)	if(WaveExists($g_SliceImage)==0)		Make/D/N=(nx,ny) $g_SliceImage	else		Redimension/N=(nx,ny) $g_SliceImage	endif		if(strlen(WinList(g_SliceWin,";",""))==0)		Display		AppendImage $g_SliceImage		ModifyGraph height={Aspect,1}		DoWindow/C $g_SliceWin	else		DoWindow/F $g_SliceWin	endif	index=start	do		$g_SliceImage=$g_name[p][q][index]		DoUpdate		Sleep/S 0.2		index+=skip	while(index<stop)endMacro ImageIntegrateCsr()	Variable start,stop	start=pcsr(A)	stop=pcsr(B)//	print start,stop	ImageIntegrate(g_name,start,stop,g_SliceWin,g_SliceImage)EndProc ImageIntegrate(name,start,stop,WindowName,wname)	String name=g_name,WindowName=g_SliceWin,Wname=g_SliceImage	Variable start=0,stop=1340,skip=10	PauseUpdate;Silent 1	ImageIntegrateFunc(name,start,stop,WindowName,wname)EndFunction ImageIntegrateFunc(name,start,stop,WindowName,wname)	String name,WindowName,Wname	Variable start,stop	Variable zz,namelen,nx,ny,nl	Variable index	String xname//	Variable start=800,eend,skip=4		SVAR g_name	SVAR g_name=name	namelen=strlen(name)	xname="L"+name[1,namelen-1]	Wave xn=$xname,nm=$name	print xn[start],xn[stop]	nx=DimSize(nm,0)	ny=DimSize(nm,1)	nl=DimSize(nm,2)	if(WaveExists($wname)==0)		Make/D/N=(nx,ny) $wname	else		Redimension/N=(nx,ny) $wname	endif	index=start	Wave wn=$wname	wn=nm[p][q][index]	index+=1	do//		DoUpdate//		Sleep/S 0.2		wn+=nm[p][q][index]		index+=1	while(index<stop)	if(strlen(WinList(WindowName,";",""))==0)		Display		AppendImage $wname		ModifyGraph height={Aspect,1}		DoWindow/C $WindowName	else		DoWindow/F $WindowName	endifendProc SpacialIntegration(name,targetw)	String name=g_name,targetw=g_name+"_Intg"	PauseUpdate;Silent 1		SpacialIntegrationFunc(name,targetw)EndFunction SpacialIntegrationFunc(name,targetw)	String name,targetw	Variable nx,ny,nl	Variable index	String xname		SVAR g_name	g_name=name//	xname="L"+name[1,namelen-1]	Wave nm=$name	nx=DimSize(nm,0)	ny=DimSize(nm,1)	nl=DimSize(nm,2)	Wave tw=$targetw	if(WaveExists($targetw)==0)		Make/D/N=(nl) $targetw	else		Redimension/N=(nl) $targetw	endif	Wave dummyywave0	if(WaveExists(dummyywave0)==0)		Make/D/N=(nx,ny) $"dummyywave0"	else		Redimension/N=(nx,ny) dummyywave0	endif		index=0	do		dummyywave0=nm[p][q][index]		tw[index]=area(dummyywave0,-Inf,Inf)		index+=1	while(index<nl)EndMacro KillSlicersWin(name)	String name	Prompt name,"Kill slices related to",popup,wavelist("M*",";","DIMS:3")	PauseUpdate;Silent 1		String IntgWin,aSpctWin,SliceWin		IntgWin=name+"IntgWin"	aSpctWin=name+"aSpctWin"	SliceWin=name+"SliceImage"	DoWindow/K $IntgWin	DoWindow/K $aSpctWin	DoWindow/K $sliceWinEnd//// Macro JoinMappingData(wvnm,prefix,nstart,nend,nskip,ftrans)	String wvnm,prefix="M"	Variable nstart=1,nend=1,nskip=1,ftrans=1	PauseUpdate;Silent 1		String wv,xname,xname_orig	Variable nx,ny,npoint,i,i2	wv=prefix+num2istr(nstart)	xname_orig="L"+name[1,strlen(prefix)-1]+num2istr(nstart)	xname="L"+name[1,strlen(wvnm)-1]	Duplicate/O xname,xname_orig	nx=(nend-nstart)/nskip	ny=dimsize($wv,1)	npoint=dimsize($wv,0)	print nx,ny,npoint	if(ftrans==1)		Make/O/D/N=(nx,ny,npoint) $wvnm	else		Make/O/D/N=(nx,npoint,ny) $wvnm	endif	i=nstart	i2=0	do		wv=prefix+num2istr(i)		if(ftrans==1)			MatrixTranspose $wv		endif		$wvnm[i2][][]=$wv[q][r]		i+=nskip		i2+=1		if(ftrans==1)			MatrixTranspose $wv		endif	while(i<nend)EndMacro JoinMappingData2(wvnm,prefix,nstart,nend,nskip,ftrans)	String wvnm,prefix="M"	Variable nstart=1,nend=1,nskip=1,ftrans=1	PauseUpdate;Silent 1		String wv,xname,xname_orig	Variable nx,ny,npoint,i,i2	xname_orig="L"+name[1,strlen(prefix)-1]+num2istr(nstart)	xname="L"+name[1,strlen(wvnm)-1]	Duplicate/O xname,xname_orig	MatrixWavesTo3DMatrixWave(wvnm,prefix,1,nstart,nend,nskip,ftrans)End//////Macro WaveLengthMapBtwCsr(name,threshold,smth,index)	String name=g_name//	String WindowName=g_SliceWin,Wname=g_SliceImage	Variable threshold=30,smth=1,index=0	PauseUpdate;Silent 1		g_name=name	WaveLengthMap(name,threshold,smth,index,pcsr(A),pcsr(B))EndMacro WaveLengthMap(name,threshold,smth,index,start,stop)	String name=g_name//	String WindowName=g_SliceWin,Wname=g_SliceImage	Variable start=0,stop=1340,threshold=30,smth=1,index	PauseUpdate;Silent 1	Variable nx,ny,nl	Variable ix,iy,namelen	String wvwave,intwave,xname		g_name=name	namelen=strlen(name)	xname="L"+name[1,namelen-1]	nx=DimSize($name,0)	ny=DimSize($name,1)	nl=DimSize($name,2)//	print nx,ny,nl		wvwave="maxwl_"+num2str(index)	intwave="maxint_"+num2str(index)	Make/O/D/N=(nl) dummywave	Make/O/D/N=(nx,ny) $wvwave,$intwave	print $xname[start],$xname[stop]	ix=0	do		iy=0		do			dummywave[]=$name[ix][iy][p]			if(smth>0)				Smooth smth, dummywave			endif			WaveStats/Q/R=(start,stop) dummywave			if(V_max>threshold)				$wvwave[ix][iy]=$xname[V_maxloc]				$intwave[ix][iy]=V_max//				print ix,iy,V_maxloc			else				$wvwave[ix][iy]=0				$intwave[ix][iy]=0			endif			iy+=1		while(iy<ny)		ix+=1	while(ix<nx)		Display	AppendImage $wvwave	ModifyGraph height={Aspect,1}	ModifyImage $wvwave ctab= {$xname[start],$xname[stop],YellowHot,0}	ModifyImage $wvwave minRGB=NaN,maxRGB=NaNEnd MacroProc DisplaySlicerSPE(name)	String name=g_name	PauseUpdate; Silent 1	DisplaySlicer(name)End ProcMacro DuplicateSliceImage(dest,orig)	String orig=g_SliceImage,dest=g_SliceImage+"_0"	PauseUpdate;Silent 1	Duplicate $orig,$dest;	Display /W=(588,192,1039,622)	AppendImage $dest	ModifyGraph height={Aspect,1}EndMacro DuplicateSpecrum(dest,orig)	String orig=g_aSpct,dest=g_aSpct+"_0"	PauseUpdate;Silent 1	Duplicate $orig,$dest;	Display /W=(287,352,586,718) $destEnd