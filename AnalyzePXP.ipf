#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Macro AnalyzePXP()
	PauseUpdate; Silent 1
	
	String expname=IgorInfo(1) // experiment name
	String wvlist=WaveList("*",";","") // wave names
	String grlist=WinList("*",";","WIN:1") // trace names
	Variable i0,i1,n,n1
	String gname,yname,xname,trlist
	
	print "Experiment name:", expname
	print "Waves : ",wvlist
	Print "Graphs : "
	String fullpath=FullPathToHomeFolder()+":"+expname+".pxp"
	CreateFolderInHomeFolder(expname+"_graphs", "graph_tmp")
	
	// analize Graphs
	n=itemsInList(grlist,";")
	do
		gname=StringFromList(i0,grlist)
		DoWindow/F $gname
		SavePICT/E=-5/P=graph_tmp/B=72
		i1=0
		trlist=TraceNamelist(gname,";",1)
		n1=ItemsInList(trlist,";")
		do // analyze traces in a graph
			yname=StringFromList(i1,trlist,";")
			xname=StringByKey("XWAVE",TraceInfo(gname,yname,0))
			print gname,":", yname, " vs ", xname
			i1+=1
		while(i1<n1)
		i0+=1
	while(i0<n)
	KillPath /Z graph_tmp
End

// FullPathToHomeFolder()
// Returns colon-separated path to experiment's home folder with trailing colon
// or "" if there is no home folder.
Function/S FullPathToHomeFolder()
	PathInfo home
	if (V_flag == 0)
		// The current experiment was never saved so there is no home folder
		return ""
	endif
 
	String path = S_path
	return path
End
 
Function CreateFolderInHomeFolder(folderName, symbolicPathName)
	String folderName				// Name of folder to be created
	String symbolicPathName		// Name to use for the symbolic path
 
	String fullPath = FullPathToHomeFolder()
	if (strlen(fullPath) == 0)
		// Error - there is no home folder because the current experiment was never saved
		return -1
	endif
	fullPath += folderName
	NewPath/O/C $symbolicPathName, fullPath
	return 0						// Success
End