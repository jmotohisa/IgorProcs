#pragma rtGlobals=1		// Use modern global access method.// MatrixOperations2 by J. Motohisa// some macros to work with matrix wave// ver 0.1 ?// ver 0.2 2003/08/12// ver 0.3a 2004/11/09 : add feature to load columns data and convert to matrix wave// ver 0.3b 2005/02/26 : bug in DiffYmat fixed//							general procedure for x and y operation XYProc added// ver 0.4a 2006/01/30 : add LoadMatrixBinaryWave procedure (prelimnary version)// ver 0.4b 2006/06/22 : modified LoadMatrixBinaryWave procedure// ver 0.4b2 2006/06/26: added MultiLoadMatrixWave2// ver 0.4b3 2006/11/29: added Global variable for pathname,wvname,and filename in LoadMatrixWave// ver 0.4b4 2006/12/01: data are loaded into waves starting with "dummy" and duplicated into another wave (overwritten)// ver 0.5a 2008/04/04: added MakeMeshDataForNonUnifMesh// ver 0.5a1 2008/05/12: added MatrixWavePlot // 			note in 2008/08/14 : in LoadColumnDataToMatrix, it might be better to use /G rather than /J, but leave it for a moment// ver 0.5a2 2010/10/12:  LoadColumnDataToMatrix is modified for ndata <=1// ver 0.5b1 2011/06/09:  "_calculated" is replace with "_none_" in MatrixWavePlot// ver 0.5b2 2012/12/21:  MatrixWavePlotFunc added// ver 0.5b3 2012/12/27: IntegrateWaveX and IntegrateWaveY can dow with x or y- wave// ver 0.5b4 2013/05/23: bug fixed in IntegrateWaveY// ver 0.5b5 2014/03/13: Function FLoadColumnDataToMatrix is added// ver 0.5b6 2014/04/01: Function FLoadMatrixWave is added// ver 0.5b7 2014/10/04: Function FKillDummyWaves is added#include <Strings as Lists>#include "JEG Color Legend" // requires Jonathon Geyer's "JEG Tools"#include "wname"Macro LoadMatrixWave(wvname,filename,pathName,scaleflag,startflag,transpose)	String wvname,filename,pathName="home"	Variable scaleflag=1,startflag,transpose=1	Prompt scaleflag,"read scaling delta x and y ?",popup,"yes;no"	Prompt startflag,"read x0 and y0 value ?",popup,"yes;no"	Prompt transpose,"Transpose x and y ?",popup,"yes;no"		Silent 1; PauseUpDate	String/G g_wvname,g_filename,g_pathname	Variable ref,deltax,deltay,x0,y0,skips	String w0,buffer	FLoadMatrixWave(wvname,filename,pathName,scaleflag,startflag,transpose)End MacroMacro LoadCMatrixWave(wvname,filename,pathName,scaleflag,startflag,withbl,transpose)	String wvname,filename,pathName="home"	Variable scaleflag=1,startflag,transpose=1,withbl=1	Prompt scaleflag,"read scaling delta x and y ?",popup,"yes;no"	Prompt startflag,"read x0 and y0 value ?",popup,"yes;no"	Prompt transpose,"Transpose x and y ?",popup,"yes;no"	Prompt withbl,"with bl ?",popup,"yes;no"		Silent 1; PauseUpDate	String/G g_wvname,g_filename,g_pathname	Variable ref,deltax,deltay,x0,y0,skips	String w0,buffer	FLoadCMatrixWave(wvname,filename,pathName,scaleflag,startflag,withbl,transpose)End MacroFunction FLoadMatrixWave(wvname,filename,pathName,scaleflag,startflag,transpose)	String wvname,filename,pathName	Variable scaleflag,startflag,transpose		Variable ref,deltax,deltay,x0,y0,skips	String w0,buffer,wvname1,wvname2	SVAR g_wvname,g_filename,g_pathname		if (strlen(fileName)<=0)		Open /D/R/P=$pathName/T="sGBWTEXT.dat" ref		fileName= S_fileName	endif	print fileName	// read scaling information	Open /R/P=$pathName/T="sGBWTEXT.dat" ref as fileName	if(scaleflag==1)		FReadLine ref,buffer		deltax = str2num(GetStrFromList(buffer,0,"\t"))		deltay = str2num(GetStrFromList(buffer,1,"\t"))	else		deltax=1		deltay=1	endif	if(startflag==1)		FReadLine ref,buffer		x0 = str2num(GetStrFromList(buffer,0,"\t"))		y0 = str2num(GetStrFromList(buffer,1,"\t"))	else		x0=0		y0=0	endif	Close ref	skips=(2-scaleflag)+(2-startflag)		LoadWave/G/M/D/N=dummy/L={0,(skips),0,0,0}/P=$pathName filename		if(V_flag==0)		return(0)	endif		Variable index=0	do		w0 = GetStrFromList(S_waveNames,index,";")		if(strlen(w0)<=0)			break		endif		if (strlen(wvname)<1)			wvname1="M"+wname(fileName)			if(V_flag==1)				wvname2="M"+wname(fileName)			else				wvname2="M"+wname(fileName)+"_"+num2str(index)			endif		else			wvname1=wvname			if(V_flag==1)				wvname2=wvname			else				wvname2=wvname+"_"+num2str(index)			endif		endif		Duplicate/O $w0,$wvname2		if(scaleflag==1)			SetScale/P x x0,deltax,"m", $wvname2			SetScale/P y y0,deltay,"m", $wvname2		endif		if(transpose==1)			MatrixTranspose $wvname2		endif		index+=1	while(1)	g_pathname=pathname	g_filename=filename	g_wvname=wvname1EndFunction FLoadCMatrixWave(wvname,filename,pathName,scaleflag,startflag,withbl,transpose)	String wvname,filename,pathName	Variable scaleflag,startflag,transpose,withbl		String wv_re,wv_im,wv_c	Variable nx0,nx,ny	SVAR g_wvname	FLoadMatrixWave(wvname,filename,pathName,scaleflag,startflag,transpose)	wvname=g_wvname;	wv_re=wvname+"_0"	wv_im=wvname+"_1"	wv_c=wvname+"_c"	Duplicate/O $wv_re,$wv_c	Wave wwv_re=$wv_re	Wave wwv_im=$wv_im//	nx0=DimSize($wvname,0)//	ny=DimSize($wvname,1)//	if(withbl==1)//		nx=(nx0-1)/2//	else//		nx=nx0/2//	endif//	nx0=nx0-nx//	Redimension/N=(nx,ny) wwv_re//	DeletePoints 0,nx0,wwv_im//	Redimension/C/N=(nx,ny) $wv_c	Redimension/C $wv_c	Wave/c wwv_c=$wv_c;	wwv_c=cmplx(wwv_re,wwv_im)End//Macro LoadMatrixBinaryWave(dest,path,file,sizex,sizey,skip,format1,format2)	String path,file,dest	Variable sizex=640,sizey=480,format1=16,format2=4,skip=0//	Prompt format1,"data type",popup,"single;double;32bit_singed;16bit_signed;8bit_signed;32bit_unsinged;16bit_unsigned;8bit_unsigned"	PauseUpdate; Silent 1		Variable ref		if (strlen(file)<=0)		Open /D/R/T="????"/P=$path ref		file= S_fileName	endif	print file	Variable fType=16,wType=4	GBLoadWave/O/Q/P=$path/S=(skip)/T={fType,wType}/W=(sizey)/U=(sizex) file	if (strlen(dest)<1)		dest="M"+wname(fileName)	endif	WavesToMatrix("wave",dest,0,sizey,1)End MacroMacro MultiLoadMatrixWave(thePath,scaleflag,startflag,transpose)	String thePath="_New Path_"	Variable scaleflag = 1,transpose=1,startflag=1	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"	Prompt scaleflag,"read scaling delta x and y ?",popup,"yes;no"	Prompt startflag,"read x0 and y0 values ?",popup,"yes;no"	Prompt transpose,"Transpose x and y ?",popup,"yes;no"	String ftype="TEXT"		Silent 1		String fileName	Variable fileIndex=0, gotFile		if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?		NewPath/O data			// this brings up dialog and creates or overwrites path		thePath = "data"	endif		do		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path		gotFile = CmpStr(fileName, "")		if (gotFile)			FLoadMatrixWave("",filename,thePath,scaleflag,startflag,transpose)		endif		fileIndex += 1	while (gotFile)									// until TextFile runs out of filesEnd MacroMacro MultiLoadMatrixWave2(thePath,prefix,scaleflag,startflag,transpose)	String prefix,thePath="_New Path_"	Variable scaleflag = 1,transpose=1,startflag=1	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"	prompt prefix,"prefix for file names"	Prompt scaleflag,"read scaling delta x and y ?",popup,"yes;no"	Prompt startflag,"read x0 and y0 values ?",popup,"yes;no"	Prompt transpose,"Transpose x and y ?",popup,"yes;no"	String ftype="TEXT"		Silent 1		String fileName	Variable fileIndex=0, gotFile,prefixmatch		if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?		NewPath/O data			// this brings up dialog and creates or overwrites path		thePath = "data"	endif		do		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path		gotFile = CmpStr(fileName, "")		prefixmatch=strsearch(filename,prefix,0)		if (gotFile && prefixmatch==0)			FLoadMatrixWave("",filename,thePath,scaleflag,startflag,transpose)		endif		fileIndex += 1	while (gotFile)									// until TextFile runs out of filesEnd MacroFunction FLoadColumnDataToMatrix(wvname,filename,pathName,icol,ndata,transpose)	String wvname,filename,pathName	Variable icol,ndata,transpose	Variable ref,deltax,deltay,x0,y0,skips,index,nskip,nrow	String wn,buffer,extstr//	open file dialogue to load data//	extstr = FileTypeStr()	extstr=".dat"	if (strlen(fileName)<=0)//		Open /D/R/P=$pathName/T="sGBWTEXT" ref		Open /D/R/T=(extstr) ref		fileName= S_fileName	endif	print fileName		LoadWave/J/D/O/K=0/V={"\t, "," $",0,0}/N=dummy/L={0,0,0,icol,1}/Q/P=$pathName fileName//	LoadWave/G/D/O/K=0/V={"\t, "," $",0,0}/N=dummy/L={0,0,0,icol,1}/Q/P=$pathName fileName // might be better ?	wn = StringFromList(0,S_waveNames,";")	Duplicate/O $wn,$wvname	if(ndata>1)		nrow=numpnts($wvname)/ndata		Redimension/N=(ndata,nrow) $wvname		if(transpose==1)			MatrixTranspose $wvname		endif	endifEndMacro LoadColumnDataToMatrix(wvname,filename,pathName,icol,ndata,transpose)	String wvname="M",filename,pathName="home"	Variable icol=2,ndata=1,transpose=2	Prompt icol,"Column number to load ?"	Prompt ndata,"number of data in one row"	Prompt transpose,"Transpose x and y ?",popup,"yes;no"	Silent 1; PauseUpDate	FLoadColumnDataToMatrix(wvname,filename,pathName,icol,ndata,transpose)End MacroMacro WavesToMatrix(wvname,matwName,startindex,ncol,skip)// Converto multiple waves into a single matrix wave//	String wvname	String matwName	Variable ncol,startindex,skip=1	Prompt wvname, "Enter String that begin with"//,popup,WaveList("*",";","")	Prompt matwName,"Enter Destination Matrix Wave Name"	Prompt startindex,"starting index"	Prompt ncol,"Number of Waves"		Silent 1; PauseUpDate	FWavesToMatrix(wvname,"",matwName,startindex,ncol,skip)//	Variable nrow//	//	Variable index=0,index1=startindex//	String wn//	//	wn=wvname+num2istr(index1) // underscore removed on 2013/05/28//	nrow = numpnts($wn)//	if(WaveExists($matwName)==0)//		Duplicate $wn,$matwName//	endif//	Redimension /N=(nrow,ncol) $matwName////	do//		wn = wvname +num2str(index1)////		print wn//		if(WaveExists($wn)==0)//			break//		endif//		$matwName[][index] = $wn[p]//		index += 1//		index1+=skip//	while(index<ncol)End MacroFunction FWavesToMatrix(wvname,suffix,matwName,startindex,ncol,skip)// Converto multiple waves into a single matrix wave//	String wvname,suffix	String matwName	Variable ncol,startindex,skip//	Prompt wvname, "Enter String that begin with"//,popup,WaveList("*",";","")//	Prompt matwName,"Enter Destination Matrix Wave Name"//	Prompt startindex,"starting index"//	Prompt ncol,"Number of Waves"	//	Silent 1; PauseUpDate	Variable nrow		Variable index=0,index1=startindex	String wn		wn=wvname+num2istr(index1) // underscore removed on 2013/05/28	nrow = numpnts($wn)	if(WaveExists($matwName)==0)		Duplicate $wn,$matwName	endif	Wave dest=$matwName	Redimension /N=(nrow,ncol) dest	do		wn = wvname +num2str(index1)+suffix		Wave orig=$wn//		print wn		if(WaveExists(orig)==0)			break		endif		dest[][index] = orig[p]		index += 1		index1+=skip	while(index<ncol)End MacroMacro WavesInAGraphToMatrix(graphname,matwname)	String graphname,matwname	Prompt graphname,"Graph Name",popup,WinList("*",";","WIN:1")	prompt matwname,"name of Destination Matrix"	PauseUpdate;Silent 1	String wlist=TraceNameList(graphname,";",1),wn	Variable index=0,index1,nrow,ncol	wn=GetStrFromList(wlist,index,";")	nrow=numpnts($wn)	ncol=ItemsInList(wlist)	if(WaveExists($matwName)==0)		Duplicate $wn,$matwName		Redimension /N=(nrow,ncol) $matwName	endif	index+=1	do		wn=GetStrFromList(wlist,index,";")		if(strlen(wn)==0)			break		endif		$matwName[][index]=$wn[p]		index+=1	while(1)End Macro		Macro MatrixWavePlot(matwname,newplot,axis,xaxis)	String matwname,xaxis="_none_"	Variable newplot=1,axis=1	Prompt matwname,"matrix wave name",popup,WaveLIst("*",";","DIMS:2")	Prompt newplot,"display or append",popup,"display;append"	Prompt axis,"axis",popup,"left;right"	Prompt xaxis,"x-axis",popup,"_none_;"+WaveList("*",";","DIMS:1")	PauseUpdate;Silent 1		MatrixWavePlotFunc(matwname,newplot,axis,xaxis)End MacroFunction MatrixWavePlotFunc(matwname,newplot,axis,xaxis)	String matwname,xaxis	Variable newplot,axis		Variable nplot,i=0	nplot =DimSize($matwname,1)	if(newplot==1)		Display	endif	Wave mwv=$matwname	Do		if(axis==1)			if(CmpStr(xaxis,"_none_")==0)				AppendToGraph mwv[][i]			else				AppendToGraph mwv[][i] vs $xaxis			endif		else			if(CmpStr(xaxis,"_none_")==0)				AppendToGraph/R mwv[][i]			else				AppendToGraph/R mwv[][i] vs $xaxis			endif		endif		i+=1	while(i<nplot)End MacroMacro MatrixToWaves(Mat,index)// Convert the indexed column of a single matrix wave into a wave//	String Mat	Variable index	prompt Mat,"input the desired matrix",popup,"_none_;"+WaveList("*",";","DIMS:2")	Prompt index,"column index"	Silent 1; PauseUpdate	Variable nrs=DimSize($Mat,0),ncs=DimSize($Mat,1)	if(index<ncs)		Make/O/N=(nrs) $(Mat+"_"+num2str(Index))		CopyScales $Mat,$(Mat+"_"+num2str(Index))		$(Mat+"_"+num2str(Index))[] = $Mat[p][Index]	endifEndMacro MatrixAllToWaves(Mat)// Convert a single matrix wave into multiple waves//	String Mat	prompt Mat,"input the desired matrix",popup,"_none_;"+WaveList("*",";","DIMS:2")	Silent 1; PauseUpdate	Variable nrs=DimSize($Mat,0),ncs=DimSize($Mat,1)	Variable lrs=DimOffset($Mat,0),lcs=DimOffset($Mat,1)	Variable Index=0//	print nrs,ncs,lrs,lcs	do		Make/O/N=(nrs) $(Mat+"_"+num2str(Index))		CopyScales $Mat,$(Mat+"_"+num2str(Index))		$(Mat+"_"+num2str(Index))[] = $Mat[p][Index]		Index += 1	while (Index < ncs)End// for old versions that does not support "Display w[][i]"Proc PlotMatrix(Mat)	String Mat	Prompt Mat, "choose the matrix",popup,WaveList("*Mat",";","")	Silent 1; PauseUpdate	MatrixAllToWaves(Mat)	String wvname,GraphTitle	GraphTitle = "Graph_of_"+Mat	Variable Index = 1	wvname = Mat+"_0"	Display $wvname as GraphTitle	DoWindow/C $GraphTitle	do		wvname = Mat+"_"+num2str(Index)		if (WaveExists($wvname) == 1)			AppendToGraph $wvname		else			break		endif		Index += 1	while (1)EndMacro PlotMatrixSingleX(Mat,index)	String Mat	Variable index=0	Prompt Mat, "choose the matrix",popup,WaveList("*",";","DIMS:2")	Prompt index,"column number to plot"	Silent 1; PauseUpdate	String wn1,wn2	String GraphTitle	MatrixToWaves(Mat,index)	wn1 = Mat+"_"+num2str(index)	wn2 = Mat+"_x"+num2str(index)	print wn1,wn2	Rename $wn1,$wn2	GraphTitle = "Graph_of_"+Mat	Display $wn2EndMacro PlotMatrixSingleY(Mat,index)	String Mat	Variable index=0	Prompt Mat, "choose the matrix",popup,WaveList("*",";","DIMS:2")	Prompt index,"column number to plot"	Silent 1; PauseUpdate		String wvname,GraphTitle,wn1,wn2	MatrixTranspose $Mat	MatrixToWaves(Mat,index)	MatrixTranspose $Mat	wn1 = Mat+"_"+num2str(index)	wn2 = Mat+"_y"+num2str(index)	Rename $wn1,$wn2	GraphTitle = "Graph_of_"+Mat	Display $wn2EndMacro NormalizeMatXY(Mat,xy)	String Mat	Variable xy=1	Prompt Mat "Input matrix",popup,WaveList("*",";","DIMS:2")	Prompt xy,"x or y",popup,"x;y"	Silent 1;PauseUpdate	String cmd,Mat2		cmd="WaveStats/Q temp_wave;temp_wave/=V_max;"	if(xy==1)		Mat2=Mat+"_xnrm"		XYProc(Mat,Mat2,cmd,"x",0)	else		Mat2=Mat+"_ynrm"		XYProc(Mat,Mat2,cmd,"y",0)	endifEndMacro SmoothMat(Mat,xy)	String Mat	Variable xy=1	Prompt Mat "Input matrix",popup,WaveList("*",";","DIMS:2")	Prompt xy,"x or y",popup,"x;y"	Silent 1;PauseUpdate		String Mat2,cmd="Smooth 1, "	if(xy==1)		Mat2=Mat+"_xsm"		XYProc(Mat,Mat2,cmd,"x",1)	else		Mat2=Mat+"_ysm"		XYProc(Mat,Mat2,cmd,"y",1)	endifEndMacro DiffXMat(Mat)	String Mat	prompt Mat,"input the desired matrix",popup,WaveList("*",";","DIMS:2")	Silent 1;PauseUpdate		String MatDiff = Mat +"_xdiff",cmd="Differentiate"	XYProc(Mat,MatDiff,cmd,"x",1)End MacroMacro DiffYMat(Mat)	String Mat	prompt Mat,"Input the desired matrix",popup,WaveList("*",";","DIMS:2")	Silent 1;PauseUpdate		String MatDiff = Mat +"_ydiff",cmd="Differentiate"	XYProc(Mat,MatDiff,cmd,"y",1)End MacroProc XYProc(wvorig,wvdest,cmd,xy,oprflag)	String wvorig,wvdest,cmd,xy	Variable oprflag // if oprflag=1, add wavename at the end of "cmd"	Silent 1;PauseUpdate		Variable nrs,ncs,Index=0	String cmd0//	print wvorig,wvdest	if(strlen(wvdest)==0)		$wvdest=$wvorig	else		Duplicate/O $wvorig,$wvdest	endif	if(stringmatch(LowerStr(xy), "y"))		MatrixTranspose $wvdest	endif	nrs=DimSize($wvdest,0)	ncs=DimSize($wvdest,1)	Make/O/N=(nrs) temp_wave	do		CopyScales $wvdest,temp_wave		temp_wave[] = $wvdest[p][Index]		if(oprflag==1)			cmd0=cmd+" temp_wave"		else			cmd0=cmd		endif//		print cmd//		print cmd0		Execute cmd0		$wvdest[][Index] = temp_wave[p]		Index += 1	while (Index < ncs)	KillWaves temp_wave		if(stringmatch(LowerStr(xy), "y"))		MatrixTranspose $wvdest	endifEndFunction/D AreaAllMatrix(MMat)	Wave MMat//	prompt MMat,"input the desired matrix",popup,WaveList("*",";","DIMS:2")		Silent 1;PauseUpdate	Variable nrs=DimSize(MMat,0),ncs=DimSize(MMat,1),Index=0	Variable/D res=0	Make/O/N=(nrs) temp_wave	do		CopyScales MMat,temp_wave		temp_wave[] = MMat[p][Index]		res +=area(temp_wave,-Inf,Inf)		Index += 1	while (Index < ncs)//	print "results = ",res*DimDelta($MMat,1)	KillWaves temp_wave	return res*DimDelta(MMat,1)End FunctionFunction MakeMeshDataFunc(orig0,dest0)	String orig0,dest0	Variable n,i	Wave orig=$orig0	n=DimSize(orig,0)	Make/N=(n+1)/D/O $dest0	Wave dest=$dest0	dest[0]=orig[0]	i=1	do		dest[i]=(orig[i-1]+orig[i])/2		i+=1	while(i<n)	dest[n]=orig[n-1]EndMacro MakeMeshDataForNonUnifMesh(orig,dest)	String orig,dest	Prompt orig,"original wave for nonuniform mesh"	Prompt dest,"Destination wave for nonuniform mesh"	PauseUpdate;Silent 1	MakeMeshDataFunc(orig,dest)EndMacro IntegrateWaveX(wvname,dest,xstart,xend,xwv)	String wvname,dest,xwv	Variable xstart,xend	Prompt wvname,"wave name",popup,WaveLIst("*",";","DIMS:2")	Prompt dest,"destination wave name"	Prompt xstart,"start"	Prompt xend,"end"	Prompt xwv,"x wave name"	PauseUpdate;Silent 1		Variable nx,ny,i	String temp="t_"+dest	nx=DimSize($wvname,0)	ny=DimSize($wvname,1)	Duplicate/O $wvname,$temp	Duplicate/O $wvname,$dest	Redimension/N=(nx) $temp	MatrixTranspose $dest	Redimension/N=(ny) $dest	i=0	do		$temp=$wvname[p][i]		if(xstart==0&&xend==0)			if(Exists(xwv))				$dest[i]=areaXY($xwv,$temp)			else				$dest[i]=area($temp)			endif		else			if(Exists(xwv))				$dest[i]=areaXY($xwv,$temp,xstart,xend)			else				$dest[i]=area($temp,xstart,xend)			endif		Endif		i+=1	while(i<ny)	KillWaves $temp//	$dest = area($wvname,xstart,xend)EndMacro IntegrateWaveY(wvname,dest,xstart,xend,xwv)	String wvname,dest,xwv	Variable xstart,xend	Prompt wvname,"wave name",popup,WaveLIst("*",";","DIMS:2")	Prompt dest,"destination wave name"	Prompt xstart,"start"	Prompt xend,"end"	Prompt xwv,"y wave name"	PauseUpdate;Silent 1		Variable nx,ny,i	String temp="t_"+dest	nx=DimSize($wvname,0)	ny=DimSize($wvname,1)	Duplicate/O $wvname,$temp	Duplicate/O $wvname,$dest	MatrixTranspose $temp	Redimension/N=(ny) $temp	Redimension/N=(nx) $dest	i=0	do		$temp=$wvname[i][p]		if(xstart==0&&xend==0)			if(Exists(xwv))				$dest[i]=areaXY($xwv,$temp)			else				$dest[i]=area($temp)			endif		else			if(Exists(xwv))				$dest[i]=areaXY($xwv,$temp,xstart,xend)			else				$dest[i]=area($temp,xstart,xend)			endif		Endif		i+=1	while(i<nx)	KillWaves $temp//	$dest = area($wvname,xstart,xend)EndFunction FMatrixDivX(orig,wv,dest)	String orig,wv,dest	Wave worig=$orig	Wave wwv=$wv	Variable nx,n0,ny	nx=DimSize(worig,0)	ny=DimSize(worig,1)	n0=DimSize(wwv,0)	if(nx!=n0)		return(0)	endif	Duplicate/O worig, $dest	Wave wdest=$dest	Variable i=0	do		wdest[i][]/=wwv[i]		i+=1	while(i<nx)EndFunction FMatrixDivY(orig,wv,dest)	String orig,wv,dest	Wave worig=$orig	Wave wwv=$wv	Variable nx,n0,ny	nx=DimSize(worig,0)	ny=DimSize(worig,1)	n0=DimSize(wwv,0)	if(ny!=n0)		return(0)	endif	Duplicate/O worig, $dest	Wave wdest=$dest	Variable i=0	do		wdest[][i]/=wwv[i]		i+=1	while(i<ny)EndFunction FKillDummyWaves()        Silent 1;PauseUpdate        Variable index=0        String dummy        do                dummy="dummy"+num2istr(index)                if(waveExists($dummy)==0)                        break                endif                KillWaves $dummy                index+=1        while(1)EndMacro