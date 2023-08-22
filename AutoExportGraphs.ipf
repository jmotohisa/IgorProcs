#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function FAutoExportGraph()

	String homepath,destfolder,destfolderpath
	
	// create Path and folder	
	PathInfo/S home
	homepath=S_path
	
	destfolder=IgorInfo(1)+"_graphs"
	destfolderpath = homepath+destfolder+":"
	NewPath/C/O graphs destfolderpath
	
	// Write open graphs
	Variable i
	String grwin,gwindowslist = winlist("*",";","WIN:1")
	i=0
	do
		grwin=StringFromList(i,gwindowslist)
		if(strlen(grwin)<=0)
			break
		endif
		DoWindow/F $grwin
		SavePICT/P=graphs/E=-2
		i+=1
	while(1)
	
	// Write Graphs in Macros
	gwindowslist=macrolist("*",";","KIND:4")
	// omit Graphplot;Graphplotxy;
	
	i=0
	String cmd
	do
		grwin=StringFromList(i,gwindowslist)
		if(strlen(grwin)<=0)
			break
		endif
//		DoWindow/F $grwin
		if(stringmatch(grwin,"!Graphplot") && stringmatch(grwin,"!Graphplotxy"))
			sprintf cmd,"%s()",grwin
			print cmd
			Execute cmd
			SavePICT/P=graphs/E=-2
		Endif
		i+=1
	while(1)
End