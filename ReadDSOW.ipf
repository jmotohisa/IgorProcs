#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// readDSOW.ipf
// read  DSOW data of JDS UDS oscilloscope

// revision history
//		17/01/02	ver 0.1:	 first version

Macro LoadDSOW(pname,fname,wvname)
	String pname,fname,wvname
	PauseUpdate; Silent 1

	FLoadDSOW(pname,fname,wvname)
End

Function FLoadDSOW(pname,fname,wvname)
	String pname,fname,wvname

	Variable ref,i=0,d0,skips,pos,val,npnt,delta
	Variable voltdiv,timediv,start,stop
	String buffer,tmpwv,str0
	
	if (strlen(fName)<=0)
		Open /D/R/P=$pname/T="sGBWTEXT.datDSOW" ref
		fName= S_fileName
	endif
	print fName
	
// read scaling information
	Open /R/P=$pName/T="sGBWTEXT.datDSOW" ref as fName
	do
		FReadLine ref,buffer
		str0="data="
		pos=getval(buffer,str0,val)
		if(pos>=0)
			d0=val
			break
		Endif
		str0="TimeDiv="
		pos=getval(buffer,str0,val)
		if(pos>=0)
			timediv=val
		endif
		str0="VoltDiv="
		pos=getval(buffer,str0,val)
		if(pos>=0)
			voltdiv=val
		endif
		str0="Start="
		pos=getval(buffer,str0,val)
		if(pos>=0)
			start=val
		endif
		str0="End="
		pos=getval(buffer,str0,val)
		if(pos>=0)
			Stop=val
		endif
		i+=1
	while(1)
	Close ref
	print start,stop,timediv,voltdiv
	skips=i+1
//	LoadWave/G/D/W/L={0,(skips),0,0,0} fName
//	LoadWave/J/D/K=1/L={0,(skips),0,0,0} fName
//	LoadWave/G/D/N=dummy/L={0,(skips),0,0,0}/P=$pName fName
	LoadWave/J/D/N=dummy/L={0,(skips),0,0,0}/P=$pName fName
	if(V_flag==0)
		return(0)
	endif

	tmpwv=StringFromList(1,S_wavenames)
	Wave wwv=$tmpwv
	KillWaves wwv

	tmpwv=stringFromList(0,S_wavenames)
//	Wave wwv=$tmpwv
	Wave wwv=$tmpwv
	InsertPoints 0,1,wwv
	wwv[0]=d0
	if(strlen(wvname)<=0)
		wvname="W"+wname(fName)
	endif
	
	Duplicate/O $tmpwv,$wvname
	
	Wave wwv=$wvname
	wwv*=1e-6 // assume VoltUnit=microV
	voltdiv*=1e-6
	start*=1e-12 // assume TImeUnit=ps
	stop*=1e-12
	npnt=DimSize(wwv,0)
	delta=(stop-start)/npnt
	
//	SetScale/P x 0,timediv*1e-12,"s",wwv
//	SetScale/I x -0.0025,0.00249749874937469,"s"
	SetScale/P x start,delta,"s", wwv 
	SetScale/P y 0,voltdiv,"V", wwv
End

Function getval(buffer,str0,val)
	String buffer,str0
	Variable &val
	
	variable pos,len,len0
	len=strlen(buffer)
	len0=strlen(str0);
	pos=strsearch(buffer,str0,0,2);
	if(pos>=0)
		val=str2num(buffer[pos+len0,len])
	endif
	return(pos)
End

