#pragma rtGlobals=1		// Use modern global access method.#include "WLtoEne3"// loadSPEdata2.ipf//	Macro to load SPE data file (version 1.7)  (SPE file with extention of "SPE")//	04/04/24 ver. 0.2 by J. Motohisa////	revision history//		?/?/?		ver 0.1	first version (named as loadSPEdata.ipf)//		04/04/24	ver 0.2	modified to comply with DataSetOperations//			(renamed as loadSPEdata2.ipf)//		04/08/21	ver 0.21 more modification for DataSetOperations//		04/10/03	ver 0.211 procedure for loading general spectrum is moved to new file//		05/10/26- ver 0.3 modified for general data load//		09/06/28- ver 0.31: naming scheme modified if nmschm=0, wavelength information is stored in image load//		10/09/29- ver 0.31.1: MultiLoadSPEComments added//		12/02/11- ver 0.31.2: macro WLtoEne3 included, display file name and wave name//		12/12/27- ver 0.33.3: function PasteColdPixels added//		13/06/14- ver 0.33.4: modified because of the change of DataSetOperations.ipf// To Do: make module to read and store header information (which should be put into LoadSPEsub)//#include <Strings as Lists>#include "wname"#include "LoadSPEsub"#include "GraphPlot"#include "JMGraphStyles"#include "DataSetOperations"// load single spectrum from a fileMacro SPEload2(name,file,path,expnml,nmschm,which)	String name,file	String path="home",which="W"	Variable expnml=1,nmschm=2	Prompt name,"wave name"	Prompt file,"file name"	Prompt path,"path name"	Prompt expnml,"normalize with exptime and accumulation?",popup,"yes;no"	Prompt nmschm,"wave naming scheme (0 for long name)"	Prompt which,"prefix"	PauseUpdate; Silent 1		Variable /D ref,npoint,datatype,n_poly,dtype,skip,xmin,xmax	Variable ROIinfo,startx,endx,groupx,starty,endy,groupy,exp_sec	Variable ydim,NumFrames,lavgexp	String xname,extstr//	variable IgorVersion	Variable wnlength	Variable SpecCenterWlNm // spectrometer central wavelength	String tmpname,tmpname2//	open file dialogue to load data//	extstr = FileTypeStr()	extstr=".spe"//	print extstr	if (strlen(file)<=0)		Open /D/R/P=$path/T=(extstr) ref		file= S_fileName	endif//	print file	// read data header	Open /R/P=$path/T=(extstr) ref as file	FsetPos ref,10	FBinRead/B=3/F=4 ref,exp_sec	FsetPos ref,42	FBinRead /B=3/F=2/U ref,npoint	FsetPos ref,72	FBinRead/B=3/F=4 ref,SpecCenterWlNm	FsetPos ref,108	FBinRead /B=3/F=2 ref,datatype	FSetPos ref,656	FBinRead /B=3/F=2/U ref,ydim	FSetPos ref,668	FBinRead /B=3/F=3 ref,lavgexp	FSetPos ref,1446	FBinRead /B=3/F=3/U ref,NumFrames	FsetPos ref,1510	FBinRead/B=3/F=2 ref,ROIinfo	if(ROIinfo==0)		ROIinfor=1	endif	FSetPos ref,1512+(ROIinfo-1)*12	FBinRead /B=3/F=2/U ref,startx	FBinRead /B=3/F=2/U ref,endx	FBinRead /B=3/F=2/U ref,groupx	FBinRead /B=3/F=2/U ref,starty	FBinRead /B=3/F=2/U ref,endy	FBinRead /B=3/F=2/U ref,groupy	FSetPos ref,3101	FBinRead /B/F=1 ref,n_poly	Close ref//	print exp_sec,npoint,datatype,n_poly//	print ROIinfo,startx,endx,groupx,starty,endy,groupy//	dtype=fdatatype(datatype)//	print datatype,dtype,exp_time	// load calibration data	GBLoadWave/Q/N=$"coef"/T={4,4}/B/U=6/S=3263/W=1/P=$path file//	print SpecCenterWlNm// load spectrum//	skip=4100//	dtype=fdatatype(datatype)//	GBLoadWave /N=$"dummyywave"/T={(dtype),4}/B/U=(npoint)/S=(skip)/W=1/P=$path file//	print file,path,npoint,NumFrames,ydim,datatype,exp_sec,lavgexp	LoadSPEsub(file,path,"dummyywave0",npoint,NumFrames,ydim,datatype)	// name waves: case for single spectrum	if(NumFrames==1 && ydim==1)		LoadSPE2_single(name,file,expnml,nmschm,which,startx,exp_sec,lavgexp)	endif// name waves: case for Multiple spectrum	if(NumFrames>1 && ydim==1)		LoadSPE2_multiple(name,file,expnml,nmschm,which,startx,exp_sec,lavgexp,NumFrames)	endif// name waves: case for image	if(NumFrames==1 && ydim>1)		LoadSPE2_img(name,expnml,startx,exp_sec,lavgexp)	endifEndMacro MultiSPELoad(thePath, expnml,nmschm,which,dsetnm,wantToPrint,flag)	String thePath="_New Path_",which="W",dsetnm="data"	Variable expnml=1,nmschm=2,wantToPrint=2	Variable flag=1	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"	Prompt expnml,"normalize with exptime ?",popup,"yes;no"	Prompt nmschm,"wave naming scheme"	Prompt which,"wave prefix"	Prompt dsetnm, "prefix for dataset name"	Prompt wantToPrint, "Do you want to print graphs?", popup, "Yes;No"	Prompt flag,"swap wavelength ?",popup,"no;yes"	PauseUpdate;Silent 1		String fileName,ftype	Variable fileIndex=0, gotFile	String name,nametmp	Variable wnlength,filenum=0// create data set	InitDataSetOperations(dsetnm)	DSOCreate0(0,1)	dsetnm=dsetnm+num2istr(g_DSOindex-1)	if(nmschm==0)		Make/T/N=1/O tmpnm	endif	//	Make/N=1/T/O ExpDate; Make/N=2000/D/O Expostime; //	ftype=FileTypeStr()	ftype=".spe"	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?		NewPath/O data			// this brings up dialog and creates or overwrites path		thePath = "data"	endif		DoWindow /F Graphplotxy							// make sure Graphplot is front window	if (V_flag == 0)								// Graphplot does not exist?		Make/N=2/D/O dummyxwave0		Make/N=2/D/O dummyywave0		Graphplotxy()									// create it	endif// load spectrum	do		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path		gotFile = CmpStr(fileName, "")		if (gotFile)//			SPEload2("",fileName,thePath,expnml,0)	// load with old wave naming scheme			nametmp=wname(fileName)			wnlength=strlen(nametmp)			if(nmschm==0)				Redimension/N=(fileIndex+1) tmpnm				tmpnm[fileIndex]=nametmp				name=which+num2istr(fileIndex)				print fileName,":",name			else				name=which+nametmp[wnlength-nmschm,wnlength-1]				print fileNameS			endif			SPEload2(name,fileName,thePath,expnml,nmschm,which)			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName			DoUpdate	// make sure graph updated before printing			if (wantToPrint == 1)				PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1	// print graph			endif			$dsetnm(filenum)=name			filenum +=1		endif		fileIndex += 1	while (gotFile)									// until TextFile runs out of files	Redimension/N=(filenum) $dsetnm	DSODisplayTable(dsetnm)	if(nmschm==0)		Edit tmpnm	EndifEndMacro// name waves: procedure for single spectrumProc LoadSPE2_single(name,file,expnml,nmschm,which,startx,exp_sec,lavgexp)	String name,file,which="W"	Variable startx,exp_sec=1,lavgexp=1	Variable expnml=1,nmschm=2	Prompt name,"wave name"	Prompt file,"file name"	Prompt expnml,"normalize with exptime ?",popup,"yes;no"	Prompt nmschm,"wave naming scheme"	Prompt which,"prefix"	Prompt startx,"starting x"	Prompt exp_sec,"exposure time"	Prompt lavgexp,"accumulations"	PauseUpdate;Silent 1		Variable xmin,xmax,wnlength	String tmpname,tmpname2,xname		Duplicate/O dummyywave0,dummyxwave0	SetScale/P x startx,1,"", dummyxwave0	dummyxwave0=poly(coef0, x)	Wavestats/Q dummyxwave0	xmin=V_min	xmax=V_max	SetScale/I x xmin,xmax,"",dummyywave0	if(expnml==1)		dummyywave0/=(exp_sec*lavgexp)	endif// Duplicate with a specified name	if (strlen(name)<1)		tmpname=wname(file)		if(nmschm==0) // conventional naming scheme			name="W"+tmpname			xname="L"+tmpname		else // simplified naming schme (use only last "nmchm"-digits)			wnlength=strlen(tmpname)			tmpname2=tmpname[wnlength-nmschm,wnlength-1]			xname=which+tmpname+"_0"			name=which+tmpname+"_1"		endif	else		tmpname=name		xname=tmpname+"_0"		name=tmpname+"_1"	endif	duplicate /O dummyywave0,$name	duplicate /O dummyxwave0,$xnameEnd// name waves: procedure for single spectrumProc LoadSPE2_multiple(name,file,expnml,nmschm,which,startx,exp_sec,lavgexp,NumFrames)	String name,file,which="W"	Variable startx,exp_sec=1,lavgexp=1,NumFrames	Variable expnml=1,nmschm=2	Prompt name,"wave name"	Prompt file,"file name"	Prompt expnml,"normalize with exptime ?",popup,"yes;no"	Prompt nmschm,"wave naming scheme"	Prompt which,"prefix"	Prompt startx,"starting x"	Prompt exp_sec,"exposure time"	Prompt lavgexp,"accumulations"	Prompt NumFrames, "number of frames"	PauseUpdate;Silent 1		Variable xmin,xmax,wnlength,npoint	String tmpname,tmpname2,xname		Duplicate/O dummyywave0,dummyxwave0	SetScale/P x startx,1,"", dummyxwave0	dummyxwave0=poly(coef0, x)	Wavestats/Q dummyxwave0	xmin=V_min	xmax=V_max	SetScale/I x xmin,xmax,"",dummyywave0	if(expnml==1)		dummyywave0/=(exp_sec*lavgexp)	endif// Duplicate with a specified name	if (strlen(name)<1)		tmpname=wname(file)		if(nmschm==0) // conventional naming scheme			name="W"+tmpname			xname="L"+tmpname		else // simplified naming schme (use only last "nmchm"-digits)			wnlength=strlen(tmpname)			tmpname2=tmpname[wnlength-nmschm,wnlength-1]			xname=which+tmpname+"_0"			name=which+tmpname+"_1"		endif	else		tmpname=name		xname=tmpname+"_0"		name=tmpname+"_1"	endif	duplicate /O dummyywave0,$name	duplicate /O dummyxwave0,$xname	npoint=DimSize($xname,0)	Redimension/N=(npoint) $xnameEnd// procedure for imageProc LoadSPE2_img(name,expnml,startx,exp_sec,lavgexp)	String name	Variable exp_sec,lavgexp=1	Variable expnml=1,startx	Prompt name,"wave name"	Prompt expnml,"normalize with exptime ?",popup,"yes;no"	Prompt startx,"starting x"	Prompt exp_sec,"exposure time"	Prompt lavgexp,"accumulation"	PauseUpdate;Silent 1	//	Variable xmin,xmax,wnlength//	String tmpname,tmpname2,xname	Variable nmschm,wnlength	String tmpname,xname,tmpname2,which	Variable xmin,xmax,npoint//	Duplicate/O dummyywave0,dummyxwave0// Duplicate with a specified name//	Redimension dymmyxwave0//	SetScale/P x startx,1,"", dummyxwave0//	dummyxwave0=poly(coef0, x)//	Wavestats/Q dummyxwave0//	xmin=V_min//	xmax=V_max//	SetScale/I x xmin,xmax,"",dummyywave0//	nmschm=0	Duplicate/O dummyywave0,dummyxwave0	SetScale/P x startx,1,"", dummyxwave0	dummyxwave0=poly(coef0, x)	Wavestats/Q dummyxwave0	xmin=V_min	xmax=V_max	SetScale/I x xmin,xmax,"",dummyywave0	nmschm=0	if (strlen(name)<1)		tmpname=wname(file)		if(nmschm==0) // conventional naming scheme			name="W"+tmpname			xname="L"+tmpname		else // simplified naming schme (use only last "nmchm"-digits)			wnlength=strlen(tmpname)			tmpname2=tmpname[wnlength-nmschm,wnlength-1]			xname=which+tmpname+"_0"			name=which+tmpname+"_1"		endif	else		tmpname=name		xname=tmpname+"_0"		name=tmpname+"_1"	endif	if(expnml==1)		dummyywave0/=(exp_sec*lavgexp)	endif	name="img"+name	xname="img"+xname//	Display;AppendImage $name	duplicate /O dummyywave0,$name	duplicate /O dummyxwave0,$xname	npoint=DimSize($xname,0)	Redimension/N=(npoint) $xname//	Redimension/N=(npoint+1) $xname//	$xname[npoint]=$xname[npoint-1]EndMacro MultiLoadSPEComments(thePath)	String thePath="_New Path_"	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"	PauseUpdate;Silent 1		String fileName,ftype	Variable fileIndex=0, filenum=0,i,gotFile,ref	String nametmp,cmmt// create data set	Make/O/T/N=(1,6) CommentsWave	//	Make/N=1/T/O ExpDate; Make/N=2000/D/O Expostime; //	ftype=FileTypeStr()	ftype=".spe"	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?		NewPath/O data			// this brings up dialog and creates or overwrites path		thePath = "data"	endif	// load SPE comment	do		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path		gotFile = CmpStr(fileName, "")		if (gotFile)			nametmp=wname(fileName)			Redimension/N=(filenum+1,6) CommentsWave			CommentsWave[filenum][0]=nametmp			Open /R/P=$thePath/T=(ftype) ref as fileName			i=0			cmmt=PadString(cmmt,80,0)			do				FSetPos ref,200+i*80				FBinRead ref,cmmt				CommentsWave[filenum][i+1]=cmmt				i+=1			while(i<5)			Close ref			filenum +=1		endif		fileIndex += 1	while (gotFile)									// until TextFile runs out of files	Redimension/N=(filenum,6) CommentsWave	Edit CommentsWaveEndMacro// In some CCD, there seems "cold" pixels (depending on the exposure conditions)// To get rid of cold pixels, pixel value is replace with an avaraged value of adjacent pixcelsFunction PasteColdPixels1(wvname)	String wvname		Variable index	Wave wv=$wvname	if(WaveDims(wv)==1)		index=649		wv[index]=(wv[index+1]+wv[index-1])/2		index=1070		wv[index]=(wv[index+1]+wv[index-1])/2	else		if(WaveDims(wv)==2)			index=649			wv[index][]=(wv[index+1][q]+wv[index-1][q])/2			index=1070			wv[index][]=(wv[index+1][q]+wv[index-1][q])/2		endif	endifEnd 