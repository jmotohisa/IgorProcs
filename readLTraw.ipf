#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// readLTraw.ipf
// read LTspice raw data
// rename, split, and plot data

// revision history
//		14/10/03-14/10/04	ver 0.1: first version

#include "MatrixOperations2"

Macro LTReadRaw(fname,path,wvheader,fheader)
	String fname,path,wvheader="header"
	Variable fheader=1
	Prompt fname,"file name"
	Prompt path,"path name"
	Prompt wvheader,"header wave name"
	Prompt fheader,"print header ?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	String xwv,ywv
	xwv="xdata"
	ywv="ydata"
	FLTReadRaw(fname,path,wvheader,xwv,ywv,fheader)
End

Macro LTDisplay0(xwv0,ywv0,wvheader,index,fsplit,num_row,num_column)
	String xwv0="xdata",ywv0="ydata",wvheader="header"
	Variable index=1,fsplit=1,num_row,num_column
	Prompt xwv0,"x-data"
	Prompt ywv0,"y-data"
	Prompt wvheader,"header wave name"
	Prompt index,"data index to plot (>0)"
	Prompt fsplit,"split data ?",popup,"yes;no"
	PauseUpdate; Silent 1

	String xwv,ywv
	Variable numvars,numpoints
	xwv=LTRename(xwv0,0,wvheader)
	ywv=LTRename(ywv0,index,wvheader)
	numvars=LTheaderToNum(4,$wvheader)-1
	numpoints=LTheaderToNum(5,$wvheader)

	if(fsplit==1)
		SplitData_x(xwv,num_row,num_column)
		SplitData(ywv,num_row,num_column)
	endif
	
	MatrixWavePlotFunc(ywv,1,1,xwv)
End
	
Function FLTReadRaw(fname,path,wvheader,xwv,ywv,fheader)
	String fname,path,wvheader,xwv,ywv
	Variable fheader
	
	String extstr,dum_header
	Variable ref,found,offset,index
	extstr=".raw"
	
	if (strlen(fname)<=0)
		Open /D/R/P=$path/T=(extstr) ref
//		if(ref==0)
//			return
//		endif
		if(strlen(S_filename)<=0)
			return -1
		endif
		fname= S_fileName
		Print fname
	endif
	
	// read hader
	Make/O/T $wvheader
	Wave/T wwheader=$wvheader
	Open /R/P=$path/T=(extstr) ref as fname
	found=0
	offset=0
	index=0
	do
		FReadLine ref,dum_header
		if(fheader==1)
			print dum_header
		endif
		offset+=strlen(dum_header)
		wwheader[index]=dum_header
		if(GrepString(dum_header,"Binary:"))
			found=1
		endif
		index+=1
	while(found==0)
	Close ref
	Redimension/N=(index) wwheader
	
	Variable numpoints,numvars
	numvars=LTheaderToNum(4,wwheader)
	numpoints=LTheaderToNum(5,wwheader)
	print "number of variables =", numvars,", number of points=", numpoints
	
// read x data
//	GBLoadWave/Q/N=wxwv/T={4,4}/B/U=(numpoints)/S=(offset)/W=1/P=$path fname
	Make/O/N=(numpoints) $xwv
	Wave wxwv=$xwv
	Variable xdat0
	index=0
	Open /R/P=$path/T=(extstr) ref as fname	
	do
		FSetPos ref,offset+index*(8+(numvars-1)*4)
		FBinRead/B=3/F=5 ref, xdat0
		wxwv[index]=xdat0
		index+=1
	while(index<numpoints)
	Close ref
//	LTRename(xwv,0,wvheader)

// read y data
	GBLoadWave/Q/N=dummy/T={2,4}/B/U=(numvars+1)/S=(offset)/W=(numpoints)/P=$path fname
	FWavesToMatrix("dummy","",ywv,0,numpoints,1)
	Wave wdummy=$ywv
	DeletePoints/M=0 0,2,wdummy
	MatrixTranspose wdummy
	
	return 0
End

Function LTheaderToNum(index,wwheader)
	Wave/T wwheader
	Variable index
	
	Variable num,length
	String str0,substr
	str0=wwheader[index]
	length=strlen(str0)
	num=strsearch(str0,":",0)
	substr=str0[num+1,length]
	return str2num(substr)
End

// Rename and append unit based on header
Function/S LTRename(orig,index,wvheader)
	Variable index
	String orig,wvheader
	
	Variable n
	String dest,expr="\\t(\\w+)\\t([\\w()]+)\\t(\\w+)",num,var,unit,s,unit0
	Wave/T wwheader=$wvheader
	Wave worig=$orig
	
	n=DimSIze(worig,0)

	SplitString/E=expr wwheader[index+9],num,var,unit
	s=ReplaceString("(",var,"_")
	dest=ReplaceString(")",s,"")
//	print var
	unit0=UnitToUnit(unit)
	Make/O/N=(n) $dest
	Wave wdest=$dest
	if(index==0)
		wdest=worig
	else
		wdest[]=worig[p][index-1]
	endif
	SetScale d 0,0,unit0, $dest
	
	Return dest
End

Function/S UnitToUnit(unit)
	String unit
	String unit0
	if(stringmatch(unit,"time"))
		unit0="sec"
	else
		if(stringmatch(unit,"voltage"))
			unit0="V"
		else
			if(stringmatch(unit,"device_current"))
				unit0="A"
			endif
		endif
	endif
	return(unit0)
End

// split data
Function SplitData(orig,num_row,num_column)
	String orig
	Variable num_row,num_column
	PauseUpdate; Silent 1
	
	Variable num0
	num0=DimSize($orig,0)
	if(num0!=(num_row+1)*num_column-1)
		printf "wave size =",num0,", does not much."
		return -1
	endif
	
//	Wave dummy
	Wave wvorig=$orig
	Duplicate/O wvorig,dummy
	Redimension/N=(num_row,num_column) dummy
	Variable i1,i2
	i1=0
	i2=0
	do
		i1=i2*(num_row+1)
		dummy[][i2]=wvorig[p+i1]
		i2+=1
	while(i2<num_column)
	Duplicate/O dummy,wvorig
End

Function SplitData_x(orig,num_row,num_column)
	String orig
	Variable num_row,num_column
	PauseUpdate; Silent 1
	
	Variable num0
	num0=DimSize($orig,0)
	if(num0!=(num_row+1)*num_column-1)
		printf "wave size =",num0,", does not much."
		return -1
	endif
	
	Redimension/N=(num_row) $orig
End
