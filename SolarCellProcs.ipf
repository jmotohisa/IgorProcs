#pragma rtGlobals=1		// Use modern global access method.

// tot=900.139e-9
// Procedures to calculate Ultimate Efficiency/average absorption

// DirectCircumsolar2, wavelength2 : AM1.5G spectrum, lambda = 300nm~4micron

Proc initSolarCellProcs()
	String/G g_DirectCircumSolar="DirectCircumSolar2"
	String/G g_wavelength="wavelength2"
End

Function CalcUltimateEffciency0(ywvname,wvlambda,wvSun,Eg)
	String ywvname,wvlambda,wvSun
	Variable Eg
//	PauseUpdate; Silent 1
	
	Wave lambda=$wvlambda,ywv=$ywvname,sun=$wvSun
	Variable tot=900.139e-9,x0,eta
	if(strlen(wvlambda)==0)
		x0=DimOffset(ywv,0)
		Duplicate/O ywv,wvtmp
		wvtmp=ywv*Sun*x
		eta=area(wvtmp,x0,1239.8e-9/Eg)*eg/1239.8e-9/tot
	else
		x0=lambda[0]
		Duplicate/O $wvlambda,wvtmp
		wvtmp=ywv*Sun*lambda
		eta=areaxy(lambda,wvtmp,x0,1239.8e-9/Eg)*eg/1239.8e-9/tot
	endif
	return(eta)
End

// weighted average absorbance

Function CalcWeightedAvrAbs(ywvname,wvlambda,wvSun,wlstart,wlend)
	String ywvname,wvlambda,wvSun
	Variable wlstart,wlend
//	PauseUpdate; Silent 1
	
	Wave lambda=$wvlambda,ywv=$ywvname,sun=$wvSun
	Variable tot,eta
	if(strlen(wvlambda)==0)
		// euqally spaced data both for absorption and sun spectra
		Duplicate/O ywv,wvtmp
		wvtmp=ywv*Sun
		eta=area(wvtmp,wlstart*1e-9,wlend*1e-9)/area(sun,wlstart,wlend)*1e9
	else
		Duplicate/O $wvlambda,wvtmp
		wvtmp=ywv*Sun
		eta=areaxy(lambda,wvtmp,wlstart*1e-9,wlend*1e-9)/areaXY(lambda,sun,wlstart*1e-9,wlend*1e-9)
	endif
	return(eta)
End

Function UEforMat(ywvname,mat,Eg,skip)
	String ywvname,mat
	Variable skip,Eg
	
//	String mat="InP"
	Variable eta
	String wl="wl"+mat+num2str(skip),ss="ss"+mat+num2str(skip)
	if(WaveExists($ss)==0)
		
	endif
	eta=CalcUltimateEffciency0(ywvname,wl,ss,Eg)
	return (eta)
End

Function UEforInP(ywvname,skip)
	String ywvname
	Variable skip
	return(UEforMat(ywvname,"InP",1.344,skip))
End

Function UEforGaAs(ywvname,skip)
	String ywvname
	Variable skip
	return(UEforMat(ywvname,"GaAs",1.424,skip))
End

Function UEforSi(ywvname,skip)
	String ywvname
	Variable skip
	
	return(UEforMat(ywvname,"Si",1.12,skip))
End

Function UEforGe(ywvname,skip)
	String ywvname
	Variable skip
	
	return(UEforMat(ywvname,"Ge",0.661,skip))
End

Function toSS(mat,Eg,skip)
	String mat
	Variable skip,Eg
	
	Variable n,i,nn
	String sss0="ss"+num2str(skip)
	String wls0="wl"+num2str(skip)
	String sss="ss"+mat+num2str(skip)
	String wls="wl"+mat+num2str(skip)
	Wave  ss0=$sss0,wl0=$wls0
	Duplicate/O ss0,$sss
	Duplicate/O wl0,$wls
	Wave ss=$sss,wl=$wls
	n=DimSize(wl0,0)
	i=0
	do
		nn=i
		if(wl0[i]>1239.8/Eg)
			break
		endif
		i+=1
	while(i<n)
	wl*=1e-9
	Redimension/N=(i) ss,wl
End

Function toSSInP(skip)
	Variable skip
	toSS("InP",1.344,skip)
End

Function toSSGaAs(skip)
	Variable skip
	toSS("GaAs",1.424,skip)
End

Function toSSSi(skip)
	Variable skip
	toSS("Si",1.12,skip)
End

Function toSSGe(skip)
	Variable skip
	toSS("Ge",0.661,skip)
End

Macro CalcUEforDS(dest,dsname,skip,mat,Eg)
	String dest,dsname,mat
	Variable skip,Eg
	PauseUpdate; Silent 1
	
	Variable nn=DimSize($dsname,0),index=0
	Make/O/D/N=(nn) $dest
	index=0
	String ssn="ss"+mat+num2str(skip)
	do
		$dest[index]=CalcUltimateEffciency0($dsname[index]+"_abs",$dsname[index]+"_wl",ssn,Eg)
		index+=1
	while(index<nn)
	Display $dest
End

Macro CalcWAAforDS(dest,dsname,skip,mat,wlstart,wlstop)
	String dest,dsname,mat,
	Variable skip,wlstart=300,wlstop=960
	PauseUpdate; Silent 1
	
	Variable nn=DimSize($dsname,0),index=0
	Make/O/D/N=(nn) $dest
	index=0
	String ssn="ss"+mat+num2str(skip)
	do
		$dest[index]=CalcWeightedAvrAbs($dsname[index]+"_abs",$dsname[index]+"_wl",ssn,wlstart,wlstop)
//		CalcUltimateEffciency0($dsname[index]+"_abs",$dsname[index]+"_wl",ssn,Eg)
		index+=1
	while(index<nn)
	Display $dest
End