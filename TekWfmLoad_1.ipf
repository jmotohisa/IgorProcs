#pragma rtGlobals=1		// Use modern global access method.

//  Developed by Richard Sandstrom, Cymer
//  An attempt at a fairly universal reader for the various Tektronix oscilloscope  waveform file formats. Will load single and multi-frame waveforms.
//  Imports file extensions .wfm and .isf, Tek file types LLWFM, WFM#001 to #003 (.wfm files) and WFMPRE (.isf).
//  Does not support  pixel map types. 

//  v 1.02  Fixed bug in loading WFM#003 type waveforms  1/2014
//	v 1.01  Cleaned up path names for Windows/MacIntosh compatibility and fixed bugs in LoadFourWaveforms  12/2013
//  Initial release 1.0  12/2013



//  Simple shell program for loading a single waveform, calling the main  LoadTekWfm function.

Macro LoadTekWaveform()
Variable/G  Displayflag,OWFlag=1,TimeStampFlag,FrameIndex,N_Frames
String FullFilePath
String/G OutName
Variable Refnum
//  Get file name and refnumber
Open/R/D/F= "Tek WFM or ISF file:.wfm,.isf;" 	Refnum			//  Retrieve the full path to the desired file with .wfm or .isf  extension; file not opened
FullFilePath = ParseFilePath(5,S_filename,":",0,0)			//  Convert to Macintosh path convention
Outname = ParseFilePath(3, FullFilePath,":",0,0)				// Retrieve file name minus extension
Outname = CleanupName(Outname, 1 )							//  Enforce liberal naming rules
GetNewName()													//  Give opportunity to change name, ask about plotting.  Return name via global.
If(CheckName(OutName, 1 )!= 0)								//  name already exists
	Asktooverwrite()											// Set overwite flag.  If the answer is no, the macro will skip the load.
EndIf
If(OWFlag == 1)
	LoadTekWfm(FullFilePath, OutName, TimeStampFlag)		// load waveform
// Plot results
	If(DisplayFlag == 1)										// New graph
		Display/W=(235,149,1074,696) $OutName
		ModifyGraph grid=1
		ModifyGraph tick=2
		ModifyGraph mirror=1
		ModifyGraph nticks(left)=15,nticks(bottom)=10
		If(N_Frames >1)										//  This is fast-frame data, add frame control
			AddFrameControl()
		EndIf
	EndIf
	If(DisplayFlag == 2)
		Appendtograph $OutName
	EndIf
EndIf
end

Macro AddFrameControl()
	ControlBar 50
	SetVariable setvar0,pos={369,24},size={126,22},proc=SetVarProc_FrameControl,title="Frame #"
	SetVariable setvar0,fSize=14,value= FrameIndex
End

//  LoadFourWaveforms()  Loads up to 4 waveforms and renames them according to channel number.  Some scopes will save all active channel waveforms in a single save call,
//   automatically generating names of the form  <Name>_CH1, <Name>_CH2, etc., where <Name> is typically a time/date code.  This macro allows
//  user-selected names to be substituted for CH1, CH2, etc. for more readability  It also reverses the order to <New name for channel>_<Name>
//  Select a representative file <Name>_CHx to load,  and the other three files will be loaded and renamed (if they exist).
//  If "Scale and deskew" is selected, a second dialog appears that allows scale factors and time skews to be input.  The waveforms are multiplied by the scale factors,
//  and the time skews are applied to the x-scaling of the waves to correct for interchannel delays.  A positive time skew will shift the waveform to the right.

Macro LoadFourWaveforms(CH1Name,CH2Name,CH3Name,CH4Name,Flag,DispFlag) 
String/G LastCh1Name,LastCh2Name,LastCh3Name,LastCH4Name
Variable/G LastFlag,LastDispFlag
String CH1Name = LastCh1Name
String CH2Name = LastCh2Name
String CH3Name = LastCh3Name
String CH4Name = LastCh4Name
Variable Flag = LastFlag
Variable DispFlag = LastDispFlag
Prompt Ch1Name, "CH1 Name"
Prompt Ch2Name, "CH2 Name"
Prompt Ch3Name, "CH3 Name"
Prompt Ch4Name, "CH4 Name"
Prompt DispFlag, "Plot?",popup,"No;Make New Graph;Add to top graph;Display Only"
Prompt Flag,"Scale and de-skew?",popup,"No;Use last valid;Change"

Variable/G  LastDispFlag = DispFlag
Variable/G LastSF1,LastSF2,LastSF3,LastSF4,LastTS1,LastTS2,LastTS3,LastTS4
If(Flag==3)
	LoadScaleFactors()
EndIf
String Name1,Name2,Name3,Name4,FolderPath,FullFilePath,Name,OutName1,OutName2,OutName3,OutName4,Ext
Variable Refnum
Open/R/D/F= "Tek WFM or ISF file:.wfm,.isf;"  Refnum		//  Retrieve the full path to the desired file with .wfm or .isf  extension; file not opened
FullFilePath = ParseFilePath(5,S_filename,":",0,0)		//  Convert to Macintosh path convention
FolderPath = ParseFilePath(1, FullFilePath,":",1,0)		//  path to folder containing file
Ext = ParseFilePath(4, FullFilePath,":",0,0)				//  Get file extension
Name = ParseFilePath(3, FullFilePath,":",0,0)				// Retrieve file name minus extension
Name = Name[0,strlen(Name)-5]							//  strip off _CHx. This becomes the base name
Name1 = FolderPath+Name+"_CH1."+Ext
Name2 = FolderPath+Name+"_CH2."+Ext
Name3 = FolderPath+Name+"_CH3."+Ext
Name4 = FolderPath+Name+"_CH4."+Ext
If(DispFlag == 4)			//  for display only;  give generic names Disp_CHx
	OutName1 = "Disp_CH1"
	OutName2 = "Disp_CH2"
	OutName3 = "Disp_CH3"
	OutName4 = "Disp_CH4"
Else
	OutName1 = CleanupName(CH1Name+"_"+Name, 1 )		//  Enforce liberal naming rules
	OutName2 = CleanupName(CH2Name+"_"+Name, 1 )
	OutName3 = CleanupName(CH3Name+"_"+Name, 1 )
	OutName4 = CleanupName(CH4Name+"_"+Name, 1 )
EndIf
LoadTekWfm(Name1,OutName1, 0)
LoadTekWfm(Name2,OutName2, 0)
LoadTekWfm(Name3,OutName3, 0)
LoadTekWfm(Name4,OutName4, 0)
String/G LastCH1Name = CH1Name			
String/G LastCH2Name = CH2Name
String/G LastCH3Name = CH3Name
String/G LastCH4Name = CH4Name
Variable NewXO
If(Flag>=2)			//  scale and de-skew
	If(exists(OutName1)==1)
		$OutName1 *= LastSF1
		NewXO = leftx($OutName1)+LastTS1*1e-9
		Setscale/P x,NewXO,deltax($OutName1), $OutName1
	endIf
	If(exists(OutName2)==1)
		$OutName2 *= LastSF2
		NewXO = leftx($OutName2)+LastTS2*1e-9
		Setscale/P x,NewXO,deltax($OutName2), $OutName2
	endIf
	If(exists(OutName3)==1)
		$OutName3 *= LastSF3
		NewXO = leftx($OutName3)+LastTS3*1e-9
		Setscale/P x,NewXO,deltax($OutName3), $OutName3
	endIf
	If(exists(OutName4)==1)
		$OutName4 *= LastSF4
		NewXO = leftx($OutName4)+LastTS4*1e-9
		Setscale/P x,NewXO,deltax($OutName4), $OutName4
	endIf
EndIf
If(DispFlag == 4)
	CheckDisplayed /A Disp_CH1, Disp_CH2,Disp_CH3,Disp_CH4		//  check to see if generic display plot exists
	If(V_flag == 0 )		//  If generic plot not displayed, treat as new graph.  If already displayed, don't do anything.
		DispFlag = 2			
	EndIf
EndIf
If(DispFlag == 2)										// New graph.  We don't know which channels are present.
		Variable Tempflag = 0
		If(exists(OutName1)==1)
			Display/W=(235,149,1074,696) $OutName1
			TempFlag = 1
		Endif
		If(exists(OutName2)==1)
			If(TempFlag == 0)
				Display/W=(235,149,1074,696) $OutName2
				TempFlag = 1
			Else
				Appendtograph $OutName2
			Endif	
		Endif
		If(exists(OutName3)==1)
			If(TempFlag == 0)
				Display/W=(235,149,1074,696) $OutName3
				TempFlag = 1
			Else
				Appendtograph $OutName3
			Endif	
		Endif
		If(exists(OutName4)==1)
			If(TempFlag == 0)
				Display/W=(235,149,1074,696) $OutName4
			Else
				Appendtograph $OutName4
			Endif	
		Endif
		ModifyGraph grid=1
		ModifyGraph tick=2
		ModifyGraph mirror=1
		ModifyGraph nticks(left)=15,nticks(bottom)=10
EndIf
If(DispFlag == 3)		// append to existing
		If(exists(OutName1)==1)
			Appendtograph $OutName1	
		Endif
		If(exists(OutName2)==1)
			Appendtograph $OutName2	
		Endif
		If(exists(OutName3)==1)
			Appendtograph $OutName3	
		Endif
		If(exists(OutName4)==1)
			Appendtograph $OutName4	
		Endif
EndIf
end

//  Dialog to import scale factors and time skews.  
Proc LoadScaleFactors(SF1,SF2,SF3,SF4,TS1,TS2,TS3,TS4)
Variable/G LastSF1,LastSF2,LastSF3,LastSF4,LastTS1,LastTS2,LastTS3,LastTS4
Variable SF1=LastSF1
Variable SF2=LastSF2
Variable SF3=LastSF3
Variable SF4=LastSF4
Variable TS1 = LastTS1
Variable TS2 = LastTS2
Variable TS3 = LastTS3
Variable TS4 = LastTS4
Prompt SF1,"Scale factor CH1"
Prompt SF2,"Scale factor CH2"
Prompt SF3,"Scale factor CH3"
Prompt SF4,"Scale factor CH4"
Prompt TS1,"Time skew CH1, ns"
Prompt TS2,"Time skew CH2, ns"
Prompt TS3,"Time skew CH3, ns"
Prompt TS4,"Time skew CH4, ns"
LastSF1 = SF1
LastSF2 = SF2
LastSF3 = SF3
LastSF4 = SF4
LastTS1 = TS1
LastTS2 = TS2
LastTS3 = TS3
LastTS4 = TS4
end

//  An attempt at a fairly universal reader for the various Tek wavefrom file formats. Will load single and multi-frame waveforms.
//  Imports file extensions .wfm and .isf, Tek file types LLWFM, WFM#001 to #003 (.wfm files) and WFMPRE (.isf).
// Does not support  pixel map types. Structured so that new formats can be added as they evolve.  This is the functional core of the load routine, and is designed to 
//	be called from another routine. 
//	FullFilePath is a string representing the full path to the Tek file to be loaded.  This is usually determined in a dialog prior to calling this function.  If FullFilePath does not exist, the function terminates without loading or error.
//  Outname is a string representing the name of the loaded wave.  Usually it is defaulted to the loaded filename, but may be different.  In case of a name conflict, an existing wave will be
//	over-written, so perform name checking before calling this function.
//	Set TimeStampFlag =1 if you want a fast-frame file to generate an associated time stamp wave name OutName_TimeStmp.  Set to 0 to skip this.  Ignored for single-frame files.

Function LoadTekWfm(FullFilePath, OutName, TimeStampFlag)
String FullFilePath, OutName					
Variable TimeStampFlag

Variable Refnum, Offset,Type=0
String HeaderString
Make/O/n=15/T  HeaderInfoStr=""			//  "Universal" collection of key string and numerical data contained in header, independent of Tek Waveform type
Make/O/n=15  HeaderInfoData=0			//  Not meant to be exhaustive list of possible parameters, just the most basic.  Designed to be extended if needed.
//HeaderInfoStr = {Source_file_name, File_type, Source_waveform, Acq_mode, Horiz_unit, Vert_unit, Vert_coupling}
//HeaderInfoData = {Hscale_pt, Trig_pos, NSamples, Vert_gain, V_Offset, V_Pos, DataRead_fType, DataRead_Offset,H_Offset,DataRead_ByteOrder,N_Frames}
 Variable Hscale_pt, Trig_pos, NSamples, Vert_gain, V_Offset, V_Pos, DataRead_fType, DataRead_Offset,H_Offset,DataRead_ByteOrder
 Variable/G  N_Frames
 String Source_file_name
//  Open file and get refnumber
FullFilePath = ParseFilePath(5,FullFilePath,":",0,0)		//  Convert to Macintosh path convention
Open/Z/R Refnum as FullFilePath	
If(V_flag ==0)			//  File exists		
	HeaderInfoStr[0] = ParseFilePath(3, S_filename,":",0,0)					//  strip off full path, store file name of source file
	//  Read first 15 bytes, determine file type, then import file header info.
	FReadLine/N=15 RefNum,HeaderString
	HeaderInfoStr[1] = ""
	If(GrepString(HeaderString, "[Ll][Ll][Ww][Ff][Mm]") == 1)		// Look for file type LLWFM.  TDS640
		HeaderInfoStr[1] = "LLWFM"
		If(StrSearch(HeaderString, ":",0) == -1)		//  no extra colon found
			Offset = 7
		Else
			Offset = 8
		EndIf
		GetLLWFMHeaderInfo(Refnum,Offset)
	EndIf
	If(GrepString(HeaderString, "[Ww][Ff][Mm]#001") == 1)		//  Look for format file type WFM#001.  TDS5000,TDS6000,TDS7000
		HeaderInfoStr[1] = "WFM#001"
		GetWFM00xHeaderInfo(Refnum,1)
		Type=1
	EndIf
	If(GrepString(HeaderString, "[Ww][Ff][Mm]#002") == 1)		//  Look for format file type WFM#002   TDS 5000B
		HeaderInfoStr[1] = "WFM#002"
		GetWFM00xHeaderInfo(Refnum,2)
		Type=2
	EndIf
	If(GrepString(HeaderString, "[Ww][Ff][Mm]#003") == 1)		//  Look for format file type WFM#003  DPO7000, DPO70000, DSA70000
		HeaderInfoStr[1] = "WFM#003"
		GetWFM00xHeaderInfo(Refnum,3)
		Type=3
	EndIf
	If(GrepString(HeaderString, "[Ww][Ff][Mm][Pp][Rr][Ee]") == 1)		//  Look for format file type WFMPRE  (.isf files).  TDS 3000 and DPO4000
		HeaderInfoStr[1] = "WFMPRE"
		GetWFMPREHeaderInfo(Refnum)
	EndIf
	If(cmpstr(HeaderInfoStr[1], "")==0)		//  Unknown file type
		Abort "Unknown file type"
	EndIf
	//  Import data.  Can be complicated by missing bytes at end of file.  Call status info on file and find number of bytes in file before loading.
	NSamples = HeaderInfoData[2]
	DataRead_fType = HeaderInfoData[6]
	DataRead_Offset = HeaderInfoData[7]
	DataRead_ByteOrder = HeaderInfoData[9]
	N_Frames = HeaderInfoData[10]
	FStatus refnum						//  get number of bytes in file
	Variable datapoints,totalbytes,bytesperpt
	totalbytes = V_logEOF
	Make/O/N=6 TempBytes
	TempBytes = {0,1,2,4,4,8}
	bytesperpt = TempBytes[DataRead_fType]  			//  get number of bytes per data point, from 	Igor DataRead_fType
	Killwaves TempBytes
	If(N_Frames <= 1)			//  Single frame data
		FSetPos refNum, DataRead_Offset
		datapoints = min((totalbytes-DataRead_Offset)/bytesperpt,NSamples)		//  take lesser of expected versus actual data points in file
	Else														//  Fast-frame data set;  load initially into 1D wave, then re-shape  later into matrix.  Includes 16 points pre- and post-charge data
		FSetPos refNum, DataRead_Offset-16					//  Start read 16 bytes before 1st valid data ("precharge region"). Will strip off later.
		datapoints = min((totalbytes-DataRead_Offset+16)/bytesperpt,(NSamples+32)*N_Frames)		//  take lesser of expected versus actual data points in file
	EndIf
	Make/O/n=(datapoints) Outwave
	If(DataRead_fType < 0)												//  Look for flag (negative sign) denoting unsigned  data
		FBinRead /F=(-DataRead_fType)/U/B=(DataRead_ByteOrder ) refNum, Outwave
	Else
		FBinRead /F=(DataRead_fType)/B=(DataRead_ByteOrder ) refNum, Outwave
	EndIf
	
	//  Import timestamp data, if selected
	If((TimeStampFlag==1) && ( N_Frames > 1))			//  make timestamp file.  Seconds is offset from start of file
		Variable Type2Offset=0,Type3Offset=0,TToffset,FracSec,GMTsec,TToffset0,FracSec0,GMTsec0
		String TimeStampName = OutName[0,24]+"_TStmp"
		TimeStampName=CleanupName(TimeStampName, 1 )
		Make/D/O/N=(N_Frames) $TimeStampName
		Wave TS = $TimeStampName
		If(Type >= 2)						//  Set up 'offsets' according to file type.  This compensates the byte offsets of parameters, due to Tektronix shoe-horning in new or extended parameters into the header data.
			Type2Offset = 2
		EndIf
		If(Type >= 3)
			Type3Offset = 4
		EndIf
		FSetPos refNum, 770+Type2Offset+2*Type3Offset
		FBinRead /F=5/B=(DataRead_ByteOrder ) refNum, 	TToffset0		//  read in timing for first waveform
		FBinRead /F=5/B=(DataRead_ByteOrder ) refNum, FracSec0
		FBinRead /F=3/B=(DataRead_ByteOrder ) refNum, GMTsec0
		TS[0] = 0
		Variable I=1,ReadPos
		Do
			ReadPos = 824+Type2Offset+2*Type3Offset+(I-1)*24			//  There is a typo in the Tek reference document.  FastFrame WfmUpdateSpec data starts at hex 0x334 = 820
			FSetPos refNum, ReadPos
			FBinRead /F=5/B=(DataRead_ByteOrder ) refNum, 	TToffset		//  read in timing for I'th waveform
			FBinRead /F=5/B=(DataRead_ByteOrder ) refNum, FracSec
			FBinRead /F=3/B=(DataRead_ByteOrder ) refNum, GMTsec
	//		print /d TToffset,FracSec,GMTsec
			TS[I] = (GMTsec-GMTsec0)+(FracSec-FracSec0)+(TToffset-TToffset0)*HeaderInfoData[0]
			I+=1
		While(I< N_Frames)		
	EndIf	
	Close refnum
	//  Scale binary data to physical units
	Hscale_pt = HeaderInfoData[0]
	Trig_pos = HeaderInfoData[1]
	Vert_gain = HeaderInfoData[3]
	V_Offset = HeaderInfoData[4]
	 V_Pos = HeaderInfoData[5]
	 H_Offset = HeaderInfoData[8]
	Variable xstart
	If(cmpstr(HeaderInfoStr[1], "LLWFM")==0)		//  Scale LLWFM data
		xstart = -NSamples*Trig_pos/100*Hscale_pt		//  xstart = -NSample*Trig_Pos/100*Hscale_pt
		Setscale/P x, xstart,Hscale_pt, Outwave
		Outwave = Outwave[p]*Vert_gain/25/256+V_Offset - V_Pos*Vert_gain  //  scaled data = vdata*v_gain/25/256+V_offset-V_gain*V_pos
	EndIf
	If(strsearch(HeaderInfoStr[1], "WFM#00",0 )==0)		//  Scale WFM#00x data;  fast frame data still in 1D format
		xstart = H_Offset 										//  xstart = -H_Offset
		Setscale/P x, xstart,Hscale_pt, Outwave							
		Outwave = Outwave[p]*Vert_gain+V_Offset 			 //  scaled data = vdata*v_gain+V_offset  	
	EndIf
	If(strsearch(HeaderInfoStr[1], "WFMPRE",0 )==0)		//  Scale WFMPRE data (.isf)
		xstart = H_Offset 							//  xstart = -H_Offset
		Setscale/P x, xstart,Hscale_pt, Outwave
		Outwave = (Outwave[p]-V_Offset )*Vert_gain		 //  scaled data = (vdata-V_offset)*v_gain.  Don't you wish Tektronix would make up its mind?
	EndIf
	//  Re-shape wave as necessary
	If(N_Frames <= 1)			//  single frame data.  Make sure it has NSamples
		Redimension/N=(NSamples) OutWave
	Else													//  Fast-frame data, reformat into matrix.  Strip off pre- and post-charge data
		Redimension/N=((NSamples+32),N_Frames) OutWave
		DeletePoints /M=0 0, 16, Outwave
		DeletePoints /M=0 NSamples,16, Outwave
	EndIf
	//  Write wave note
	Note/K Outwave, "Source file name:  "+HeaderInfoStr[0]+ ".wfm     "+HeaderInfoStr[2]
	If(N_Frames > 1)
		Note Outwave, "Fast frame data set.  Number of frames = "+num2str(N_Frames)
	EndIf
	Note Outwave, "Vertical unit:  "+HeaderInfoStr[5]+"   "+HeaderInfoStr[7]+"   "+HeaderInfoStr[3]
	Note Outwave, "Horizontal unit:  "+HeaderInfoStr[4]+",  Increment/pt:  "+num2str(Hscale_pt)+"  "+HeaderInfoStr[4]
	If((TimeStampFlag==1) && ( N_Frames > 1))			//  Copy notes into timestamp file
		Note/K $TimeStampName, "Time stamp for fast-frame data  "+OutName
		Note $TimeStampName, note(Outwave)
	EndIf	
	//  Rename output wave.  Try to do it efficiently.
	If(CheckName(OutName, 1 )== 0)					//  Name does not already exist
		Rename Outwave,  $OutName
	Else
		Duplicate/O Outwave, $OutName
		Killwaves Outwave
	EndIf
	KillWaves/Z HeaderInfoStr,HeaderInfoData
EndIf
End



//  Dialog to change file name, ask about plotting, ask about the timestamp
Proc GetNewName(name,flag, TSFlag)
String/G Outname
String name=OutName
Variable Flag, TSFlag
Prompt name, "Enter wave name:"
Prompt Flag, "Plot?",popup,"No;Make New Graph;Add to top graph"
Prompt TSFlag, "Fast-frame files:  make time stamp file?",popup,"No;Yes"
Variable/G  Displayflag = Flag-1
Variable/G TimeStampFlag=TSFlag-1
Outname = CleanupName(name, 1 )			//  modify as needed to valid name
end



//  Dialog to set over write flag
Proc Asktooverwrite(Flag)
Variable Flag
Prompt Flag,"Name already exists.  Over-write wave?",popup,"No;Yes"
Variable/G OWFlag = Flag-1
End



//  Imports header info for the Tek waveform file type LLWFM.  Places the results in the waves HeaderInfoStr (text items), and
//  HeaderInfoData (numerical items).
Function GetLLWFMHeaderInfo(Refnum,Offset)
Variable Refnum,Offset
Wave/T HeaderInfoStr
Wave HeaderInfoData
Variable ndigits, TekCode, Temp
FSetPos refNum, Offset
FBinRead /F=1/U refNum, ndigits
ndigits = str2num(num2char(ndigits))		//  loaded as ASCII code, needs to be converted to number
Offset +=1+ndigits+40						//  advance to Acq. mode
FSetPos refNum, (Offset)  					//  set pointer to first Tek Code item, Acquisition mode
FBinRead /F=2/B=2 refNum, TekCode							
HeaderInfoStr[3]=TekCodeStr(TekCode)
Offset+=12									//  Jump 2+10 bytes to  Tek Code item, Vert. coupling
FSetPos refNum, (Offset)  					
FBinRead /F=2/B=2 refNum, TekCode
HeaderInfoStr[7]=TekCodeStr(TekCode)		//  Vert. coupling				
FBinRead /F=2/B=2 refNum, TekCode
HeaderInfoStr[4]=TekCodeStr(TekCode)		//  H units  					
FBinRead /F=5/B=2 refNum, Temp
HeaderInfoData[0] = Temp					//  H scale/pt					
FBinRead /F=2/B=2 refNum, TekCode
HeaderInfoStr[5]=TekCodeStr(TekCode)		//  V units					
FBinRead /F=5/B=2 refNum, Temp
HeaderInfoData[4] = Temp					//  V offset					
FBinRead /F=5/B=2 refNum, Temp
HeaderInfoData[5] = Temp					//  V position
FBinRead /F=5/B=2 refNum, Temp
HeaderInfoData[3] = Temp					//  V scale
FBinRead /F=3/B=2 refNum, Temp
HeaderInfoData[2] = Temp					//  NSamples
FBinRead /F=2/B=2 refNum, Temp
HeaderInfoData[1] = Temp					//  TrigPos, %
FStatus refnum				
FSetPos refNum, ( V_filepos+6)			//  jump forward 6 bytes
FBinRead /F=2/B=2 refNum, TekCode
HeaderInfoStr[2]=TekCodeStr(TekCode)		//  Vert. coupling
FStatus refnum	
HeaderInfoData[7] = v_filepos+60			//  pointer position for start of data, DataRead_Offset
HeaderInfoData[6] = 2						//  /F option value for FBinRead,  DataRead_fType = I16
HeaderInfoData[9] = 2						//  Byte order is assumed to be Big-endian
End


//  Converts Tek string code numbers to their appropriate strings.  Used in LLWFM file headers.
Function/S TekCodeStr(Code)
Variable Code
String CodeStr = num2Str(Code), ReturnStr
ReturnStr = StringByKey(CodeStr, "0:;2:Peak Detect;3:Hi Res;4:Average;25:Ground;565:DC Coupling;566:AC Coupling;609:Volts;610:s;97:On;98:Off;")
ReturnStr += StringByKey(CodeStr, "187:Envelope;285:Sample;669:Normal;930:RMS Average;631:Unknown;736:Hz;740:dB;766:V-sec;767:VVs;")
ReturnStr += StringByKey(CodeStr, "768:V/s;920:V/V;107:Ch1;108:Ch2;109:Ch3;110:Ch4;907:Ch5;908:Ch6;909:Ch7;910:Ch8;911:Ch9;912:Ch10;")
ReturnStr += StringByKey(CodeStr, "913:Ch11;914:Ch12;915:Ch13;916:Ch14;917:Ch15;918:Ch16;111:Math1;112:Math2;113:Math3;972:Math4;")
ReturnStr += StringByKey(CodeStr, "973:Math5;974:Math6;975:Math7;114:Ref1;115:Ref2;116:Ref3;117:Ref4;118:Ref5;119:Ref6;120:Ref7;121:Ref8;")
Return ReturnStr
End




//  Imports header info for the Tek waveform file type WFM#001,002,and 003.  Places the results in the waves HeaderInfoStr (text items), and
//  HeaderInfoData (numerical items).  (Type is the x in WFM#00x).  Byte offsets are from the Tek article 001137803.pdf.
//	HeaderInfoStr = {Source_file_name, File_type, Source_waveform, Acq_mode, Horiz_unit, Vert_unit, Vert_coupling}
//	HeaderInfoData = {Hscale_pt, Trig_pos, NSamples, Vert_gain, V_Offset, V_Pos, DataRead_fType, DataRead_Offset,H_Offset,DataRead_ByteOrder,N_Frames}
Function GetWFM00xHeaderInfo(Refnum,Type)
Variable Refnum,Type

Wave/T HeaderInfoStr
Wave HeaderInfoData

Variable/D ndigits, Offset, Temp
Variable Type2Offset=0,Type3Offset=0,Byteorder
String TempStr
//  Set up 'offsets' according to file type.  This compensates the byte offsets of parameters, due to Tektronix shoe-horning in new or extended parameters into the header data.
If(Type >= 2)
	Type2Offset = 2
EndIf
If(Type >= 3)
	Type3Offset = 4
EndIf
//  Check for data byte order.
FSetPos refNum, 0
FBinRead/F=2/U  refNum, Temp	//  load first two bytes, to check for byte ordering
If(Temp == 61680)				//  U16 code for "ננ", signifying high-byte first
	HeaderInfoData[9] = 2			//  Big-endian byte ordering
	Byteorder = 2
Else
	HeaderInfoData[9] = 3			//  Little-endian byte ordering
	Byteorder = 3
endif
//  Start parsing the header
FSetPos refNum, 16
FBinRead /F=3/B=(Byteorder) refNum, Temp			//  DataRead_Offset to start of buffer
HeaderInfoData[7] = Temp								//  This value is incomplete;  it will be refined later
FSetPos refNum, 72					
FBinRead /F=3/U/B=(Byteorder) refNum, Temp			
HeaderInfoData[10] = Temp+1							//  N_Frames, number of frames of data.  Normally = 1 for ordinary traces.	
If(Type >= 2)
	FSetPos refNum, 154
	FBinRead /F=2/U/B=(Byteorder) refNum, Temp			//  Read Summary frame type
	HeaderInfoStr[3] =  StringFromList(Temp, "Sample;Average;Envelope;")
EndIf
FSetPos refNum, 166+Type2Offset						
FBinRead /F=5/B=(Byteorder) refNum, Temp			
HeaderInfoData[3] = Temp								//  V scale	
FSetPos refNum, 174+Type2Offset						
FBinRead /F=5/B=(Byteorder) refNum, Temp			
HeaderInfoData[4] = Temp								//  V offset
FSetPos refNum, (186+Type2Offset)
TempStr = PadString(" ", 20, 0)						// allocate 20 characters for read	
FBinRead  refNum, TempStr								//  V units, terminated by null
HeaderInfoStr[5] = TempStr[0,strsearch(TempStr, num2char(0), 0)]		//  parse V units by stopping at first null
FSetPos refNum, 238+Type2Offset
FBinRead /F=1/U refNum, Temp					// Tek data format code:  0 = I16, 1 = I32, 2 = U32, 3 = U64, 4 = FP32, 5 = FP64, 6 = U8, 7 = I8, 8 = invalid
Make/O/N=7 FormatCode
FormatCode= {2,3,-3,0,4,5,-1,1,0}				//  	Convert Tek format code into Igor's equivalent (used in FBinRead/F option).  0 = native,1=I8 , 2 = I16, 3 = I32, 4 = FP32, 5 = FP64
HeaderInfoData[6] = FormatCode[Temp]				//  Igor covers the possible range of data read formats with a combination of /F code and the /U option.  We represent the /U option by a minus sign.
KillWaves FormatCode
FSetPos refNum, 306+Type2Offset+Type3Offset						
FBinRead /F=5/B=(Byteorder) refNum, Temp			//  H trigger position, %	
HeaderInfoData[1] = Temp
FSetPos refNum, 478+Type2Offset+2*Type3Offset							
FBinRead /F=5/B=(Byteorder) refNum, Temp			//  H scale, time/pt	
HeaderInfoData[0] = Temp						
FBinRead /F=5/B=(Byteorder) refNum, Temp			//  H offset 
HeaderInfoData[8] = Temp
FBinRead /F=3/U/B=(Byteorder) refNum, Temp		//  NSamples + 32 extra
HeaderInfoData[2] = Temp-32
FSetPos refNum, 498+Type2Offset+2*Type3Offset				
FBinRead  refNum, TempStr								//  H units
HeaderInfoStr[4] = TempStr[0,strsearch(TempStr, num2char(0), 0)]		//  parse units by stopping at first null
FSetPos refNum, 804+Type2Offset+4*Type3Offset							
FBinRead /F=3/U/B=(Byteorder) refNum, Temp			//  byte offset from start of buffer to first valid data pt, = DataRead_Offset +Data Start Offset
HeaderInfoData[7] += Temp
end

//  Imports preamble data from .isf file format.   The preamble looks like:
//:WFMPRE:BYT_NR 2;BIT_NR 16;ENCDG BIN;BN_FMT RI;BYT_OR MSB;NR_PT 10000;WFID "Ch1, DC coupling, 2.0E0 V/div, 1.0E-5 s/div, 10000 points, Sample mode";
//PT_FMT Y;XINCR 1.0E-8;PT_OFF 0;XZERO 3.5E-4;XUNIT "s";YMULT 3.125E-4;YZERO 0.0E0;YOFF 0.0E0;YUNIT "V";:CURVE #520000<binary data>

Function GetWFMPREHeaderInfo(Refnum)
Variable Refnum

Wave/T HeaderInfoStr
Wave HeaderInfoData
String HeaderString,TempStr
FSetPos refNum, 0
FReadLine/N=500 RefNum,HeaderString			// read first 500 characters of file as text, after :WFMPRE:
HeaderInfoStr[2] = StringByKey("WFID",HeaderString, " ",";")					//  put most of note comments in this slot
HeaderInfoStr[4] = StringByKey("XUNIT",HeaderString, " ",";")					//  H units
HeaderInfoStr[5] = StringByKey("YUNIT",HeaderString, " ",";")					//  V units
HeaderInfoData[0] = str2num(StringByKey("XINCR",HeaderString, " ",";"))		//  Hscale_pt
HeaderInfoData[2] = str2num(StringByKey("NR_PT",HeaderString, " ",";"))	//  NSamples
HeaderInfoData[3] = str2num(StringByKey("YMULT",HeaderString, " ",";"))	//  Vert gain
HeaderInfoData[4] = str2num(StringByKey("YOFF",HeaderString, " ",";"))		//  Vert Offset
HeaderInfoData[6] = str2num(StringByKey(":WFMPRE:BYT_NR",HeaderString, " ",";"))	//  Number of bytes/pt
HeaderInfoData[8] = str2num(StringByKey("XZERO",HeaderString, " ",";"))		//  H Offset
TempStr = StringByKey("BYT_OR",HeaderString, " ",";")				//  Byte order
If(cmpstr(TempStr,"MSB")==0)					//  Big-endian byte order
	HeaderInfoData[9] = 2
Else
	HeaderInfoData[9] = 3				//  Little-endian byte order
EndIf
If(HeaderInfoData[6]== 4)				//  convert byte number to fType for binary read
	HeaderInfoData[6]=3				//  ftype = # bytes for f=1,2;  ftype = 3 for 4 byte I32
EndIf
Variable DataRead_Offset = strsearch(HeaderString,":CURVE #",0)+8			// position of "X" number denoting # of digits in byte count
Variable DigCnt = str2num(HeaderString[DataRead_Offset])						//  number of digits
HeaderInfoData[7] = DataRead_Offset+1+DigCnt									//  pointer position (in bytes) to the first curve data point
end


//  Used to replot one or more fastframe traces according to the frame number.  Called whenever the frameindex is changed
//  The major characteristics of each plot (axes,color, mode,line style) are preserved.
Function SetVarProc_FrameControl(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	Variable /G  FrameIndex
	String TraceNames = TraceNameList("", ";", 1)
	String TraceName,TraceInfoStr,XAxisname,Yaxisname
	TraceNames =ReplaceString("'", TraceNames, "")		
	Variable NTraces = ItemsInList(TraceNames), I=0
	Variable mode,gaps,LSize,LStyle,marker,msize,offx,offy,red,green,blue
	Do
		TraceName = ReplaceString("'", StringFromList(0, TraceNameList("", ";", 1)),"")		//  Allways get first in list, because the list numbering is constantly revolving.  Strip off  single quotes used on liberal names;  incompatible with $ operator
		TraceInfoStr=TraceInfo("", TraceName, 0)												//  Get plotting info about this trace, so it can be reproduced
		Xaxisname = StringbyKey("XAXIS",TraceInfoStr)
		Yaxisname = StringbyKey("YAXIS",TraceInfoStr)
		TraceInfoStr= TraceInfoStr[strsearch(TraceInfoStr,"RECREATION",0)+11,strlen(Traceinfostr)-1]
		gaps=NumberByKey("gaps(x)", TraceInfoStr, "=", ";")
		mode=NumberByKey("mode(x)", TraceInfoStr, "=", ";")
		LSize=NumberByKey("LSize(x)", TraceInfoStr, "=", ";")
		LStyle=NumberByKey("LStyle(x)", TraceInfoStr, "=", ";")
		marker=NumberByKey("marker(x)", TraceInfoStr, "=", ";")
		msize=NumberByKey("msize(x)", TraceInfoStr, "=", ";")
		offx=str2num(StringfromList(0,ReplaceString(")",StringByKey("offset(x)", TraceInfoStr, "=", ";"),"")[1,100],","))		//  Whew!
		offy=str2num(StringfromList(1,ReplaceString(")",StringByKey("offset(x)", TraceInfoStr, "=", ";"),"")[1,100],","))
		red=str2num(StringfromList(0,ReplaceString(")",StringByKey("rgb(x)", TraceInfoStr, "=", ";"),"")[1,100],","))
		green=str2num(StringfromList(1,ReplaceString(")",StringByKey("rgb(x)", TraceInfoStr, "=", ";"),"")[1,100],","))
		blue=str2num(StringfromList(2,ReplaceString(")",StringByKey("rgb(x)", TraceInfoStr, "=", ";"),"")[1,100],","))
	if (stringmatch(Xaxisname, "top")&&stringmatch(Yaxisname, "left"))							//  clumsy way to specify append flags
		AppendToGraph/T $TraceName [][FrameIndex]
	elseif (stringmatch(Xaxisname, "bottom")&&stringmatch(Yaxisname, "right"))
		AppendToGraph/R $TraceName [][FrameIndex]
	elseif (stringmatch(Xaxisname, "top")&&stringmatch(Yaxisname, "right"))
		AppendToGraph/R/T $TraceName [][FrameIndex]
	else
		AppendToGraph $TraceName [][FrameIndex]
	endif
		RemoveFromGraph $TraceName					//  Trace appended at end, initially gets #1 appended, then dropped when original trace is removed.  Trace just modified is last on list now
		ModifyGraph mode($TraceName)=(mode), gaps($TraceName)=(gaps), LSize($TraceName)=(LSize), LStyle($TraceName)=(LStyle), marker($TraceName)=(marker)		
		ModifyGraph msize($TraceName)=(msize), offset($TraceName)={offx,offy}, rgb($TraceName)=(red,green,blue)
		I+=1
	While(I < NTraces)
End

//  Uses the cursors on the top graph to define the baseline window for baseline zeroing.  Multiplies
// the curve by ScaleF
Macro AdjustBaselineAndScale(Name,ScaleF)
Variable/G LastScaleF
String Name
Variable ScaleF = LastScaleF
Prompt Name, "Wave",popup,TraceNameList("", ";", 1)
Prompt ScaleF, "Scale factor to multiply graph by"

LastScaleF = ScaleF
WaveStats/Q/R=(xcsr(A),xcsr(B))  $Name
$Name-=V_avg
$Name*=ScaleF
end
