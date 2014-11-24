#pragma rtGlobals=1		// Use modern global access method.

// reflectivity.ipf
// by J. Motohisa
// calculation of reflectivity in two-layer / three layer
// two-layer: calculate reflectivity/transmitance as a function of incident angle
// three-layer: calculate reflectivity/transmiattance as a function of wavelength

// revision history
// ver 0.3 : 2010/09/27 three layer with normal incidence added, two layer with complex epsilon added
// ver 0.2 : 2008/10/15 : first bugfixed version
// ver 0.1  ???? : development started, not documented 
//

Macro Initialize_Reflectvivity(grname,wvname)
	String grname,wvname
	Prompt grname,"graph name"
	Prompt wvname,"prefix for wave name"
	PauseUpdate; Silent 1
	
	String/G g_grname,g_wvname,g_wvnameH,g_wvnameE
	String wvnameE,wvnameH
	g_grname=grname
	g_wvname=wvname
	wvnameE=wvname+"E"
	wvnameH=wvname+"H"
	
	Make/D/O $wvnameE,$wvnameH
	Make/C/D/O kx,kz
	Make/C/O kx0,yy0
	SetScale/I x 0,90,"degree",kx,kz,$wvnameE,$wvnameH,kx0,yy0
//	kx=sin(x/180*pi)
//	kz=cos(x/180*pi)
End

Macro cal_reflectivity(grname,wvname,eps0,eps1)
	Variable/D eps1=3,eps0=1
	String grname=g_grname,wvname=g_wvname
	PauseUpdate; Silent 1
	
	String tbstr0,tbstr1
	String wvnameE,wvnameH
	g_wvname=wvname
	g_grname=grname
	wvnameE=wvname+"E"
	wvnameH=wvname+"H"

	kx = sqrt(eps0) * sin(x/180*pi)
	kz = sqrt(eps0) * cos(x/180*pi)
	kx0 = sqrt(eps1 - kz*kz)
	yy0 = kx/kx0
	$wvnameE = cabs(((eps1/eps0)*yy0-1)/((eps1/eps0)*yy0+1))^2
	$wvnameH = cabs((yy0-1)/(yy0+1))^2
	if(strsearch(WinList("*",";","WIN:1"),grname,0)<0)
		display $wvnameE,$wvnameH;DoWindow/C $grname
	else
		DoWindow/F $grname
	endif
	ReflectivityStyle()
	tbstr0="\\s("+wvnameE+") E-wave\r\\s("+wvnameH+") H-wave"
	tbstr1="\\F'Symbol'e\\F'Helvetica'\\B1\\M/\\F'Symbol'e\\F'Helvetica'\\B0\\M = "+num2str(eps0)+"/"+num2str(eps1)
	if(strsearch(AnnotationList(""),"text0",0)<0)
		Legend/J/N=text0/F=0/A=MC/X=-28.96/Y=30.88 tbstr0
	else
		Legend/C/N=text0/F=0/A=MC/X=-28.96/Y=30.88 tbstr0
	endif
	if(strsearch(AnnotationList(""),"text1",0)<0)
		Textbox/N=text1/F=0/A=MC/X=28.66/Y=40.00 tbstr1
	else
		Textbox/C/N=text1/F=0/A=MC/X=28.66/Y=40.00 tbstr1
	endif
End Macro

Macro cal_reflectivity2(grname,wvname,eps0,eps11,eps12)
	Variable/D eps11=3,eps12=0,eps0=1
	String grname=g_grname,wvname=g_wvname
	PauseUpdate; Silent 1
	
	String tbstr0,tbstr1
	String wvnameE,wvnameH
	Variable/C eps1=cmplx(eps11,eps12)
	g_wvname=wvname
	g_grname=grname
	wvnameE=wvname+"E"
	wvnameH=wvname+"H"

	kx = sqrt(eps0) * sin(x/180*pi)
	kz = sqrt(eps0) * cos(x/180*pi)
	kx0 = sqrt(eps1 - kz*kz)
	yy0 = kx/kx0
	$wvnameE = cabs(((eps1/eps0)*yy0-1)/((eps1/eps0)*yy0+1))^2
	$wvnameH = cabs((yy0-1)/(yy0+1))^2
	if(strsearch(WinList("*",";","WIN:1"),grname,0)<0)
		display $wvnameE,$wvnameH;DoWindow/C $grname
	else
		DoWindow/F $grname
	endif
	ReflectivityStyle()
	tbstr0="\\s("+wvnameE+") E-wave\r\\s("+wvnameH+") H-wave"
	tbstr1="\\F'Symbol'e\\F'Helvetica'\\B1\\M/\\F'Symbol'e\\F'Helvetica'\\B0\\M = "+num2str(eps11)+"+ "+num2istr(eps12)+"i/"+num2str(eps0)
	if(strsearch(AnnotationList(""),"text0",0)<0)
		Legend/J/N=text0/F=0/A=MC/X=-28.96/Y=30.88 tbstr0
	else
		Legend/C/N=text0/F=0/A=MC/X=-28.96/Y=30.88 tbstr0
	endif
	if(strsearch(AnnotationList(""),"text1",0)<0)
		Textbox/N=text1/F=0/A=MC/X=28.66/Y=40.00 tbstr1
	else
		Textbox/C/N=text1/F=0/A=MC/X=28.66/Y=40.00 tbstr1
	endif
End Macro

Proc ReflectivityStyle() : GraphStyle
	PauseUpdate; Silent 1		// modifying window...
	ModifyGraph/Z gfSize=14,width=227,height=227
	ModifyGraph/Z lStyle[1]=2
	ModifyGraph/Z tick=2
	ModifyGraph/Z mirror=1
	ModifyGraph/Z standoff=0
	ModifyGraph/Z manTick(bottom)={0,30,0,0},manMinor(bottom)={3,50}
	Label/Z left "Refrectivity R"
	Label/Z bottom "Incident Angle \\F'Symbol'a\\F'Helvetica' (\\U)"
	SetAxis/Z left 0,1.1
EndMacro

/// three layer
// eps0 : first (incident layer)
// eps11: real part of the dielectric constant in the 2nd layer
// eps12: imaginary part of the dielectric constant in the 2nd layer
// eps2: dielectric constant in the 3nd layer
// t: thickness of 2nd layer devided by wavelength (t/lambda)

Function transmission3(eps0,eps11,eps12,eps2,t)
	Variable eps0,eps11,eps12,eps2,t

	Variable/c trn,k1,e0,e00
	Variable k0,k2,e000
	k1=sqrt(cmplx(eps11,eps12))
	k0=sqrt(eps0)
	k2=sqrt(eps2)

	e0=exp(k1*cmplx(0,1)*t*2*pi)
	e00=(k0+k1)*(k1+k2)/e0+((k0-k1)*(k1-k2)*e0)
	trn=4*k0*k1/e00
	return(cabs(trn)^2*k2/k0)
end

Function reflectivity3(eps0,eps11,eps12,eps2,t)
	Variable eps0,eps11,eps12,eps2,t

	Variable/c ref,k1,e0
	Variable k0,k2
	k1=sqrt(cmplx(eps11,eps12))
	k0=sqrt(eps0)
	k2=sqrt(eps2)

	e0=exp(2*k1*cmplx(0,1)*t*2*pi)
	ref=((k0-k1)*(k1+k2)+(k0+k1)*(k1-k2)*e0)/((k0+k1)*(k1+k2)+(k0-k1)*(k1-k2)*e0)
	return(cabs(ref)^2)
end



