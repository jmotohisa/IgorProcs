#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// MPBProcs by J. Motohisa
// some macros to work with  MPB
//
//	ver 0.01	2013/08/31-09/02	develepment started 

//#include "MatrixOperations2"
//#include "h5procs"
//#include "StrRpl"
//#include "wname"
//#include "AddNoteToWave"
#include "JMGeneralTextDataLoad" menus=0

Function MPB_init()
	JMGTDLinit("data","","")
End

Macro LoadMPBFreqs(fname,pname,bname,scalenum0,fconv,dispTable,dispGraph,fquiet)
	String fname,pname,bname
	Variable scalenum0,fconv,dispTable=2,dispGraph=2,fquiet=1
	Prompt fname,"file name"
	Prompt pname,"path name"
	Prompt bname,"base wave name"
	prompt scalenum0,"wave number for scaling",popup,"kx;ky;kz;k"
	Prompt fconv,"unit",popup,"freq:(k/2pi);omega:k"
	prompt dispTable, "display table ?", popup,"yes;no"
	prompt dispGraph, "display Graph ?", popup,"yes;no"
	prompt fquiet, "quiet ?", popup,"yes;no"	
	PauseUpdate; Silent 1
	
	FLoadMPBFreqs(fname,pname,bname,scalenum0,fconv,dispTable,dispGraph,fquiet)
End

Function FLoadMPBFreqs(fname,pname,bname,scalenum0,fconv,dispTable,dispGraph,fquiet)
	String fname,pname,bname
	Variable scalenum0,dispTable,dispGraph,fquiet
	Variable fconv

	String suffixlist=";;kx;ky;kz;kk;#"
	String ftype=".dat"
	Variable ndata
	Variable xmin,dx
	String smn

	ndata=JMGeneralDatLoaderFunc(fname,pname,ftype,bname,suffixlist,scalenum0+1,dispTable,dispGraph,fquiet)
	ndata=ndata-4
	
	String savDF=GetDataFolder(1)
	SetDataFolder root:Packages:JMGTDL
	SVAR g_baseName
	bname=g_baseName
	SetDataFolder savDF
	
	if(fconv==2)
	// rescale
		ReScaleWavesAll(bname,2*pi,ndata)
	endif
	return(ndata)
End

Function ReScaleWaves(wvname,factor)
	String wvname
	Variable factor
	
	Wave w=$wvname
	Variable xmin,dx
	String uni
	if(waveexists(w))
		xmin=DimOffset(w,0)
		dx=DimDelta(w,0)
		uni=WaveUnits(w,0)
		SetScale/P x xmin*factor,dx*factor,uni,w
		w*=factor
	endif
End

Function ReScaleWavesAll(bname,factor,ndata)
	String bname
	Variable factor,ndata

	Variable index=0
	ReScaleWaves(bname+"_kx",2*pi)
	ReScaleWaves(bname+"_ky",2*pi)
	ReScaleWaves(bname+"_kz",2*pi)
	ReScaleWaves(bname+"_kk",2*pi)
	do
		ReScaleWaves(bname+"_"+num2istr(index),2*pi)
		index+=1
	while(index<ndata)
End
		

Function DisplayBand(prefix,fdisp)
	String prefix
	Variable fdisp
	
	String wvname
	Variable index
	if(fdisp==1)
		Display
	endif
	do
		wvname=prefix+"_"+num2istr(index)
		if(waveExists($wvname))
			AppendToGraph $wvname
		else
			break
		endif
		index+=1
	while(1)
End

Function DisplayBand_omk(prefix,kwave0,fdisp)
	String prefix,kwave0
	Variable fdisp
	
	String wvname
	Variable index
	if(fdisp==1)
		Display
	endif
	String kwave=prefix+"_"+kwave0
	do
		wvname=prefix+"_"+num2istr(index)
		if(waveExists($wvname))
			AppendToGraph $kwave vs $wvname
		else
			break
		endif
		index+=1
	while(1)
End
