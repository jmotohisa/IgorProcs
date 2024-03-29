#pragma rtGlobals=1		// Use modern global access method.

// LoadDelftData.ipf
// by J. Motohisa
// load single and multiple data saved by "MeasureDelft" program
//
// requires: "wname","MatrixOperations2"
//		note: MatrixOperations2 requires "JEG Tools" (http://www.his.com/jguyer/)

//	revision history
//		2000/11/?? ver 0.01: first version @delft
// ... many revisions
//		2005/01/08 ver 0.2 : 
//		2007/04/27: strrpl is now in another procedure
//		2017/07/26	ver 0.3: making compatibility with DataSetOperations
//		2017/10/17: load multiple data and cocatanate
//		2021/10/28: ability to load time series data of MeasureDelft3
//		2021/11/10: load MCA data file of multiple storage

//#include <Strings as Lists>
#include "wname"
#include "StrRpl"
#include "MatrixOperations2"
#include "DataSetOperations"
#include "JMGraphStyles"

Macro LoadDelftData(fileName,pathName,scalex,scaley,numdat,wantToDisp,convMat,iformat,fdso)
	String fileName
	String pathName="home"
	Variable scalex=1e6,scaley=1e12,wantToDisp=2,convMat=2,numdat=1,iformat=3,fdso=2
	Prompt wantToDisp, "Do you want to display graphs?", popup, "Yes;No"
	Prompt convMat, "Do you want to convert into Matrix?", popup, "Yes;No"
	Prompt numdat,"Number of measurement per each scan"
	Prompt iformat,"data format",popup,"Delft;Hokudai;Hokudai new;Hokudai time"
	Prompt fdso,"add to dataset ?",popup,"yes;no"

	Silent 1; PauseUpDate
	FLoadDelftData(fileName,pathName,scalex,scaley,numdat,wantToDisp,convMat,iformat)
End

Function/S FLoadDelftData(fileName,pathName,scalex,scaley,numdat,wantToDisp,convMat,iformat)
	String fileName
	String pathName
	Variable scalex,scaley,wantToDisp,convMat,numdat,iformat
	
	String dwname,xwname,ywname,destw,destw0,wnames,cmdstr,buffer
	Variable ref
	Variable index,index1,index2
	String retstr=""
	
	if (strlen(fileName)<=0)
		if(CmpStr(IgorInfo(2), "Macintosh") == 0)
//			Open /D/R/P=$pathName/T="sGBWTEXT" ref // MacOS
			Open /D/R/P=$pathName/T=".DAT" ref // windows
		else
			Open /D/R/P=$pathName/T=".DAT" ref // windows
		endif
		fileName= S_fileName
		print filename
	endif
	
	if(iformat==3)
		Open /R/P=$pathName/T="TEXT" ref as fileName
		FReadLine ref,buffer
		numdat = str2num(buffer)
	endif

	LoadWave/G/D/N=$"dummy"/W/P=$pathName/Q fileName
	if(V_flag==0)
		return(retstr)
	endif
	
//	print S_wavenames
	
	destw0=strrpl(wname(fileName),"-","_")
	index=0
	index1=0
	if(wantToDisp==1 %& convMat ==2)
		Display /W=(3,41,636,476)
	endif

	if(iformat!=4) // time series
	do
		dwname = StringFromList(index,S_waveNames,";")
		if(strlen(dwname)==0)
			break
		endif
		xwname=StringFromList(index+1,S_waveNames,";")
		Wave wxwv=$xwname
		wxwv/=scalex
		index2=0
		wnames=""
		do
			if(index2==numdat)
				break
			endif
			ywname=StringFromList(index+2+index2,S_waveNames,";")
			Wave yxwv=$ywname
			yxwv /=scaley
			wnames=wnames+","+ywname
			index2+=1
		while(1)
		cmdstr="Sort "+xwname+","+xwname+wnames
		Execute cmdstr
		WaveStats/Q $xwname
		index2=0
		do
			if(index2==numdat)
				break
			endif
			ywname=StringFromList(index+2+index2,S_waveNames,";")
			SetScale/I x,V_min,V_max,"V",$ywname
			SetScale y,0,1,"A",$ywname
			if(numdat==1)
				destw=destw0+"_"+num2istr(index1)
				Duplicate/O $ywname,$destw
			else
				destw=destw0+"_"+num2istr(index2)+"_"+num2istr(index1)
				Duplicate/O $ywname,$destw
			endif
			retstr=retstr+destw+";"
			if(wantToDisp==1 %& convMat ==2)
				AppendToGraph $destw
			endif
			index2+=1
		while(1)
		index+=2+numdat
		index1+=1
	while(1)
	else // time data
		index=0
		do
			ywname = StringFromList(index,S_waveNames,";")
			if(strlen(ywname)==0)
				break
			endif
			Wave yxwv=$ywname
			yxwv /=scaley
			destw=destw0+"_"+num2istr(index)
			Duplicate/O yxwv,$destw
			if(wantToDisp==1 %& convMat ==2)
				AppendToGraph $destw
			endif
			index+=1
		while(1)
		retstr=retstr+destw0+";"
	endif
	
	if(wantToDisp==1 %& convMat ==2)
		Legend/N=text0/F=0/A=MC/X=-38.04/Y=39.31
		Label left "Current (\\U)"
		Label bottom "Voltage (\\U)"
		Execute("ColorWaves()")
	endif
	
	if(convMat==1 %& numdat==1)
		FWavesToMatrix(destw0+"_","","M"+destw0,0,index1,1)
		retstr="M"+destw0
	endif
	return(retstr)
End

Macro LoadDelftDataAll(pathName,scalex,scaley,numdat,wantToDisp,convmat,iformat,fdso,dsetnm)
	Variable scalex=1e6,scaley=1e12
	String pathName="_New Path_",dsetnm="data"
	Variable wantToDisp=1,iformat=3,convmat=2,numdat=1,fdso=1
	Prompt pathName, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Prompt wantToDisp, "Do you want to display graphs?", popup, "Yes;No"
	Prompt convMat, "Do you want to convert into Matrix?", popup, "Yes;No"
	Prompt numdat,"Number of measurement per each scan"
	Prompt iformat,"data format",popup,"Delft;Hokudai;Hokudai new;Hokudai time"
	Prompt fdso,"use dataset?",popup,"yes;no"
	Prompt dsetnm,"data set name"

	Silent 1; PauseUpDate
	Variable/G g_DSOindex
	FLoadDelftDataAll(pathName,scalex,scaley,numdat,wantToDisp,convmat,iformat,fdso,dsetnm)
End

Function FLoadDelftDataAll(pathName,scalex,scaley,numdat,wantToDisp,convmat,iformat,fdso,dsetnm)
	Variable scalex,scaley
	String pathName,dsetnm
	Variable wantToDisp,iformat,convmat,numdat,fdso
	
	String fileName,ftype,wvs,wvs0
	NVAR g_DSOindex

// dataset operation
	if(fdso==1)
		FDSOinit0(dsetnm)
		DSOCreate0(0,1)
		dsetnm=dsetnm+num2istr(g_DSOindex-1)
		Wave/T wdsetnm=$dsetnm
	endif

	Variable index=0,index2=0,index3=0
	if(CmpStr(IgorInfo(2), "Macintosh") == 0)
//		ftype="TEXT"
		ftype=".DAT"
	else
		ftype=".DAT"
	endif

	if (CmpStr(PathName, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		PathName = "data"
	endif
	
	do
		fileName = IndexedFile($pathName, index,ftype)
		if(strlen(fileName)==0)
			break
		endif
		Print "loding file ",filename
		wvs=FLoadDelftData(fileName,pathName,scalex,scaley,numdat,wantToDisp,convmat,iformat)
		index+=1
		if(fdso==1)
			index2=0
			do
				wvs0=StringFromList(index2,wvs,";")
				if(strlen(wvs0)<=0)
					break
				endif
				wdsetnm[index3]=wvs0
				index2+=1
				index3+=1
			while(1)
		endif			
	while(1)
	
	if(Exists("temporaryPath"))
		KillPath temporaryPath
	endif
	
	if(fdso==1)
		Redimension/N=(index3) wdsetnm
	endif
End

Macro PrintDelftDataComment(filename,pathname)
	String fileName
	String pathName="home"
//	Variable scalex=1e6,scaley=1e12,wantToDisp=1,convMat=2
//	Prompt wantToDisp, "Do you want to display graphs?", popup, "Yes;No"
//	Prompt convMat, "Do you want to convert into Matrix?", popup, "Yes;No"

	Silent 1; PauseUpDate

	String dwname,xwname,ywname,destw,destw0,cmt,dummy
	Variable ref
	Variable index,index1
	
	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T="sGBWTEXT" ref
		fileName= S_fileName
	endif
	
	print filename
	Open /R/P=$pathName/T="sGBWTEXT" ref as fileName
	FReadLine ref,dummy
	print dummy
	index=1
	do
		cmt=FindScanNum(ref,index)
		if(strlen(cmt)==0)
			break
		endif
		print cmt
		index+=1
	while(1)
	close ref
End	
	
Function/S FindScanNum(fileVar,scanNum)	// search for start of scan
	Variable fileVar		// file ref number
	Variable scanNum		// scan number to find

	if (scanNum<0)
		return ""
	endif
	String search = "-"+num2istr(scanNum)+"L"

	String buffer=" "		// set up large buffer for reading data file
	Variable bufSize=5e5
	Variable Nread=strlen(search)+bufSize
	buffer = PadString(buffer, Nread, 0)

	FStatus fileVar
	Variable fpos0=V_filePos
	Variable more=1,i,j=-bufSize

	do
		j += bufSize
		FSetPos fileVar, (j+fpos0)
		FStatus fileVar
		if ((V_logEOF-V_filePos)<Nread)	// not enough data to fill buffer
			buffer = ""
			buffer = PadString(buffer,V_logEOF-V_filePos, 0)
			more = 0
		endif
		FBinRead fileVar, buffer	// read next buffer full of data
		i = strsearch(buffer, search, 0)// check
	while ((i<0) %& more)			// continue if not found and more data in file

	if (i<0)				// not found
		return ""
	endif

	FSetPos fileVar, (i+j+fpos0)
	String line=" "
	FReadLine fileVar, line
	return line
End

Macro DisplayDelftData(wname)
	String wname="_"
	Prompt wname,"Starting Strings of the wave name"
	Silent 1;PauseUpdate
	
	String wn0
	Variable index=0
	Display /W=(3,41,636,476)
	
	do
		wn0=wname+num2istr(index)
		if(waveExists($wn0)==0)
			break
		endif
		Append $wn0
		index+=1
	while(1)
EndMacro

Macro ColorWaves() : GraphStyle
	Modify/Z minor(bottom)=1
	Modify/Z rgb[0]=(65535,0,0)
	Modify/Z rgb[1]=(0,0,65535),rgb[2]=(3009,65535,1882),rgb[3]=(0,0,0)
	Modify/Z rgb[4]=(0,0,65535),rgb[5]=(63953,3661,65535)
	Modify/Z rgb[6]=(37510,1,1),rgb[7]=(27232,40528,22540),rgb[8]=(1531,1314,28456)
	Modify/Z mode=4
	Modify/Z marker[0] = 11,mode=4,marker[1] = 12,mode=4,marker[2] = 13
	Modify/Z marker[3] = 14,mode=4,marker[4] = 15,mode=4,marker[5] = 16
	Modify/Z marker[6] = 17,mode=4,marker[7] = 18,mode=4,marker[8] = 19
	Silent 1;PauseUpdate
End

Macro ResetColorWaves() : GraphStyle
	Silent 1;PauseUpdate
	Modify/Z minor(bottom)=1
	Modify/Z rgb=(65535,0,0)
	Modify/Z mode=0
End

Macro KillDummyWaves()
	Silent 1;PauseUpdate
	Variable index=0
	String dummy
	do
		dummy="dummy"+num2istr(index)
		if(waveExists($dummy)==0)
			break
		endif
		KillWaves $dummy
		index+=1
	while(1)
EndMacro

Proc LoadDelftDataDSOthePath, expnml,nmschm,which,dsetnm,wantToPrint,flag)
	String thePath,which,dsetnm
	Variable expnml,nmschm,wantToPrint
	Variable flag

	String fileName,ftype
	Variable fileIndex=0, gotFile
	String name,nametmp
	Variable wnlength,filenum=0
	String cmd
	NVAR g_DSOindex

	FDSOinit0(dsetnm)
	DSOCreate0(0,1)
	dsetnm=dsetnm+num2istr(g_DSOindex-1)
	Wave/T wdsetnm=$dsetnm
End

Macro InvertPolarity(wvname,opt)
	String wvname
	Variable opt=3
	Prompt wvname,"wave name"
	Prompt opt,"invert",popup,"x;y;xy";	
	PauseUpdate; Silent 1

	FInvertPolarity(wvname,opt)	
End

#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Macro LoadDelftData_mul(fileName,pathName,scalex,scaley,numdat,wantToDisp,concat,convMat,fdso)
	String fileName
	String pathName="home"
	Variable scalex=1e6,scaley=1e12,wantToDisp=2,convMat=2,numdat=1,fdso=2,concat=1
	Prompt wantToDisp, "Do you want to display graphs?", popup, "Yes;No"
	Prompt concat,"Concatante or convert column data?",popup,"Concat;Matrix;No"
	Prompt convMat, "Do you want to convert into Matrix?", popup, "Yes;No"
	Prompt numdat,"Number of measurement per each scan"
	Prompt fdso,"add to dataset ?",popup,"yes;no"

	Silent 1; PauseUpDate
	FLoadDelftData_mul(fileName,pathName,scalex,scaley,numdat,wantToDisp,concat,convMat,fdso)
End


Function/S FLoadDelftData_mul(fileName,pathName,scalex,scaley,numdat,wantToDisp,concat,convMat,fdso)
	String fileName
	String pathName
	Variable scalex,scaley,wantToDisp,convMat,numdat,fdso,concat
	
	String dwname,ywname,destw,destw0,wnames,cmdstr,buffer
	Variable ref
	Variable index,index1,index2
	String retstr=""
	
	if (strlen(fileName)<=0)
		if(CmpStr(IgorInfo(2), "Macintosh") == 0)
//			Open /D/R/P=$pathName/T="sGBWTEXT" ref // MacOS
			Open /D/R/P=$pathName/T=".DAT" ref // windows
		else
			Open /D/R/P=$pathName/T=".DAT" ref // windows
		endif
		fileName= S_fileName
		print filename
	endif
	
	LoadWave/G/D/N=$"dummy"/W/P=$pathName/Q fileName
	if(V_flag==0)
		return(retstr)
	endif
//	print S_wavenames
	
	destw0=strrpl(wname(fileName),"-","_")
	index=0
	index1=0
	if(wantToDisp==1 %& convMat ==2)
		Display /W=(3,41,636,476)
	endif

	Variable nload=ItemsInList(S_WaveNames,";")
	if(concat==3)
		do
			if(index>nload)
				break
			endif
			index2=0
			wnames=""
			do
				if(index2==numdat)
					break
				endif
				ywname=StringFromList(index+index2,S_waveNames,";")
				Wave yxwv=$ywname
				yxwv/=scaley
//			SetScale y,0,1,"V",$ywname
				if(numdat==1)
					destw=destw0+"_"+num2istr(index1)
					Duplicate/O $ywname,$destw
				else
					destw=destw0+"_"+num2istr(index2)+"_"+num2istr(index1)
					Duplicate/O $ywname,$destw
				endif
				retstr=retstr+destw+";"
				if(wantToDisp==1 %& convMat ==2)
					AppendToGraph $destw
				endif
				index2+=1
			while(1)
			index1+=1
			index+=numdat
		while(1)
	
	if(wantToDisp==1 %& convMat ==2)
		Legend/N=text0/F=0/A=MC/X=-38.04/Y=39.31
		Label left "Current (\\U)"
		Label bottom "Voltage (\\U)"
//		Execute("ColorWaves()")
	endif
	
	if(convMat==1 %& numdat==1)
		FWavesToMatrix(destw0+"_","","M"+destw0,0,index1,1)
		retstr="M"+destw0
	endif

	else // concatnate or matrix
		String cmd
		index2=0
		do
			if(index>=nload)
				break
			endif
			destw=destw0+"_"+num2istr(index2)
			if(concat==1)
				cmd="Concatenate/NP/O/D {"
			else
				cmd="Concatenate/O/D {"
			endif
			index1=0
			do
				if(index2+index1*numdat>=nload)
					break
				endif
				ywname=StringFromList(index2+index1*numdat,S_WaveNames,";")
				if(index1!=0)
					cmd = cmd+","
				endif
				cmd = cmd+ywname
				index1+=1
				index+=1
			while(1)
			cmd=cmd+"},"+destw
			print cmd
			Execute cmd
			Wave yxwv=$destw
			yxwv/=scaley
			if(wantToDisp==1)
				AppendToGraph yxwv
			endif
			retstr=retstr+destw+";"
			index2+=1
		while(1)
	endif

	return(retstr)
End

Function/S FLoadDelftData_MCA(fileName,pathName,wvname,dt,fswap,wantToDisp)
	String fileName
	String pathName,wvname
	Variable dt,fswap,wantToDisp
	
	String dwname,xwname,ywname,destw,destw0,wnames,cmdstr,buffer
	Variable ref
	Variable index
	String retstr=""
	
	if (strlen(fileName)<=0)
		if(CmpStr(IgorInfo(2), "Macintosh") == 0)
//			Open /D/R/P=$pathName/T="sGBWTEXT" ref // MacOS
			Open /D/R/P=$pathName/T=".DAT.MCA" ref // windows
		else
			Open /D/R/P=$pathName/T=".DAT.MCA" ref // windows
		endif
		fileName= S_fileName
		print filename
	endif
	
	LoadWave/G/D/N=$"dummy"/W/P=$pathName/Q fileName
	if(V_flag==0)
		return(retstr)
	endif
	
//	print S_wavenames

	if(strlen(wvname)==0)
		destw0=strrpl(wname(fileName),"-","_")
	else
		destw0=wvname
	endif
	index=0
	if(wantToDisp==1)
		Display /W=(3,41,636,476)
	endif
	
	index=0
	do
		dwname = StringFromList(index,S_waveNames,";")
		if(strlen(dwname)==0)
			break
		endif
		wave yxwv=$dwname

		if(dt>0)
			SetScale/P x,0,dt,"s",yxwv
		else
			SetScale/I x,0,10,"V",yxwv
		endif
		if(fswap==1)
			Reverse yxwv
		endif
		destw=destw0+"_"+num2istr(index)
		Duplicate/O yxwv,$destw
		if(wantToDisp==1)
			AppendToGraph $destw
		endif
		retstr=retstr+destw+";"
		index+=1
	while(1)
	
	if(wantToDisp==1)
		Legend/N=text0/F=0/A=MC/X=-38.04/Y=39.31
		Label left "Count (\\U)"
		Label bottom "time (\\U)"
		Execute("ColorWaves()")
	endif
	
	return(retstr)
End

Function FLoadDelftData_MCAAll(pathName,dt,fswap,wantToDisp,fdso,dsetnm)
	Variable dt,fswap, wantToDisp,fdso
	String pathName,dsetnm
	
	String fileName,ftype,wvs,wvs0,wvname
	NVAR g_DSOindex

// dataset operation
	if(fdso==1)
		FDSOinit0(dsetnm)
		DSOCreate0(0,1)
		dsetnm=dsetnm+num2istr(g_DSOindex-1)
		Wave/T wdsetnm=$dsetnm
	endif

	Variable index=0,index2=0,index3=0,pos
	if(CmpStr(IgorInfo(2), "Macintosh") == 0)
//		ftype="TEXT"
		ftype=".DAT"
	else
		ftype=".DAT"
	endif

	if (CmpStr(PathName, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		PathName = "data"
	endif
	
	do
		fileName = IndexedFile($pathName, index,ftype)
		if(strlen(fileName)==0)
			break
		endif
		pos=strsearch(filename,"_mul",0)
		if(pos>0)
			Print "loding file ",filename
			wvname=wname(filename)
			wvname=wvname[0,strlen(wvname)-5] // take out "_mul"
			wvs=FLoadDelftData_MCA(fileName,pathName,wvname,dt,fswap,wantToDisp)
			if(fdso==1)
				index2=0
				do
					wvs0=StringFromList(index2,wvs,";")
					if(strlen(wvs0)<=0)
						break
					endif
					wdsetnm[index3]=wvs0
					index2+=1
					index3+=1
				while(1)
			endif
		endif
		index+=1
	while(1)
	
	if(Exists("temporaryPath"))
		KillPath temporaryPath
	endif
	
	if(fdso==1)
		Redimension/N=(index3) wdsetnm
	endif
End

Macro LoadDelftData_MCAAll(pathName,dt,fswap,wantToDisp,fdso,dsetnm)
	Variable dt=1e-12,fswap=1
	String pathName="_New Path_",dsetnm="data"
	Variable wantToDisp=1,fdso=1

	Prompt pathName, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Prompt dt,"time division"
	Prompt fswap,"swap spectra ?",popup,"Yes;No"
	Prompt wantToDisp, "Do you want to display graphs?", popup, "Yes;No"
	Prompt fdso,"use dataset?",popup,"yes;no"
	Prompt dsetnm,"data set name"
	
	FLoadDelftData_MCAAll(pathName,dt,fswap,wantToDisp,fdso,dsetnm)
End