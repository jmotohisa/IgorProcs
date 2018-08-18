#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "wname"
#include "MatrixOperations2"

// readLTraw.ipf
// read LTspice raw data
// rename, split, and plot data

// revision history
//		18/08/18	ver 0.2.3: fix insersion of Null in header in LTSpiceXVII
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

	String xwv,ywv,plotnamestr
	Variable numvars,numpoints,plotname
	plotnamestr=LTheaderToStr(2,$wvheader)
	plotname=fplotname(plotnamestr)
	xwv=LTRename(xwv0,0,wvheader)
	if(plotname==2) // AC analysis
		ywv=LTRename2(ywv0,index,wvheader)
	else
		ywv=LTRename(ywv0,index,wvheader)		
	endif
	numvars=LTheaderToNum(4,$wvheader)-1
	numpoints=LTheaderToNum(5,$wvheader)

	if(fsplit==1)
		SplitData_x(xwv,num_row,num_column,plotname)
		if(plotname==2)
			SplitData(ywv+"_re",num_row,num_column,plotname)
			SplitData(ywv+"_im",num_row,num_column,plotname)
		else
			SplitData(ywv,num_row,num_column,plotname)
		Endif
	endif
	
	if(plotname==2)
		String ywv1=ywv+"_re",ywv2=ywv+"_im"
		String ywv11=ywv+"_1",ywv22=ywv+"_2"
		Duplicate/O $ywv1,$ywv,$ywv11,$ywv22
//		Wave wywv1=$(ywv+"_re"),wywv2=$(ywv+"_im")
		Redimension/C $ywv
		$ywv=r2polar($ywv)
//		Wave wywv11=$(ywv+"_1"),wywv22=$(ywv+"_2")
		$ywv11=real($ywv)
		$ywv22=imag($ywv)
		unwrap 2*pi,$ywv22
		MatrixWavePlotFunc(ywv+"_re",1,1,xwv)
		MatrixWavePlotFunc(ywv+"_im",2,2,xwv)
		ModifyGraph log(bottom)=1
		MatrixWavePlotFunc(ywv+"_1",1,1,xwv)
		MatrixWavePlotFunc(ywv+"_2",2,2,xwv)
		ModifyGraph log(bottom)=1
	else
		MatrixWavePlotFunc(ywv,1,1,xwv)
	endif
End
	
Function FLTReadRaw(fname,path,wvname,wvheader,fheader)
	String fname,path,wvheader,wvname
	Variable fheader
	
	String extstr,dum_header,dum_header0
	Variable ref,found,offset,index
	Variable plotname
	String plotnamestr
	String xwv,ywv
	Variable flg_XVII=0
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
		FReadLine ref,dum_header0
//		dum_header=ConvertTextEncoding(dum_header,TextEncodingCode("UTF-8"),TextEncodingCode("ShiftJIS"),1,0)
		offset+=strlen(dum_header0)
		if(strsearch(dum_header0,"\000",0)>0)
			flg_XVII=1
		endif
		dum_header=ReplaceString("\000",dum_header0,"") // remove null char
		if(fheader==1)
			print dum_header
		endif
		wwheader[index]=dum_header[0,strlen(dum_header)-2]
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
	if(flg_XVII==1)
		offset+=1 // additional null
	endif
	printf "offset=%d, h%x\r",offset,offset
	
	Variable numpoints,numvars
	plotnamestr=LTheaderToStr(2,wwheader)
	numvars=LTheaderToNum(4,wwheader)
	numpoints=LTheaderToNum(5,wwheader)
	print "number of variables =", numvars,", number of points=", numpoints
	plotname=fplotname(plotnamestr)
	
// read x data
//	GBLoadWave/Q/N=wxwv/T={4,4}/B/U=(numpoints)/S=(offset)/W=1/P=$path fname

	Variable pos
	if(found==1) // binary
		Make/O/N=(numpoints) $xwv
		Wave wxwv=$xwv
		Variable xdat0
		index=0
		Open /R/P=$path/T=(extstr) ref as fname
		Fstatus ref
		print V_logEOF

		if(plotname==1) // transient alnalysis
			do
				pos=offset+index*(8+(numvars-1)*4)
				FSetPos ref,pos
//				FgetPos ref
//				print V_filePos
//		Fstatus ref
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
			DeletePoints/M=1 0,1,wdummy  // this is an origin of complication
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

// for AC analysis (real and imag part)
Function/S LTRename2(orig,index,wvheader)
	Variable index
	String orig,wvheader
	
	Variable n
	String dest,expr="\\t(\\w+)\\t([\\w()]+)\\t(\\w+)",num,var,unit,s,unit0
	String dest1,dest2
	Wave/T wwheader=$wvheader
	Wave worig=$orig
	
	n=DimSIze(worig,0)

	SplitString/E=expr wwheader[index+9],num,var,unit
	s=ReplaceString("(",var,"_")
	dest=ReplaceString(")",s,"")
	dest1=dest+"_re"
	dest2=dest+"_im"
//	print var
	unit0=UnitToUnit(unit)
	
	if(stringmatch(dest,"time"))
		dest="time0"
	endif
	if(stringmatch(dest,"freqency"))
		dest="freq0"
	endif
	
	Make/O/N=(n) $dest1,$dest2
	Wave wdest1=$dest1,wdest2=$dest2
	if(index==0)
		wdest1=worig
		wdest2=worig
	else
		wdest1[]=worig[p][index*2]
		wdest2[]=worig[p][index*2+1]
	endif
	SetScale d 0,0,unit0, $dest1,$dest2
	
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
Function SplitData(orig,num_row,num_column,plotname)
	String orig
	Variable num_row,num_column,plotname
	PauseUpdate; Silent 1
	
	Wave wvorig=$orig
	Variable num0,num1,num_row1
	num0=DimSize(wvorig,0)
	if(plotname==1) // transient, do not split, just duplicate
		return num0
	endif

	if(plotname==2) // AC 
		num1=num0
		num_row1=num_row
	else // Additional point is added somehow
		num1=num0+1
		num_row1=num_row+1
	endif
	if(num1!=(num_row1)*num_column)
		print "wave size =",num0,", does not much."
		return -1
	endif
	
//	Wave dummy
	Duplicate/O wvorig,dummy
	Redimension/N=(num_row,num_column) dummy
	Variable i1,i2

	i1=0
	i2=0
	do
		if(plotname==0)
			i1=i2*(num_row+1) //DC transfer
		else
			i1=i2*(num_row) // AC analysis
		endif
		dummy[][i2]=wvorig[p+i1]
		i2+=1
	while(i2<num_column)
	Duplicate/O dummy,wvorig
End

Function SplitData_x(orig,num_row,num_column,plotname)
	String orig
	Variable num_row,num_column,plotname
	PauseUpdate; Silent 1
	
	Variable num0,num1,num_row1
	num0=DimSize($orig,0)
	if(plotname==1) // transient data cannot be split
		return -1
	Endif

	if(plotname==2) // AC 
		num1=num0
		num_row1=num_row
	else // Additional point is added somehow
		num1=num0+1
		num_row1=num_row+1
	endif
	if(num1!=num_row1*num_column)
		print "wave size =",num0,", does not much."
		return -1
	endif
	
	Redimension/N=(num_row) $orig
	return num_row
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