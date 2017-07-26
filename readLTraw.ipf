#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "wname"
#include "MatrixOperations2"

// readLTraw.ipf
// read LTspice raw data
// rename, split, and plot data

// revision history
//		17/07/25	ver 0.2.2: enable loading DC transfer analysis
//		17/01/14	ver 0.2.1: plot bode diagram
//		17/01/02	ver 0.2:		ac analysis
//		14/10/03-14/10/04	ver 0.1: first version

#include "MatrixOperations2"

Macro LTReadRaw(fname,path,wvname,wvheader,fheader)
	String fname,path,wvname,wvheader="header"
	Variable fheader=1
	Prompt fname,"file name"
	Prompt path,"path name"
	Prompt wvname,"wave name"
	Prompt wvheader,"header wave name"
	Prompt fheader,"print header ?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	FLTReadRaw(fname,path,wvname,wvheader,fheader)
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
	
Function FLTReadRaw(fname,path,wvname,wvheader,fheader)
	String fname,path,wvheader,wvname
	Variable fheader
	
	String extstr,dum_header
	Variable ref,found,offset,index
	Variable plotname
	String plotnamestr
	String xwv,ywv
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
	if(strlen(wvname)<=0)
		wvname=wname(fname)
	endif
	xwv=wvname+"_xdata"
	ywv=wvname+"_ydata"
	
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
		if(GrepString(dum_header,"Values:"))
			found=-1
		endif
		index+=1
	while(found==0)
	Close ref
	Redimension/N=(index) wwheader
	printf "offset=%d, h%x\r",offset,offset
	
	Variable numpoints,numvars
	plotnamestr=LTheaderToStr(2,wwheader)
	numvars=LTheaderToNum(4,wwheader)
	numpoints=LTheaderToNum(5,wwheader)
	print "number of variables =", numvars,", number of points=", numpoints
	plotname=fplotname(plotnamestr)
	
// read x data
//	GBLoadWave/Q/N=wxwv/T={4,4}/B/U=(numpoints)/S=(offset)/W=1/P=$path fname

	if(found==1) // binary
		Make/O/N=(numpoints) $xwv
		Wave wxwv=$xwv
		Variable xdat0
		index=0
		Open /R/P=$path/T=(extstr) ref as fname	

		if(plotname==1) // transient alnalysis
			do
				FSetPos ref,offset+index*(8+(numvars-1)*4)
				FBinRead/B=3/F=5 ref, xdat0
				wxwv[index]=xdat0
				index+=1
			while(index<numpoints)
			Close ref
			SetScale d 0,0,"s", wxwv
//	LTRename(xwv,0,wvheader)
	// read y data
			GBLoadWave/Q/N=dummy/T={2,4}/B/U=(numvars+1)/S=(offset)/W=(numpoints)/P=$path fname
			FWavesToMatrix("dummy","",ywv,0,numpoints,1)
			Wave wdummy=$ywv
			DeletePoints/M=0 0,2,wdummy
			MatrixTranspose wdummy
		elseif(plotname==2) // ac analysis
			do
				FSetPos ref,offset+index*(16+(numvars-1)*16)
				FBinRead/B=3/F=5 ref, xdat0
				wxwv[index]=xdat0
				index+=1
			while(index<numpoints)
			Close ref
			SetScale d 0,0,"Hz", wxwv
	// read y data
			GBLoadWave/Q/N=dummy/T={4,4}/B/U=((numvars)*2)/S=(offset)/W=(numpoints)/P=$path fname
			FWavesToMatrix("dummy","",ywv,0,numpoints,1)
			Wave wdummy=$ywv
//			DeletePoints/M=0 0,2,wdummy
			MatrixTranspose wdummy
		elseif (plotname==3) // operating point
			GBLoadWave/Q/N=dummy/T={2,4}/B/U=(numvars+1)/S=(offset)/W=(numpoints)/P=$path fname
			ywv=StringFromList(0,S_WaveNames)
			Wave wdummy=$ywv
			print wdummy
		elseif (plotname==0)  // DC transfere characteristics
			do
				FSetPos ref,offset+index*(8+(numvars-1)*4)
				FBinRead/B=3/F=5 ref, xdat0
				wxwv[index]=xdat0
				index+=1
			while(index<numpoints)
			Close ref
			SetScale d 0,0,"V", wxwv
			GBLoadWave/Q/N=dummy/T={2,4}/B/U=(numvars+1)/S=(offset)/W=(numpoints)/P=$path fname
			FWavesToMatrix("dummy","",ywv,0,numpoints,1)
			Wave wdummy=$ywv
//			DeletePoints/M=0 0,2,wdummy
			MatrixTranspose wdummy
			DeletePoints/M=1 0,1,wdummy
		endif
	endif
	// ascii data is not compatible yet
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

Function/S LTheaderToStr(index,wwheader)
	Wave/T wwheader
	Variable index
	
	Variable num,length
	String str0,substr
	str0=wwheader[index]
	length=strlen(str0)
	num=strsearch(str0,":",0)
	substr=str0[num+1,length]
	return substr
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
	
	if(stringmatch(dest,"time"))
		dest="time0"
	endif
	if(stringmatch(dest,"freqency"))
		dest="freq0"
	endif
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
		unit0="s"
	elseif(stringmatch(unit,"voltage"))
		unit0="V"
	elseif(stringmatch(unit,"device_current"))
			unit0="A"
	elseif(stringmatch(unit,"frequency"))
						unit0="Hz"
	else
		unit0=""
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

function fplotname(plotnamestr)
	String plotnamestr
	
	if(strsearch(plotnamestr,"transient analysis",0,2)>=0)
		return(1)
	endif
	if(strsearch(plotnamestr,"ac analysis",0,2)>=0)
		return(2)
	endif
	if(strsearch(plotnamestr,"Operating Point",0,2)>=0)
		return(3)
	endif
	return(0)
End

Function MakeGainPhase(wvorig,index,wvgain,wvphase,wvfreq)
	String wvorig,wvgain,wvphase,wvfreq
	Variable index
	
	Duplicate/O $wvfreq $wvgain,$wvphase
	Wave wwvorig=$wvorig
	Wave wwvfreq=$wvfreq
	Wave wwvgain=$wvgain
	Wave wwvphase=$wvphase
	SetScale d 0,0,"dB", wwvgain
	SetScale d 0,0,"deg", wwvphase
	wwvgain=10*log(wwvorig[p][index*2]^2+wwvorig[p][index*2+1]^2)
	wwvphase=atan2(wwvorig[p][index*2+1],wwvorig[p][index*2])/pi*180
	Display wwvgain vs wwvfreq
	AppendToGraph/L=left2 wwvphase vs wwvfreq
	ModifyGraph gfSize=18
//	ModifyGraph lStyle($wvgain)=2,lStyle($wvphase)=2
	ModifyGraph rgb($wvgain)=(0,0,0),rgb($wvgain)=(0,0,0)
	ModifyGraph log(bottom)=1
	ModifyGraph mirror=1
	ModifyGraph lblPos(left)=85,lblPos(left2)=83
	ModifyGraph freePos(left2)=0
	ModifyGraph axisEnab(left)={0,0.7}
	ModifyGraph axisEnab(left2)={0.75,1}
	ModifyGraph manTick(left2)={0,90,0,0},manMinor(left2)={0,50}
	Label left "Gain (\\U)"
	Label bottom "Frequency (\\U)"
	Label left2 "phase (\\U)"
	SetAxis left2 -180,180
End