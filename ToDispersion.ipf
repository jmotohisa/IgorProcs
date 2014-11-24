#pragma rtGlobals=1		// Use modern global access method.

//	from 2Dim wave to dispersion data
//	orig: 2Dim wave with combination of
//		(wavelength-theta)
//		(omega-theta)
// uinit c=1
//
//	ver 0.1	2013/05/13: development started (based on CalcDispersion in various pxp experiments

Macro ToDispersion(orig,mode,kmode,unita,refindex)
	String orig
	Variable mode,kmode
	Variable unita=1,refindex=1
	Prompt orig,"Original 2Dim wave",popup,WaveList("*",";","DIMS:2")
	Prompt mode,"mode",popup,"x:wl-y:theta;x:omega-y:th"
	Prompt kmode,"k-mode",popup,"k-parallel;k-vertical"
	Prompt unita,"unit wavelength"
	Prompt refindex,"refractive index"
//	Variable pitch=0.4e-6,refindex=sqrt(12)
	Silent 1;PauseUpdate
	
	Variable nx,ny,ix,iy
	String xwv="xwv_"+orig,xwv2="xwv2_"+orig,ywv="ywv_"+orig,zwv="zwv_"+orig
	String cmd
	
	nx=DimSize($orig,0)
	ny=DimSize($orig,1)
	Duplicate/O $orig,$xwv,$xwv2,$ywv,$zwv
	if(kmode==1)
		$xwv=2*pi/x*sin(y*pi/180)*unita // normalized k_parallel
	else
		$xwv=2*pi/x*cos(y*pi/180)*unita // normalized k_vertical
	endif
//	if(mode==1)
		$xwv2=x/unita // wavelength
		$ywv=unita/x // normalized omega
//	else
//		$xwv2=unita/x // wavelength
//		$ywv=x/unita // normalized omega
//	endif

	Redimension/N=(nx*ny) $xwv,$xwv2,$ywv,$zwv
	$xwv=$xwv*refindex
//	$xwv=$xwv*n_AlGaAs_sellmeier($xwv2,0) // if reflective index is wavelength dependent
	
	Display /W=(192,44,823,766) $ywv vs $xwv
	ModifyGraph mode=3,marker=19
//	cmd="ModifyGraph zColor("+ywv+")={"+zwv+",0,1,BlueHot}"
	cmd="ModifyGraph zColor("+ywv+")={"+zwv+",*,*,BlueHot}"
	Execute cmd
	ModifyGraph mode=3,marker=19

End
