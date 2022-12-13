#include "wname"
#include "GraphPlot"
#include "XYToWave2"
#include "DataSetOperations"

// Macro to load PL data taken by VEE programs
//      PLtest.vee, PL1-2, etc...
//
//		??/??/?? : first version ???
//		21/11/10 ver 0.2 : some updates
//		21/11/25 ver 0.2 : modified to work with DSO (SPC only)
 
Macro LoadPLdata(fileName,pathName,wvnamey,flag,flag2)
	String fileName, pathName="home", wvname
	Variable flag=2,flag2=1;
	Prompt flag,"channel y data ?",popup,"yes;yes_but_skip;no"
	Prompt flag2,"equal wavelength spacing ?", popup,"yes;intepolate;no"
	Silent 1; PauseUpDate
	
	FLoadPLdata(fileName,pathName,wvnamey,flag,flag2)
EndMacro

Function/T FLoadPLdata(fileName,pathName,wvnamey,flag,flag2)
	String fileName, pathName, wvnamey
	Variable flag,flag2;

	String w0,w1,w2,wvnameyL
	Variable ref,numpoints
	String retstr=""
	
	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=".dat" ref
		fileName= S_fileName
	endif
	
	LoadWave/G/D/A/W/P=$pathName fileName
	if(V_flag==0)
		return(retstr) 
	endif
	
	w0 = StringFromList(0,S_waveNames,";")	// wavelength
	w1 = StringFromList(1,S_waveNames,";")	// channel x
	if (flag != 3)
		w2 = StringFromList(2,S_waveNames,";")	// channel y (only for LIA detection)
	endif
	if(flag == 2)
		KillWaves $w2
	endif

	if (flag==1)
		Sort $w0, $w0, $w1,$w2
		WaveStats/Q $w0
		SetScale/I x,V_min,V_max,"nm",$w0,$w1,$w2
	else
		Sort $w0, $w0, $w1
		WaveStats/Q $w0
		SetScale/I x,V_min,V_max,"nm",$w0,$w1
	endif
	
	if(flag2==1)
		KillWaves $w0
	else
		if(flag2==2)
			numpoints = numpnts($w0)
			if(flag==1)
				XYtoWave2($w0,$w1,"tempx",numpoints)
				XYtoWave2($w0,$w2,"tempy",numpoints)
				KillWaves $w0,$w1,$w2
				Rename $"tempx",$w1
				Rename $"tempy",$w2
			else
				XYtoWave2($w0,$w1,"tempx",numpoints)
				KillWaves $w0,$w1,$w2
				Rename $"tempx",$w1
			endif
		endif
	endif

	wvnameyL="L"+wvnamey
	retstr=wvnameyL
	if (strlen(wvnamey)<1)
		wvnamey="W"+wname(fileName)
		wvnameyL="L"+wname(fileName)
		retstr=wvnamey
	endif

	print wvnamey
	if(flag==1)
		w0=wvnamey+"_y"
		wvnamey = wvnamey + "_x"
		Rename $w1,$wvnamey
		Rename $w2,$w0
	else
		Rename $w1,$wvnamey
	endif
	
	Duplicate/O $wvnamey,dummywave0
	if(flag2==2)
		Duplicate/O $wvnamey,dummyxwave
		Duplicate/O $wvnameyL,dummyywave		
	endif
	
	return(retstr)
End

Macro MultiPLdataLoad(thePath, wantToPrint,flag,flag2)
	String thePath="_New Path_"
	Variable wantToPrint=2
	Variable flag=2,flag2=1
	Prompt thePath, "Name of path containing text files", popup, PathList("*", ";", "")+"_New Path_"
	Prompt wantToPrint, "Do you want to print graphs?", popup, "Yes;No"
	Prompt flag,"channel y data ?",popup,"yes;yes_but_skip;no"
	Prompt flag2,"equal wavelength spacing ?", popup,"yes;intepolate;no"
	PauseUpdate;Silent 1
	
	FMultiPLdataLoad(thePath, wantToPrint,flag,flag2)
EndMacro

Function FMultiPLdataLoad(thePath, wantToPrint,flag,flag2)
	String thePath
	Variable wantToPrint,flag,flag2

	String ftype=".dat"
	String fileName
	Variable fileIndex=0, gotFile
	
	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif
	
	if(flag2==2)
		DoWindow /F Graphplotxy							// make sure Graphplot is front window
		if (V_flag == 0)								// Graphplot does not exist?
			Make/N=2/D/O dummyxwave0
			Make/N=2/D/O dummyywave0
			FGraphplotxy("wavelength","intensity")									// create it
		endif
	else
		DoWindow /F Graphplot							// make sure Graphplot is front window
		if (V_flag == 0)								// Graphplot does not exist?
			Make/N=2/D/O dummywave0
			FGraphplot("wavelength","intensity")									// create it
		endif
	endif

	do
		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path
		gotFile = CmpStr(fileName, "")
		if (gotFile)
			FLoadPLdata(fileName,thePath,"",flag,flag2)
			//LoadWave/G/P=$thePath/O/N=wave fileName		// load the waves from file
			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName
			DoUpdate		// make sure graph updated before printing
			if (wantToPrint == 1)
				Execute("PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1")	// print graph
			endif
		endif
		fileIndex += 1
	while (gotFile)									// until TextFile runs out of files
End

Function FMultiPLdataLoad_DSO(thePath, expnml,nmschm,which,dsetnm,wantToPrint,flag,flag2)
	String thePath,dsetnm,which
	Variable expnml,nmschm
	Variable wantToPrint,flag,flag2

	String ftype=".dat"
	String fileName
	Variable fileIndex=0, gotFile
	
	NVAR g_DSOindex
	String name,nametmp
	Variable wnlength,filenum=0
	String cmd
	
	// create data set
	FDSOinit0(dsetnm)
	DSOCreate0(0,1)
	dsetnm=dsetnm+num2istr(g_DSOindex-1)
	Wave/T wdsetnm=$dsetnm
	
	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif
	
	if(flag2==2)
		DoWindow /F Graphplotxy							// make sure Graphplot is front window
		if (V_flag == 0)								// Graphplot does not exist?
			Make/N=2/D/O dummyxwave0
			Make/N=2/D/O dummyywave0
			FGraphplotxy("wavelength","intensity")									// create it
		endif
	else
		DoWindow /F Graphplot							// make sure Graphplot is front window
		if (V_flag == 0)								// Graphplot does not exist?
			Make/N=2/D/O dummywave0
			FGraphplot("wavelength","intensity")									// create it
		endif
	endif

	do
		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path
		gotFile = CmpStr(fileName, "")
		if (gotFile)
			name=FLoadPLdata(fileName,thePath,"",flag,flag2)
			//LoadWave/G/P=$thePath/O/N=wave fileName		// load the waves from file
			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName
			DoUpdate		// make sure graph updated before printing
			if (wantToPrint == 1)
				Execute("PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1")	// print graph
			endif
			wdsetnm[fileNum]=name
			fileNum+=1
		endif
		fileIndex += 1
	while (gotFile)									// until TextFile runs out of files
End

Macro LoadPLdata_csv(fileName,pathName,wvnamey,flag2)
	String fileName, pathName="home", wvname
	Variable flag2=1;
	Prompt flag2,"equal wavelength spacing ?", popup,"yes;intepolate;no"
	Silent 1; PauseUpDate
	
	FLoadPLdata_csv(fileName,pathName,wvnamey,flag2)
EndMacro

Function/T FLoadPLdata_csv(fileName,pathName,wvnamey,flag2)
	String fileName, pathName, wvnamey
	Variable flag2;

	String w0,w1,w2,wvnameyL
	Variable ref,numpoints
	String retstr=""
	
	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=".csv" ref
		fileName= S_fileName
	endif
	
	LoadWave/G/D/A/W/O/P=$pathName fileName
		if(V_flag==0)
		return(retstr) 
	endif
	
	w0 = StringFromList(1,S_waveNames,";")	// wavelength
	w1 = StringFromList(2,S_waveNames,";")	// channel x

	Sort $w0, $w0, $w1
	WaveStats/Q $w0
	SetScale/I x,V_min,V_max,"nm",$w0,$w1
	
	if(flag2==1)
		KillWaves $w0
	else
		if(flag2==2)
			numpoints = numpnts($w0)
			XYtoWave2($w0,$w1,"tempx",numpoints)
			KillWaves $w0,$w1,$w2
			Rename $"tempx",$w1
		endif
	endif

	wvnameyL="L"+wvnamey
	retstr=wvnameyL
	if (strlen(wvnamey)<1)
		wvnamey="W"+wname(fileName)
		wvnameyL="L"+wname(fileName)
		retstr=wvnamey
	endif

	print wvnamey
	Rename $w1,$wvnamey
	
	Duplicate/O $wvnamey,dummywave0
	if(flag2==2)
		Duplicate/O $wvnamey,dummyxwave
		Duplicate/O $wvnameyL,dummyywave		
	endif
	
	return(retstr)
End

Macro MultiPLdataLoad_csv(thePath,nmschm,which,dsetnm,wantToPrint,flag2)
	String thePath="_New Path_",which="W",dsetnm="data"
	Variable nmschm=2,wantToPrint=2
	Variable flag2=1
	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Prompt nmschm,"wave naming scheme"
	Prompt which,"wave prefix"
	Prompt dsetnm, "prefix for dataset name"
	Prompt wantToPrint, "Do you want to print graphs?", popup, "Yes;No"
	Prompt flag2,"equal wavelength spacing ?", popup,"yes;intepolate;no"
	PauseUpdate;Silent 1
	
	Variable/G g_DSOindex
	FMultiPLdataLoad_csv(thePath,nmschm,which,dsetnm,wantToPrint,flag2)
EndMacro

Function FMultiPLdataLoad_csv(thePath,nmschm,which,dsetnm,wantToPrint,flag2)
	String thePath,dsetnm,which
	Variable nmschm
	Variable wantToPrint,flag2

	String ftype=".csv"
	String fileName
	Variable fileIndex=0, gotFile
	
	NVAR g_DSOindex
	String name,nametmp
	Variable wnlength,fileNum=0
	String cmd
	
	// create data set
	FDSOinit0(dsetnm)
	DSOCreate0(0,1)
	dsetnm=dsetnm+num2istr(g_DSOindex-1)
	Wave/T wdsetnm=$dsetnm

	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif
	
	if(flag2==2)
		DoWindow /F Graphplotxy							// make sure Graphplot is front window
		if (V_flag == 0)								// Graphplot does not exist?
			Make/N=2/D/O dummyxwave0
			Make/N=2/D/O dummyywave0
			FGraphplotxy("wavelength","intensity")									// create it
		endif
	else
		DoWindow /F Graphplot							// make sure Graphplot is front window
		if (V_flag == 0)								// Graphplot does not exist?
			Make/N=2/D/O dummywave0
			FGraphplot("wavelength","intensity")									// create it
		endif
	endif

	do
		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path
		gotFile = CmpStr(fileName, "")
		if (gotFile)
			name=FLoadPLdata_csv(fileName,thePath,"",flag2)
			//LoadWave/G/P=$thePath/O/N=wave fileName		// load the waves from file
			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName
			DoUpdate		// make sure graph updated before printing
			if (wantToPrint == 1)
				Execute("PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1")	// print graph
			endif
			wdsetnm[fileNum]=name
			fileNum+=1
		endif
		fileIndex += 1
	while (gotFile)									// until TextFile runs out of files
	
	Redimension/N=(filenum) $dsetnm
	DSODisplayTable(dsetnm)
End

// Macro to load PL data taken by spectramax program 
//      (SPC file with extention of "SPC")

Macro SPCload(name,file,path)
	String name,file
	String path="home"
	PauseUpdate; Silent 1
	
	FSPCload(name,file,path)
EndMacro

Function FSPCload(name,file,path)
	String name,file
	String path
	
	Variable /D ref,lhead,lblock,npoint,offreg,xmin,xmax,dx,skip,fnsub,fexp
	String xname

	if (strlen(file)<=0)
		Open /D/R/P=$path/T=".spc" ref
		file= S_fileName
	endif
	print file
	Open /R/P=$path/T=".spc" ref as file
	FsetPos ref,4
	FBinRead /B=3/F=3 ref,npoint
	FsetPos ref,8
	FBinRead /B=3/F=5 ref,xmin
	FsetPos ref,16
	FBinRead /B=3/F=5 ref,xmax
	FsetPos ref,24
	FBinRead /B=3/F=3 ref,fnsub
	skip = 512 + npoint*4+1
	FsetPos ref,skip
	FBinRead /B=3/F=1 ref,fexp
	Close ref

	dx=(xmax-xmin)/(npoint-1)
//	print npoint,xmin,xmax,dx,fexp

	skip=512
	GBLoadWave /N=$"dummyxwave"/T={2,2}/B=3/U=(npoint)/S=(skip)/W=1/P=$path file
	skip=512+npoint*4+32
	GBLoadWave /N=$"dummyywave"/T={32,2}/B=3/U=(npoint)/S=(skip)/W=1/Y={0,2^(fexp-32)}/P=$path file
	if (strlen(name)<1)
		name="W"+wname(file)
		xname="L"+wname(file)
	endif
	SetScale/I x xmin,xmax,"",dummyywave0
	duplicate /O dummyywave0,$name
	duplicate /O dummyxwave0,$xname
End

Function FSPCload2(name,fileName,thePath,expnml,nmschm,which)
	String name,fileName
	String thePath,which
	Variable expnml,nmschm
		
	Variable /D ref,lhead,lblock,npoint,offreg,xmin,xmax,dx,skip,fnsub,fexp
	Variable wnlength
	String xname,tmpname,tmpname2

	if (strlen(fileName)<=0)
		Open /D/R/P=$thePath/T=".spc" ref
		fileName= S_fileName
	endif
	print fileName
	Open /R/P=$thePath/T=".spc" ref as fileName
	FsetPos ref,4
	FBinRead /B=3/F=3 ref,npoint
	FsetPos ref,8
	FBinRead /B=3/F=5 ref,xmin
	FsetPos ref,16
	FBinRead /B=3/F=5 ref,xmax
	FsetPos ref,24
	FBinRead /B=3/F=3 ref,fnsub
	skip = 512 + npoint*4+1
	FsetPos ref,skip
	FBinRead /B=3/F=1 ref,fexp
	Close ref

	dx=(xmax-xmin)/(npoint-1)
//	print npoint,xmin,xmax,dx,fexp

	skip=512
	GBLoadWave /N=$"dummyxwave"/T={2,2}/B=3/U=(npoint)/S=(skip)/W=1/P=$thePath fileName
	skip=512+npoint*4+32
	GBLoadWave /N=$"dummyywave"/T={32,2}/B=3/U=(npoint)/S=(skip)/W=1/Y={0,2^(fexp-32)}/P=$thePath fileName
// Duplicate with a specified name
	if (strlen(name)<1)
		tmpname=wname(fileName)
		if(nmschm==0) // conventional naming scheme
			name="W"+tmpname
			xname="L"+tmpname
		elseif(nmschm<0)
			xname=which+tmpname+"_0"
			name=which+tmpname+"_1"
		else  // simplified naming schme (use only last "nmchm"-digits)
			wnlength=strlen(tmpname)
			tmpname2=tmpname[wnlength-nmschm,wnlength-1]
			xname=which+tmpname+"_0"
			name=which+tmpname+"_1"
		endif
	else
		tmpname=name
		xname=tmpname+"_0"
		name=tmpname+"_1"
	endif
	SetScale/I x xmin,xmax,"",dummyywave0
	duplicate /O dummyywave0,$name
	duplicate /O dummyxwave0,$xname
End


Macro MultiSPCLoad(thePath, nmschm,which,dsetnm,wantToPrint,flag)
	String thePath="_New Path_",which="W",dsetnm="data"
	Variable expnml=1,nmschm=2,wantToPrint=2
	Variable flag=1
	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Prompt nmschm,"wave naming scheme"
	Prompt which,"wave prefix"
	Prompt dsetnm, "prefix for dataset name"
	Prompt wantToPrint, "Do you want to print graphs?", popup, "Yes;No"
	Prompt flag,"swap wavelength ?",popup,"no;yes"
	PauseUpdate;	Silent 1

	Variable/G g_DSOindex
	FMultiSPCLoad(thePath, expnml,nmschm,which,dsetnm, wantToPrint,flag)
Endmacro

Function FMultiSPCLoad(thePath,expnml,nmschm,which,dsetnm,wantToPrint,flag)
	String thePath,which,dsetnm
	Variable expnml,nmschm,wantToPrint
	Variable flag
	
	String ftype=".spc"
	String fileName,name,nametmp
	Variable filenum=0, gotFile,wnlength
	NVAR g_DSOindex

	// create data set
	FDSOinit0(dsetnm)
	DSOCreate0(0,1)
	dsetnm=dsetnm+num2istr(g_DSOindex-1)
	Wave/T wdsetnm=$dsetnm
	
	if(nmschm==0)
		Make/T/N=1/O tmpnm
	endif

	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif
	
	DoWindow /F Graphplotxy							// make sure Graphplot is front window
	if (V_flag == 0)								// Graphplot does not exist?
		Make/N=2/D/O dummyxwave0
		Make/N=2/D/O dummyywave0
		FGraphplotxy("wavelength","count")									// create it
	endif
	
	do
		fileName = IndexedFile($thePath,filenum,ftype)			// get name of next file in path
		gotFile = CmpStr(fileName, "")
		if (gotFile)
			nametmp=wname(fileName)
			wnlength=strlen(nametmp)
			if(nmschm==0)
				Redimension/N=(filenum+1) tmpnm
				tmpnm[filenum]=nametmp
				name=which+num2istr(filenum)
				print fileName,":",name
			elseif (nmschm <0)
				name=which+nametmp
				print filename, ":",name
			else // conventional naming scheme with
				name=which+nametmp[wnlength-nmschm,wnlength-1]
				print fileName
			endif
			FSPCload2(name,fileName,thePath,expnml,nmschm,which)
			//LoadWave/G/P=$thePath/O/N=wave fileName		// load the waves from file
			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName
			DoUpdate		// make sure graph updated before printing
			if (wantToPrint == 1)
				Execute("PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1")	// print graph
			endif
		endif
		print dsetnm,filenum,name
		wdsetnm[filenum]=name
		filenum += 1
	while (gotFile)									// until TextFile runs out of files
	
	Redimension/N=(filenum) $dsetnm
	DSODisplayTable(dsetnm)
	if(nmschm==0)
		Edit tmpnm
	Endif
End

// Macro to load PL data taken by spectramax program 
//      (converted ascii file, with extention of "PRN")
//

Macro LoadPRNfileData(wvnamey,fileName,pathName,flag)
	String fileName, pathName="home", wvnamey
	Variable flag=1
	Prompt flag,"swap wavelength ?",popup,"no;yes"

	Silent 1; PauseUpDate
	FLoadPRNfileData(wvnamey,fileName,pathName,flag)
EndMacro

Function/T FLoadPRNfileData(wvnamey,fileName,pathName,flag)
	String fileName, pathName, wvnamey
	Variable flag

	String w0,w1
	Variable ref
	String retstr=""
	
	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=".PRN" ref
		fileName= S_fileName
	endif
	
	Print fileName
	
	LoadWave/G/D/A/W/P=$pathName fileName
	if(V_flag==0)
		return(retstr)
	endif
	
	w0 = StringFromList(0,S_waveNames,";")
	w1 = StringFromList(1,S_waveNames,";")

	if(flag==2)
		Sort/R $w0,$w0,$w1
		Print "Data is swaped !!"
	else
		Sort $w0,$w0,$w1
	endif
	WaveStats/Q $w0
	SetScale/I x,V_min,V_max,"nm",$w1
	
	KillWaves $w0


	if (strlen(wvnamey)<1)
		wvnamey="W"+wname(fileName)
	endif
	
	Rename $w1,$wvnamey

	Duplicate/O $wvnamey,dummywave0
//	Display dummywave0
	return(retstr)
End

Macro MultiPRNfileLoad(thePath, wantToPrint,flag)
	String thePath="_New Path_"
	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Variable wantToPrint=2
	Prompt wantToPrint, "Do you want to print graphs?", popup, "Yes;No"
	Variable flag=1
	Prompt flag,"swap wavelength ?",popup,"no;yes"
	String ftype=".PRN"
	
	PauseUpdate;Silent 1

	FMultiPRNfileLoad(thePath, wantToPrint,flag)
End Macro

Function FMultiPRNfileLoad(thePath, wantToPrint,flag)
	String thePath
	Variable wantToPrint
	Variable flag
	
	String ftype=".PRN"
	String fileName
	Variable fileIndex=0, gotFile
	
	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif
	
	DoWindow /F Graphplot							// make sure Graphplot is front window
	if (V_flag == 0)								// Graphplot does not exist?
		Make/N=2/D/O dummywave0
		FGraphplot("wavelength","counts")									// create it
	endif
	
	do
		fileName = IndexedFile($thePath,fileIndex,ftype)			// get name of next file in path
		gotFile = CmpStr(fileName, "")
		if (gotFile)
			 FLoadPRNFileData("",fileName,thePath,flag)
			//LoadWave/G/P=$thePath/O/N=wave fileName		// load the waves from file
			Textbox/C/N=tb_file/F=0/A=MT/X=-30/Y=5 "File: "+fileName
			DoUpdate		// make sure graph updated before printing
			if (wantToPrint == 1)
				Execute("PrintGraphs/R Graphplot(2, 2, 98, 98)/F=1")	// print graph
			endif
		endif
		fileIndex += 1
	while (gotFile)									// until TextFile runs out of files
End


// name of waves depending on nmschm
// nmschm:
//		0 "W"+tmpname
//		>0
//		<0
Function/T DSONameWave1(fileName,which,DSname,fileIndex,nmschm,index,flag)
	String filename,which,DSName
	Variable fileIndex,nmschm,index,flag

	String name,nametmp
	Wave/T tmpnm=$DSname
	Variable wnlength

	nametmp=wname(fileName)
	wnlength=strlen(nametmp)
	if(nmschm==0)
		Redimension/N=(fileIndex+1) tmpnm
		tmpnm[fileIndex]=nametmp
		name=which+num2istr(fileIndex)
		print fileName,":",name
	elseif (nmschm <0)
		name=which+nametmp
		print filename, ":",name
	else // conventional naming scheme with
		name=which+nametmp[wnlength-nmschm,wnlength-1]
		print fileName
	endif
	return name
End

Function/T DSONameWave2(name,file,which,nmschm)
	String name,file,which
	Variable nmschm
	
	String tmpname,tmpname2
	Variable wnlength
	
	if (strlen(name)<1)
		tmpname=wname(file)
		if(nmschm==0) // conventional naming scheme
//			name="W"+tmpname
//			xname="L"+tmpname
			name=tmpname
		elseif(nmschm<0)
//			xname=which+tmpname+"_0"
//			name=which+tmpname+"_1"
			name=which+tmpname
		else  // simplified naming schme (use only last "nmchm"-digits)
			wnlength=strlen(tmpname)
			tmpname2=tmpname[wnlength-nmschm,wnlength-1]
//			xname=which+tmpname+"_0"
//			name=which+tmpname+"_1"
			name=which+tmpname2
		endif
	else
		tmpname=name
//		xname=tmpname+"_0"
//		name=tmpname+"_1"
		name=tmpname
	endif
	
	return name
End

Function/T DSONameWave_x(name,nmschm)
	String name
	Variable nmschm
	
	if(nmschm==0)
		name="L"+name
	else
		name=name+"_0"
	endif
	return name
End

Function/T DSONameWave_y(name,nmschm)
	String name
	Variable nmschm
	
	if(nmschm==0)
		name="W"+name
	else
		name=name+"_1"
	endif
	return name
End
