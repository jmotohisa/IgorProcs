#pragma rtGlobals=1		// Use modern global access method.#include "JEG NanoLoader"#include "ImagePlus"//// load Nanoscope data//Macro LoadAFMAll(pathName)	String pathName="_New Path_"		Silent 1; PauseUpDate		String fileName//	String ftype="sGBW"//	String ftype="TEXT"	String ftype="????"	Variable index=0	String returnvalue	String fullpath		if (CmpStr(PathName, "_New Path_") == 0)		// user selected new path ?		NewPath/O data			// this brings up dialog and creates or overwrites path		PathName = "data"	endif	PathInfo/S $pathName	fullpath=S_path	do		fileName = IndexedFile($pathName, index,ftype)//		print filename		if(strlen(fileName)==0)			break		endif				Print "loding file ",filename		filename=fullpath+filename//		PathInfo/S $pathName		JEG_LoadNanoScopeJMmod(filename,1, "")//		returnvalue = JEG_LoadNanoScope(filename,1, "")//		 print returnvalue		index+=1	while(1)		if(Exists("temporaryPath"))		KillPath temporaryPath	endifEnd MacroFunction/S JEG_LoadNanoScopeJMmod(theFilename, convertToFP, postProcess)	String   theFilename, postProcess	Variable convertToFP	String df = GetDataFolder(1)	NewDataFolder/O/S root:Packages	NewDataFolder/O/S 'JEG NanoLoader'	if (Exists("S_JEG_UpdateImageHistoryProc") != 2)		String/G S_JEG_UpdateImageHistoryProc = ""	endif	if (Exists("S_JEG_RemoveFromHistoryProc") != 2)		String/G S_JEG_RemoveFromHistoryProc = ""	endif	SetDataFolder df	Variable NSfile	String loadedWaves = ""		if ( strlen(theFilename) == 0 )		Open/D/T="????"/R/M="Select a NanoScope¨ SPM image" NSfile		theFilename = S_filename	endif	if ( strlen(theFilename) > 0 )		Open/R/Z NSfile as theFilename		if (V_flag)			Abort "Error opening file " + theFilename + ".\rCheck the file name."		endif				string lf = num2char(10)		string crlf = "\r" + lf		string ctrlZ = num2char(26)				String theHeader = ""				// Scan for the header length				Variable theHeaderSize		String   theVersion		Variable isNSIIfile = 0				// Scan the header and see which type of NanoScope¨ image this is				// read in the whole header		FReadLine /T=ctrlZ NSfile, theHeader		// determine how long it's supposed to be		theHeaderSize = JEG_NumByKey("\Data length", theHeader, ":", crlf)		// get the hex version code		theVersion = JEG_StrByKey("\Version: ", theHeader, "0x", crlf)		// check for _old_ style format		isNSIIfile = ( JEG_NumByKey("Data_File_Type", theHeader, " ", crlf) >= 7 )		Close NSfile		if ( isNSIIfile )			loadedWaves = JEG_LoadNanoScopeII( theFilename, convertToFP )		else			if  ( str2num(theVersion) < 4300000 )	// previous to 4.3x				string operatingMode = ""				operatingMode = JEG_ParseNSIIIHeader( theHeader )								Wave theHeaders = theHeaders								String/G fileName = CleanupName( JEG_FileTail( theFileName ), 1 )				if ( numpnts( theHeaders ) > 2 )					NewDataFolder/O/S $fileName					MoveWave ::theHeaders, :				else					String/G S_NSfileName = fileName				endif								JEG_LoadNSIII_SimpleFile( "Image", thefilename, 1, "" ) //				String cmd//				if ( strlen( operatingMode ) > 0 )//					if ( cmpstr(operatingMode, "Force Volume") == 0 )//						cmd = "JEG_LoadNSIII_ForceVolumeFile( \"%s\", %d, \"%s\" ) \r"//						sprintf cmd, cmd, theFileName, convertToFP, postProcess//					else//						cmd = "JEG_LoadNSIII_SimpleFile( \"%s\", \"%s\", %d, \"%s\" ) \r"//						sprintf cmd, cmd, operatingMode, theFileName, convertToFP, postProcess//					endif//					print cmd//						Execute cmd//										SVAR S_loadedNSWaves = S_loadedNSWaves//										loadedWaves = S_loadedNSWaves//				endif			else				loadedWaves = JEG_LoadNanoScopeCIAO( theFilename, theHeaderSize, convertToFP )			endif		endif	endif	return loadedWaves		End//// dispolay AFM image//Macro DisplayAFM(wavename)	String wavename	Prompt wavename,"select wave",popup,WaveList("*", ";", "" )	silent 1		String tagname="tg0"	JEG_DisplayNanoScope_Image($wavename)	Tag/N=$tagname/F=0/X=10.71/Y=99.60/L=0 $wavename, 0, "\\ON"	ModifyImage $wavename ctab= {*,*,YellowHot,0}	ModifyImage ColorLegend ctab= {*,*,YellowHot,0}//	String cmd//	cmd="JEG_DisplayNanoScope_Image("+wavename+")"//	Execute cmdEnd//// Automatically display images//Macro Initialize4Graphs(suffics,graphName,LayoutName,index)	String suffics = "",graphName = "tmpgraphs",LayoutName = "LayoutOf4"	Variable index=0		String/G g_graphName = graphName,g_layoutName = layoutName,g_suffics=suffics	Variable/G g_index=index	layout4graphs()End MacroMacro disp4AFMImage(start,suffics,pflag)	String suffics=g_suffics	Variable start=g_index,pflag=1	prompt start,"start"	prompt suffics,"Display waves starting with..."	prompt pflag,"outomatically print layout ?",popup,"yes;no"	PauseUpdate; Silent 1		| building window...		Variable n=start,index=0,increment=4	String w1,wlist = wavelist(suffics+"*",";","")	kill4graphs()	do		w1=GetStrFromList(wlist,n,";")		displayAFMImages(w1,g_graphName,index)		index+=1		n +=1	while (index<increment)	if(strsearch(WinList("*",";","WIN:4"),g_layoutName,0)<0)		layout4graphs()	endif	DoWindow/F $g_layoutName	DoUpdate		if(pflag==1)		PrintLayout $g_layoutName	endif	g_index = start + increment	g_suffics = sufficsEndMacroMacro kill4graphs()	PauseUpdate; Silent 1	Variable index	String grname = g_graphname,lname = g_layoutname	String gname	|	Dowindow/K $lname	index=0	do		gname=grname+num2istr(index)		DoWindow/K $gname		index+=1	while(index<4)EndMacroMacro displayAFMImages(waveName,graphName,index)	String waveName	String graphName=g_graphname	Variable index=0	Prompt waveName,"Wave Name",popup,WaveList("*",";","")	Prompt graphName,"Graph Name"	Prompt index,"Index"		if(exists(waveName)==1)		DisplayAFM(wavename)|		AttachDataNameToImagePlot()		DoWindow/C $(graphName+num2istr(index))|		ModifyGraph log(left)=1|		ModifyGraph/Z rgb[1]=(0,0,65535)|		Legend/N=text0/F=0/A=MC/X=43/Y=-70	endifEndMacroMacro layout4graphs()	PauseUpdate; Silent 1		| building window...		String graphName=g_graphName,layoutName=g_layoutName	String tmp		tmp = graphname + "0(17,16,416,292)/O=1"	Layout/W=(36,44,537,620) $tmp	DoWindow/C $layoutname	tmp = graphname+"1(424,16,823,292)/O=1"; Append $tmp	tmp = graphname+"2(17,300,416,576)/O=1"; Append $tmp	tmp = graphname+"3(424,300,823,576)/O=1"; Append $tmpEndMacro