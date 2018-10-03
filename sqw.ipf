#pragma rtGlobals=1		// Use modern global access method.
#include "BandGaps"
#include "PhysicalConstants"

// sqw.ipf
//
// Procedure for calculation of quantized energy in a single quantum well.
// based on Model Solid Theory (C. van de Walle, PRB 39, 1871 (1989).)
//
//	05/12/21 ver. 0.2b by J. Motohisa
//
//	revision history
//		05/12/16 ver. 0.1a: first version
//		05/12/21 ver. 0.2a: macro for GaAs/AlGaAs QW; flag for draw graph is added to SQWEnergy_Wellwidth macro
//		06/12/21 ver. 0.2b: macro for GaAs/AlGaAs QW; flag for draw graph is added to SQWEnergy_Wellwidth macro
//		06/09/06 ver. 0.21a: modified not to make wave to display graph of eigenvalue equation (temporary, use optional parameter to display it in the future vesion)
//		07/01/09 ver. 0.22a: solution of odd states added
//		08/05/06	ver 0.22a1: procedure init_phsicalConstants becomes a independent procedure PhysicalConstants.ipf
//		18/10/02	ver 0.3a1: calculation of SL energy added

Macro init_SQW(wv,l1,l2)
	String wv
	Variable l1=5e-9,l2=10e-9
	Prompt wv, "wave name"
	Prompt l1, "start well width (m)"
	Prompt l2, "Stop well width (m)"	
	PauseUpdate; Silent 1
	
	init_PhysicalConstants()
	String/G g_sqwwv=wv
	Variable/G g_energy
	String gn
	Make/O/N=5 sqw_prm
	Make/O $wv
	Lwwave(wv,l1,l2)
	gn="graph_"+wv
	Display $wv
	DoWindow/C $gn
	ModifyGraph zero(left)=1
End

Proc Lwwave(wv,lw1,lw2)
	String wv=g_sqwwv
	Variable lw1,lw2
	PauseUpdate; Silent 1
	
	g_sqwwv=wv
	Make/O $wv
	SetScale/I x,lw1,lw2,"m",$wv
	SetScale d 0,0,"eV",$wv
End

Macro SQWEnergy_WellWidth(wv,V0,mw,mb,fgraph)
	String wv=g_sqwwv
	Variable V0,mw,mb,fgraph=2
	Prompt wv,"wave name"
	Prompt V0,"Barrier height (eV)"
	Prompt mw,"effective mass in the well"
	Prompt mb,"effective mass in the barrier"
	Prompt fgraph,"Draw graph",popup,"no;yes"
	PauseUpdate;Silent 1
	
	Variable i=0,n=DimSize($wv,0),Lw
	Do
//		print x
		Lw=DimOffset($wv,0)+i*DimDelta($wv,0)
		find_energy_SQW(Lw, 0,V0,mw,mb,2)
//		print Lw,g_energy
		$wv[i]=g_energy
		i+=1
	while(i<n)
	if(fgraph==2)
		Display $wv
	endif
End

Function Ffind_energy_SQW(Lw, Lb,V0,mw,mb,fd)
	Variable Lw,Lb,V0,mw,mb
	Variable fd

	Variable alph,beta
	Variable a,b
	Variable epsilon=V0/1000,e0
	NVAR g_MEL,g_EC,g_HBAR
	String prmwv="sqw_prm",tempwv="sqw_tempwv",reswv="sqw_results"
	Wave wprmwv=$prmwv
	wprmwv[0]=Lw
	wprmwv[1]=Lb
	wprmwv[2]=V0
	wprmwv[3]=mw
	wprmwv[4]=mb

	if(fd==1)
		Make/O $tempwv
		Display $tempwv
	endif
	Wave wtempwv=$tempwv

	e0=g_HBAR^2*(pi/Lw)^2/(2*g_MEL*mw)/g_EC
	if(e0>V0)
		e0=v0*0.999
	endif
	a = 2.*g_MEL*wprmwv[3]*g_EC/(g_HBAR*g_HBAR)
	if(fd==1)
		SetScale/I x,epsilon,V0,wtempwv
		wtempwv=sqw_function_even(wprmwv,x)
//		$tempwv= sqrt( mw/mb * (V0/x-1.))*cos(sqrt(a*x)*Lw/2.) - sin(sqrt(a*x)*Lw/2.)
		//sqrt(w[3]/w[4] * (w[2]/xx-1.))*cos(a*sqrt(xx)*w[0]/2.) - sin(a*sqrt(xx)*w[0]/2.)
		SetAxis left -2,2 
		ModifyGraph zero(left)=1
	endif

	FindRoots/Q/L=(epsilon)/H=(e0) sqw_function_even,wprmwv
	If(V_flag!=0)
		print V_flag
	Endif
	return(V_Root)
End

Macro find_energy_SQW(Lw, Lb,V0,mw,mb,fd)
	Variable Lw=10e-9,Lb=0,V0=1,mw=0.067,mb=0.067
	Variable fd=1
	Prompt Lw,"Well width (m)"
	Prompt Lb,"Barrier width (m)"
	Prompt V0,"Barrier height (eV)"
	Prompt mw,"effective mass in well (m0)"
	Prompt mb,"effective mass in barrier (m0)"
	Prompt fd,"draw tempgraph ?",popup,"yes;no"
	PauseUpdate;Silent 1

	g_energy=Ffind_energy_SQW(Lw, Lb,V0,mw,mb,fd)
End

Macro find_energy_SQW_all(Lw, Lb,V0,mw,mb,fd)
	Variable Lw=10e-9,Lb=0,V0=1,mw=0.067,mb=0.067
	Variable fd=1
	Prompt Lw,"Well width (m)"
	Prompt Lb,"Barrier width (m)"
	Prompt V0,"Barrier height (eV)"
	Prompt mw,"effective mass in well (m0)"
	Prompt mb,"effective mass in barrier (m0)"
	Prompt fd,"draw tempgraph ?",popup,"yes;no"
	PauseUpdate;Silent 1

	Variable alph,beta
	Variable a,b
	Variable epsilon=V0/1000,e0,el_even,el_odd,er
	Variable nbound,nn
	String prmwv="sqw_prm",tempwv_even="sqw_tempwv_even",tempwv_odd="sqw_tempwv_odd",reswv="sqw_results"
	$prmwv[0]=Lw
	$prmwv[1]=Lb
	$prmwv[2]=V0
	$prmwv[3]=mw
	$prmwv[4]=mb
	
	nbound=1+floor(sqrt(2*mw*g_MEL*V0*g_EC)*Lw/(pi*g_HBAR))
	print "number of bound states : ",nbound

	e0=g_HBAR^2*(pi/Lw)^2/(2*g_MEL*mw)/g_EC
	if(e0>V0) then
		e0=v0*0.999
	endif
	a = 2.*g_MEL*$prmwv[3]*g_EC/(g_HBAR*g_HBAR)

	Make/O $tempwv_even,$tempwv_odd
	SetScale/I x,epsilon,V0,$tempwv_even,$tempwv_odd
	$tempwv_even= sqrt( mw/mb * (V0/x-1.))*cos(sqrt(a*x)*Lw/2.) - sin(sqrt(a*x)*Lw/2.)
	$tempwv_odd= sqrt( mw/mb * (V0/x-1.))*sin(sqrt(a*x)*Lw/2.) + cos(sqrt(a*x)*Lw/2.)

	if(fd==1)
		Display $tempwv_even,$tempwv_odd
		ModifyGraph rgb($tempwv_odd)=(0,0,65535)
		SetAxis left -2,2 
		ModifyGraph zero(left)=1
	endif

	nn=1
	el_even=epsilon
	el_odd=epsilon
	er=e0
	do
		if(mod(nn,2)==1)
			FindRoots/Q/L=(el_even)/H=(er) sqw_function_even,$prmwv
		else
			FindRoots/Q/L=(el_odd)/H=(er) sqw_function_odd,$prmwv
		endif
		If(V_flag!=0)
			Print "energy not found, error code = ",V_flag
			print nn,el_even,el_odd,er,e0
			break
		Endif
		print "Energy ",nn,"=",V_Root
		nn+=1
		
//		if(mod(nn,2)==1)
			el_even =V_Root*1.1
//		else
			el_odd = V_Root*1.1
//		endif
		er=e0*nn^2
		if(er>V0) then
			er=v0*0.999
		endif
	while(nn<=nbound)
//	g_energy= V_Root
End

Function sqw_function_even(w,xx)
	Wave w
	Variable xx
	Variable a,b
	a= sqrt(w[3])*5.12285e+09
//	b= w[4]*2.64748e+19
//	a = 2.*g_MEL*w[3]*g_EC/(g_HBAR*g_HBAR)
//	b = 2.*g_MEL*w[4]*g_EC/(g_HBAR*g_HBAR)
	Return(sqrt(w[3]/w[4] * (w[2]/xx-1.))*cos(a*sqrt(xx)*w[0]/2.) - sin(a*sqrt(xx)*w[0]/2.))
End

Function sqw_function_odd(w,xx)
	Wave w
	Variable xx
	Variable a,b
	a= sqrt(w[3])*5.12285e+09
//	b= w[4]*2.64748e+19
//	a = 2.*g_MEL*w[3]*g_EC/(g_HBAR*g_HBAR)
//	b = 2.*g_MEL*w[4]*g_EC/(g_HBAR*g_HBAR)
	Return(sqrt(w[3]/w[4] * (w[2]/xx-1.))*sin(a*sqrt(xx)*w[0]/2.) + cos(a*sqrt(xx)*w[0]/2.))
End

Macro SQW_GaAs_AlGaAs(wv,xAl,temp,dec,ems,emh)
	String wv=g_sqwwv
	Variable xAl=1,temp=300,dec=60, ems=0.067,emh=0.35
	Prompt wv,"wave name (x the well width)"
	Prompt xAl,"Aluminum content"
	Prompt temp,"temperature (K)"
	Prompt dec "conduction band offset (%)"
	Prompt ems "electron effective mass (m0)"
	Prompt emh,"hole effective mass (m0)"
	PauseUpdate;Silent 1
	
	String wv_e=wv+"_e1",wv_hh=wv+"_hh"
	Variable V0,mw,mb,Eg_GaAs,Eg_AlGaAs,dEg
	String cmd
	Duplicate/O $wv,$wv_e,$wv_hh
	Eg_GaAs=EgT_GaAs(temp)
	Eg_AlGaAs=Egd_AlGaAs(xAl)
	dEg=Egd_AlGaAs(xAl)-Egd_AlGaAs(0)
// electron
	V0=dEg*dec/100
	mw=ems
	mb= mw+ 0.083*(xAl)
	print "for electron : V0, mw, mb: ",V0,mw,mb
	SQWEnergy_WellWidth(wv_e,V0,mw,mb,1)
// heavy hole
	V0=dEg*(1-dec/100)
	mw=emh
	mb= mw+ 0.3*(xAl)
	print "for hole : V0, mw, mb: ",V0,mw,mb
	SQWEnergy_WellWidth(wv_hh,V0,mw,mb,1)
//
	cmd=wv+"="+wv_e+"+"+wv_hh+"+Eg_GaAs"
	Execute cmd
	Display $wv
	Append/R $wv_e,$wv_hh
End

Function Func_asqw(ene,lw,v1,v3,mw,mb1,mb3)
	Variable ene,lw,v1,v3,mw,mb1,mb3
	Variable alph1,beta1,beta3,aa,bb,tankl
	NVAR g_MEL,g_HBAR,g_EC
	alph1 = sqrt(2.*g_MEL*mw*g_EC * ene)/g_HBAR
	beta1 = sqrt(2.*g_MEL*mb1*g_EC*(v1-ene))/g_HBAR
	beta3 = sqrt(2.*g_MEL*mb3*g_EC*(v3-ene))/g_HBAR
	aa=alph1*mb1/(beta1*mw)
	bb=alph1*mb3/(beta3*mw)
	tanKL=tan(lw*alph1)
	return((aa+bb)*cos(lw*alph1)+(1-aa*bb)*sin(lw*alph1))
End

//	$prmwv[0]=Lw
//	$prmwv[1]=Lb
//	$prmwv[2]=V0
//	$prmwv[3]=mw
//	$prmwv[4]=mb

Function Ffind_energy_SL1(Lw, Lb,V0,mw,mb,fd)
	Variable Lw,Lb,V0,mw,mb
	Variable fd
	
	Variable alph,beta
	Variable a,b
	Variable epsilon=V0/1000,e0
	String prmwv="sqw_prm",tempwv="sqw_tempwv",reswv="sqw_results"
	NVAR g_energy,g_HBAR,g_EC,g_MEL
	Wave wprmwv=$prmwv
	
	wprmwv[0]=Lw
	wprmwv[1]=Lb
	wprmwv[2]=V0
	wprmwv[3]=mw
	wprmwv[4]=mb

	if(fd==1)
		Make/O $tempwv
		Display $tempwv
	endif

	e0=g_HBAR^2*(pi/Lw)^2/(2*g_MEL*mw)/g_EC
	if(e0>V0)
		e0=v0*0.999
	endif
	a = 2.*g_MEL*wprmwv[3]*g_EC/(g_HBAR*g_HBAR)
	if(fd==1)
		SetScale/I x,epsilon,V0,$tempwv
		Wave wtempwv=$tempwv
		wtempwv=SL_function_odd_min(wprmwv,x)
//		wtempwv= sqrt( mw/mb * (V0/x-1.))*cos(sqrt(a*x)*Lw/2.) - sin(sqrt(a*x)*Lw/2.)
		SetAxis left -2,2 
		ModifyGraph zero(left)=1
	endif

	FindRoots/Q/L=(epsilon)/H=(e0) SL_function_odd_min,$prmwv
	If(V_flag!=0)
		print V_flag
	Endif
//	g_energy= V_Root

	return(V_Root)
End

Macro find_energy_SL1(Lw, Lb,V0,mw,mb,fd)
	Variable Lw=10e-9,Lb=0,V0=1,mw=0.067,mb=0.067
	Variable fd=1
	Prompt Lw,"Well width (m)"
	Prompt Lb,"Barrier width (m)"
	Prompt V0,"Barrier height (eV)"
	Prompt mw,"effective mass in well (m0)"
	Prompt mb,"effective mass in barrier (m0)"
	Prompt fd,"draw tempgraph ?",popup,"yes;no"
	PauseUpdate;Silent 1

	g_energy=Ffind_energy_SL1(Lw, Lb,V0,mw,mb,fd)
End

Function SL_function_odd_min(w,xx)
	Wave w
	Variable xx
	
	NVAR g_MEL,g_EC,g_HBAR
	Variable x1,x2
	Variable a,b,val
	a = w[0]*sqrt(2.*g_MEL*w[3]*g_EC)/g_HBAR
	b = w[1]*sqrt(2.*g_MEL*w[4]*g_EC)/g_HBAR
	x1=sqrt(xx)
	if(xx<w[2])
		x2=sqrt(w[2]-xx)
		val=sin(a/2*x1)-sqrt(w[3]/w[4]*(w[2]/xx-1))*tanh(b*x2/2)*cos(a/2*x1)
	else
		x2=sqrt(xx-w[2])
		val=tan(a/2*x1)+sqrt(w[3]/w[4]*(1-w[2]/xx))*tan(b*x2/2);
	endif
	return(val)
End
