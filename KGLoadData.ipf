#pragma rtGlobals=1		// Use modern global access method.
#include "StrRpl"

// KGLoadData.ipf
// load KaleidaGraph QDA file
// based on kgraph.py by Christoph Gohlke <http://www.lfd.uci.edu/~gohlke/>

//	revision history
//		11/03/30		ver 0.1	first version

// To do :
// load column data type for DATE, TIME, TEXT

Macro KGLoadInit()
	PauseUpdate;Silent 1
	Variable/G g_index
	Make/T/N=1 W_folder, W_file, W_header,W_wname
	Edit W_folder, W_file, W_header, W_wname
End

Macro KGLoad(name,file,path)
	String name,file
	String path
	Prompt name,"wave name"
	Prompt file,"file name"
	Prompt path,"path name"
	PauseUpdate; Silent 1
	
	String extstr=".QDA",pathstr,name2,name3
	String str
	Variable ref,index,val,skip
	Variable fileid,numcol
//	print extstr

	if (strlen(file)<=0)
		if(strlen(path)==0)
			Open /D/R/T=(extstr) ref
		else
			Open /D/R/P=$path/T=(extstr) ref
		endif
		file= S_fileName
	endif
	print file

	Open/R/P=$path/T=(extstr) ref as file
	// read file id (2byte integer), should be 6 or 8 or 12
	FBinRead/B=2/F=2 ref,fileid
	print "fileid=",fileid
	
	// read number of columns (2byte integer)
	FBinRead/B=2/F=2 ref,numcol
	print "number of colums=",numcol
	Make/O/D/N=(numcol) JMKG_numrow
	Make/O/T/N=(numcol) JMKG_header
	
	// read numberof rows in each column (4byte integer)
	skip=512
	FSetPos ref,skip
	index=0
	do
		FBinRead/B=2/F=3 ref,val // assume fileid is 12 (4byte), else, it should be /F=2 (2byte)
		JMKG_numrow[index]=val
		index+=1
	while(index<numcol)
	print "number of rows :",JMKG_numrow
	skip=512+numcol*4

// read datatypes: 0: 4 byte float (single precision), 3: 8 byte float (double precision), 4: 4 byte integer
	// currently, assume everthing is f4
	Make/O/D/N=(numcol) JMKG_dtype,JMKG_dlength
	index=0
	do
		FBinRead/B=2/F=2 ref,val
		if(val==0)
			JMKG_dtype[index]=2
			JMKG_dlength[index]=4
		else
			if(val==3)
				JMKG_dtype[index]=4
				JMKG_dlength[index]=8
			else
				if(val==4)
					JMKG_dtype[index]=32
					JMKG_dlength[index]=4
				else
					JMKG_dtype[index]=2
					JMKG_dlength[index]=4
				endif
			endif			
		endif
 		index+=1
 	while(index<numcol)
 	print "data types :",JMKG_dtype
 	
// read headers
	String header
	skip=skip+2*numcol
	header=PadString(header,40,0)
	index=0
	do
		FSetPos ref,skip+index*40
		FBinRead ref,header
//		print header
		JMKG_header[index]=header
		index+=1
	while(index<numcol)
	print "KG headers :",JMKG_header
	
	Close ref
	Variable skip0
	skip0=skip+40*numcol
	
// read data
	Variable dtype,dlength,npoint
	dtype=2 // assume floting point 
	dlength=4
	index=0
	skip=skip0
	do
		npoint=JMKG_numrow[index]
		dtype=JMKG_dtype[index]
		dlength=JMKG_dlength[index]
		if(npoint!=0)
			if(strlen(path)==0)
				GBLoadWave/Q/N=dummy/T={(dtype),4}/B=0/S=(skip)/U=(npoint)/W=1 file
			else
				GBLoadWave/Q/N=dummy/T={(dtype),4}/B=0/S=(skip)/U=(npoint)/W=1/P=$path file
			endif
			Redimension/N=(g_index+1) W_folder,W_file, W_header,W_wname
//			print ParseFilePath(1, file, ":", 1, 0)
//			W_folder[g_index]=ParseFilePath(1, file, ":", 1, 0)
			if(strlen(path)==0)
				W_folder[g_index]=ParseFilePath(1, file, ":", 1, 0)
			else
				PathInfo $path
				W_folder[g_index]=S_path
			endif
			W_file[g_index]=ParseFilePath(0, file, ":", 1, 0)
			sprintf str,"%s",JMKG_header[index]
			W_header[g_index]=str
			W_wname[g_index]="KG"+num2str(g_index)
//			name3=strrpl(JMKG_header[index],"-","_")
			if(strlen(name)==0)
				if(cmpstr(name3,"E")==0)
					name3=name3+name3
				endif
				sprintf name2,"%s",strrpl(JMKG_header[index],"-","_")
			else
				sprintf name2,"%s_%s",name,strrpl(JMKG_header[index],"-","_")
			endif
			if(cmpstr(name2,"E")==0)
				name2="EE"
			endif
			if(cmpstr(name2,"I")==0)
				name2="II"
			endif
			if(cmpstr(name2,"J")==0)
				name2="JJ"
			endif
			Duplicate/O dummy0,$name2
			Duplicate dummy0,$W_wname[g_index]
			print "data loaded into \"",name2,"\" and  ","\"",W_wname[g_index],"\""
			skip+=dlength*npoint+2*npoint
			g_index+=1
		endif
		skip+=136
		index+=1
	while(index<numcol)
End

Macro MultiKGLoad(thePath,bname)
	String thePath="_New_Path_",bname="KG"
	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New_Path_"
	Prompt bname,"base name for wave"
	PauseUpdate; Silent 1
	
	String ftype
	ftype=".qda"
	if (CmpStr(thePath, "_New_Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif

	Variable index=0,gotfile
	String name,fileName
	do
		fileName = IndexedFile($thePath,index,ftype)			// get name of next file in path
		gotFile = CmpStr(fileName, "")
		if (gotFile)
			name=bname+num2str(index)
			KGLoad(name,fileName,thePath)
			index+=1
		endif
	while(gotfile)
End
