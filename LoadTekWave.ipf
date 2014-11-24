#include "wname"// Load wfm data of Tektronix scope file//// Based on Igor Mailing list in : //X-Sybari-Trust: d819bae0 e86bf6ce 8254a02f 00000129//From: Mike Cable <cable@xenogen.com>//To: Igor Mailing List <igor@pica.army.mil>,"'Michael Johas Teener'" <teener@apple.com>//Subject: RE: Read TEK "wfm" files?//Date: Wed, 7 Jan 2004 10:32:41 -0800 //Sender: <igor@pica.army.mil>// read old formatMacro LoadTekWave()// Loads a wave from a Tektronix 684 scope file.  File is assumed to be a single scope channel saved in the Tektronix internal format.//  See Igor notebook "documentation" for more info//	MC 1/98   (modified from original 7/96 version)	PauseUpdate;Silent 1	variable FileNum, Nstupid, WFH, temp, icount	variable vertOffset, vertGain, vertPos, RecLength, horzScalePerPoint,trigPos	string DataString, TekFileName,wn	Variable ByteOrder//	string /g TekWaveName//open the data file (first get the name)	Open /D /R /M="Select the Tektronix data file to be opened." FileNum	if (CmpStr(S_filename,"") == 0)			//null string, user cancelled the open		Abort	else		TekFileName = S_filename			//file name is stored here	endif	Open /R FileNum as TekFileName	print "Data loaded from file: ", TekFileName	//	DataString = "12345678901234567890"			//fill DataString with number of bytes to read in the next line, 20 is more than I need	FBinRead FileNum, DataString	Nstupid = str2num(DataString[7])			//number of bytes in file length byte string - since the length of this byte string can vary,need this to position for more reads	WFH = 15 + Nstupid//1st byte of WaveForm Header is immediately after WFH + 1//vertical position	FSetPos FileNum, WFH+67 // fp= 86 (Nstupid=4)	FBinRead  /F=5 FileNum, vertPos			//vertical position, in division numbers	print "Vertical Position = ", vertPos, " divisions"//vertical offset	FSetPos FileNum, WFH+59 // fp =74	FBinRead  /F=5 FileNum, vertOffset			//vertical offset, in Volts	print "Vertical Offset = ", vertOffset, " Volts"//vertical gain	FSetPos FileNum, WFH+75 // fp=	FBinRead  /F=5 FileNum, vertGain			//vertical gain in Volts/division	print "Vertical Gain = ", vertGain, " Volts/division"//trigger position	FSetPos FileNum, WFH+87	FBinRead  /F=2 /U FileNum, trigPos			//trigger position as per cent of record length	print "Trigger Position = ", trigPos, "% of digitizer record"//record length	FSetPos FileNum, 12+Nstupid	FBinRead  /F=3 /U FileNum, RecLength			//record length +124 byte WFH + 64 bytes of wave preamble and postamble	RecLength -= 188//cut down to actual record length in bytes	RecLength /= 2//2 bytes per point	print "Record Length = ",  RecLength, " points"//horizontal scale per point	FSetPos FileNum, WFH+49	FBinRead  /F=5  FileNum, horzScalePerPoint			//in seconds, width of each sample in digitizer record	print "Time scale = ", 1e9*horzScalePerPoint, " ns/digitizer sample"//Create and fill the data wave//	GetName()	wn=wname(TekFileName)	GBLoadWave /Q/O/V/N=name/T={16,2}/S=(172+Nstupid)/W=1/U=(RecLength) TekFileName	Duplicate /O name0 $wn		//name0 was created	KillWaves name0//would have just renamed, but can't handle overwrite of an existing wave	Close FileNum//Scale the wave so that time and amplitude are correct	$wn -= vertPos*25*256		//vertPos in volts, yoffset in digitizer levels	$wn *= (vertGain/25/256)		//vertGain in volts/div, ymult in volts/dig level	$wn += vertOffset				//vertical offset, in volts	temp =  -1*(trigPos/100)*RecLength*1e9*horzScalePerPoint +0.5e9*horzScalePerPoint		//time value of first sample (center of sample)	SetScale/P x temp,1e9*horzScalePerPoint,"", $wn//ns, t=0 is trigger point	Display $wn	Label left "Signal (V)";DelayUpdate	Label bottom "Time (ns)"End// For new file format// Loads a wave from a Tektronix 7000 scope file.  File is assumed to be a single scope channel saved in the Tektronix internal format.//  See Igor notebook "documentation" for more info//	MC 1/98   (modified from original 7/96 version)Macro LoadTekWave2(name,TekFileName,path)	String name,TekFileName	String path="home"	Prompt name,"wave name"	Prompt TekFileName,"file name"	Prompt path,"path name"	PauseUpdate;Silent 1		variable FileNum, Nstupid, WFH, temp, icount	variable vertOffset, vertGain, vertPos, RecLength, horzScalePerPoint,trigPos	string DataString,wn,extstr	Variable ByteOrder,bo,numframes,nskip	Variable expdimsize1,expdimoffset1,expdimscale1,expformat1	Variable expdimsize2,expdimoffset2,expdimscale2,expformat2	Variable impdimsize1,impdimoffset1,impdimscale1,impformat1	Variable precharge,dataoffsetstart,postchargestart,postchargestop//	string /g TekWaveName//open the data file (first get the name)	extstr=".wfm"	if (strlen(TekFileName)<=0)		Open /D/R/P=$path/T=(extstr)/M="Select the Tektronix data file to be opened." FileNum		TekFileName= S_fileName	endif	print "Data loaded from file: ", TekFileName	Open /R FileNum as TekFileName	FBinRead/U/F=2 FileNum,ByteOrder // byte order verification, unsigned short	if(ByteOrder==0xF0F0)		print "Byte order is PPC."		bo=2	else		if(ByteOrder==0x0F0F)			print "byte Order is Intel."			bo=3		endif	endif		DataString="12345678"	FSetPos FileNum,2	FBinRead FileNum,DataString // version number	print "Version number : ",DataString// number of frame	FsetPos FileNum,72 // number of frames, usigined long	FBinRead/U/F=3 FileNum, numframes	numframes +=1	print "Number of Frames : ",numframes	// Explicit dimension 1	FSetPos FileNum, 166 // dim scale, double	FBinRead/B=(bo)  /F=5 FileNum, expdimScale1	FSetPos FileNum, 174 // dim offset, double	FBinRead/B=(bo)/F=5 FileNum, expdimoffset1	FSetPos FileNum, 182 // dim size, usigined long	FBinRead/B=(bo)/U/F=3 FileNum, expdimsize1	FSetPos FileNum, 238 // format, int	FBinRead/B=(bo)/F=2 FileNum, expformat1	// Explicit dimension 2	FSetPos FileNum, 322 // dim scale, double	FBinRead/B=(bo)  /F=5 FileNum, expdimScale2	FSetPos FileNum, 330 // dim offset, double	FBinRead/B=(bo)/F=5 FileNum, expdimoffset2	FSetPos FileNum, 338 // dim size, usigined long	FBinRead/U/F=3 FileNum, expdimsize2	FSetPos FileNum, 394 // format, int	FBinRead/F=2 FileNum, expformat2// implicit dimension 1	FSetPos FileNum, 478 // dim scale, double	FBinRead/B=(bo)  /F=5 FileNum, impdimScale1	FSetPos FileNum, 486 // dim offset, double	FBinRead/B=(bo)/F=5 FileNum, impdimoffset1	FSetPos FileNum, 494 // dim size, usigined long	FBinRead/B=(bo)/U/F=3 FileNum, impdimsize1//	FSetPos FileNum 238 // format, int//	FBinRead/F=2 FileNum, impformat1	print "Buffer size:", impdimsize1	print "time division : ", impdimscale1	print "time offset : ", impdimoffset1	print "voltage :", expdimscale1	print "voltage offset : ",expdimoffset1	print "format",expformat1	// wfm curve information	FsetPos FileNum,800 // precharge start offset, unsinged long	FBinRead/U/F=3/B=(bo) FileNum,precharge	FsetPos FileNum,804 // precharge start offset, unsinged long	FBinRead/U/F=3/B=(bo) FileNum,dataoffsetstart	FsetPos FileNum,808 // postcharge start offset, unsinged long	FBinRead/U/F=3/B=(bo) FileNum,postchargestart	FsetPos FileNum,812 // postcharge stop offset, unsinged long	FBinRead/U/F=3/B=(bo) FileNum,postchargestop	print precharge,dataoffsetstart,postchargestart,postchargestop	//Create and fill the data wave//	GetName()	wn=wname(TekFileName)// curve buffer	nskip=820+24*(numframes-1)+30*(numframes-1)+precharge//	nskip = dataoffsetstart	///Y={expdimscale1, expdimoffset2/expdimscale1}	GBLoadWave /Q/O/V/N=name/T={16,2}/S=(nskip)/W=1/U=(impdimsize1) TekFileName	Duplicate /O name0 $wn		//name0 was created	KillWaves name0//would have just renamed, but can't handle overwrite of an existing wave	Close FileNum//Scale the wave so that time and amplitude are correct	$wn*=expdimscale1	$wn+=expdimoffset1	SetScale/P x impdimoffset1,impdimscale1,"sec",$wn	SetScale y 0,0,"V",$wn	Display $wn	Label left "Signal (\\U)";DelayUpdate	Label bottom "Time (\\U)"EndFuncion/S formatoptionstr(i)	Variable i	String s	if(i==0)		s="/F=1"	else		if(i==1)			s="/F=2"		else			if(i==2)				s="/U/F=2"			else				if(i==3)					s="/U/F=3"				else					if(i==4)						s="/F=4"					else						if(i==5)							s="/F=5"						endif					endif				endif			endif		endif	endif	return send