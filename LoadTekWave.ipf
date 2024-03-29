#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "wname"
#include "TekWFMload_1"
#include "GraphPlot"
#include "DataSetOperations"

// Load wfm data of Tektronix scope file
//
// Based on Igor Mailing list in : 
//X-Sybari-Trust: d819bae0 e86bf6ce 8254a02f 00000129
//From: Mike Cable <cable@xenogen.com>
//To: Igor Mailing List <igor@pica.army.mil>,"'Michael Johas Teener'" <teener@apple.com>
//Subject: RE: Read TEK "wfm" files?
//Date: Wed, 7 Jan 2004 10:32:41 -0800 
//Sender: <igor@pica.army.mil>

// ver 0.01: ??/??/?? first version
// ver 0.1: add LoadTekWave3 based on "TekWFMLoad_1.ipf" taken from IgorExchange
// ver 0.2: add LoadTekDataFile for text load

// read old format

Macro LoadTekWave()
// Loads a wave from a Tektronix 684 scope file.  File is assumed to be a single scope channel saved in the Tektronix internal format.
//  See Igor notebook "documentation" for more info
//	MC 1/98   (modified from original 7/96 version)
	PauseUpdate;Silent 1
	variable FileNum, Nstupid, WFH, temp, icount
	variable vertOffset, vertGain, vertPos, RecLength, horzScalePerPoint,trigPos
	string DataString, TekFileName,wn
	Variable ByteOrder
//	string /g TekWaveName
//open the data file (first get the name)
	Open /D /R /M="Select the Tektronix data file to be opened." FileNum
	if (CmpStr(S_filename,"") == 0)			//null string, user cancelled the open
		Abort
	else
		TekFileName = ParseFilePath(5,S_filename,":",0,0)			//file name is stored here
	endif
	Open /R FileNum as TekFileName
	print "Data loaded from file: ", TekFileName
	
//	DataString = "12345678901234567890"			//fill DataString with number of bytes to read in the next line, 20 is more than I need
	FBinRead FileNum, DataString
	Nstupid = str2num(DataString[7])			//number of bytes in file length byte string - since the length of this byte string can vary,need this to position for more reads
	WFH = 15 + Nstupid
//1st byte of WaveForm Header is immediately after WFH + 1
//vertical position
	FSetPos FileNum, WFH+67 // fp= 86 (Nstupid=4)
	FBinRead  /F=5 FileNum, vertPos			//vertical position, in division numbers
	print "Vertical Position = ", vertPos, " divisions"
//vertical offset
	FSetPos FileNum, WFH+59 // fp =74
	FBinRead  /F=5 FileNum, vertOffset			//vertical offset, in Volts
	print "Vertical Offset = ", vertOffset, " Volts"
//vertical gain
	FSetPos FileNum, WFH+75 // fp=
	FBinRead  /F=5 FileNum, vertGain			//vertical gain in Volts/division
	print "Vertical Gain = ", vertGain, " Volts/division"
//trigger position
	FSetPos FileNum, WFH+87
	FBinRead  /F=2 /U FileNum, trigPos			//trigger position as per cent of record length
	print "Trigger Position = ", trigPos, "% of digitizer record"
//record length
	FSetPos FileNum, 12+Nstupid
	FBinRead  /F=3 /U FileNum, RecLength			//record length +124 byte WFH + 64 bytes of wave preamble and postamble
	RecLength -= 188
//cut down to actual record length in bytes
	RecLength /= 2
//2 bytes per point
	print "Record Length = ",  RecLength, " points"
//horizontal scale per point
	FSetPos FileNum, WFH+49
	FBinRead  /F=5  FileNum, horzScalePerPoint			//in seconds, width of each sample in digitizer record
	print "Time scale = ", 1e9*horzScalePerPoint, " ns/digitizer sample"
//Create and fill the data wave
//	GetName()
	wn=ParseFilePath(3, TekFileName,":",0,0)
	GBLoadWave /Q/O/V/N=name/T={16,2}/S=(172+Nstupid)/W=1/U=(RecLength) TekFileName
	Duplicate /O name0 $wn		//name0 was created
	KillWaves name0
//would have just renamed, but can't handle overwrite of an existing wave
	Close FileNum
//Scale the wave so that time and amplitude are correct
	$wn -= vertPos*25*256		//vertPos in volts, yoffset in digitizer levels
	$wn *= (vertGain/25/256)		//vertGain in volts/div, ymult in volts/dig level
	$wn += vertOffset				//vertical offset, in volts
	temp =  -1*(trigPos/100)*RecLength*1e9*horzScalePerPoint +0.5e9*horzScalePerPoint		//time value of first sample (center of sample)
	SetScale/P x temp,1e9*horzScalePerPoint,"", $wn
//ns, t=0 is trigger point
	Display $wn
	Label left "Signal (V)";DelayUpdate
	Label bottom "Time (ns)"
End

// For new file format

// Loads a wave from a Tektronix 7000 scope file.  File is assumed to be a single scope channel saved in the Tektronix internal format.
//  See Igor notebook "documentation" for more info
//	MC 1/98   (modified from original 7/96 version)

Macro LoadTekWave2(name,TekFileName,path)
	String name,TekFileName
	String path="home"
	Prompt name,"wave name"
	Prompt TekFileName,"file name"
	Prompt path,"path name"
	PauseUpdate;Silent 1
	
	variable FileNum, Nstupid, WFH, temp, icount
	variable vertOffset, vertGain, vertPos, RecLength, horzScalePerPoint,trigPos
	string DataString,wn,extstr
	Variable ByteOrder,bo,numframes,nskip
	Variable expdimsize1,expdimoffset1,expdimscale1,expformat1
	Variable expdimsize2,expdimoffset2,expdimscale2,expformat2
	Variable impdimsize1,impdimoffset1,impdimscale1,impformat1
	Variable precharge,dataoffsetstart,postchargestart,postchargestop

//	string /g TekWaveName
//open the data file (first get the name)
	extstr=".wfm"
	if (strlen(TekFileName)<=0)
		Open /D/R/P=$path/T=(extstr)/M="Select the Tektronix data file to be opened." FileNum
		TekFileName= ParseFilePath(5,S_filename,":",0,0)
	endif
	print "Data loaded from file: ", TekFileName
	Open /R FileNum as TekFileName

	FBinRead/U/F=2 FileNum,ByteOrder // byte order verification, unsigned short
	if(ByteOrder==0xF0F0)
		print "Byte order is PPC."
		bo=2
	else
		if(ByteOrder==0x0F0F)
			print "byte Order is Intel."
			bo=3
		endif
	endif
	
	DataString="12345678"
	FSetPos FileNum,2
	FBinRead FileNum,DataString // version number
	print "Version number : ",DataString

// number of frame
	FsetPos FileNum,72 // number of frames, usigined long
	FBinRead/U/F=3 FileNum, numframes
	numframes +=1
	print "Number of Frames : ",numframes
	
// Explicit dimension 1
	FSetPos FileNum, 166 // dim scale, double
	FBinRead/B=(bo)  /F=5 FileNum, expdimScale1
	FSetPos FileNum, 174 // dim offset, double
	FBinRead/B=(bo)/F=5 FileNum, expdimoffset1
	FSetPos FileNum, 182 // dim size, usigined long
	FBinRead/B=(bo)/U/F=3 FileNum, expdimsize1
	FSetPos FileNum, 238 // format, int
	FBinRead/B=(bo)/F=2 FileNum, expformat1
	
// Explicit dimension 2
	FSetPos FileNum, 322 // dim scale, double
	FBinRead/B=(bo)  /F=5 FileNum, expdimScale2
	FSetPos FileNum, 330 // dim offset, double
	FBinRead/B=(bo)/F=5 FileNum, expdimoffset2
	FSetPos FileNum, 338 // dim size, usigined long
	FBinRead/U/F=3 FileNum, expdimsize2
	FSetPos FileNum, 394 // format, int
	FBinRead/F=2 FileNum, expformat2

// implicit dimension 1
	FSetPos FileNum, 478 // dim scale, double
	FBinRead/B=(bo)  /F=5 FileNum, impdimScale1
	FSetPos FileNum, 486 // dim offset, double
	FBinRead/B=(bo)/F=5 FileNum, impdimoffset1
	FSetPos FileNum, 494 // dim size, usigined long
	FBinRead/B=(bo)/U/F=3 FileNum, impdimsize1
//	FSetPos FileNum 238 // format, int
//	FBinRead/F=2 FileNum, impformat1

	print "Buffer size:", impdimsize1
	print "time division : ", impdimscale1
	print "time offset : ", impdimoffset1
	print "voltage :", expdimscale1
	print "voltage offset : ",expdimoffset1
	print "format",expformat1
	
// wfm curve information
	FsetPos FileNum,800 // precharge start offset, unsinged long
	FBinRead/U/F=3/B=(bo) FileNum,precharge
	FsetPos FileNum,804 // precharge start offset, unsinged long
	FBinRead/U/F=3/B=(bo) FileNum,dataoffsetstart
	FsetPos FileNum,808 // postcharge start offset, unsinged long
	FBinRead/U/F=3/B=(bo) FileNum,postchargestart
	FsetPos FileNum,812 // postcharge stop offset, unsinged long
	FBinRead/U/F=3/B=(bo) FileNum,postchargestop
	print precharge,dataoffsetstart,postchargestart,postchargestop
	
//Create and fill the data wave
//	GetName()
	wn=ParseFilePath(3, TekFileName,":",0,0)
// curve buffer
	nskip=820+24*(numframes-1)+30*(numframes-1)+precharge
//	nskip = dataoffsetstart
	///Y={expdimscale1, expdimoffset2/expdimscale1}
	GBLoadWave /Q/O/V/N=name/T={16,2}/S=(nskip)/W=1/U=(impdimsize1) TekFileName
	Duplicate /O name0 $wn		//name0 was created
	KillWaves name0
//would have just renamed, but can't handle overwrite of an existing wave
	Close FileNum
//Scale the wave so that time and amplitude are correct
	$wn*=expdimscale1
	$wn+=expdimoffset1
	SetScale/P x impdimoffset1,impdimscale1,"sec",$wn
	SetScale y 0,0,"V",$wn

	Display $wn
	Label left "Signal (\\U)";DelayUpdate
	Label bottom "Time (\\U)"
End

Funcion/S formatoptionstr(i)
	Variable i
	String s
	
	switch (i)
	case 0:
		s="/F=1"
		break
	case 1:
		s="/F=2"
		break
	case 2:
		s="/U/F=2"
		break
	case 3:
		s="/U/F=3"
		break
	case 4:
		s="/F=4"
		break
	case 5:
		s="/F=5"
		break
	default:
		s="/F=1"
	endswitch
	return s
end

Macro LoadTekWave3(name,TekFileName,path)
	String name,TekFileName
	String path="home"
	Prompt name,"wave name"
	Prompt TekFileName,"file name"
	Prompt path,"path name"
	PauseUpdate;Silent 1
	FLoadTekWave3(name,TekFileName,path)
End

Function FLoadTekWave3(name,TekFileName,path,TimeStampFlag)
	String name,TekFileName
	String path
	Variable TimeStampFlag

	String FullFilePath, OutName
	String extstr
	Variable FileNum

	extstr=".wfm"
	if (strlen(TekFileName)<=0)
		Open /D/R/P=$path/T=(extstr)/M="Select the Tektronix data file to be opened." FileNum
		TekFileName= ParseFilePath(5,S_filename,":",0,0)
	endif
	
	if(strlen(name)==0)
		OutName=ParseFilePath(3, TekFileName,":",0,0)
//		OutName = wname(TekFileName)
	else
		OutName = name
	endif
	
	PathInfo $path
	FullFilePath = S_path + TekFileName
	LoadTekWfm(FullFilePath, OutName, TimeStampFlag)
End

Macro MultiTekLoad3(thePath,TimeStampFlag)
	String thePath="_New Path_"
	Variable TimeStampFlag
	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Prompt TimeStampFlag,"time stamp flag"
	PauseUpdate; Silent 1
	
	FMultiTekLoad3(thePath,TimeStampFlag)
End


Function FMultiTekLoad3(thePath,TimeStampFlag)
	String thePath
	Variable TimeStampFlag
	
	String FileName,ftype=".wfm",nametmp
	Variable fileIndex,gotfile

	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif
	
	DoWindow /F gGraphPlot					// make sure Graphplot is front window
	if (V_flag == 0)								// Graphplot does not exist?
		Make/N=2/D/O dummywave0
		FGraphPlot("sec","V")									// create it
		DoWindow/C gGraphPlot
	endif

// load wfm file
	do
		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path
		gotFile = CmpStr(fileName, "")
		if (gotFile)
			nametmp=ParseFilePath(3, fileName,":",0,0)
			FLoadTekWave3(nametmp,fileName,thePath,TimeStampFlag)
			Duplicate/O $nametmp,dummywave0
			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName
			DoUpdate	// make sure graph updated before printing
//			if (wantToPrint == 1)
//				cmd="PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1"	// print graph
//				execute cmd
//			endif
//			wdsetnm[filenum]=name
//			filenum +=1
		endif
		fileIndex += 1
	while (gotFile)									// until TextFile runs out of files

//	Redimension/N=(filenum) $dsetnm
//	DSODisplayTable(dsetnm)
//	if(nmschm==0)
//		Edit tmpnm
//	Endif
End

Macro CalculateDelay(wn,threshold,startX,endX)
	String wn
	Variable threshold,startX,endX
	Prompt wn,"wave name",popup,WaveList("*",";","")
	Prompt threshold,"threshold"
	PauseUpdate;Silent 1
	
	print FCalculateDelay(wn,threshold,startX,endX)
End


// find delay between peak and percentheight of the peak
Function FCalculateDelay(wn,threshold,withCursor)
	String wn
	Variable threshold,withCursor
	
	Variable peakx,peakvalue,level,startX_orig
	Variable percentheight = 0.2
	Wave wwn=$wn
	Variable startx,endx,startx0

	// find a peak (negative peak)
	if(withCursor==1)
		startx=hcsr(A)
		startx0=pcsr(A)
		endx=hcsr(B)
		FindAPeak threshold,2,3,$wn (startx,endx)
	else
		startx=0
		FindAPeak threshold,2,3,$wn
	endif
	peakx=V_peakX
	peakValue=wwn[V_peakP]
	print "peak found at ", peakx,peakvalue,V_peakP
	if(withCursor!=1)
		Cursor A,$wn,V_peakX
	endif
	//
	level=peakValue*percentheight
	FindLevel/R=[startx0,V_peakP],$wn,level
//	print peakx-V_levelX
	if(withCursor!=1)
		Cursor B,$wn,V_levelX
	endif
	return(peakx-V_levelX)
End

Macro CalcDelayonGraph(grname,destwv,threshold,withCursor)
	String grname,destwv
	Variable threshold=-0.1,withCursor=1
	Prompt grname,"Graph name",popup,WinList("*", ";","WIN:1")
	Prompt withCursor,"use cursor",popup,"yes;no"
	PauseUpdate; Silent 1
	
	FCalcDelayonGraph(grname,destwv,threshold,withCursor)
End

Function FCalcDelayonGraph(grname,destwv,threshold,withCursor)
	String grname,destwv
	Variable threshold,withCursor

	Variable nwv,index
	Variable startX,endX
	String trname,trnames
	trnames=TraceNameList(grname,";",1)
	nwv = itemsinlist(trnames)
	Make/N=(nwv)/D/O $destwv
	Wave wvdest=$destwv

	do
		trname=NameOfWave(TraceNameToWaveRef(grname,StringFromList(index,trnames,";")))
		wvdest[index]=FCalculateDelay(trname,threshold,withCursor)
		index+=1
	while(index<	nwv)
End

Macro FindLevelBetweenCursor(wn,level)
	String wn
	Variable level=0
	PauseUpdate; Silent 1
	
	Print FFindLevelbetweenCursor(wn,level)
End

Function FFindLevelbetweenCursor(wn,level)
	String wn
	Variable level
	
	Variable startX=xcsr(A),endX=xcsr(B),val
	FindLevel/Q/R=(startX,endX),$wn,level
	val=V_LevelX
	return(val)
End

Macro FindLevelOnGraph(grname,destwv,level)
	String grname,destwv
	Variable level
	Prompt grname,"Graph name",popup,WinList("*", ";","WIN:1")
	PauseUpdate; Silent 1
	
	FFindLevelOnGraph(grname,destwv,level)
End

Function FFindLevelOnGraph(grname,destwv,level)
	String grname,destwv
	Variable level

	Variable nwv,index
	String trname,trnames
	trnames=TraceNameList(grname,";",1)
	nwv = itemsinlist(trnames)
	Make/N=(nwv)/D/O $destwv
	Wave wvdest=$destwv
	do
		trname=NameOfWave(TraceNameToWaveRef(grname,StringFromList(index,trnames,";")))
		wvdest[index]=FFindLevelbetweenCursor(trname,level)
		index+=1
	while(index<	nwv)
End

Macro LoadTekDataFile(wvname,filename,pathname,prefix,ncols)
	String wvname,filename,pathName,prefix
	Variable ncols
	PauseUpdate; Silent 1

	FLoadTekDatFile(wvname,filename,pathname,prefix,ncols)
End

Macro MultiLoadTekDataFile(thePath,nmschm,prefix,ncols,fdso,dsetnm,wantToPrint)
	String thePath="_New Path_",prefix="T",dsetnm="data"
	Variable nmschm=2,ncols=0
	Variable wantToPrint=2,fdso=1
	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Prompt nmschm,"wave naming scheme"
	Prompt prefix,"wavename prefix"
	Prompt ncols,"number of column in each data"
	Prompt fdso,"create Datatset",popup,"yes;yes(per file);no"
	Prompt dsetnm, "prefix for dataset name"
	Prompt wantToPrint, "Do you want to print graphs?", popup, "Yes;No"
	PauseUpdate; Silent 1

	FMultiLoadTekDatFile(thePath,nmschm,prefix,ncols,fdso,dsetnm,wantToPrint)
End

Function  FMultiLoadTekDatFile(thePath,nmschm,prefix,ncols,fdso,dsetnm,wantToPrint)
	String thePath,prefix,dsetnm
	Variable nmschm,ncols
	Variable wantToPrint,fdso
	
	Variable/G g_DSOindex
	Variable/G g_nwv
	if(fdso==1 || fdso==2)
		// create data set
		FDSOinit0(dsetnm)
		DSOCreate0(0,1)
		dsetnm=dsetnm+num2istr(g_DSOindex-1)
		Wave/T wdsetnm=$dsetnm
	endif
	if(nmschm==0)
		Make/T/N=1/O tmpnm
	endif

	String ftype=".dat"
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
		FGraphPlot("sec","amplitude")									// create it
		DoWindow/C gGraphPlot
	endif
	
	Variable wnlength,filenum,i0
	String nametmp,name,name0,cmd
	do
		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path
		gotFile = CmpStr(fileName, "")
		if (gotFile)
//			print fileName,thePath,flag
			nametmp=wname(fileName)
			wnlength=strlen(nametmp)
			if(nmschm==0)
				name=prefix+num2istr(fileIndex)
				print fileName,":",name
			elseif (nmschm <0)
				name=prefix+nametmp
				print fileName, ":",name
			else // conventional naming scheme with
				name=prefix+nametmp[wnlength-nmschm,wnlength-1]
				print fileName
			endif
			wvname=FLoadTekDatFile(name,filename,thePath,"",ncols)
			if(g_nwv>=2)
				if(nmschm==0)
					Redimension/N=(fileIndex+nmschm) tmpnm
					do
						tmpnm[fileIndex+i0]=nametmp+"_"+num2istr(i0)
						i0+=1
					while(i0<nmschm)
				endif
			else // number of wave loadeed=1
				if(nmschm==0)
					Redimension/N=(fileIndex+1) tmpnm
					tmpnm[fileIndex]=nametmp
				endif
			endif
//FReadMCA8000D(fileName,thePath,"",flag,len,timediv)
//FReadMCA8000D(fileName,pathName,wvName,flag,len,timediv)
//			Duplicate/O $wvname,$name0
			//LoadWave/G/P=$thePath/O/N=wave fileName		// load the waves from file
			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName
			DoUpdate		// make sure graph updated before printing
			if (wantToPrint == 1)
				cmd="PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1"	// print graph
			endif
			if(g_nwv>=2)
				i0=0
				do
					wdsetnm[filenum+i0]=name+"_"+num2istr(i0)
					i0+=1
				while(i0<g_nwv)
			else
				wdsetnm[filenum]=name
			endif
			filenum +=g_nwv
		endif
		fileIndex += 1
	while (gotFile)									// until TextFile runs out of files
	
	Redimension/N=(filenum) $dsetnm
	DSODisplayTable(dsetnm)
	if(nmschm==0)
		Edit tmpnm
	Endif
End

Function/S FLoadTekDatFile(wvname,filename,pathname,prefix,ncols)
	String wvname,filename,pathName,prefix
	Variable ncols
	
	Variable ref,t0,dt,skips,len,nwv,npt,nwv2
	NVAR g_nwv
	String buffer,buf2,w0,wvname2
	
	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=".datsGBWTEXT" ref
		fileName= S_fileName
	endif
	print fileName

//	read all the waves first
	skips=1
//	ncols=2
	print filename
	LoadWave/G/D/N=dummywave/L={0,(skips),0,0,ncols}/P=$pathName filename
	if(V_flag==0)
		return ""
	endif
//	nwv=ItemsInList(S_wavenames)
	nwv=V_Flag
	if(ncols==0)
		nwv2=nwv
	else
		nwv2=nwv/ncols
	endif
	
	if (strlen(wvname)<1)
		wvname=prefix+wname(fileName)
	else
		wvname=prefix+wvname
	endif
	
	Variable ind0=0,index=0
	
	Open /R/P=$pathName/T="sGBWTEXT.dat" ref as fileName
	do
		w0=StringFromList(index,S_wavenames,";")
		if(strlen(w0)<=0)
			break;
		endif
		do
			// read scaling information, searching valid scaling data
			FReadLine ref,buffer
			buf2=StringFromList(0,buffer,";")
			sscanf buf2, "t0= %f", t0
			buf2=StringFromList(1,buffer,";")
			sscanf buf2, "dt= %f", dt
			if(dt!=0)
				break;
			endif
		while(1)
		npt=DimSize($w0,0)
		ind0=0
		do
			FreadLine ref,buffer
			ind0+=1
		while(ind0<npt)
		
		SetScale/P x t0,dt,"s",$w0

		wvname2=wvname+"_"+num2str(index)
		Duplicate/O $w0,$wvname2

//		if(V_flag==1)
//			wvname2="M"+wname(fileName)
//		else
//			wvname2="M"+wname(fileName)+"_"+num2str(index)
//		endif
//	else
//			wvname1=wvname
//		if(V_flag==1)
//			wvname2=wvname
//		else
//			wvname2=wvname+"_"+num2str(index)
//		endif
//	endif
	
//	w0 = StringFromList(0,S_waveNames,";")
//	Duplicate/O $w0,$wvname2
		if(ncols==0)
			index+=1
		else
			index+=ncols
		endif
	while(1)
	Close ref
	g_nwv=nwv
	return wvname
End

Function FFindZeroCrossingAfterPeak(wn,threshold,xpos)
	String wn
	Variable threshold,xpos
	
	Variable endx=DimOffset($wn,0)+DimDelta($wn,0)*(DimSize($wn,0)-1)
	FindPeak/M=(threshold)/Q/N/R=(xpos,endx) $wn
	Variable startx=V_PeakLoc,val
	
	FindLevel/Q/R=(startX,endX),$wn,0
	val=V_LevelX
	return(val)
End

Function FFindZeroCrossingonGraph(grname,destwv,threshold,xpos)
	String grname,destwv
	Variable threshold,xpos

	Variable nwv,index
	String trname,trnames
	trnames=TraceNameList(grname,";",1)
	nwv = itemsinlist(trnames)
	Make/N=(nwv)/D/O $destwv
	Wave wvdest=$destwv
	do
		trname=NameOfWave(TraceNameToWaveRef(grname,StringFromList(index,trnames,";")))
		wvdest[index]=FFindZeroCrossingAfterPeak(trname,threshold,xpos)
		index+=1
	while(index<nwv)
End
