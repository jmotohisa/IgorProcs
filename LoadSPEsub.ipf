#pragma rtGlobals=1		// Use modern global access method.// loadSPEsub.ipf// 	collections of subprocedures for load SPE//	05/10/26 ver. 0.1 by J. Motohisa////	revision history//		05/10/26		ver 0.1	first version//		06/01/30		ver 0.1a: bugs in DataByteLength fixed//		08/09/21		ver 0.2a: operation using datafolder //		13/02/18		ver 0.2b: add notes//		16/04/29		ver 0.2c: consider glued spectra//		20/12/02		ver 0.2d: bug fixed in FloadSPEsub which did not work alone#include "AddNoteToWave"#include "MatrixOperations2"Function/D SPEReadBin(ref,pos,datatype)	Variable ref,pos,datatype	Variable/D val		FsetPos ref,pos	switch (datatype)		case 0: //char			FBinRead/B=3/F=1 ref,val		case 1: // short			break			FBinRead/B=3/F=2 ref,val		case 2: // LONG			FBinRead/B=3/F=3 ref,val			break		case 3: // float			FBinRead/B=3/F=4 ref,val			break		case 4: // double			FBinRead/B=3/F=5 ref,val			break		case 5: // BYTE, unsigned char			FBinRead/B=3/F=1/U ref,val			break		case 6: // WORD, unsigned int			FBinRead/B=3/F=2/U ref,val			break		case 7:// DWORD, unsigned long			FBinRead/B=3/F=3/U ref,val			break		default:			val=0	endswitch	return(val)EndFunction/S SPEReadStr(ref,pos,len)	Variable ref,pos,len	String str	str=PadString(" ",len,0)	FSetPos ref,pos	FBinRead ref,str	return(str)EndProc ReadSPEVersion(file)	String file	PauseUpdate; silent 1	FreadSPEversion(file)EndFunction FReadSPEversion(file)	string file	variable ref	string path,versionstr,ftype	path="home"	ftype=fileTypeStr()	if (strlen(file)<=0)		Open /D/R/P=$path/T=(ftype) ref		file= S_fileName		print file	endif	Open /R/P=$path/T=(ftype) ref as file		versionstr=SPEReadStr(ref,688,16)	Close ref	print versionstrEndProc Init_SPELoad()	PauseUpdate;Silent 1;	if(DataFolderExists("root:SPEdata")==0)		NewDataFolder root:SPEdata	endif	SetDataFolder root:SPEData	if(WaveExists($"SPEHeaderData_W")==0)		Make/N=18 SPEHeaderData_W		Make/N=12/T SPEHeaderData_TW		Make/N=(6,10) SPEHeaderData_ROI				SetDimLabel 0,0,'avgexp',SPEHeaderData_W		SetDimLabel 0,1,'exposure',SPEHeaderData_W		SetDimLabel 0,2,'exp_sec',SPEHeaderData_W		SetDimLabel 0,3,'noscan',SPEHeaderData_W		SetDimLabel 0,4,'npoint',SPEHeaderData_W		SetDimLabel 0,5,'datatype',SPEHeaderData_W	SetDimLabel 0,6,'calibpol1',SPEHeaderData_W	SetDimLabel 0,7,'calibpol2',SPEHeaderData_W	SetDimLabel 0,8,'calibpol3',SPEHeaderData_W	SetDimLabel 0,9,'calibpol4',SPEHeaderData_W	SetDimLabel 0,10,'ydim',SPEHeaderData_W	SetDimLabel 0,11,'lexpos',SPEHeaderData_W	SetDimLabel 0,12,'lnoscan',SPEHeaderData_W	SetDimLabel 0,13,'lavgexp',SPEHeaderData_W//	FSetPos ref,672//	FBinRead ref,stripfil		SetDimLabel 0,14,'StoreSync',SPEHeaderData_W	SetDimLabel 0,15,'NumFrames',SPEHeaderData_W	SetDimLabel 0,16,'ROIinfo',SPEHeaderData_W	SetDimLabel 0,17,'n_poly',SPEHeaderData_W			SetDimLabel 0,0,'startx',SPEHeaderData_ROI		SetDimLabel 0,1,'endx',SPEHeaderData_ROI		SetDimLabel 0,2,'groupx',SPEHeaderData_ROI		SetDimLabel 0,3,'starty',SPEHeaderData_ROI		SetDimLabel 0,4,'endy',SPEHeaderData_ROI		SetDimLabel 0,5,'groupy',SPEHeaderData_ROI	EndifEndFunction fdatatype(datatype)	Variable datatype	Variable dtype	if(datatype==0)		dtype= 2	else		if(datatype==1)			dtype= 32		else			if(datatype==2)				dtype= 16			else				if(datatype==3)					dtype= 16+64				endif			endif		endif	endif	return dtypeEnd// returs data byte length from datatype// datatype=0 - floatiing point//			1 - long integer//			2 - integer//			3 - unsigned integerFunction DataByteLength(datatype)	Variable datatype	Variable nbyte	if(datatype==1 || datatype==0)		nbyte=4	else		nbyte=2	endif//	if(datatype==0)//		nbyte=4//		else//		if(datatype==1)//			nbyte=8//		else//			if(datatype==2)//				nbyte=8//			else//				nbyte=4//			endif//		endif//	endif//	nbyte=4	return nbyteendfunction/S fileTypeStr()	string platform=IgorInfo(2),extstr	Variable IgorVersion	IgorVersion = str2num(StringFromList(1,StringFromList(0,IgorInfo(0),";"),":"))		if(cmpstr(platform,"Macintosh")==0)		extstr = ".SPEsGBWTEXT"	else		if(IgorVersion<4.05)			extstr="????"		else			extstr=".SPE"		endif	endif	return extstrEnd// load SPE y data from a given fileFunction FLoadSPEsub(file,path,name,npoint,NumFrames,ydim,datatype)	String file,path,name	Variable npoint,NumFrames,ydim,datatype		Variable skip=4100,dtype	dtype=fdatatype(datatype)	Pathinfo $path//	nbyte=DataByteLength(datatype)// single spectrum	if(NumFrames==1&&ydim==1)		if(V_flag==0)			GBLoadWave/Q/N=dummy/T={(dtype),4}/B/S=(skip)/U=(npoint)/W=1 file		else			GBLoadWave/Q/N=dummy/T={(dtype),4}/B/S=(skip)/U=(npoint)/W=1/P=$path file		endif//		if(strsearch(name,"dummyywave0",0)<0)//			Duplicate/O dummy0,dummyywave0//			DoUpdate		Duplicate/O dummy0,$name//		endif	else//multiple spectrum		if(ydim==1)			print "Loading multiple spectrum : number of frames = ",NumFrames			if(V_flag==0)				GBLoadWave/Q/N=dummy/T={(dtype),4}/B/S=(skip)/U=(npoint)/W=(NumFrames) file			else				GBLoadWave/Q/N=dummy/T={(dtype),4}/B/S=(skip)/U=(npoint)/W=(NumFrames)/P=$path file			endif			FWavesToMatrix("dummy","",name,0,NumFrames,1)// image		else			print "Loading images : image size = (",npoint, " x ", ydim,")"			if(V_flag==0)				GBLoadWave/Q/N=dummy/T={(dtype),4}/B/S=(skip)/U=(npoint)/W=(ydim) file			else				GBLoadWave/Q/N=dummy/T={(dtype),4}/B/S=(skip)/U=(npoint)/W=(ydim)/P=$path file			endif			FWavesToMatrix("dummy","",name,0,ydim,1)		endif	endif	AddStdNoteToWave($name,path,file)End MacroProc LoadSPEsub(file,path,name,npoint,NumFrames,ydim,datatype)	String file,path,name	Variable npoint,NumFrames,ydim,datatype	Prompt file,"File Name"	Prompt path,"Path name"	Prompt name,"wave Name"	Prompt npoint, "numberof data"	Prompt NumFrames, "number of frames"	Prompt ydim,"Y-dimension"	Prompt datatype,"datatype",popup, "FLOATING POINT;LONG INTEGER;INTEGER;UNSIGNED INTEGER"	PauseUpdate; Silent 1		FLoadSPEsub(file,path,name,npoint,NumFrames,ydim,datatype)End Macro// read header of SPE file (version 2.5)Proc SPEReadHeader(file,path)	String file,Path="home"	Prompt file,"file name"	Prompt Path, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"	PauseUpdate; Silent 1		FSPEReadHeaderV25(file,path)EndFunction FSPEReadHeaderV25(file,path)	String file,Path	Variable /D ref,lhead,lblock,npoint,offreg,xmin,xmax,dx,skip,fnsub,fexp	Variable/D datatype,dtype,n_poly,ROIinfo,startx,endx,groupx,starty,endy,groupy	Variable avgexp,exposure,exp_sec,lexpos,noscan,lnoscan,lavgexp	Variable calibpol1,calibpol2,calibpol3,calibpol4,ydim,StoreSync,NumFrames	Variable glue, offset, scalefactor, final	String xname,ftype	String extstr,stripfil//	open file dialogue to load data//	extstr = FileTypeStr()	extstr=".spe"//	print extstr	if (strlen(file)<=0)		Open /D/R/P=$path/T=(extstr) ref		file= S_fileName	endif	print file	if (strlen(file)<=0)		Open /D/R/P=$path/T=(ftype) ref		file= S_fileName	endif	print "Reading SPE file information from : ",file	stripfil=PadString(stripfil,16,0)		Open /R/P=$path/T=(ftype) ref as file	FsetPos ref,2;FBinRead /B=3/F=2 ref,avgexp// short	FsetPos ref,4;FBinRead /B=3/F=2 ref,exposure	FsetPos ref,10;FBinRead/B=3/F=4 ref,exp_sec// float	FsetPos ref,34; FBinRead/B=3/F=2 ref,noscan	FsetPos ref,42;FBinRead /B=3/F=2/U ref,npoint	FSetPos ref, 76; FBinRead/B=3/F=2 ref,glue //glue flag, short	FSetPos ref, 78; FBinRead/B=3/F=4 ref,offset //offset	FSetPos ref, 82; FBinRead/B=3/F=4 ref,final //final wavelength	FSetPos ref, 86; FBinRead/B=3/F=4 ref,minoverlap // minimum overrap	FSetPos ref, 90; FBinRead/B=3/F=4 ref,scalefactor //scalefactor	FsetPos ref,108; FBinRead /B=3/F=2 ref,datatype	FsetPos ref,158;FBinRead/B=3/F=5 ref,calibpol1 // double	FsetPos ref,166;FBinRead/B=3/F=5 ref,calibpol2	FsetPos ref,174;FBinRead/B=3/F=5 ref,calibpol3	FsetPos ref,182;FBinRead/B=3/F=5 ref,calibpol4	FSetPos ref,650;FBinRead/B=3/F=2 ref,SpecGrooves // spectrograph gratin grooves	FSetPos ref,656;FBinRead /B=3/F=2/U ref,ydim	FSetPos ref,660;FBinRead /B=3/F=3 ref,lexpos	FSetPos ref,664;FBinRead /B=3/F=3 ref,lnoscan	FSetPos ref,668;FBinRead /B=3/F=3 ref,lavgexp//	stripfil = FSPEReadStr(ref,672,16)	FSetPos ref,1434;FBinRead /B=3/F=2/U ref,StoreSync	FSetPos ref,1446;FBinRead /B=3/F=2/U ref,NumFrames	FSetPos ref,1510;FBinRead /B=3/F=2 ref,ROIinfo	FSetPos ref,1512+(ROIinfo-1)*12		FBinRead /B=3/F=2/U ref,startx		FBinRead /B=3/F=2/U ref,endx		FBinRead /B=3/F=2/U ref,groupx		FBinRead /B=3/F=2/U ref,starty		FBinRead /B=3/F=2/U ref,endy		FBinRead /B=3/F=2/U ref,groupy	FSetPos ref,3101;FBinRead /B/F=1 ref,n_poly	Close ref		print "datatype=",datatype,"exp_sec=",exp_sec	print "avgexp=",avgexp,"exposure=",exposure,"noscan=",noscan	print "lavgexp=",lavgexp,"lexpos=",lexpos,"lnoscan=",lnoscan	print calibpol1,calibpol2,calibpol3,calibpol4	print "ydim=",ydim,"StoreSync=",StoreSync,"NumFrames=",Numframes	print "npoint=",npoint,"datatype=",datatype,"ROIinfo=",ROIinfo,n_poly	print startx,endx,groupx,starty,endy,groupy//// read coeffcients for linearization//	GBLoadWave/N=$"coef"/T={4,4}/B/U=6/S=3263/W=1/P=$path file//	skip=4100//	print dtype//	GBLoadWave /N=$"dummyywave"/T={(dtype),4}/B/U=(npoint)/S=(skip)/W=1/P=$path file//	SetScale/P x 1,1,"", $dw0End// Function to read header: see FBinRead for detail//   pos: byte offset//   b: byte ordering (for WinSpec, b=3)number of byte://   f: Native binary format of the object (default).//	    1:Signed one-byte integer.//	    2:Signed 16-bit word; two bytes. (int)//	    3:Signed 32-bit word; four bytes. (long)//	    4:32-bit IEEE floating point. (float)//	    5:64-bit IEEE floating point. (double)//   u: unsined ? true=1//   name: name of the variable//Function/S SPEReadHeaderStr(pos,b,f,u,name)	Variable pos,b,f,u	String name	return(SPEReadHeaderStr1(pos,b,f,u,name)+SPEReadHeaderStr2("SPEHeaderData_W",name))End FunctionFunction/S SPEReadHeaderROIstr(pos,b,f,u,name,i)	Variable pos,b,f,u,i	String name		String cmd	cmd="SPEHeaderData_ROI[%'"+name+"']["+num2str(i)+"]="+name+";"	return(SPEReadHeaderStr1(pos,b,f,u,name)+cmd)End FunctionFunction/S SPEReadHeaderStr1(pos,b,f,u,name)	Variable pos,b,f,u	String name	String cmd1,cmd2		if(pos>=0)		sprintf cmd1,"FsetPos ref,%d;",pos	else		cmd1=""	endif	if(u==1)		sprintf cmd2,"FBinRead/B=%d/F=%d/U ref ,%s;",b,f,name	else		sprintf cmd2,"FBinRead/B=%d/F=%d ref ,%s;",b,f,name	endif	return(cmd1+cmd2)EndFunction/S SPEReadHeaderStr2(wname,name)	String wname,name	String cmd	cmd=wname+"[%'" + name+"']="+name + ";"	return(cmd)EndMacro SPEReadHeader_DataFolder(file,path)	String file,Path="home"	Prompt file,"file name"	Prompt Path, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"	PauseUpdate; Silent 1	Variable /D ref,lhead,lblock,npoint,offreg,xmin,xmax,dx,skip,fnsub,fexp	Variable/D datatype,dtype,n_poly,ROIinfo,startx,endx,groupx,starty,endy,groupy	Variable avgexp,exposure,exp_sec,lexpos,noscan,lnoscan,lavgexp	Variable calibpol1,calibpol2,calibpol3,calibpol4,ydim,StoreSync,NumFrames	Variable i	String xname,ftype	String extstr,stripfil,cmmt	String cmd//	open file dialogue to load data//	extstr = FileTypeStr()	extstr=".spe"//	print extstr	if (strlen(file)<=0)		Open /D/R/P=$path/T=(extstr) ref		file= S_fileName	endif	print file	if (strlen(file)<=0)		Open /D/R/P=$path/T=(ftype) ref		file= S_fileName	endif	print "Reading SPE file information from : ",file	stripfil=PadString(" ",16,0)	cmmt=PadString(" ",80,0)	SetDataFolder root:SPEdata		Open /R/P=$path/T=(ftype) ref as file//	Execute SPEReadHeaderStr(0,3,2,1,"dioden")	Execute SPEReadHeaderStr(2,3,2,0,"avgexp")	Execute SPEReadHeaderStr(4,3,2,0,"exposure")//	Execute SPEReadHeaderStr(6,3,2,1,"xDimDet")//	Execute SPEReadHeaderStr(8,3,2,0,"mode")	Execute SPEReadHeaderStr(10,3,4,0,"exp_sec")//	Execute SPEReadHeaderStr(14,3,2,0,"asyavg")//	Execute SPEReadHeaderStr(16,3,2,0,"asyseq")//	Execute SPEReadHeaderStr(18,3,2,1,"yDimDet")	cmmt=PadString(" ",10,0)	FsetPos ref,20	FBinRead ref,cmmt	print cmmt	SPEHeaderData_TW[0]=cmmt//	Execute SPEReadHeaderStr(30,3,2,0,"ehour")//	Execute SPEReadHeaderStr(32,3,2,0,"eminute")	Execute SPEReadHeaderStr(34,3,2,0,"noscan")//	Execute SPEReadHeaderStr(36,3,2,0,"fastacc")//	Execute SPEReadHeaderStr(38,3,2,0,"seconds")//	Execute SPEReadHeaderStr(40,3,2,0,"DetType")	Execute SPEReadHeaderStr(42 ,3,2,1,"npoint") // xdim ?//	Execute SPEReadHeaderStr(44,3,2,0,"stdiode")//	Execute SPEReadHeaderStr(46,3,4,0,"nanox")//	Execute SPEReadHeaderStr(50,3,4,0,"calibdio0")//	Execute SPEReadHeaderStr(54,3,4,0,"calibdio1")//	Execute SPEReadHeaderStr(58,3,4,0,"calibdio2")//	Execute SPEReadHeaderStr(62,3,4,0,"calibdio3")//	Execute SPEReadHeaderStr(66,3,4,0,"calibdio4")//	Execute SPEReadHeaderStr(70,3,4,0,"calibdio5")//	Execute SPEReadHeaderStr(74,3,4,0,"calibdio6")//	Execute SPEReadHeaderStr(78,3,4,0,"calibdio7")//	Execute SPEReadHeaderStr(82,3,4,0,"calibdio8")//	Execute SPEReadHeaderStr(86,3,4,0,"calibdio9")	// fastfile, 90, 16 ,string//	Execute SPEReadHeaderStr(106 ,3,2,0,"asynen")	Execute SPEReadHeaderStr(108 ,3,2,0,"datatype")	Execute SPEReadHeaderStr(158 ,3,5,0,"calibpol1")	Execute SPEReadHeaderStr(166 ,3,5,0,"calibpol2")	Execute SPEReadHeaderStr(174 ,3,5,0,"calibpol3")	Execute SPEReadHeaderStr(182 ,3,5,0,"calibpol4")	i=0	cmmt=PadString(" ",80,0)	do		FSetPos ref,200+i*80		FBinRead ref,cmmt		SPEHeaderData_TW[i+1]=cmmt		i+=1	while(i<5)	Execute SPEReadHeaderStr(656 ,3,2,1,"ydim")	// 658,3,2,0,"scramble"	Execute SPEReadHeaderStr(660 ,3,3,0,"lexpos")	Execute SPEReadHeaderStr(664 ,3,3,0,"lnoscan")	Execute SPEReadHeaderStr(668 ,3,3,0,"lavgexp")	//	FSetPos ref,672	//	FBinRead ref,stripfil	Execute SPEReadHeaderStr(1434 ,3,2,1,"StoreSync")	Execute SPEReadHeaderStr(1446 ,3,2,1,"NumFrames")	// ROI 	Execute SPEReadHeaderStr(1510 ,3,2,0,"ROIinfo")		FSetPos ref,1512+(ROIinfo-1)*12	i=0	do		Execute SPEReadHeaderROIstr(-1,3,2,1,"startx",i)		Execute SPEReadHeaderROIstr(-1,3,2,1,"endx",i)		Execute SPEReadHeaderROIstr(-1,3,2,1,"groupx",i)		Execute SPEReadHeaderROIstr(-1,3,2,1,"starty",i)		Execute SPEReadHeaderROIstr(-1,3,2,1,"endy",i)		Execute SPEReadHeaderROIstr(-1,3,2,1,"groupy",i)		i+=1	while(i<10)	Execute SPEReadHeaderStr(3101 ,1,1,0,"n_poly")	Close ref		print "datatype=",datatype,"exp_sec=",exp_sec	print "avgexp=",avgexp,"exposure=",exposure,"noscan=",noscan	print "lavgexp=",lavgexp,"lexpos=",lexpos,"lnoscan=",lnoscan	print calibpol1,calibpol2,calibpol3,calibpol4	print "ydim=",ydim,"StoreSync=",StoreSync,"NumFrames=",Numframes	print "npoint=",npoint,"datatype=",datatype,"ROIinfo=",ROIinfo,n_poly//	print startx,endx,groupx,starty,endy,groupy//// read coeffcients for linearization	GBLoadWave/Q/N=$"coef"/T={4,4}/B/U=6/S=3263/W=1/P=$path file//	skip=4100//	print dtype//	GBLoadWave /N=$"dummyywave"/T={(dtype),4}/B/U=(npoint)/S=(skip)/W=1/P=$path file//	SetScale/P x 1,1,"", $dw0	SetDataFolder root:End//// for older versions of SPE// read header of SPE file (version 1.6)Macro SPEReadHeaderV16(file,path)	String file,Path="home"	Prompt file,"file name"	Prompt Path, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"	PauseUpdate; Silent 1	Variable /D ref,lhead,lblock,npoint,offreg,xmin,xmax,dx,skip,fnsub,fexp	Variable/D datatype,dtype,n_poly,ROIinfo,startx,endx,groupx,starty,endy,groupy	Variable avgexp,exposure,exp_sec,lexpos,noscan,lnoscan,lavgexp	Variable calibpol1,calibpol2,calibpol3,calibpol4,ydim,StoreSync,NumFrames	Variable glue, offset, scalefactor, final	String xname,ftype	String extstr,stripfil//	open file dialogue to load data//	extstr = FileTypeStr()	extstr=".spe"//	print extstr	if (strlen(file)<=0)		Open /D/R/P=$path/T=(extstr) ref		file= S_fileName	endif	print file	if (strlen(file)<=0)		Open /D/R/P=$path/T=(ftype) ref		file= S_fileName	endif	print "Reading SPE file information from : ",file	stripfil=PadString(stripfil,16,0)		Open /R/P=$path/T=(ftype) ref as file	FsetPos ref,2;FBinRead /B=3/F=2 ref,avgexp// short	FsetPos ref,4;FBinRead /B=3/F=2 ref,exposure	FsetPos ref,10;FBinRead/B=3/F=4 ref,exp_sec// float	FsetPos ref,34; FBinRead/B=3/F=2 ref,noscan	FsetPos ref,42;FBinRead /B=3/F=2/U ref,npoint	FSetPos ref, 76; FBinRead/B=3/F=2 ref,glue //glue flag, short	FSetPos ref, 78; FBinRead/B=3/F=4 ref,offset //offset	FSetPos ref, 82; FBinRead/B=3/F=4 ref,final //final wavelength	FSetPos ref, 86; FBinRead/B=3/F=4 ref,minoverlap // minimum overrap	FSetPos ref, 90; FBinRead/B=3/F=4 ref,scalefactor //scalefactor	FsetPos ref,108; FBinRead /B=3/F=2 ref,datatype	FsetPos ref,158;FBinRead/B=3/F=5 ref,calibpol1 // double	FsetPos ref,166;FBinRead/B=3/F=5 ref,calibpol2	FsetPos ref,174;FBinRead/B=3/F=5 ref,calibpol3	FsetPos ref,182;FBinRead/B=3/F=5 ref,calibpol4	FSetPos ref,650;FBinRead/B=3/F=2 ref,SpecGrooves // spectrograph gratin grooves	FSetPos ref,656;FBinRead /B=3/F=2/U ref,ydim	FSetPos ref,660;FBinRead /B=3/F=3 ref,lexpos	FSetPos ref,664;FBinRead /B=3/F=3 ref,lnoscan	FSetPos ref,668;FBinRead /B=3/F=3 ref,lavgexp//	FSetPos ref,672;FBinRead ref,stripfil	FSetPos ref,1434;FBinRead /B=3/F=2/U ref,StoreSync	FSetPos ref,1446;FBinRead /B=3/F=2/U ref,NumFrames	FSetPos ref,1510;FBinRead /B=3/F=2 ref,ROIinfo	FSetPos ref,1512+(ROIinfo-1)*12		FBinRead /B=3/F=2/U ref,startx		FBinRead /B=3/F=2/U ref,endx		FBinRead /B=3/F=2/U ref,groupx		FBinRead /B=3/F=2/U ref,starty		FBinRead /B=3/F=2/U ref,endy		FBinRead /B=3/F=2/U ref,groupy	FSetPos ref,3101;FBinRead /B/F=1 ref,n_poly	Close ref		print "datatype=",datatype,"exp_sec=",exp_sec	print "avgexp=",avgexp,"exposure=",exposure,"noscan=",noscan	print "lavgexp=",lavgexp,"lexpos=",lexpos,"lnoscan=",lnoscan	print calibpol1,calibpol2,calibpol3,calibpol4	print "ydim=",ydim,"StoreSync=",StoreSync,"NumFrames=",Numframes	print "npoint=",npoint,"datatype=",datatype,"ROIinfo=",ROIinfo,n_poly	print startx,endx,groupx,starty,endy,groupy//// read coeffcients for linearization//	GBLoadWave/N=$"coef"/T={4,4}/B/U=6/S=3263/W=1/P=$path file//	skip=4100//	print dtype//	GBLoadWave /N=$"dummyywave"/T={(dtype),4}/B/U=(npoint)/S=(skip)/W=1/P=$path file//	SetScale/P x 1,1,"", $dw0End