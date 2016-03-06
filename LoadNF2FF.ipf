#pragma rtGlobals=1		// Use modern global access method.
#include "JMGeneralTextDataLoad2"
#include <New Polar Graphs>

// LoadNF2FF.ipf
//	Macro to load nf2ff-meep data file
//	12/02/02 ver. 0.1a by J. Motohisa
//
//	revision history
//		?/?/?		ver 0.01	first version (was not a separate macro)
//		12/02/01	ver 0.1a	a separate macro
//		12/12/05	ver 0.1b	part for 3D calculation added
//		13/03/20	ver 0.1c	"quiet" option added due to change in JMGeneralTextDataLoad
//		16/03/06	ver 0.2a	to work with DSO

Function initNF2FFLoad(withPolar)
	Variable withPolar
	String/g g_nf2ffcylWN="nf2ffcylWName"
	String/g g_nf2ffcylNLWN="nf2ffcylWNameNL"
	String/g g_nf2ffcylPart="nf2ffcylPartWName"
	String/g g_nf2ffWN="nf2ffWName"
	String/g g_nf2ffLNWN="nf2ffNLWName"
	String/g g_nf2ffPart="nf2ffPartWName"
	String/g g_nf2ffcylPartN="nf2ffCYLPartWWName"
	Variable/g g_datanum=0
	String wlist
	Variable nwv

	if(withPolar==1)
		g_nf2ffWN=";wavelength;theta;phi;Etheta_re;Etheta_im;Ephi_re;Ephi_im;rcs;rcs_x;rcs_y;rcs_z"
		g_nf2ffcylWN=";wavelength;theta;phi;Etheta_re;Etheta_im;Ephi_re;Ephi_im;rcs;rcs_x;rcs_y;rcs_z"
	else
		g_nf2ffWN=";wavelength;theta;phi;Etheta_re;Etheta_im;Ephi_re;Ephi_im;rcs"
		g_nf2ffcylWN=";wavelength;theta;phi;Etheta_re;Etheta_im;Ephi_re;Ephi_im;rcs"
	endif
	
//	wlist=";theta;rcsall;rcs0;rcs1;rcs2;rcs02"
//	wlist=";theta;phi;rcsall;rcs0;rcs1;rcs2;rcs02"
//	wlist=";Nthre;Nthim;Lphre;Lphim;Nphre;Nphim;Lthre;Lthim"
	JMGTDLinit(1,"data")
End

Macro LoadNf2ffCylinder(fname,pname,index,dispTable,dispGraph,col,fquiet)
	String fname,pname="home"
	Variable index,dispTable=2,dispGraph=2,col=2,fquiet=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	Prompt col,"x-axis",popup,";angle;"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1;
	
	String extName=".dat",xunit="",yunit="",prefix="C"
	String suffixlist=g_nf2ffcylWN
	Variable scalenum=-1
//	JMGeneralDatLoaderFunc(fname,pname,prefix,g_nf2ffcylWN,suffix,col,dispTable,dispGraph,fquiet)
	JMGeneralDatLoaderFunc2(fname,pname,extName,index,prefix,suffixlist,col,xunit,yunit,fquiet)
//	g_datanum=suffix+1
End

Macro LoadNf2ff(fname,pname,index,dispTable,dispGraph,col,fquiet)
	String fname,pname="home"
	Variable index,dispTable=2,dispGraph=2,col=2,fquiet=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	Prompt col,"x-axis",popup,";angle;"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1;
	
	String extName=".dat",xunit="",yunit="",prefix="C"
	String suffixlist=g_nf2ffWN
	Variable scalenum=-1
//	JMGeneralDatLoaderFunc(fname,pname,g_nf2ffWN,suffix,col,dispTable,dispGraph,fquiet)
	JMGeneralDatLoaderFunc2(fname,pname,extName,index,prefix,suffixlist,scalenum,xunit,yunit,fquiet)
//	g_datanum=suffix+1
End

Macro LoadNF2FFpartCylinder(fname,pname,suffix,dispTable,dispGraph,col,fquiet)
	String fname,pname="home"
	Variable suffix=g_datanum,dispTable=2,dispGraph=2,col=2,fquiet=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	Prompt col,"x-axis",popup,";angle;"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1;
	
	JMGeneralDatLoaderFunc(fname,pname,g_nf2ffcylPart,suffix,col,dispTable,dispGraph,fquiet)
	g_datanum=suffix+1
End

Macro LoadNF2FFpart(fname,pname,suffix,dispTable,dispGraph,col,fquiet)
	String fname,pname="home"
	Variable suffix=g_datanum,dispTable=2,dispGraph=2,col=2,fquiet
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	Prompt col,"x-axis",popup,";angle;"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1;
	
	JMGeneralDatLoaderFunc(fname,pname,g_nf2ffPart,suffix,col,dispTable,dispGraph,fquiet)
	g_datanum=suffix+1
End

Macro LoadNF2FFLN(fname,pname,suffix,dispTable,dispGraph,col,fquiet)
	String fname,pname="home"
	Variable suffix=g_datanum,dispTable=2,dispGraph=2,col=2,fquiet
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	Prompt col,"x-axis",popup,";angle;"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1;
	
	JMGeneralDatLoaderFunc(fname,pname,g_nf2ffLNWN,suffix,col,dispTable,dispGraph,fquiet)
	g_datanum=suffix+1
End

Macro rcsNormalize(orig,dest)
	String orig="rcs_",dest
	PauseUpdate;Silent 1;
	
	Variable c
	Duplicate/O $orig,$dest
	c=area($dest)
	$dest/=c
End

Function GroupRename(nmwave,orig,modified)
	String nmwave
	String orig
	String modified
	
	Variable i,n=DimSize($nmwave,0)
	i=0
	do
		Wave/T wwnm=$nmwave
		String orig0=(wwnm[i]+"_"+orig)
		String dest0=(wwnm[i]+"_"+modified)
		If(WaveExists($orig0))
			Rename $orig0,$dest0
		endif
		i+=1
	while(i<n)
End

Proc FFIntensity():GraphStyle
	ModifyGraph gfSize=18
	ModifyGraph manTick(bottom)={0,30,0,0},manMinor(bottom)={2,50}
	Label left "Far-field intensity (arb. units)"
	Label bottom "angle \\F'Symbol'q\\F'Helvetica' (degree)"
End

// assume orig
Proc To2DimWave(orig0,suffix,ntheta)
	String orig0="rcs"
	Variable suffix,ntheta=91
	PauseUpdate; Silent 1
	
	String orig=orig0+"_"+num2str(suffix)
















