#pragma rtGlobals=1		// Use modern global access method.
#include "wname"
#include "StrRpl"

// LoadmeepFlux.ipf
// by J. Motohisa
// load flux data of meep
// ver 0.02	14/10/31
//		 by J. Motohisa

// Procedure to load flux data and calculate reflectivity/tranmittance/absorption
// assume that
// (1) file name is 
//		reference :${fn}-0.dat 
//		with scatterers :${fn}-1.dat 
// (2) the data is store as
//		flux1: freqency, trasmission, reflection1, reflection2,...
// (see bend-flux.ctl in meep tutorial)

// revision history
//	ver 0.01 11/03/17	initial version
//	ver 0.02 14/10/31	

Macro LoadMeepFlux0(path,fname,bname,wantToDisp,freqconv)
	String path,fname,bname
	Variable wantToDisp=1,freqconv=1
	Prompt path,"path name"
	Prompt fname,"file name"
	Prompt bname,"base wave name"
	Prompt wanttodisp,"Display graph ?", popup,"yes;append;no"
	Prompt freqconv,"multiply freq with 2*pi ?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	FLoadMeepFlux0(path,fname,bname,wantToDisp,freqconv)
End

Function FLoadMeepFlux0(path,fname,bname,wantToDisp,freqconv)
	String path,fname,bname
	Variable wantToDisp,freqconv
	
	Variable fmin,fmax,index,ref
	String destw0,xwname,dwname,dest
	if (strlen(fname)<=0)
		if(CmpStr(IgorInfo(2), "Macintosh") == 0)
//			Open /D/R/P=$path/T="sGBWTEXT.DAT" ref // MacOS
			Open /D/R/P=$path/T=".DAT" ref // MacOS
		else
			Open /D/R/P=$path/T=".DAT" ref // windows
		endif
		fname= S_fileName
		print fname
	endif
	
	LoadWave/J/D/K=0/N=$"dummy"/P=$path/Q fname
	if(V_flag==0)
		return V_flag
	endif

	destw0=strrpl(wname(fname),"-","_")
	if(strlen(bname)==0)
		bname=destw0
	endif
	
	if(wantToDisp==1)
		Display /W=(3,41,636,476)
	endif

	xwname=StringFromList(1,S_waveNames,";")
	Wave xwnamew=$xwname
	if(freqconv==1)
		xwnamew*=2*pi
	Endif

	WaveStats/Q $xwname
	fmin=V_min
	fmax=V_max

	index=0
	do
		dwname=StringFromList(2+index,S_waveNames,";")
		if(strlen(dwname)==0)
			break
		endif
		dest=bname+"_"+num2str(index)
		Duplicate/O $dwname,$dest
		SetScale x,fmin,fmax,"",$dest
		if(wantToDisp==1 || wantToDisp==2)
			AppendToGraph $dest
		endif
		index+=1
	while(1)
	return V_flag-2 // number of waves (including transmission)
End

// will be named as
//	reference: trn0_+suffix, refl0_0_+suffix, refl0_1_+suffix,...
//	target: "trn1_"+suffix, refl0_0_0, "refl1_1_"+suffix,...
Macro LoadMeepFlux(pathname,fname0,fname1,suffix,withloss,wanttodisp,freqconv)
	Variable suffix,withloss=2,wanttodisp=1,freqconv=1
	String fname0,fname1,pathname="home"
	Prompt pathName,"path name"
	Prompt fname0,"reference file name"
	Prompt fname1,"reflectivity fiile name"
	Prompt suffix,"suffix number"
	Prompt withloss,"calculate loss ?",popup,"yes;no"
	Prompt wanttodisp,"Display graph ?", popup,"yes;append;no"
	Prompt freqconv,"multiply freq with 2*pi ?",popup,"yes;no"
	PauseUpdate; Silent 1

	FLoadMeepFlux1(pathname,fname0,fname1,suffix,withloss,wanttodisp,freqconv)
End
	
Function FLoadMeepFlux1(pathname,fname0,fname1,suffix,withloss,wanttodisp,freqconv)
	Variable suffix,withloss,wanttodisp,freqconv
	String pathname,fname0,fname1

	String bname
	String rwname,twname,wname0,wname1,wn_abs1
	Variable n1,n2,index

	bname="reference"
	n1=FLoadMeepFlux0(pathName,fname0,bname,3,freqconv)//
	bname="target"
	n2=FLoadMeepFlux0(pathName,fname1,bname,3,freqconv)//
	if(n1==0 || n2==0)
		return -1
	endif
	if(n1!=n2)
		printf "Nunmber of data in reference and target file does not match. Aborting."
		return -1
	endif
	
	if(wanttodisp==1)
		Display
	endif

	index=0
	do
		rwname="reference_"+num2str(index)
		twname="target_"+num2str(index)
		Wave wrwname =$rwname
		Wave wtwname =$twname
		Wave reference_0
		if(index==0)
			wtwname/=reference_0
			wname0="trn0_"+num2str(suffix)
			wname1="trn1_"+num2str(suffix)
			Duplicate/O $rwname,$wname0;//KillWaves $rwname
			Duplicate/O $twname,$wname1;//KillWaves $twname
		else
//			wrwname/=reference_0
//			wtwname/=-reference_0
			wname0="refl0_"+num2str(suffix)+"_"+num2istr(index-1)
			wname1="refl1_"+num2str(suffix)+"_"+num2istr(index-1)
			Duplicate/O wrwname,$wname0;//KillWaves $rwname
			Duplicate/O wtwname,$wname1;//KillWaves $twname
			Wave wwname0=$wname0
			Wave wwname1=$wname1
			wwname0/=reference_0
			wwname1/=-reference_0
		endif
		if(wanttodisp==1 || wanttodisp==2)
			AppendToGraph  $wname1
			if(index!=0)
				ModifyGraph rgb($wname1)=(0,0,65535)
			endif
			if(withloss==1&&index!=0)
				wn_abs1="abs1_"+num2str(suffix)+"_"+num2istr(index-1)
				Wave wwn_abs1=$wn_abs1
				Wave wwname1=$wname1
				Wave wtran=$("trn1_"+num2str(suffix))
				Duplicate/O wwname1,wwn_abs1
				wwn_abs1=1-wwname1-wtran
				AppendToGraph wwn_abs1
				ModifyGraph rgb($wn_abs1)=(0,65535,0)
			endif
		endif
		index+=1
	while(index<n1)
	SetAxis left 0,1
End

Macro LoadMeepFlux1(thePath,fn,suffix,withloss,wanttodisp,freqconv)
	String fn,thePath
	Variable suffix,withloss=2,wanttodisp=1,freqconv=1
	Prompt thePath, "Name of path containing flux files", popup PathList("*", ";", "")+"_New Path_"
	Prompt fn,"base file name"
	Prompt suffix,"suffix number"
	Prompt withloss,"calculate loss ?",popup,"yes;no"
	Prompt wanttodisp,"Display graph ?", popup,"yes;append;no"
	Prompt freqconv,"multiply freq with 2*pi ?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif
	
	String fname0=fn+"-0.dat",fname1=fn+"-1.dat"
	FLoadMeepFlux1(thePath,fname0,fname1,suffix,withloss,wanttodisp,freqconv)
End

Macro LoadMeepFlux2(thePath,fn,suffix,wanttodisp,freqconv)
	String fn,thePath
	Variable suffix,withloss=2,wanttodisp=1,freqconv=1
	Prompt thePath, "Name of path containing flux files", popup PathList("*", ";", "")+"_New Path_"
	Prompt fn,"base file name"
	Prompt suffix,"suffix number"
	Prompt wanttodisp,"Display graph ?", popup,"yes;append;no"
	Prompt freqconv,"multiply freq with 2*pi ?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	if (CmpStr(thePath, "_New Path_") == 0)		// user selected new path ?
		NewPath/O data			// this brings up dialog and creates or overwrites path
		thePath = "data"
	endif
	
	String fname0=fn+"-0.dat",fname1=fn+"-1.dat"
	FLoadMeepFlux2(thePath,fname0,fname1,suffix,wanttodisp,freqconv)
End

Function FLoadMeepFlux2(pathname,fname0,fname1,suffix,wanttodisp,freqconv)
	Variable suffix,wanttodisp,freqconv
	String pathname,fname0,fname1

	String bname
	String rwname,twname,wname0,wname1,wn_abs1
	Variable n1,n2,index

	bname="r"
	n1=FLoadMeepFlux0(pathName,fname0,bname,3,freqconv)//
	bname="t"
	n2=FLoadMeepFlux0(pathName,fname1,bname,3,freqconv)//
	if(n1==0 || n2==0)
		return -1
	endif
	if(n1!=n2)
		printf "Nunmber of data in reference and target file does not match. Aborting."
		return -1
	endif
	
	if(wanttodisp==1)
		Display
	endif

	index=0
	do
		rwname="rfrn_"+num2str(suffix)+"_"+num2str(index)
		twname="trgt"+num2str(suffix)+"_"+num2str(index)
		Wave wr=$("r_"+num2str(index))
		Wave wt=$("t_"+num2str(index))
		Duplicate/O  wr,$rwname
		Duplicate/O  wt,$twname
		Wave wrwname =$rwname
		Wave wtwname =$twname
		wname0="refl_"+num2str(suffix)+"_"+num2istr(index)
		Duplicate/O wrwname,$wname0
		Wave wwname0=$wname0
		wwname0=-wtwname/wrwname
		if(wanttodisp==1 || wanttodisp==2)
			AppendToGraph  wwname0
		endif
		index+=1
	while(index<n1)
	SetAxis left 0,1
End

Macro GroupRename(target,suffix)
	String target
	Variable suffix
	PauseUpdate;Silent 1
	
	String wn_trn0,wn_refl0,wn_trn1,wn_refl1,wn_abs1
	String wn_trn01,wn_refl01,wn_trn11,wn_refl11,wn_abs11
	Variable index
	
	wn_trn0="trn0_"+num2str(suffix)
	wn_trn1="trn1_"+num2str(suffix)
	wn_trn01=target+"_trn0"
	wn_trn11=target+"_trn"
	If(WaveExists($wn_trn0))
		Rename $wn_trn0,$wn_trn01
		Rename $wn_trn1,$wn_trn11
	endif

	index=0
	do
		wn_refl0="refl0_"+num2str(suffix)+"_"+num2istr(index)
		wn_refl1="refl1_"+num2str(suffix)+"_"+num2istr(index)
		wn_abs1="abs1_"+num2str(suffix)+"_"+num2istr(index)
		if(WaveExists($wn_refl0)==0)
			break
		endif
		wn_refl01=target+"_"+num2str(index)+"_refl0"
		wn_refl11=target+"_"+num2str(index)+"_refl"
		wn_abs11=target+"_"+num2str(index)+"_abs"
		Rename $wn_refl0,$wn_refl01
		Rename $wn_refl1,$wn_refl11
		If(WaveExists($wn_abs1))
			Rename $wn_abs1,$wn_abs11
		endif
		index+=1
	while(1)
End

Macro PlotRefs(suffix)
	Variable suffix
	PauseUpdate; Silent 1;
	
	Variable index=0
	String target
	Display
	do
		target="refl0_"+num2str(index)+"_"+num2str(suffix)
		if(WaveExists($target)==0)
			Break
		endif
		AppendToGraph $target
		index+=1
	while(1)
	Label bottom "Frequency \\F'Symbol'w\\F'Helvetica'R/c";SetAxis left 0.5,1.5;ModifyGraph gfSize=18
End