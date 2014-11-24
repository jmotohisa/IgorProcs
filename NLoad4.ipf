Function BeforeFileOpenHook(refNum,fileName,pathName,type,creator,kind)	Variable refNum,kind	String fileName,pathName,type,creator	| Load ISA files	Variable handledOpen=0,nameL=strlen(fileName)	if(nameL>4)		if(cmpstr(fileName[nameL-4,nameL-1], ".L00")==0)			Execute("ISAload(\"\",\""+fileName+"\",\""+pathName+"\")")			handledOpen=1		endif	endif	return handledOpenEndMacro ISAload(name,file,path)	String name,file	String path="home"	PauseUpdate; Silent 1	Variable /D ref,lhead,lblock,npoint,offreg,xmin,xmax,dx,skip	if (strlen(file)<=0)		Open /D/R/P=$path/T="sGBWTEXT" ref		file= S_fileName	endif	print file	Open /R/P=$path/T="sGBWTEXT" ref as file	FsetPos ref,53	FBinRead /B/F=2 ref,lhead	FsetPos ref,63	FBinRead /B/F=2 ref,lblock	FsetPos ref,68	FBinRead /B/F=2 ref,offreg	FsetPos ref,offreg+5	FBinRead /B/F=4 ref,xmin	FsetPos ref,offreg+9	FBinRead /B/F=4 ref,xmax	FsetPos ref,offreg+17	FBinRead /B/F=2 ref,npoint	Close ref	skip=lhead+lblock-4*npoint	dx=(xmax-xmin)/(npoint-1)	GBLoadWave /N=$"dummywave"/F=3/B/U=(npoint)/S=(skip)/P=$path file	if (strlen(name)<1)		name="W"+wname(file)	endif	SetScale/I x xmin,xmax,"",dummywave0	duplicate /O dummywave0,$nameEndFunction/S wname(name)	string name	variable start,stop,length,tmp=-1	length=strlen(name)	do		start=tmp+1		tmp=strsearch(name,":",start)	while(tmp>-1)	stop=strsearch(name,".",0 )	if (stop<0)		stop=length	endif	return name[start,stop-1]END| AutoGraph2()| Each time you run AutoGraph2(), it prompts you for the name of a symbolic path| from which to load and graph data. In this experiment, we have created a symbolic| path called "data" which points to the "Sample Data" folder in the "AutoGraph Folder".| AutoGraph2() loads and graphs the data from each of the files, one at a time.| It then prints the graph if you have requested printing.Macro MultiISA(thePath, wantToPrint)	String thePath="_New Path_"	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"	Variable wantToPrint=2	Prompt wantToPrint, "Do you want to print graphs?", popup, "Yes;No"	|String ftype="sGBW"	String ftype="TEXT"	|Prompt ftype,"Filetype"		Silent 1		String fileName	Variable fileIndex=0, gotFile		if (CmpStr(thePath, "_New Path_") == 0)		| user selected new path ?		NewPath/O data			| this brings up dialog and creates or overwrites path		thePath = "data"	endif		DoWindow /F Graphplot							| make sure Graphplot is front window	if (V_flag == 0)								| Graphplot does not exist?		Make/N=2/D/O dummywave0		Graphplot()									| create it	endif		do		fileName = IndexedFile($thePath,fileIndex,ftype)			| get name of next file in path		gotFile = CmpStr(fileName, "")		if (gotFile)			 ISAload("",fileName,thePath)			|LoadWave/G/P=$thePath/O/N=wave fileName		| load the waves from file			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName			DoUpdate		| make sure graph updated before printing			if (wantToPrint == 1)				PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1	| print graph			endif		endif		fileIndex += 1	while (gotFile)									| until TextFile runs out of filesEndMacroMacro ISAloadsub(name,file,path)	String name,file	String path="home"	PauseUpdate; Silent 1	Variable /D ref,lhead,lblock,npoint,offreg,xmin,xmax,dx,skip	if (strlen(file)<=0)		Open /D/R/P=$path/T="sGBWTEXT" ref		file= S_fileName	endif	print file	Open /R/P=$path/T="sGBWTEXT" ref as file	FsetPos ref,53	FBinRead /B/F=2 ref,lhead	FsetPos ref,63	FBinRead /B/F=2 ref,lblock	FsetPos ref,68	FBinRead /B/F=2 ref,offreg	FsetPos ref,offreg+5	FBinRead /B/F=4 ref,xmin	FsetPos ref,offreg+9	FBinRead /B/F=4 ref,xmax	FsetPos ref,offreg+17	FBinRead /B/F=2 ref,npoint	Close ref	skip=lhead+lblock-4*npoint	dx=(xmax-xmin)/(npoint-1)	GBLoadWave /N=$"dummywave"/F=3/B/U=(npoint)/S=(skip)/P=$path file	if (strlen(name)<1)		name="W"+wname(file)	endif	SetScale/I x xmin,xmax,"",dummywave0	dummywave0-=bgrnd	duplicate /O dummywave0,$nameEndMacro MultiISAsub(thePath, wantToPrint)	String thePath="_New Path_"	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"	Variable wantToPrint=2	Prompt wantToPrint, "Do you want to print graphs?", popup, "Yes;No"	|String ftype="sGBW"	String ftype="TEXT"	|Prompt ftype,"Filetype"		Silent 1		String fileName	Variable fileIndex=0, gotFile		if (CmpStr(thePath, "_New Path_") == 0)		| user selected new path ?		NewPath/O data			| this brings up dialog and creates or overwrites path		thePath = "data"	endif		DoWindow /F Graphplot							| make sure Graphplot is front window	if (V_flag == 0)								| Graphplot does not exist?		Make/N=2/D/O dummywave0		Graphplot()									| create it	endif		do		fileName = IndexedFile($thePath,fileIndex,ftype)			| get name of next file in path		gotFile = CmpStr(fileName, "")		if (gotFile)			 ISAloadsub("",fileName,thePath)			|LoadWave/G/P=$thePath/O/N=wave fileName		| load the waves from file			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName			DoUpdate		| make sure graph updated before printing			if (wantToPrint == 1)				PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1	| print graph			endif		endif		fileIndex += 1	while (gotFile)									| until TextFile runs out of filesEndMacroMacro Multiload(thePath)	String thePath="_New Path_"	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"		PauseUpdate;Silent 1		String fileName,name,name0	Variable fileIndex=0, gotFile		if (CmpStr(thePath, "_New Path_") == 0)		| user selected new path ?		NewPath/O data			| this brings up dialog and creates or overwrites path		thePath = "data"	endif		do		fileName = TextFile($thePath,fileIndex)			| get name of next text file in path		gotFile = CmpStr(fileName, "")		if (gotFile)			name="W"+wname(fileName)+"_"			LoadWave/G/D/N=$name/O/P=$thePath fileName		| load the waves from file			name0=name+"0"			$name0=$name0		endif		fileIndex += 1	while (gotFile)									| until TextFile runs out of filesEndMacro| Graphplot()| Graphplot() is the macro that creates Graphplot.| It is called from AutoGraph1() and AutoGraph2() if Graphplot does not exist when they run.| The Graphplot() macro was made by automatically by Igor's display recreation macro feature.Window Graphplot() : Graph	PauseUpdate; Silent 1		| building window...	Display /W=(3,41,636,476) dummywave0	Label left "counts"	Label bottom "nm"	Textbox/N=tb_file/F=0/A=MT/X=-30.00 "File: XR1.L00"EndMacroMacro ISAconv(name,file,path)	String name,file	String path="home"	PauseUpdate; Silent 1	Variable /D ref,lhead,lblock,npoint,offreg,xmin,xmax,dx,skip	if (strlen(file)<=0)		Open /D/R/P=$path/T="sGBWTEXT" ref		file= S_fileName	endif	print file	Open /R/P=$path/T="sGBWTEXT" ref as file	FsetPos ref,53	FBinRead /B/F=2 ref,lhead	FsetPos ref,63	FBinRead /B/F=2 ref,lblock	FsetPos ref,68	FBinRead /B/F=2 ref,offreg	FsetPos ref,offreg+5	FBinRead /B/F=4 ref,xmin	FsetPos ref,offreg+9	FBinRead /B/F=4 ref,xmax	FsetPos ref,offreg+17	FBinRead /B/F=2 ref,npoint	Close ref	skip=lhead+lblock-4*npoint	dx=(xmax-xmin)/(npoint-1)	GBLoadWave /N=$"dummywave"/F=3/B/U=(npoint)/S=(skip)/P=$path file	if (strlen(name)<1)		name=wname(file)+".ASC"	endif	SetScale/I x xmin,xmax,"",dummywave0	Save/J/U={0,1,0,0}/P=$path dummywave0 as nameEndMacro MultiISAconv(thePath, wantToPrint)	String thePath="_New Path_"	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"	Variable wantToPrint=2	Prompt wantToPrint, "Do you want to print graphs?", popup, "Yes;No"	|String ftype="sGBW"	String ftype="TEXT"	|Prompt ftype,"Filetype"		Silent 1		String fileName	Make/N=200/T/O fnames	Variable fileIndex=0, gotFile		if (CmpStr(thePath, "_New Path_") == 0)		| user selected new path ?		NewPath/O data			| this brings up dialog and creates or overwrites path		thePath = "data"	endif		DoWindow /F Graphplot							| make sure Graphplot is front window	if (V_flag == 0)								| Graphplot does not exist?		Make/N=2/D/O dummywave0		Graphplot()									| create it	endif		do		fnames[fileIndex] = IndexedFile($thePath,fileIndex,ftype)		| get name of next file in path		gotFile = CmpStr(fnames[fileIndex], "")		fileIndex += 1	while (gotFile)									| until TextFile runs out of files	fileIndex=0		do		fileName = fnames[fileIndex]			| get name of next file in path		gotFile = CmpStr(fileName, "")		if (gotFile)			 ISAconv("",fileName,thePath)			|LoadWave/G/P=$thePath/O/N=wave fileName		| load the waves from file			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName			DoUpdate		| make sure graph updated before printing			if (wantToPrint == 1)				PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1	| print graph			endif		endif		fileIndex += 1	while (gotFile)									| until TextFile runs out of filesEndMacroMacro NewSpect(nr)	Variable nr	String s="WA0"+num2istr(nr)	Display $s	ModifyGraph/Z rgb[1]=(0,0,65535)	Legend/N=text0/F=0/A=MC/X=43/Y=-70EndMacroMacro MultiSpect(start,stop)	Variable start,stop	Variable n=stop	do		NewSpect(n)		n-=1	while (n>=start)EndMacroMacro NewPlot(nr)	Variable nr	String s="W0"+num2istr(11600+nr)	Print s|	Display $(s+"_1"),$(s+"_2") vs $(s+"_0")	Display $(s+"_1"), vs $(s+"_0")	ModifyGraph/Z rgb[1]=(0,0,65535)	Legend/N=text0/F=0/A=MC/X=34/Y=44	Legend/C/N=text0/J/B=1EndMacroMacro MultiPlots(start,stop)	Variable start,stop	Variable n=stop	do		NewPlot(n)		n-=1	while (n>=start)EndMacro