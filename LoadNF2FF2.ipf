#pragma rtGlobals=1		// Use modern global access method.
#include "JMGeneralTextDataLoad2"
#include "DataSetOperations"
#include "MatrixOperations2"
#include <New Polar Graphs>
//#include "JMGeneralTextDataLoad"

// LoadNF2FF2.ipf
//	Macro to load nf2ff-meep data file
//	based on LoadNF2FF
//	to work with DataSetOperations
//
//	12/02/02 ver. 0.1a by J. Motohisa
//
//	revision history
//		13/06/16	ver 0.1a	development started

Macro initNF2FFLoad(which,prefix)
	Variable which=1
	String prefix
	Prompt which,"load which data ?",popup,"CYL;3D;CYL-part;3D-part;LN"
	Prompt prefix,"prefix for waves"
	PauseUpdate; Silent 1
	initNF2FFLoadFunc(which,prefix)
End

Function initNF2FFLoadFunc(which,prefix)
	Variable which
	String prefix
	
	String/g g_nf2ffcyl_suffix
	String/g g_nf2ff_suffix
	String/g g_nf2ffcylpart_suffix
	String/g g_nf2ffpart_suffix
	String/g g_nf2ffpart_suffix
	String/g g_nf2ffLN_suffix
	String/g g_nf2ff_prefix
	Variable/g g_datanum
	Variable/G g_nf2ff_scalenum
	Variable/G g_nf2ffsuffixNo
	String suffixlist

	g_nf2ffsuffixNo=which
	g_nf2ff_prefix=prefix
	g_nf2ffcyl_suffix=";wavelength;theta;phi;Etheta_re;Etheta_im;Ephi_re;Ephi_im;rcs"
	g_nf2ff_suffix=";wavelength;theta;phi;Etheta_re;Etheta_im;Ephi_re;Ephi_im;rcs"
	g_nf2ffcylpart_suffix=";theta;rcsall;rcs0;rcs1;rcs2;rcs02"
	g_nf2ffpart_suffix=";theta;phi;rcsall;rcs0;rcs1;rcs2;rcs02"	
	g_nf2ffLN_suffix=";Nthre;Nthim;Lphre;Lphim;Nphre;Nphim;Lthre;Lthim"
//	wlist=";;s11;pol;s33;s34"
//	wlist=";radius;wavelength;n_real;n_imag;qscpar;qscper;qexpar;qexper;qabspar;qabsper"
//	wlist=";;t11;pol;t33;t34"

	suffixlist=fsuffixlist(which)
	DSOInitFunc("data",g_nf2ff_prefix,suffixlist)
	JMGTDLinit()
End

Function/S fsuffixlist(which)
	Variable which
	
	String suffixlist
	SVAR g_nf2ffcyl_suffix
	SVAR g_nf2ff_suffix
	SVAR g_nf2ffcylpart_suffix
	SVAR g_nf2ffpart_suffix
	SVAR g_nf2ffpart_suffix
	SVAR g_nf2ffLN_suffix
	if(which==1)
		suffixlist=g_nf2ffcyl_suffix
	elseif(which==2)
		suffixlist=g_nf2ff_suffix
	elseif(which==3)
		suffixlist=g_nf2ffcylpart_suffix
	elseif(which==4)
		suffixlist=g_nf2ffpart_suffix
	elseif(which==5)
		suffixlist=g_nf2ffLN_suffix
	else
		suffixlist=g_nf2ffcyl_suffix	
	endif	
	return(suffixlist)
end

Macro LoadNF2ffMulti(which,thePath,fNameMask,dsindex,col,fquiet)
	Variable which=g_nf2ffsuffixNo,startindex,dsindex=g_DSO_index,fquiet=1,col=2
	String thePath="_New Path_",fNameMask
	Prompt which,"load which data ?",popup,"CYL;3D;CYL-part;3D-part;LN"
	Prompt thePath, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"
	Prompt fNameMask,"mask for file name"
	Prompt dsindex,"index for data set"
	Prompt col,"x-axis",popup,";angle;"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1;
	
	Variable index,dispGraph=2
	String suffixlist=fsuffixlist(which),ftype=".dat",dsetnm0

	g_nf2ffsuffixNo=which
	dsetnm0=g_DSO_name+num2istr(dsindex)
	JMGTDL2multi0func(dsetnm0,g_DSO_prefix,thePath,fNamemask,ftype,suffixlist,col,dispGraph,fquiet)
	DoWindow/F DataSetTable
	AppendToTable $dsetnm0
	
	g_DSO_index=dsindex+1
End

Macro LoadNf2ffCylinder(fname,pname,index,dispTable,dispGraph,col,fquiet)
	String fname,pname="home"
	Variable index=g_datanum,dispTable=2,dispGraph=2,col=2,fquiet=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt index,"index"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	Prompt col,"x-axis",popup,";angle;"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1;
	
	String extName=".dat",suffixlist,prefix=g_nf2ff_prefix
	suffixlist=g_nf2ffcyl_suffix
	
	JMGeneralDatLoaderFunc2(fname,pname,extName,index,prefix,suffixlist,col,fquiet)
//	JMGeneralDatLoaderFunc(fname,pname,g_nf2ffcylWN,suffix,col,dispTable,dispGraph,fquiet)
	if(dispGraph==1)
		JMGTDDisplay(g_JMGTDL_wname,suffixlist)
	endif
	g_datanum=index+1
End

Macro LoadNf2ff(fname,pname,index,dispTable,dispGraph,col,fquiet)
	String fname,pname="home"
	Variable index=g_datanum,dispTable=2,dispGraph=2,col=2,fquiet=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt index,"index"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	Prompt col,"x-axis",popup,";angle;"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1;
	
	String extName=".dat",suffixlist,prefix=g_nf2ff_prefix
	suffixlist=g_nf2ff_suffix
	
	JMGeneralDatLoaderFunc2(fname,pname,extName,index,prefix,suffixlist,col,fquiet)
	if(dispGraph==1)
		JMGTDDisplay(g_JMGTDL_wname,suffixlist)
	endif
	g_datanum=index+1
End

Macro LoadNF2FFpartCylinder(fname,pname,index,dispTable,dispGraph,col,fquiet)
	String fname,pname="home"
	Variable index=g_datanum,dispTable=2,dispGraph=2,col=2,fquiet=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt index,"index"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	Prompt col,"x-axis",popup,";angle;"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1;
	
	String extName=".dat",suffixlist,prefix=g_nf2ff_prefix
	suffixlist=g_nf2ffcylpart_suffix
	
	JMGeneralDatLoaderFunc2(fname,pname,extName,index,prefix,suffixlist,col,fquiet)
	if(dispGraph==1)
		JMGTDDisplay(g_JMGTDL_wname,suffixlist)
	endif
	g_datanum=index+1
End

Macro LoadNF2FFpart(fname,pname,index,dispTable,dispGraph,col,fquiet)
	String fname,pname="home"
	Variable index=g_datanum,dispTable=2,dispGraph=2,col=2,fquiet=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt index,"index"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	Prompt col,"x-axis",popup,";angle;"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1;
	
	String extName=".dat",suffixlist,prefix=g_nf2ff_prefix
	suffixlist=g_nf2ffpart_suffix
	
	JMGeneralDatLoaderFunc2(fname,pname,extName,index,prefix,suffixlist,col,fquiet)
	if(dispGraph==1)
		JMGTDDisplay(g_JMGTDL_wname,suffixlist)
	endif
	g_datanum=index+1
End

Macro LoadNF2FFLN(fname,pname,suffix,dispTable,dispGraph,col,fquiet)
	String fname,pname="home"
	Variable index=g_datanum,dispTable=2,dispGraph=2,col=2,fquiet=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt index,"index"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	Prompt col,"x-axis",popup,";angle;"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate; Silent 1;
	
	String extName=".dat",suffixlist,prefix=g_nf2ff_prefix
	suffixlist=g_nf2ffLN_suffix
	
	JMGeneralDatLoaderFunc2(fname,pname,extName,index,prefix,suffixlist,col,fquiet)
	if(dispGraph==1)
		JMGTDDisplay(g_JMGTDL_wname,suffixlist)
	endif
	g_datanum=index+1
End

// make Matrix wave from a dataset
// row (x): 
// column (y): angle
Macro RCSWavestoMatrixDS(dsetnm,ind0,twvsuffix,dest,xstart,xstep,fdisp)
	String dsetnm,twvsuffix="rcsall",dest
	Variable ind0,xstart,xstep=1,fdisp=1
	Prompt dsetnm,"dataset name"
	Prompt ind0,"dataset index"
	Prompt twvsuffix,"data suffix"
	Prompt dest,"destination wave name"
	Prompt xstart,"starting x scaling"
	Prompt xstep,"step"
	Prompt fdisp,"display graph?",popup,"yes;no"
	
	FRCSWavestoMatrixDS(dsetnm,ind0,twvsuffix,dest,xstart,xstep)
	if(fdisp==1)
		Display;AppendImage $dest
	endif
End

Function FRCSWavestoMatrixDS(dsetnm,ind0,twvsuffix,dest,xstart,xstep)
	String dsetnm,twvsuffix,dest
	Variable ind0,xstart,xstep
	
	DSOFwavesToMatrix(dsetnm,ind0,twvsuffix,dest)
	MatrixTranspose $dest
	SetScale/P x xstart,xstep,"", $dest
End

///////////////////////////
// conversion from theta-phi wave to a 3D wave for parametric plot
// assume both theta-phi from 0 to 90 degree

Macro Wave2DtoPolarParametric(orig,dest,phwend,thwend,phend,thend) //,nszie)
	String orig,dest
	Variable phwend,thwend,phend,thend
//	Variable nsize=91
	Prompt orig,"Original wave",popup,WaveList("*",";","DIMS:2")
	Prompt dest,"Destination wave"
	Prompt phwend,"max ph for original wave",popup,"90deg;180deg"
	Prompt thwend,"max th for original wave",popup,"90deg;180deg"
	Prompt phend,"max ph for destination wave",popup,"360deg"
	Prompt thend,"max th for destination wave",popup,"90deg;180deg"

//	Prompt nsize,"Destination wave size"
	PauseUpdate; Silent 1
	Wave2DtoPolarParametricFunc(orig,dest,phwend,thwend,phend,thend)
End

Function Wave2DtoPolarParametricFunc(orig,dest,phwend,thwend,phend,thend)
	String orig,dest
	Variable phwend,thwend,phend,thend
	
	Variable i,j,xx,yy,zz,nth,nph,nth0,nph0,dPh,dTh,ph,th,i1,j1,i2,j2,i3,j3
	Variable thwmax,phwmax
	Variable dTh0,dPh0
	If(strlen(dest)==0)
		dest="P_"+orig
	endif
	nth0=DimSize($orig,0)
	nph0=DimSize($orig,1)
	dTh0=DimDelta($orig,0)
	dPh0=DimDelta($orig,1)
	thwmax=nth0*dTh0
	phwmax=nph0*dPh0
	dTh=dTh0*pi/180
	dPh=dPh0*pi/180
//	nth=nth0
//	ny=ny0
	if(phwend==1 && phend==1)
		nph=(nph0-1)*4+1 // 90deg -> 360deg
	else	
		nph=(nph0-1)*2+1 // 90deg -> 180deg,180deg->360deg
	endif
	if((thwend==1 && thend==1) || (thwend ==2 && thend==2))
		nth=nth0 // 90deg -> 90deg or 180deg ->180deg
	else
		nth=(nth0-1)*2+1 // 90deg -> 180deg
	endif
	
	Make/O/N=(nph,nth,3),$dest
	Wave destwv=$dest,origwv=$orig
	SetScale/P x 0,dTh0,"", destwv
	SetScale/P y 0,dPh0,"", destwv

	for(j=0;j<nth;j+=1)
		th=j*dTh
		j3=(nth0-1)-abs((nth0-1)-j)
		for(i=0;i<nph;i+=1)
			ph=i*dPh
			if(ph>pi)
				i3=((nph0-1)-abs((nph0-1)*3-ph*180/pi))
			else
				i3=(nph0-1)-abs((nph0-1)-ph*180/pi)
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

/////////////////////////////////
// calculate integrated emission intensity
Function RCSIntegrate(orig,unit)
	String orig
	Variable unit
	
	Variable val
//	Wave dummy
	Duplicate/O $orig,dummy_rcsintegrate
	Wave origwave=$orig
	if(unit==1) // unit is radian
		dummy_rcsintegrate=origwave*sin(x)
		val=area(dummy_rcsintegrate)
	else // unit is degree
		dummy_rcsintegrate=origwave*sin(pi/180*x)
		val=area(dummy_rcsintegrate)*pi/180
	endif
	return(val)
End

// Integrated emission intensity of each waves in the dataset: 
Function RCSIntegDS(dsetnm,ind0,ywvnm,dest)
	String dsetnm,ywvnm,dest
	Variable ind0
	
	String dsname0=dsetnm+num2istr(ind0)
	Wave/T dsname=$dsname0
	Variable n=DimSize(dsname,0),i
	String ywv,ywvnm2
	Make/O/N=(n) $dest
	Wave destw=$dest
	
//	DSOFDuplicate(dsetnm,ind0,ywvnm,ywvnm2)
	i=0
	Do
		ywv=dsname[i]+"_"+ywvnm
		destw[i]=RCSIntegrate(ywv,2)
		i+=1
	while(i<n)
end

// Integrated emission intensity for Matrix wave:
// scale of Wave orig is assumed to be angle theta in degree
Macro RCSIntegrate2DWave(orig,dest,flag,fdisp)
	String orig,dest
	Variable flag=2,fdisp=1
	Prompt orig,"original 2D wave"
	Prompt dest, "results wave name"
	Prompt flag,"Which is theta for theta ?", popup,"low;column"
	Prompt fdisp,"display graph ?",popup,"yes;no"
	PauseUpdate; Silent 1	
	RCSFIntegrate2Dwave(orig,dest,flag)
	if(fdisp==1)
		Display $dest
	endif
End

Function RCSFIntegrate2Dwave(orig,dest,flag)
	String orig,dest
	Variable flag
	
	Wave worig=$orig
	Variable nx,ny
	if(flag==2)
		nx=DimSize(worig,0)
		ny=DimSize(worig,1)
	else
		nx=DimSize(worig,1)
		ny=DimSize(worig,0)
	Endif
	Duplicate/O worig,$dest
	Wave wdest=$dest
	Redimension/N=(nx) wdest
	Duplicate/O worig,dummy_RCS2D
	if(flag==2)
		MatrixTranspose dummy_RCS2D
	Endif
	Redimension/N=(ny) dummy_RCS2D
	Variable i=0
	do
		if(flag==2)
			dummy_RCS2D=worig[i][p]
		else
			dummy_RCS2D=worig[p][i]
		Endif
		wdest[i]=RCSIntegrate("dummy_RCS2D",2)
		i+=1
	while(i<nx)
End
	
// calucate normalized wave and LDOS
//  Normalize for a single wave
Macro RCSNormalize(orig,dest)
	String orig="rcs_",dest
	PauseUpdate;Silent 1;
	
	Variable c
	Duplicate/O $orig,$dest
	c=RCSIntegrate(dest,2)
	$dest/=c
End

// Normalize for a matrix wave: column (y) should be an angle in degree
Macro RCSNormalize2Dwave(orig,integd,dest,fdisp)
	String orig,dest,integd
	Variable fdisp
	Prompt orig,"original 2D wave"
	Prompt integd,"2D wave for reference"
	Prompt dest, "destination 2D name"
	Prompt fdisp,"display graph ?",popup,"yes;no"
	
	Variable dointeg=0
	if(strlen(integd)==0)
		integd="dummy_"+orig
		dointeg=1
	endif
	RCSFNormalize2Dwave(orig,dest,doInteg,integd)
	if(fdisp==1)
		Display;AppendImage $dest
	Endif
End

Function RCSFNormalize2Dwave(orig,dest,doInteg,integd)
	String orig,dest,integd
	Variable doInteg
	
	if(doInteg==1)
		RCSFIntegrate2Dwave(orig,integd,2)
	endif
	FMatrixDivX(orig,integd,dest)
End

// reference FF pattern (emission from a dipole with exp(i*m*phi) symmetry
// 1D wave: return integrated intensity
Function RCSFIntegrate_zref(orig,dest,wl,r0,m)
	String orig,dest
	Variable wl,r0,m
	
	Wave worig=$orig
	Duplicate/O worig,$dest
	Wave wdest=$dest
	wdest=zdipole(y*pi/180,m,wl,r0)
	return(RCSIntegrate(dest,2))
End

Function RCSFIntegrate_cref(orig,dest,wl,r0,m)
	String orig,dest
	Variable wl,r0,m
	
	Wave worig=$orig
	Duplicate/O worig,$dest
	Wave wdest=$dest
	wdest=cdipole(y*pi/180,m,wl,r0)
	return(RCSIntegrate(dest,2))
End

// 2D wave: wave sacling is (wavelength,angle)
Function RCSFzref_2Dwave(orig,dest,r0,m)
	String orig,dest
	Variable r0,m
	
	Wave worig=$orig
	Duplicate/O worig,$dest
	Wave wdest=$dest
	wdest=zdipole(y*pi/180,m,x,r0)
End

Function RCSFcref_2Dwave(orig,dest,r0,m)
	String orig,dest
	Variable r0,m
	
	Wave worig=$orig
	Duplicate/O worig,$dest
	Wave wdest=$dest
	wdest=cdipole(y*pi/180,m,x,r0)
End

// integrate reference
Function RCSFIntegrate_zref_2Dwave(orig,dest,r0,m)
	String orig,dest
	Variable r0,m

	String temp="dummy_"+dest
	Wave worig=$orig
	Duplicate/O worig,$temp
	Wave wtemp=$temp
	wtemp=zdipole(y*pi/180,m,x,r0)
	RCSFIntegrate2DWave(temp,dest,2)
End

Function RCSFIntegrate_cref_2Dwave(orig,dest,r0,m)
	String orig,dest
	Variable r0,m

	String temp="dummy_"+dest
	Wave worig=$orig
	Duplicate/O worig,$temp
	Wave wtemp=$temp
	wtemp=cdipole(y*pi/180,m,x,r0)
	RCSFIntegrate2DWave(temp,dest,2)
End

// LDOS: for a single wave
Function zLDOS_Function(orig,wl,r0,m)
	String orig
	Variable wl,r0,m
	
	Variable rcs0,rcsref
	String dest="dummy_LDOS"
	rcs0=RCSIntegrate(orig,2)
	rcsref=RCSFIntegrate_zref(orig,dest,wl,r0,m)
	return(rcs0/rcsref)
End

Function cLDOS_Function(orig,wl,r0,m)
	String orig
	Variable wl,r0,m
	
	Variable rcs0,rcsref
	String dest="dummy_LDOS"
	rcs0=RCSIntegrate(orig,2)
	rcsref=RCSFIntegrate_cref(orig,dest,wl,r0,m)
	return(rcs0/rcsref)
End

// LDOS: for a 2D wave with scaling (wavelength,angle)
Function zLDOS_Function_2Dwave(orig,dest,r0,m)
	String orig,dest
	Variable r0,m
	
	String dest0="dummy_"+dest
	RCSFIntegrate2Dwave(orig,dest,2)
	Wave wdest=$dest
	RCSFIntegrate_zref_2Dwave(orig,dest0,r0,m)
	Wave wdest0=$dest0
	wdest/=wdest0
End

Function cLDOS_Function_2Dwave(orig,dest,r0,m)
	String orig,dest
	Variable r0,m
	
	String dest0="dummy_"+dest
	RCSFIntegrate2Dwave(orig,dest,2)
	Wave wdest=$dest
	RCSFIntegrate_cref_2Dwave(orig,dest0,r0,m)
	Wave wdest0=$dest0
	wdest/=wdest0
End

// caculate reference and total intensity (with dataset operation)
Proc calc_zref(ind0,mode,wl,r00)
	Variable ind0,mode,wl=850/115,r00
	PauseUpdate; Silent 1
	
	Variable index,r0
	String ds=g_DSO_name+num2istr(ind0)
	Variable n=DimSize($ds,0)
	String bwnm,suffix="ref",wv0,wtarget,wdest
	Do
		bwnm=$ds[index]
		r0=r00+0.1*index
		calcFFzref(bwnm,"rcsall",mode,wl,r0)
		index+=1
	while(index<n)
//	DSOFDuplicate(g_DSO_name,ind0,"rcsall","norm")
	RCSIntegDS("data",ind0,"ref","normtemp")
	DSOFMathWithaWave(g_DSO_name,ind0,"rcsall",4,"normtemp","norm")
End

Proc calc_cref(ind0,mode,wl,r00)
	Variable ind0,mode,wl=850/115,r00
	PauseUpdate; Silent 1
	
	Variable index,r0
	String ds=g_DSO_name+num2istr(ind0)
	Variable n=DimSize($ds,0)
	String bwnm,suffix="ref",wv0,wtarget,wdest
	Do
		bwnm=$ds[index]
		r0=r00+0.1*index
		calcFFcref(bwnm,"rcsall",mode,wl,r0)
		index+=1
	while(index<n)
//	DSOFDuplicate(g_DSO_name,ind0,"rcsall","norm")
	DSOFIntegWave0(g_DSO_name,ind0,"ref","","normtemp")
	DSOFMathWithaWave(g_DSO_name,ind0,"rcsall",4,"normtemp","norm")
End

///////////////////////////
// Emission from a dipole at r=r0 with azimuthal symmetry m
// z-polarization
Function zdipole(theta,m,wl,r0)
	Variable theta,m,wl,r0
	
	return(sin(theta)^2*BesselJ(m,2*pi/wl*sin(theta)*r0)^2*(2*pi/wl)^2/(8*pi))
//	return(sin(theta)^2*BesselJ(m,2*pi/wl*sin(theta)*r0)^2*(2*pi/wl)^4/(8*pi))
End

// c-polarization
Function cdipole(theta,m,wl,r0)
	Variable theta,m,wl,r0
	
	return((1+cos(theta)^2)/2*BesselJ(m,2*pi/wl*sin(theta)*r0)^2*(2*pi/wl)^2/(8*pi))
//	return(sin(theta)^2*BesselJ(m,2*pi/wl*sin(theta)*r0)^2*(2*pi/wl)^4/(8*pi))
End

///
Proc FFIntensity():GraphStyle
	ModifyGraph gfSize=18
	ModifyGraph manTick(bottom)={0,30,0,0},manMinor(bottom)={2,50}
	Label left "Far-field intensity (arb. units)"
	Label bottom "angle \\F'Symbol'q\\F'Helvetica' (degree)"
End

//// obsolete
// assume orig
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

Proc To2DimWave(orig0,suffix,ntheta)
	String orig0="rcs"
	Variable suffix,ntheta=91
	PauseUpdate; Silent 1
	
	String orig=orig+"_"+num2str(suffix)
	String wlen="wavelength_"+num2str(suffix)
	Variable wlmin,wlmax,thetamin,thetamax,ny
	if(WaveDims($orig)!=1)
		return
	endif
	WaveStats/Q $wlen
	wlmin=V_min
	wlmax=V_max
	WaveStats/Q $orig
	thetamin=V_min
	thetamax=V_max
	ny=DimSize($orig,0)/ntheta
	Redimension/N=(nthetaa,ny) $orig
	SetScale/I x,thetamin,thetamax,"",$orig
	SetScale/I y,wlmax,wlmin,"",$orig // note swapped
End
