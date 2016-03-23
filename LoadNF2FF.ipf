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
//		16/03/18	ver 0.2b	sum function to convert 2D wave and to integrate over (theta,phi) is added

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

Macro LoadNf2ff(fname,pname,index,dispTable,dispGraph,col,f2d,fquiet)
	String fname,pname="home"
	Variable index,dispTable=2,dispGraph=2,col=2,fquiet=2,f2d=0
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	Prompt col,"x-axis",popup,";angle;"
	Prompt f2d,"make 2D wave (num column)"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1;
	
	String extName=".dat",xunit="",yunit="",prefix="C"
	String suffixlist=g_nf2ffWN
	Variable scalenum=-1
//	JMGeneralDatLoaderFunc(fname,pname,g_nf2ffWN,suffix,col,dispTable,dispGraph,fquiet)
	JMGeneralDatLoaderFunc2(fname,pname,extName,index,prefix,suffixlist,scalenum,xunit,yunit,fquiet)
	if(f2d>1)
		To2DWaves(prefix+num2str(index),suffixlist,f2d)
		if(fquiet==1)
			print "Waves are converted to 2D waves."
		endif
	endif
//	g_datanum=suffix+1
End

Function To2DWaves(prefix,suffixlist,numcol)
	String prefix,suffixlist
	Variable numcol
	
	if(numcol<=1)
		return 0
	endif
	
	Variable index,nx,n0
	String suffix,wvname
	n0=ItemsInlist(suffixlist)
	index=0
	do
		suffix=StringFromList(index,suffixlist,";")
		if(strlen(suffix)>0)
			wvname=prefix+"_"+suffix
			Wave wwv=$wvname
			if(waveexists($wvname))
				nx=DimSize(wwv,0)/numcol
				Redimension/N=(nx,numcol) wwv
			endif
		endif
		index+=1
	while(index<n0)
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

Function MakeComplexField(prefix)
	String prefix
	
	Wave2Complex(prefix+"_Etheta")
	Wave2Complex(prefix+"_Ephi")
End

Function/S Wave2Complex(prefix)
	String prefix
	String orig_re,orig_im,dest
	orig_re=prefix+"_re"
	orig_im=prefix+"_im"
	dest=prefix
	Duplicate/O  $orig_re,$dest
	Redimension/C $dest
	Wave/C wdest=$dest
	Wave worig_re=$orig_re, worig_im=$orig_im
	wdest=cmplx(worig_re,worig_im)
	return(dest)
End

Function rcs2dIntegration(wvname,thetamax)
	String wvname
	Variable thetamax
	
	Variable xmin,xmax,ymin,ymax
	xmin=0
	xmax=thetamax
	ymin=0
	ymax=90
	Variable/G globalXmin=xmin
	Variable/G globalXmax=xmax
	Variable/G globalY
	Duplicate/O $wvname,my2DSpectralWave
	return Integrate1d(userFunction2,ymin,ymax,1)*(pi*pi/(180*180))*4 // Romberg integration
End

Function AvrSrcPol(polaravr,polarx,polary,polarz)
	String polaravr,polarx,polary,polarz
	Wave wpolaravr=$polaravr
	Wave wpolarx=$polarx
	Wave wpolary=$polary
	Wave wpolarz=$polarz
	wpolaravr=(wpolarx+wpolary)/4+wpolarz/2
End

Function userFunction1(inX)
	Variable inX
	NVAR globalY=globalY
	Wave my2DSpectralWave
	return Interp2d(my2DSpectralWave,inX,globalY)*sin(inX*pi/180)
End

Function userFunction2(inY)
	Variable inY
	NVAR globalY=globalY
	globalY=inY
	NVAR globalXmin=globalXmin
	NVAR globalXmax=globalXmax
	return integrate1D(userFunction1,globalXmin,globalXmax,1) // Romberg integration
End


Macro Wave2DtoPolarParametric(orig,dest) //,nszie)
	String orig,dest
//	Variable nsize=91
	Prompt orig,"Original wave",popup,WaveList("*",";","DIMS:2")
	Prompt dest,"Destination wave"
//	Prompt nsize,"Destination wave size"
	PauseUpdate; Silent 1
	Wave2DtoPolarParametricFunc(orig,dest)
End

Function Wave2DtoPolarParametricFunc(orig,dest)
	String orig,dest
	
	Variable i,j,xx,yy,zz,nth,nph,nth0,nph0,dPh,dTh,ph,th,i1,j1,i2,j2,i3,j3
	If(strlen(dest)==0)
		dest="P_"+orig
	endif
	nth0=DimSize($orig,0)
	nph0=DimSize($orig,1)
	dTh=DimDelta($orig,0)*pi/180
	dPh=DimDelta($orig,1)*pi/180
//	nth=nth0
//	ny=ny0
	nph=(nph0-1)*4+1
	nth=(nth0-1)*2+1
	Make/O/N=(nph,nth,3),$dest
	Wave destwv=$dest,origwv=$orig
	for(j=0;j<nth;j+=1)
		th=j*dTh
		j3=90-abs(90-j)
		for(i=0;i<nph;i+=1)
			ph=i*dPh
			if(i>180)
				i3=90-abs(270-i)
			else
				i3=90-abs(90-i)
			endif
			xx=origwv[j3][i3]*cos(ph)*sin(th)
			yy=origwv[j3][i3]*sin(ph)*sin(th)
			zz=origwv[j3][i3]*cos(th)
			destwv[i][j][0]=xx
			destwv[i][j][1]=yy
			destwv[i][j][2]=zz
		endfor
	endfor
End

// assume orig
Proc To2DimWave(orig0,suffix,ntheta)
	String orig0="rcs"
	Variable suffix,ntheta=91
	PauseUpdate; Silent 1
	
	String orig=orig0+"_"+num2str(suffix)
End
//
