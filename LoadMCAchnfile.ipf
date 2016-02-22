#include <Value Report>#include <strings as lists>#include "GraphPlot"#include "wname"#include "MCAsub"// loadMCAchnfile.ipf//	Macro to load chn data file of SEIKO WinMCA//	07/02/17 ver. 0.11 by J. Motohisa////	revision history//		?/?/?		ver 0.1	first version//		07/02/17	ver 0.11 modified for newest IgorPro//		16/02/22	ver 0.12	procs except loader is moved to other procedureMacro MultiChnLoad(thePath,flag,wantToPrint)	String thePath="_New Path_"	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"	Variable flag=2	Prompt flag,"swap channel ?",popup,"no;yes"	Variable wantToPrint=2	Prompt wantToPrint, "Do you want to print graphs?", popup, "Yes;No"//	String ftype="sGBW"//	String ftype="TEXT"	String ftype=".chn"	//Prompt ftype,"Filetype"		Silent 1		String fileName	Variable fileIndex=0, gotFile		if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?		NewPath/O data			// this brings up dialog and creates or overwrites path		thePath = "data"	endif		DoWindow /F Graphplot							// make sure Graphplot is front window	if (V_flag == 0)								// Graphplot does not exist?		Make/N=2/D/O dummywave0		Graphplot()									// create it	endif		do		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path		gotFile = CmpStr(fileName, "")		if (gotFile)			print fileName,thePath,flag			 ReadChn(fileName,thePath,"",flag)			//LoadWave/G/P=$thePath/O/N=wave fileName		// load the waves from file			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName			DoUpdate		// make sure graph updated before printing			if (wantToPrint == 1)				PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1	// print graph			endif		endif		fileIndex += 1	while (gotFile)									// until TextFile runs out of filesEndMacroMacro ReadChn(fileName,pathName,waveName,flag)	String fileName,pathName="home",waveName	Variable flag=2	Prompt flag,"swap channel ?",popup,"no;yes"		Silent 1; PauseUpDate		Variable /D ref	Variable IFlag,INo,ISeg,IReal,ILive,IStach,ISize		if (strlen(fileName)<=0)		Open /D/R/P=$pathName/T="sGBWTEXT" ref		fileName= S_fileName	endif	print fileName	if (strlen(waveName)<1)		waveName="chn"+wname(fileName)	endif	Open /R/P=$pathName/T="sGBWTEXT" ref as fileName	FsetPos ref,0	FBinRead /F=2/B ref,IFlag	FsetPos ref,2	FBinRead /F=2/B ref,INo	FsetPos ref,4	FBinRead /F=2/B ref,ISeg	FsetPos ref,8	FBinRead /F=3/B ref,IReal	FsetPos ref,12	FBinRead /F=3/B ref,ILive	FsetPos ref,28	FBinRead /F=2/B ref,IStach	FsetPos ref,30	FBinRead /F=2/B ref,ISize	Close ref//	Print IFlag,INo,ISeg,IReal,ILive,IStach,ISize		GBLoadWave/N=$"dummywave"/B/F=1/S=32/W=1/U=(ISize)/P=$pathName fileName// swap//	waveName = GetStrFromList(S_waveNames,0,";")	if(flag==2) then		Duplicate/O dummywave0,tmpwave		tmpwave = -x		Sort tmpwave tmpwave,dummywave0		KillWaves/Z tmpwave	endif//	duplicate dummywave0,$waveNameEnd Macro