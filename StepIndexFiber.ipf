#pragma rtGlobals=1		// Use modern global access method.
#include "PhysicalConstants"
#include "dbessel"
#include <Extract Contours As Waves>

// StepIndexFiber.ipf
// Calculate propagation constant in step index fiber
// 
//	09/11/15 ver. 0.1b by J. Motohisa
//
//	revision history
//		22/07/21 ver 0.5: critical bug fixed: TE and TM were flipped !!!! (version 0.4 was wrong !!!!)
//		22/03/23 ver 0.4: critical bug fixed: TE and TM were flipped !!!!
//		13/08/22 ver 0.3c: bug fixed in DispersionAll_wave
//		13/06/26 ver 0.3b: field in the RZ plane added, bug in field for TE mode fixed
//		13/04/13 ver 0.3a: development for the caluclation of leaky mode started
//		12/12/11 ver 0.2e: minor bug fixed, dispersion for normlized beta and omega dispersion is replaced added to menu
//		11/03/23 ver 0.2d: some procedures are converted to functions, findroot_all added
//		11/03/15 ver 0.2c: some function for calculatind dispersion added and modified
//		10/09/11 ver 0.2b: some function for calculatind dispersion added
//		10/07/15 ver 0.2a: field output added, a number of bugs fixed
//		09/11/15 ver 0.1b: bug fixed
//		??/??/?? ver. 0.1a: first version, was part of a Igor experiment file

Menu "StepIndexFiber"
	"Initialize StepIndexFiber",Init_StepIndexFiber()
	"Set parameters",SetParamwv()
	"-"
	"Show graph of eigenvalue equation",Proc_ShowFunction()
	"Find root",Proc_FindRoot()
	"Find root between cursol",Proc_FindRoot_csr()
	"-"
	"Show field xy-plane",Show_Field()
	"Show field xy-plane all",Show_Field_XY()
	"Show field rz-plane",Show_Field_RZ()
	"Show vector field",FieldArrowPlotXY()
	"-"
	"Initialize for dispersion calculation lam",initialize_calculate_dispersion()
	"dispersion: beta vs lambda",calculate_dispersion_LambdaBeta()
	"dispersion: beta vs omega",Dispersion_OmegaBetaAll()
	"Get beta-lambda from dipersion",FieldFromCursor_betaomega()
End

// Initialization
//  g_paramwv: parameter wave nameu
//  g_funcwv: function wave name
//  g_graphname: 
//  g_modename: 

Proc Init_StepIndexFiber(paramwv,funcwv,graphname,modename)
	String paramwv="param_StepIndexFiber",funcwv="func_StepIndexFiber",graphname="graph_StepIndexFiber",
	String modename="hybrid"
	Prompt paramwv,"parameter wave name"
	Prompt funcwv,"function wave name"
	Prompt graphname,"Graph name"
	Prompt modename,"mode name",popup,"hybrid;HE;EH;TE;TM;HE1;HEp;EHp;TETM"
	PauseUpdate;Silent 1

	String cmd
	String/G g_paramwv=paramwv,g_funcwv=funcwv,g_graphname=graphname,g_mode=modename
	Variable/G g_y1,g_y2,g_wl1,g_wl2,g_om1,g_om2,g_delta=0.05
	init_PhysicalConstants()
	Make/O/D/N=25 $paramwv
	cmd="SetDimLabel 0,0,'n1', "+g_paramwv;execute cmd //n1: index of core
	cmd="SetDimLabel 0,1,'n2', "+g_paramwv;execute cmd //n2: index of clad
	cmd="SetDimLabel 0,2,'radius', "+g_paramwv;execute cmd //radius:  core radius
	cmd="SetDimLabel 0,3,'lambda', "+g_paramwv;execute cmd //lambda: wavelength
	cmd="SetDimLabel 0,4,'betamin', "+g_paramwv;execute cmd //minimum beta
	cmd="SetDimLabel 0,5,'betamax', "+g_paramwv;execute cmd //maximum beta
	cmd="SetDimLabel 0,6,'p', "+g_paramwv;execute cmd //mode number p
	cmd="SetDimLabel 0,7,'betamin0', "+g_paramwv;execute cmd //minimum beta
	cmd="SetDimLabel 0,8,'betamax0', "+g_paramwv;execute cmd //maximum beta
	cmd="SetDimLabel 0,9,'beta', "+g_paramwv;execute cmd //solution of beta
	cmd="SetDimLabel 0,10,'delta', "+g_paramwv;execute cmd //delta
	cmd="SetDimLabel 0,11,'V', "+g_paramwv;execute cmd //normalized frequency
	cmd="SetDimLabel 0,12,'b', "+g_paramwv;execute cmd //normalized propagation constant
	cmd="SetDimLabel 0,13,'u', "+g_paramwv;execute cmd //normalized transverse propagation constant
	cmd="SetDimLabel 0,14,'w', "+g_paramwv;execute cmd //normalized transverse extinction constant
	cmd="SetDimLabel 0,15,'s', "+g_paramwv;execute cmd //for field calculation
	cmd="SetDimLabel 0,16,'s1', "+g_paramwv;execute cmd //
	cmd="SetDimLabel 0,17,'s0', "+g_paramwv;execute cmd //
	cmd="SetDimLabel 0,18,'lambda_c', "+g_paramwv;execute cmd //cutoff wavelength
	cmd="SetDimLabel 0,19,'beta_re', "+g_paramwv;execute cmd // for leaky mode: real part of beta
	cmd="SetDimLabel 0,20,'beta_im', "+g_paramwv;execute cmd // for leaky mode: imaginary part of beta
	cmd="SetDimLabel 0,21,'beta0_re', "+g_paramwv;execute cmd // for leaky mode: initial value for real part of beta
	cmd="SetDimLabel 0,22,'beta0_im', "+g_paramwv;execute cmd // for leaky mode: initial value for imaginary part of beta
	cmd="SetDimLabel 0,23,'phil',"+g_paramwv; execute cmd // phil
	cmd="SetDimLabel 0,24,'num',"+g_paramwv; execute cmd // num: number of divisions in displaying field
	
	Make/O/D/N=1001 $funcwv //
	Make/O/D/N=1001 $(funcwv+"_hybrid") // hybrid mode
	Make/O/D/N=1001 $(funcwv+"_HE") // TE mode
	Make/O/D/N=1001 $(funcwv+"_EH") // TM mode
	Make/O/D/N=1001 $(funcwv+"_TE") // TE mode
	Make/O/D/N=1001 $(funcwv+"_TM") // TM mode
// weakly guided approximation
	Make/O/D/N=1001 $(funcwv+"_HE1") // HE1 mode
	Make/O/D/N=1001 $(funcwv+"_HEp") // HEp mode
	Make/O/D/N=1001 $(funcwv+"_EHp") // EHp mode
	Make/O/D/N=1001 $(funcwv+"_TETM") // TM/TE mode (degenerate)
	
	$g_paramwv[%'lambda']=900
	$g_paramwv[%'n1']=3.5
	$g_paramwv[%'n2']=1
	$g_paramwv[%'radius']=300
	$g_paramwv[%'p']=1
	$g_paramwv[%'num']=51

	g_wl1=$g_paramwv[%'lambda']
	g_wl2=$g_paramwv[%'lambda']
	g_om1=0.01
	g_om2=2

//	ShowFuncGraphWin()
End

Function ShowFuncGraphWin()
	SVAR g_graphname,g_funcwv
	If(strlen(winlist(g_graphname,";",""))==0)
		Display $g_funcwv
		DoWindow/C $g_graphname
		ModifyGraph zero(left)=1
		SetAxis left -1,1
		ShowInfo
	Else
		DoWindow/F $g_graphname
	Endif
End

Proc SetParamwv(wl,n1,n2,radius,pp)
//	Variable wl=816,n1=3.66,n2=3.56,radius=115,pp=1
	Variable wl=g_wl1,n1=$g_paramwv[%'n1'],n2=$g_paramwv[%'n2'],radius=$g_paramwv[%'radius'],pp=$g_paramwv[%'p']
	Prompt wl,"wavelength (nm) or 2*pi/omega"
	Prompt n1,"core index"
	Prompt n2,"clad index"
	Prompt radius,"radius (nm)"
	Prompt pp,"mode number"
	PauseUpdate;Silent 1;
	Func_SetParamwv(wl,n1,n2,radius,pp)
End

Function Func_SetParamwv(wl,n1,n2,radius,pp)
	Variable wl,n1,n2,radius,pp
	
	SVAR g_paramwv
	Wave wv=$g_paramwv
	wv[%'n1']=n1
	wv[%'n2']=n2
	wv[%'lambda']=wl
	wv[%'radius']=radius
	wv[%'p']=pp
	
	SetParamwv_recalc(wl,n1,n2)
End

Function SetParamwv_recalc(wl,n1,n2)
	Variable wl,n1,n2
	
	SVAR g_paramwv
	Wave wv=$g_paramwv
	wv[%'betamin']=(2*pi/wl*n2)
	wv[%'betamax']=(2*pi/wl*n1)
	wv[%'betamin0']=wv[%'betamin']*1.00000001
	wv[%'betamax0']=wv[%'betamax']*0.99999999
	wv[%'delta']=(n1*n1-n2*n2)/(2*n1*n1)
	wv[%'V']=2*pi/wv[%'lambda']*sqrt(n1*n1-n2*n2)*wv[%'radius']
	wv[%'lambda_c']=2*pi/2.405*n1*sqrt(wv[%'delta']*2)*wv[%'radius']
End	

//////////// functions
Function/D u_func(beta0)
	Variable beta0
	SVAR g_paramwv
	return(u_func0($g_paramwv,beta0))
End

Function/D w_func(beta0)
	Variable beta0
	SVAR g_paramwv
	return(w_func0($g_paramwv,beta0))
End

Function/D u_func0(wv,beta0)
	Wave wv
	Variable beta0
	return (u_func00(beta0,wv[%'n1'],wv[%'lambda'],wv[%'radius']))
End function

Function/D w_func0(wv,beta0)
	Wave wv
	Variable beta0
	return w_func00(beta0,wv[%'n2'],wv[%'lambda'],wv[%'radius'])
End function

Function/D u_func00(beta0,n,lambda,radius)
	Variable beta0,n,lambda,radius
	return sqrt((2*pi*n/lambda)*(2*pi*n/lambda)-beta0*beta0)*radius
End function

Function/D w_func00(beta0,n,lambda,radius)
	Variable beta0,n,lambda,radius
	return sqrt(beta0*beta0-(2*pi*n/lambda)*(2*pi*n/lambda))*radius
End function
//////////

//////////
// for weakly-guided approximation

//////////
// HE_1 mode
Function func_HE1(beta0)
	Variable beta0
	SVAR g_paramwv
	return(func_HE1_0($g_paramwv,beta0))
End Function

Function/D func_HE1_0(wv,beta0)
	Wave wv
	Variable beta0
	Variable uu,ww
	uu=u_func0(wv,beta0)
	ww=w_func0(wv,beta0)
	Return(uu*BesselJ(1,uu)*BesselK(0,ww)-BesselJ(0,uu)*ww*besselK(1,ww))
End

Proc ShowFunction_HE1_0(wl,n1,n2,radius)
	Variable wl=816,n1=3.66,n2=3.56,radius=115
	Prompt wl,"wavelength (nm)"
	Prompt n1,"core index"
	Prompt n2, "clad index"
	Prompt radius,"radius (nm)"
//	Prompt showgr,"Show Eigenvalue Eq. Graph ?",popup,"yes;no" 
	PauseUpdate;Silent 1

	Variable pp=1
	SetParamwv(wl,n1,n2,radius,pp)
	Func_ShowFunction("HE1")
End

Proc ShowFunction_HE1()
//	Variable showgr=1
//	Prompt showgr,"Show Eigenvalue Eq. Graph ?",popup,"yes;no" 
	PauseUpdate;Silent 1
	Func_ShowFunction("HE1")
End

/// find root
Proc HE1_FindRoot0(wl,n1,n2,radius,low,high,showgr)
	Variable wl=816,n1=3.66,n2=3.56,radius=115,low=-1,high=-1
	Variable showgr=1
	Prompt wl,"wavelength (nm)"
	Prompt n1,"core index"
	Prompt n2, "clad index"
	Prompt radius,"radius (nm)"
	Prompt low,"lowest value"
	Prompt high,"highest value"
	Prompt showgr,"Show Eigenvalue Eq. Graph ?",popup,"yes;no" 
	PauseUpdate;Silent 1;
	
	Variable pp=1
	SetParamwv(wl,n1,n2,radius,pp)
	Proc_FindRoot("HE1",low,high,showgr,1)
End

Proc HE1_FindRoot(low,high,showgr)
	Variable low=-1,high=-1
	Variable showgr=1
	Prompt low,"lowest value"
	Prompt high,"highest value"
	Prompt showgr,"Show Eigenvalue Eq. Graph ?",popup,"yes;no" 
	PauseUpdate;Silent 1
	Proc_FindRoot("HE1",low,high,showgr,1)
End
//////////

// HE_p mode (p>=2)
Function func_HEp(beta0)
	Variable beta0
	SVAR g_paramwv
	return(func_HEp_0($g_paramwv,beta0))
End Function

Function/D func_HEp_0(wv,beta0)
	Wave wv
	Variable/D beta0
	Variable/D uu,ww,pp
	uu=u_func0(wv,beta0)
	ww=w_func0(wv,beta0)
	pp=wv[%'p']
	Return(uu*BesselJ(pp-2,uu)*BesselK(pp-1,ww)+BesselJ(pp-1,uu)*ww*besselK(pp-2,ww))
End

// EH_p mode
Function/D func_EHp(beta0)
	Variable/D beta0
	SVAR g_paramwv
	return(func_EHp_0($g_paramwv,beta0))
End Function

Function/D func_EHp_0(wv,beta0)
	Wave wv
	Variable/D beta0
	Variable/D uu,ww,pp
	uu=u_func0(wv,beta0)
	ww=w_func0(wv,beta0)
	pp=wv[%'p']
	Return(uu*BesselJ(pp,uu)*BesselK(pp+1,ww)+BesselJ(pp+1,uu)*ww*besselK(pp,ww))
End

//TE /TM mode (in wealkly-guided approximation, they are degenerate
Function/D func_TETM(beta0)
	Variable/D beta0
	SVAR g_paramwv
	return(func_TETM_0($g_paramwv,beta0))
End Function

Function/D func_TETM_0(wv,beta0)
	Wave wv
	Variable/D beta0
	Variable/D uu,ww,pp
	uu=u_func0(wv,beta0)
	ww=w_func0(wv,beta0)
	Return(uu*BesselJ(0,uu)*BesselK(1,ww)+BesselJ(1,uu)*ww*besselK(0,ww))
End
//////////

//////////
// general case

//hybrid mode: both HE and EH
Function func_hybrid(beta0)
	Variable/D beta0
	SVAR g_paramwv
	return(func_hybrid_0($g_paramwv,beta0))
End Function

Function/D func_hybrid_0(wv,beta0)
	Wave wv
	Variable/D beta0
	Variable/D uu,ww,n1,n2,pp,e0,e1,k0
	uu=u_func0(wv,beta0)
	ww=w_func0(wv,beta0)
	n1=wv[%'n1']
	n2=wv[%'n2']
	pp=wv[%'p']
	k0=2*pi/wv[%'lambda']
	e0=(BesselJ(pp-1,uu)-BesselJ(pp+1,uu))/2/(uu*BesselJ(pp,uu))
	e1=-(BesselK(pp-1,ww)+BesselK(pp+1,ww))/2/(ww*BesselK(pp,ww))
	return((e0+e1)*(n1*n1*e0+n2*n2*e1)-pp*pp*(1/(uu*uu)+1/(ww*ww))^2*beta0*beta0/(k0*k0))
//	e0=(BesselJ(pp-1,uu)-BesselJ(pp+1,uu))/2/(BesselJ(pp,uu))*ww*ww*uu
//	e1=-(BesselK(pp-1,ww)+BesselK(pp+1,ww))/2/(BesselK(pp,ww))*uu*uu*ww
//	return((e0+e1)*(n1*n1*e0+n2*n2*e1)-pp*pp*(ww*ww+(uu*uu))^2*beta0*beta0/(k0*k0))
End

// HE mode
Function func_HE(beta0)
	Variable/D beta0
	SVAR g_paramwv
	return(func_HE_0($g_paramwv,beta0))
End

Function/D func_HE_0(wv,beta0)
	Wave wv
	Variable/D beta0
	Variable/D uu,ww,n1,n2,pp,e0,e1,k0
	Variable e00,e01
	Variable c1,c2
	uu=u_func0(wv,beta0)
	ww=w_func0(wv,beta0)
	n1=wv[%'n1']
	n2=wv[%'n2']
	pp=wv[%'p']
	k0=2*pi/wv[%'lambda']
	e00=(uu*BesselJ(pp,uu));
	e01=(ww*BesselK(pp,ww));
	e0= (BesselJ(pp-1,uu));
	e1=-(BesselK(pp-1,ww)+BesselK(pp+1,ww))/(2*e01);
	c1=(n1*n1-n2*n2)/(2*n1*n1)*e1;
	c2=pp*beta0/(n1*k0)*(1/(uu*uu)+1/(ww*ww));
  return e0+((n1*n1+n2*n2)/(2*n1*n1)*e1-(pp/(uu*uu)-sqrt(c1*c1+c2*c2)))*e00;

End

//EH mode
Function func_EH(beta0)
	Variable/D beta0
	SVAR g_paramwv
	return(func_EH_0($g_paramwv,beta0))
End

Function/D func_EH_0(wv,beta0)
	Wave wv
	Variable/D beta0
	Variable/D uu,ww,n1,n2,pp,e0,e1,k0
	Variable e00,e01
	Variable c1,c2
	uu=u_func0(wv,beta0)
	ww=w_func0(wv,beta0)
	n1=wv[%'n1']
	n2=wv[%'n2']
	pp=wv[%'p']
	k0=2*pi/wv[%'lambda']
	e00=(uu*BesselJ(pp,uu));
	e01=(ww*BesselK(pp,ww));
	e0= (BesselJ(pp+1,uu));
	e1=-(BesselK(pp-1,ww)+BesselK(pp+1,ww))/(2*e01);
	c1=(n1*n1-n2*n2)/(2*n1*n1)*e1;
	c2=pp*beta0/(n1*k0)*(1/(uu*uu)+1/(ww*ww));
	return e0-((n1*n1+n2*n2)/(2*n1*n1)*e1+(pp/(uu*uu)-sqrt(c1*c1+c2*c2)))*e00;
End

//HE mode in Weakly Guiding Approximation
Function func_HEWGA(beta0)
	Variable/D beta0
	SVAR g_paramwv
	return(func_HEWGA_0($g_paramwv,beta0))
End

Function/D func_HEWGA_0(wv,beta0)
	Wave wv
	Variable/D beta0
	Variable/D uu,ww,n1,n2,pp,e0,e1,k0
	Variable e00,e01
	Variable c1,c2
	uu=u_func0(wv,beta0)
	ww=w_func0(wv,beta0)
	n1=wv[%'n1']
	n2=wv[%'n2']
	pp=wv[%'p']
	return BesselJ(pp-1,uu)*ww*BesselK(pp,ww)-uu*BesselJ(pp,uu)*BesselK(pp-1,ww)
End

//EH mode in Weakly Guiding Approximation
Function func_EHWGA(beta0)
	Variable/D beta0
	SVAR g_paramwv
	return(func_HEWGA_0($g_paramwv,beta0))
End

Function/D func_EHWGA_0(wv,beta0)
	Wave wv
	Variable/D beta0
	Variable/D uu,ww,n1,n2,pp,e0,e1,k0
	Variable e00,e01
	Variable c1,c2
	uu=u_func0(wv,beta0)
	ww=w_func0(wv,beta0)
	n1=wv[%'n1']
	n2=wv[%'n2']
	pp=wv[%'p']
	return BesselJ(pp+1,uu)*ww*BesselK(pp,ww)+uu*BesselJ(pp,uu)*BesselK(pp+1,ww)
End

// TE mode
// n1^2/n2^2 J'_0/u J_1 + K'_0/w K_0=0
Function/D func_TE(beta0)
	Variable/D beta0
	SVAR g_paramwv
	return(func_TE_0($g_paramwv,beta0))
End Function

Function/D func_TE_0(wv,beta0)
	Wave wv
	Variable/D beta0
	Variable/D uu,ww
	uu=u_func0(wv,beta0)
	ww=w_func0(wv,beta0)
//	Return (uu*BesselJ(0,uu)*BesselK(1,ww)+BesselJ(1,uu)*w*besselK(0,ww))
	Return((-BesselJ(1,uu))*ww*BesselK(0,ww)-BesselK(1,ww)*uu*BesselJ(0,uu))
End

// TM mode
// J'_0/u J_1 + K'_0/w K_0=0
Function/D func_TM(beta0)
	Variable/D beta0
	SVAR g_paramwv
	return(func_TM_0($g_paramwv,beta0))
End Function

Function/D func_TM_0(wv,beta0)
	Wave wv
	Variable/D beta0
	Variable/D uu,ww,n1,n2
	uu=u_func0(wv,beta0)
	ww=w_func0(wv,beta0)
	n1=wv[%'n1']
	n2=wv[%'n2']
	Return(n1*n1/(n2*n2)*(-BesselJ(1,uu))*ww*BesselK(0,ww)-BesselK(1,ww)*uu*BesselJ(0,uu))
End

///////////////////// find root
Proc Proc_FindRoot(modename,pp,low,high,showgr,fquiet,stoperror)
	String modename=g_mode
	Variable/D pp=$g_paramwv[%'p'],low=-1,high=-1
	Variable showgr=1,fquiet=2
	Variable stoperror
	Prompt modename,"Name of the mode",popup,"hybrid;HE;EH;TE;TM;HE1;HEp;EHp;TETM"
	Prompt pp,"mode number"
	Prompt low,"lowest value"
	Prompt high,"highest value"
	Prompt showgr,"Show Eigenvalue Eq. Graph ?",popup,"yes;no" 
	Prompt fquiet,"quiet ?",popup,"yes;no"
	Prompt stoperror,"stoperror ?"
	PauseUpdate;Silent 1

	Proc_FindRootFunc(modename,pp,low,high,showgr,fquiet,stoperror)
End

// try to convet to function, but cannot make it now
Proc Proc_FindRootFunc(modename,pp,low,high,showgr,fquiet,stoperror)
	String modename
	Variable/D pp,low,high
	Variable showgr,fquiet,stoperror
	PauseUpdate;Silent 1

//	SVAR g_mode
//	SVAR g_paramwv
	String paramwv=g_paramwv,fname
//	Wave paramwv=$g_paramwv
	Variable n1=$paramwv[%'n1'],n2=$paramwv[%'n2']
	Variable k0=2*pi/$paramwv[%'lambda'],uu,ww
	Variable res,y1,y2
//	paramwv=g_paramwv
	g_mode=modename
	if(stringmatch(modename, "TE")==1 || stringmatch(modename,"TM")==1)
		pp=0
	Endif
	$paramwv[%'p']=pp
	String cmd
	if(low<0)
		low=$paramwv[%'betamin0']
	endif
	if(high<0)
		high=$paramwv[%'betamax0']
	Endif
//	print low,high
//	print $paramwv[%'betamin'],low,high
	if(showgr==1)
		Func_ShowFunction(modename)
	Endif
	fname="func_"+modename+"_0"
//	print fname,low,high
//	sprintf cmd,"y1=%s(%s,low)",fname,paramwv
//	Execute cmd
//	sprintf cmd,"y2=%s(%s,high)",fname,paramwv
//	Execute cmd

	y1=$fname($paramwv,low)
	y2=$fname($paramwv,high)
	if(y1*y2<0)
		sprintf cmd,"FindRoots/Q/L=(%e)/H=(%e) func_%s_0,%s",low,high,modename,paramwv
		cmd="FindRoots/Q/L=(low)/H=(high) func_"+modename+"_0,"+paramwv
		Execute cmd
//	FindRoots/L=(low)/H=(high) func_HE1_0,$paramwv
//	return(V_root)
//		print fname
		sprintf cmd,"res=%s(%s,V_root)",fname,paramwv
//		NVAR V_root
		if(fquiet !=1)
			print "beta=",V_root,res
			return
		endif
		SetBeta(V_root)
//		$paramwv[%'beta']=V_root
//		$paramwv[%'b']=(V_root*V_root/(k0*k0)-n2*n2)/(n1*n1-n2*n2)
//		uu=u_func(V_root)
//		ww=w_func(V_root)
//		$paramwv[%'u']=uu
//		$paramwv[%'w']=ww
//		$paramwv[%'s']=pp*(1/(uu*uu)+1/(ww*ww))/(dBesselJ(pp,uu)/(uu*BesselJ(pp,uu))+dBesselK(pp,ww)/(ww*BesselK(pp,ww)))
//		$paramwv[%'s1']=$paramwv[%'s']*V_root*V_root/(k0*k0*n1*n1)
//		$paramwv[%'s0']=$paramwv[%'s']*V_root*V_root/(k0*k0*n2*n2)
	else
		print "cannot be bracketed for low=",low, ", high=", high, " at wavelength ",$paramwv[%'lambda']
		print low,y1,high,y2
		if(stoperror==1)
			Abort
		endif
	endif
End

Function Func_FindRootAll(modename)
	String modename
	PauseUpdate;Silent 1

	SVAR g_funcwv,g_paramwv
	Variable res,y1,y2
	Variable i,j,nx=DimSize($g_funcwv,0)
	String cmd
	wave wv=$g_paramwv
	Variable pp=wv[%'p']

	func_function_calculate(modename,pp)
//	sprintf cmd,"function_calculate0(\"%s\")",modename
//	Execute cmd
	Wave bracketwvL,bracketwvR,solwv,funcwv=$g_funcwv
	Make/O bracketwvL,bracketwvR,solwv
	solwv=NaN
	
	y1=funcwv[nx-1]
	i=nx-1
	j=0
	do
		y2=funcwv[i]
		if(y1*y2<0)
			bracketwvL[j]=pnt2x(funcwv,i-1)
			bracketwvR[j]=pnt2x(funcwv,i)
//			print j,bracketwvL[j],bracketwvR[j]
//			sprintf cmd,"FindRoots/Q/L=%g/H=%g func_%s_0,%s",bracketwvL[j],bracketwvR[j],modename,g_paramwv
//			Execute cmd
			j+=1
		endif
		y1=y2
		i-=1
	while (i>=0)
	if(j==0)
		return 0
	endif
	
	solwv[0]=j
	i=0
	do
		sprintf cmd,"FindRoots/Q/L=%g/H=%g func_%s_0,%s",bracketwvL[i],bracketwvR[i],modename,g_paramwv
		Execute cmd
		NVAR V_flag
		if(V_flag==0)
		NVAR V_root
//		Print i, V_root
		solwv[i+1]=V_root
		endif
		i+=1
	while(i<j)
	return j
End

Function SetBeta(beta0)
	Variable beta0
	
	SVAR g_paramwv
	Wave paramwv=$g_paramwv
	Variable uu,ww,k0,n1,n2,pp
	n1=2*pi/paramwv[%'n1']
	n2=2*pi/paramwv[%'n2']
	k0=2*pi/paramwv[%'lambda']
	pp=paramwv[%'p']
	paramwv[%'beta']=beta0
	paramwv[%'b']=(beta0*beta0/(k0*k0)-n2*n2)/(n1*n1-n2*n2)
	uu=u_func(beta0)
	ww=w_func(beta0)
	paramwv[%'u']=uu
	paramwv[%'w']=ww
	paramwv[%'s']=pp*(1/(uu*uu)+1/(ww*ww))/(dBesselJ(pp,uu)/(uu*BesselJ(pp,uu))+dBesselK(pp,ww)/(ww*BesselK(pp,ww)))
	paramwv[%'s1']=paramwv[%'s']*beta0*beta0/(k0*k0*n1*n1)
	paramwv[%'s0']=paramwv[%'s']*beta0*beta0/(k0*k0*n2*n2)
End

Proc Proc_FindRoot_csr(modename,pp,showgr,fquiet)
	String modename=g_mode
	Variable/D pp=$g_paramwv[%'p']
	Variable showgr=1,fquiet=2
	Prompt modename,"Name of the mode",popup,"hybrid;HE;EH;TE;TM;HE1;HEp;EHp;TETM"
	Prompt pp,"mode number"
	Prompt showgr,"Show Eigenvalue Eq. Graph ?",popup,"yes;no" 
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate;Silent 1

	String paramwv=g_paramwv,fname
	Variable low,high,tmp
	g_mode=modename
	
	low=xcsr(A,g_graphname)
	high=xcsr(B,g_graphname)
	if(high<low)
		tmp=low
		low=high
		high=tmp
	endif
	
	Func_FindRoot(modename,pp,low,high,showgr,fquiet)
End

////// find root: function version
Function Func_FindRoot(modename,pp,low,high,showgr,fquiet)
	String modename
	Variable/D pp,low,high
	Variable showgr,fquiet
	PauseUpdate;Silent 1

	SVAR g_mode
	SVAR g_paramwv
	String paramwv=g_paramwv,fname
	Wave wv=$g_paramwv
	Variable n1=wv[%'n1'],n2=wv[%'n2']
	Variable k0=2*pi/wv[%'lambda'],uu,ww
	Variable res,y1,y2
//	paramwv=g_paramwv
	wv[%'p']=pp
	g_mode=modename
	if(stringmatch(modename, "TE")==1 || stringmatch(modename,"TM")==1)
		pp=0
	Endif
	wv[%'p']=pp
	String cmd
	if(low<0)
		low=wv[%'betamin0']
	endif
	if(high<0)
		high=wv[%'betamax0']
	Endif
//	print low,high
//	print $paramwv[%'betamin'],low,high
	if(showgr==1)
//		cmd="Proc_ShowFunction(modename)"
		Func_ShowFunction(modename,pp)
//		Execute cmd
	Endif
	print "wavelenth=",wv[%'lambda'],"k=",k0
	Func_FindRoot0(modename,low,high,fquiet)
End

Function Func_FindRoot0(modename,low,high,fquiet)
	String modename
	Variable/D low,high
	Variable fquiet

	SVAR g_paramwv
	NVAR g_y1,g_y2
	String fname,cmd
	Wave wv=$g_paramwv
	Variable res

	fname="func_"+modename+"_0"

//	print fname,low,high
// somehow, it doew not work unless g_y1 and g_y2 are globals
	sprintf cmd,"g_y1=%s(%s,%g)",fname,g_paramwv,low
	Execute cmd
	sprintf cmd,"g_y2=%s(%s,%g)",fname,g_paramwv,high
	Execute cmd
//	y1=$fname($paramwv,low)
//	y2=$fname($paramwv,high)

	if(g_y1*g_y2<0)
		res=Func_FindRoot000(modename,wv,low,high,fquiet)
		return res
	else
		print "cannot be bracketed for low=",low, ", high=", high
		print low,g_y1,high,g_y2
		return -1
	endif
End

// assume blacketed
Function/D Func_FindRoot00(modename,pp,wv,low,high)
	Wave wv
	Variable low,high
	String modename

	Variable pp
	String cmd,fname
	Variable fquiet=1

	wv[%'p']=pp
	if(low<0)
		low=wv[%'betamin0']
	endif
	if(high<0)
		high=wv[%'betamax0']
	Endif
	return(Func_FindRoot000(modename,wv,low,high,fquiet))	
End Function

Function/D Func_FindRoot000(modename,wv,low,high,fquiet)
	Wave wv
	Variable low,high,fquiet
	String modename

	String cmd,fname

	fname="func_"+modename+"_0"
	FindRoots/L=(low)/H=(high)/Q $fname, wv
	wv[%'beta']=V_root
	SetBeta(V_root)
	if(fquiet !=1)
//			NVAR V_Root,V_YatRoot
		print "beta=",V_Root,", residual=",V_YatRoot
	endif
	return(V_root)	
End Function

///////////////////////// show graphs
Proc Proc_ShowFunction(modename,pp)
	String modename=g_mode
	Variable pp=$g_paramwv[%'p']
	Prompt modename,"Name of the mode",popup,"hybrid;HE;EH;TE;TM;HE1;HEp;EHp;TETM"
	prompt pp,"mode Number"
	PauseUpdate;Silent 1
	
	Func_ShowFunction(modename,pp)
End

Function Func_ShowFunction(modename,pp)
	String modename
	Variable pp
		
	func_function_calculate(modename,pp)
	ShowFuncGraphWin()
End

// probably obsolete
Proc ShowFunction_All()
	String paramwv=g_paramwv,funcwv=g_funcwv,graphname=g_graphname
	String wv,modename,cmd,graphname0="graph_all"
	Variable betamin,betamax
	
	betamin=$paramwv[%'betamin0']
	betamax=$paramwv[%'betamax0']
	SetScale/I x betamin,betamax,"", $funcwv
	If(strlen(winlist(graphname0,";",""))==0)
		Display
		DoWindow/C $graphname0
	Else
		DoWindow/F $graphname0
	Endif

	modename="HE1"
	mode_function_calculate(modename)
	wv=funcwv+"_"+modename
	If(strlen(winlist(graphname0,";",""))==0)
		Append $wv
	Endif

	modename="HEp"
	mode_function_calculate(modename)
	wv=funcwv+"_"+modename
	If(strlen(winlist(graphname0,";",""))==0)
		Append $wv
	Endif

	modename="EHp"
	mode_function_calculate(modename)
	wv=funcwv+"_"+modename
	If(strlen(winlist(graphname0,";",""))==0)
		Append $wv
	Endif

	modename="TETM"
	mode_function_calculate(modename)
	wv=funcwv+"_"+modename
	If(strlen(winlist(graphname0,";",""))==0)
		Append $wv
	Endif

	modename="TE"
	mode_function_calculate(modename)
	wv=funcwv+"_"+modename
	If(strlen(winlist(graphname0,";",""))==0)
		Append $wv
	Endif

	modename="TM"
	mode_function_calculate(modename)
	wv=funcwv+"_"+modename
	If(strlen(winlist(graphname0,";",""))==0)
		Append $wv
	Endif

	modename="hybrid"
	mode_function_calculate(modename)
	wv=funcwv+"_"+modename
	If(strlen(winlist(graphname0,";",""))==0)
		Append $wv
	Endif

	SetAxis left -1,1
	ModifyGraph zero(left)=1
	SetAxis bottom betamin,betamax

End

Proc mode_function_calculate(mode)
	String mode
	PauseUpdate;Silent 1
	
	String wv,cmd
	String paramwv=g_paramwv,funcwv=g_funcwv,graphname=g_graphname
	wv=funcwv+"_"+modename
	cmd=funcwv+"=func_"+modename+"_0("+paramwv+",x)"
	Execute cmd
	Duplicate/O $funcwv,$wv
End

/////////////////////// field calculation
Function Show_Field_All()
	PauseUpdate; Silent 1
	Func_Show_field("Er")
	Func_Show_field("Et")
	Func_Show_field("Ez")
	Func_Show_field("Hr")
	Func_Show_field("Ht")
	Func_Show_field("Hz")
End

Proc Show_Field_RZ_All(rmax,zmin,zmax)
	Variable rmax,zmin,zmax
	PauseUpdate; Silent 1
	Func_Show_field_RZ("Er",rmax,zmin,zmax,0)
	Func_Show_field_RZ("Et",rmax,zmin,zmax,90)
	Func_Show_field_RZ("Ez",rmax,zmin,zmax,0)
	Func_Show_field_RZ("Hr",rmax,zmin,zmax,90)
	Func_Show_field_RZ("Ht",rmax,zmin,zmax,0)
	Func_Show_field_RZ("Hz",rmax,zmin,zmax,90)
End

Proc Show_Field(fieldname)
	String Fieldname
	Prompt fieldname,"Name of the mode",popup,"Er;Et;Ez;Hr;Ht;Hz"
	PauseUpdate; Silent 1

	Func_Show_Field(fieldname)	
End

Function Func_Show_Field(fieldname)
	String Fieldname
	
	Variable xx,beta0,phil
	Variable num,range=1.5
	String cmd,gname,wname
	SVAR g_paramwv,g_mode
	Wave wv=$g_paramwv
	xx=wv[%'radius']*range
	if(stringmatch(g_mode,"TE")==1)
		phil=90
		wv[%'phil']=phil*pi/180
	endif
	if(stringmatch(g_mode,"TM")==1)
		phil=0
		wv[%'phil']=phil*pi/180
	endif
	num=wv[%'num']
	wname="wfield_"+fieldname
	Make/O/N=(num,num) $wname
	SetScale/I x -xx,xx,"",$wname
	SetScale/I y -xx,xx,"",$wname
//	beta0 = Func_FindRoot("HE1",1,$g_paramwv,-1,-1)
	cmd=wname+"="+fieldname+"(sqrt(x*x+y*y),atan2(y,x),"+g_paramwv+")"
//	field=Er(sqrt(x*x+y*y),atan2(y,x),$g_paramwv)
	Execute cmd
	gname="field_"+fieldname
	If(strlen(winlist(gname,";",""))==0)
		Display;AppendImage $wname
		DoWindow/C $gname
		ModifyGraph height={Aspect,1}
		ModifyGraph tick=3,noLabel=2,standoff=0
		ModifyGraph axThick=0
		ModifyImage $wname ctab= {*,*,RedWhiteBlue,0}
//		SetScale left -1,1
//		ShowInfo
	Else
		DoWindow/F $gname
	Endif
End

Proc Show_Field_RZ(fieldname,rmax,zmin,zmax,phil)
	String Fieldname
	Variable rmax,zmin,zmax,phil
	Prompt fieldname,"Name of the mode",popup,"Er;Et;Ez;Hr;Ht;Hz"
	PauseUpdate; Silent 1
	
	Func_Show_Field_RZ(fieldname,rmax,zmin,zmax,phil)
End

Function Func_Show_Field_RZ(fieldname,rmax,zmin,zmax,phil)
	String Fieldname
	Variable rmax,zmin,zmax,phil
	
	Variable xx,beta0,th=0
	Variable range=1.5,nr=100,nz=1000
	String cmd,gname,wname
	SVAR g_paramwv
	SVAR g_mode
	Wave paramwv=$g_paramwv
//	xx=$g_paramwv[%'radius']*range
	rmax=paramwv[%'radius']*rmax
	zmin=paramwv[%'radius']*zmin
	zmax=paramwv[%'radius']*zmax
	if(stringmatch(g_mode,"TE")==1)
		phil=90
		paramwv[%'phil']=phil*pi/180
	endif
	if(stringmatch(g_mode,"TM")==1)
		phil=0
		paramwv[%'phil']=phil*pi/180
	endif
	wname="wfield_"+fieldname
	Make/O/N=(nz,nr) $wname
	SetScale/I x zmin,zmax,"",$wname
	SetScale/I y 0,rmax,"",$wname
//	beta0 = Func_FindRoot("HE1",1,paramwv,-1,-1)
	sprintf cmd "%s=%s(y,%f,%s)*cos(x*%f)",wname,fieldname,th,g_paramwv,paramwv[%'beta']
//	field=Er(sqrt(x*x+y*y),atan2(y,x),paramwv)
	Execute cmd
	gname="field_"+fieldname+"RZ"
	If(strlen(winlist(gname,";",""))==0)
		Display;AppendImage $wname
		DoWindow/C $gname
		ModifyGraph height=0
		ModifyGraph tick=3,noLabel=2,standoff=0
		ModifyGraph axThick=0
		ModifyGraph width={Plan,1,bottom,left},height=0
		ModifyImage $wname ctab= {*,*,RedWhiteBlue,0}
		SetDrawEnv ycoord= left
		SetDrawEnv dash= 1
		DrawLine 0,paramwv[%'radius'],1,paramwv[%'radius']
//		SetScale left -1,1
//		ShowInfo
	Else
		DoWindow/F $gname
	Endif
End

Proc Show_Field_XY(num)
//	String Fieldname
//	Prompt fieldname,"Name of the mode",popup,"Er;Et;Ez;Hr;Ht;Hz"
	Variable num=50
	PauseUpdate; Silent 1
	
	Func_Show_Field_XY(num)
End


Function Func_Show_Field_XY(num)
//	String Fieldname
//	Prompt fieldname,"Name of the mode",popup,"Er;Et;Ez;Hr;Ht;Hz"
	Variable num
	
	SVAR g_paramwv,g_mode
	wave wv=$g_paramwv
	Variable xx,beta0,phil
	String cmd,gname,wname,rwv,twv,xwv,ywv
	if(stringmatch(g_mode,"TE")==1)
		phil=90
		wv[%'phil']=phil*pi/180
	endif
	if(stringmatch(g_mode,"TM")==1)
		phil=0
		wv[%'phil']=phil*pi/180
	endif

	wv[%'num']=num
	rwv="wfield_Er"
	twv="wfield_Et"
	Func_show_field("Et")
	Func_show_field("Er")
	xwv="wfield_Ex"
	ywv="wfield_Ey"
	Duplicate/O $rwv,$xwv,$ywv
	Wave wxwv=$xwv
	Wave wywv=$ywv
	Wave wrwv=$rwv
	Wave wtwv=$twv
	wxwv=wrwv*cos(atan2(y,x))-wtwv*sin(atan2(y,x))
	wywv=wrwv*sin(atan2(y,x))+wtwv*cos(atan2(y,x))
	gname="field_"+"Ex"
	wname="wfield_"+"Ex"
	If(strlen(winlist(gname,";",""))==0)
		Display;AppendImage $wname
		DoWindow/C $gname
		ModifyGraph height={Aspect,1}
		ModifyGraph tick=3,noLabel=2,standoff=0
		ModifyGraph axThick=0
//		SetScale left -1,1
//		ShowInfo
	Else
		DoWindow/F $gname
	Endif
	gname="field_"+"Ey"
	wname="wfield_"+"Ey"
	If(strlen(winlist(gname,";",""))==0)
		Display;AppendImage $wname
		DoWindow/C $gname
		ModifyGraph height={Aspect,1}
		ModifyGraph tick=3,noLabel=2,standoff=0
		ModifyGraph axThick=0
//		SetScale left -1,1
//		ShowInfo
	Else
		DoWindow/F $gname
	Endif
End

//////////////////////////////////////////////////
//field

Function/D Er(r,theta,wv)
	Variable/D r,theta
	Wave wv
	Variable/D radius=wv[%'radius'],k0=2*pi/wv[%'lambda'],n1=wv[%'n1'],n2=wv[%'n2'],pp=wv[%'p'],beta0=wv[%'beta']
	Variable/D res,kappa,gamma0,s,s1,s0,A=1,phil=wv[%'phil']
//	kappa=u_func(beta0)
//	gamma0=w_func(beta0)
	kappa=wv[%'u']
	gamma0=wv[%'w']
	s=wv[%'s']
//	s=(pp*(1/(kappa*kappa)+1/(gamma0*gamma0))/(dBesselJ(pp,kappa)/(kappa*BesselJ(pp,kappa))+dBesselK(pp,gamma0)/(gamma0*BesselK(pp,gamma0))))
//	s1=s*beta0*beta0/(k0*k0*n1*n1)
//	s0=s*beta0*beta0/(k0*k0*n2*n2)
	if(pp==0)
		if(r<radius)
			res=-A*beta0*radius/(kappa)*(-1)*BesselJ(1,kappa*r/radius)*cos(phil)
		else
			res=-A*beta0*radius/(gamma0)*BesselJ(0,kappa)/BesselK(0,gamma0)*BesselK(1,gamma0*r/radius)*cos(phil)
		endif
	else
		if(r<radius)
			res=-A*beta0*radius/(kappa)*((1-s)/2*BesselJ(pp-1,kappa*r/radius)-(1+s)/2*BesselJ(pp+1,kappa*r/radius))*cos(pp*theta+phil)
		else
			res=-A*beta0*radius/(gamma0)*BesselJ(pp,kappa)/BesselK(pp,gamma0)*((1-s)/2*BesselK(pp-1,gamma0*r/radius)+(1+s)/2*BesselK(pp+1,gamma0*r/radius))*cos(pp*theta+phil)
		endif
	endif
	return(res)
End Function

// Electric flux density
Function/D Dr(r,theta,wv)
	Variable/D r,theta
	Wave wv
	Variable/D radius=wv[%'radius'],k0=2*pi/wv[%'lambda'],n1=wv[%'n1'],n2=wv[%'n2'],pp=wv[%'p'],beta0=wv[%'beta']
	Variable/D res,kappa,gamma0,s,s1,s0,A=1,phil=wv[%'phil']
//	kappa=u_func(beta0)
//	gamma0=w_func(beta0)
	kappa=wv[%'u']
	gamma0=wv[%'w']
	s=wv[%'s']
//	s=(pp*(1/(kappa*kappa)+1/(gamma0*gamma0))/(dBesselJ(pp,kappa)/(kappa*BesselJ(pp,kappa))+dBesselK(pp,gamma0)/(gamma0*BesselK(pp,gamma0))))
//	s1=s*beta0*beta0/(k0*k0*n1*n1)
//	s0=s*beta0*beta0/(k0*k0*n2*n2)
	if(r<radius)
		res=-n1*n1*A*beta0*radius/(kappa)*((1-s)/2*BesselJ(pp-1,kappa*r/radius)-(1+s)/2*BesselJ(pp+1,kappa*r/radius))*cos(pp*theta+phil)
	else
		res= -n2*n2*A*beta0*radius/(gamma0)*BesselJ(pp,kappa)/BesselK(pp,gamma0)*((1-s)/2*BesselK(pp-1,gamma0*r/radius)+(1+s)/2*BesselK(pp+1,gamma0*r/radius))*cos(pp*theta+phil)
	endif
	return(res)
End Function

Function/D Et(r,theta,wv)
	Variable/D r,theta
	Wave wv
	Variable/D radius=wv[%'radius'],k0=2*pi/wv[%'lambda'],n1=wv[%'n1'],n2=wv[%'n2'],pp=wv[%'p'],beta0=wv[%'beta']
	Variable/D res,kappa,gamma0,s,s1,s0,A=1,phil=wv[%'phil']
	kappa=u_func(beta0)
	gamma0=w_func(beta0)
	s=wv[%'s']
//	s=(pp*(1/(kappa*kappa)+1/(gamma0*gamma0))/(dBesselJ(pp,kappa)/(kappa*BesselJ(pp,kappa))+dBesselK(pp,gamma0)/(gamma0*BesselK(pp,gamma0))))
//	s1=s*beta0*beta0/(k0*k0*n1*n1)
//	s0=s*beta0*beta0/(k0*k0*n2*n2)
	if(pp==0)
		if(r<radius)
			res= - A*k0*radius/kappa*BesselJ(1,kappa*r/radius)*sin(phil)
		else
			res=   A*k0*radius/gamma0*BesselJ(0,kappa)/BesselK(0,gamma0)*BesselK(1,gamma0*r/radius)*sin(phil)
		endif
	else
		if(r<radius)
			res=  A*beta0*radius/(kappa)*((1-s)/2*BesselJ(pp-1,kappa*r/radius)+(1+s)/2*BesselJ(pp+1,kappa*r/radius))*sin(pp*theta+phil)
		else
			res=  A*beta0*radius/(gamma0)*BesselJ(pp,kappa)/BesselK(pp,gamma0)*((1-s)/2*BesselK(pp-1,gamma0*r/radius)-(1+s)/2*BesselK(pp+1,gamma0*r/radius))*sin(pp*theta+phil)
		endif
	endif
	return(res)
End Function

Function/D Ez(r,theta,wv)
	Variable/D r,theta
	Wave wv
	NVAR g_EPSILON
	Variable/D radius=wv[%'radius'],k0=2*pi/wv[%'lambda'],n1=wv[%'n1'],n2=wv[%'n2'],pp=wv[%'p'],beta0=wv[%'beta']
	Variable/D res,kappa,gamma0,s,s1,s0,A=1,phil=wv[%'phil'],mue0=4*pi*g_EPSILON,omega=k0/sqrt(g_EPSILON*MUE0)
	kappa=u_func(beta0)
	gamma0=w_func(beta0)
//	s=(pp*(1/(kappa*kappa)+1/(gamma0*gamma0))/(dBesselJ(pp,kappa)/(kappa*BesselJ(pp,kappa))+dBesselK(pp,gamma0)/(gamma0*BesselK(pp,gamma0))))
//	s1=s*beta0*beta0/(k0*k0*n1*n1)
//	s0=s*beta0*beta0/(k0*k0*n2*n2)
	if(r<radius)
		res= A*besselJ(pp,kappa*r/radius)*cos(pp*theta+phil)
	else
		res= A*besselJ(pp,kappa)/besselK(pp,gamma0)*besselK(pp,gamma0*r/radius)*cos(pp*theta+phil)
	endif
	return(res)
End Function

Function/D Hr(r,theta,wv)
	Variable/D r,theta
	Wave wv
	NVAR g_EPSILON
	Variable/D radius=wv[%'radius'],k0=2*pi/wv[%'lambda'],n1=wv[%'n1'],n2=wv[%'n2'],pp=wv[%'p'],beta0=wv[%'beta']
	Variable/D res,kappa,gamma0,s,s1,s0,A=1,phil=wv[%'phil'],mue0=4*pi*g_EPSILON,omega=k0/sqrt(g_EPSILON*MUE0)
	kappa=u_func(beta0)
	gamma0=w_func(beta0)
	s=wv[%'s']
	s1=wv[%'s1']
	s0=wv[%'s0']
//	s=(pp*(1/(kappa*kappa)+1/(gamma0*gamma0))/(dBesselJ(pp,kappa)/(kappa*BesselJ(pp,kappa))+dBesselK(pp,gamma0)/(gamma0*BesselK(pp,gamma0))))
//	s1=s*beta0*beta0/(k0*k0*n1*n1)
//	s0=s*beta0*beta0/(k0*k0*n2*n2)
	if(pp==0)
		if(r<radius)
			res=-A*beta0*radius/(kappa)*BesselJ(1,kappa*r/radius)*sin(pp*theta+phil)
		else
			res= A*beta0*radius/(gamma0)*BesselJ(0,kappa)/BesselK(0,gamma0)*(BesselK(1,gamma0*r/radius))*sin(pp*theta+phil)
		endif
	else
		if(r<radius)
			res=-A*omega*g_EPSILON*n1*n1*radius/(kappa)*((1-s1)/2*BesselJ(pp-1,kappa*r/radius)+(1+s1)/2*BesselJ(pp+1,kappa*r/radius))*sin(pp*theta+phil)
		else
			res=-A*omega*g_EPSILON*n2*n2*radius/(gamma0)*BesselJ(pp,kappa)/BesselK(pp,gamma0)*((1-s0)/2*BesselK(pp-1,gamma0*r/radius)-(1+s0)/2*BesselK(pp+1,gamma0*r/radius))*sin(pp*theta+phil)
		endif
	endif
	return(res)
End Function

Function/D Ht(r,theta,wv)
	Variable/D r,theta
	Wave wv
	NVAR g_EPSILON
	Variable/D radius=wv[%'radius'],k0=2*pi/wv[%'lambda'],n1=wv[%'n1'],n2=wv[%'n2'],pp=wv[%'p'],beta0=wv[%'beta']
	Variable/D res,kappa,gamma0,s,s1,s0,A=1,phil=wv[%'phil'],mue0=4*pi*g_EPSILON,omega=k0/sqrt(g_EPSILON*MUE0)
	kappa=u_func(beta0)
	gamma0=w_func(beta0)
	s=wv[%'s']
	s1=wv[%'s1']
	s0=wv[%'s0']
//	s=(pp*(1/(kappa*kappa)+1/(gamma0*gamma0))/(dBesselJ(pp,kappa)/(kappa*BesselJ(pp,kappa))+dBesselK(pp,gamma0)/(gamma0*BesselK(pp,gamma0))))
//	s1=s*beta0*beta0/(k0*k0*n1*n1)
//	s0=s*beta0*beta0/(k0*k0*n2*n2)
	if(pp==0)
		if(r<radius)
			res=  -A*k0*g_EPSILON*n1*n1*radius/(kappa)*(-1)*BesselJ(pp+1,kappa*r/radius)*cos(phil)
		else
			res=  -A*k0*g_EPSILON*n2*n2*radius/(gamma0)*BesselJ(pp,kappa)/BesselK(pp,gamma0)*BesselK(1,gamma0*r/radius)*cos(phil)
		endif
	else
		if(r<radius)
			res=  -A*omega*g_EPSILON*n1*n1*radius/(kappa)*((1-s1)/2*BesselJ(pp-1,kappa*r/radius)-(1+s1)/2*BesselJ(pp+1,kappa*r/radius))*cos(pp*theta+phil)
		else
			res=  -A*omega*g_EPSILON*n2*n2*radius/(gamma0)*BesselJ(pp,kappa)/BesselK(pp,gamma0)*((1-s0)/2*BesselK(pp-1,gamma0*r/radius)+(1+s0)/2*BesselK(pp+1,gamma0*r/radius))*cos(pp*theta+phil)
		endif
	endif
	return(res)
End Function

Function/D Hz(r,theta,wv)
	Variable/D r,theta
	Wave wv
	NVAR g_EPSILON
	Variable/D radius=wv[%'radius'],k0=2*pi/wv[%'lambda'],n1=wv[%'n1'],n2=wv[%'n2'],pp=wv[%'p'],beta0=wv[%'beta']
	Variable/D res,kappa,gamma0,s,s1,s0,A=1,phil=wv[%'phil'],mue0=4*pi*g_EPSILON,omega=k0/sqrt(g_EPSILON*MUE0)
	kappa=u_func(beta0)
	gamma0=w_func(beta0)
	s=wv[%'s']
	s1=wv[%'s1']
	s0=wv[%'s0']
//	s=(pp*(1/(kappa*kappa)+1/(gamma0*gamma0))/(dBesselJ(pp,kappa)/(kappa*BesselJ(pp,kappa))+dBesselK(pp,gamma0)/(gamma0*BesselK(pp,gamma0))))
//	s1=s*beta0*beta0/(k0*k0*n1*n1)
//	s0=s*beta0*beta0/(k0*k0*n2*n2)
	if(pp==0)
		if(r<radius)
			res=A*BesselJ(0,kappa*r/radius)*sin(pp*theta+phil)
		else
			res=A*BesselJ(0,kappa)/BesselK(0,gamma0)*BesselK(0,gamma0*r/radius)*sin(pp*theta+phil)
		endif
	else
		if(r<radius)
			res=-A*beta0/(omega*mue0)*s*BesselJ(pp,kappa*r/radius)*sin(pp*theta+phil)
		else
			res=-A*beta0/(omega*mue0)*s*BesselJ(pp,kappa)/BesselK(pp,gamma0)*BesselK(pp,gamma0*r/radius)*sin(pp*theta+phil)
		endif
	endif
	return(res)
End Function

// core
//Er = -A*beta0*radius/(kappa*a)*((1-s)/2*BesselJ(pp-1,kappa*r)-(1+s)/2*BesselJ(pp+1,kappa*r))*cos(pp*theta+phil)
//Et =  A*beta0*radius/(kappa*a)*((1-s)/2*BesselJ(pp-1,kappa*r)+(1+s)/2*BesselJ(pp+1,kappa*r))*sin(pp*theta+phil)
//Ez = A*BesselJ(pp,kappa*r)*cos(pp*theta+phil)
//Hr = -A*omega*g_EPSILON*n1*n1*radius/(kappa*a)*((1-s0)/2*BesselJ(pp-1,kappa*r)+(1+s0)/2*BesselJ(pp+1,kappa*r))*sin(pp*theta+phil)
//Ht = -A*omega*g_EPSILON*n1*n1*radius/(kappa*a)*((1-s0)/2*BesselJ(pp-1,kappa*r)-(1+s0)/2*BesselJ(pp+1,kappa*r))*cos(pp*theta+phil)
//Hz = -A*beta0/(omega*mue0)*s*BesselJ(kappa*r)*sin(pp*theta+phil)

// clad
//Er = -A*beta0*radius/(gamma0*a)*BesselJ(pp,kappa*radius)/BesselK(pp,gamma0*radius)*((1-s)/2*BesselK(pp-1,gamma0*r)+(1+s)/2*BesselK(pp+1,gamma0*r))*cos(pp*theta+phil)
//Et = A*beta0*radius/(gamma0*a)*BesselJ(pp,kappa*radius)/BesselK(pp,gamma0*radius)*((1-s)/2*BesselK(pp-1,gamma0*r)-(1+s)/2*BesselK(pp+1,gamma0*r))*sin(pp*theta+phil)
//Ez = A*BesselJ(pp,kappa*radius)/BesselK(pp,gamma0*radius)*BesselK(pp,kappa*r)*cos(pp*theta+phil)
//Hr = -A*omega*g_EPSILON*n1*n1*radius/(gamma0*a)*BesselJ(pp,kappa*radius)/BesselK(pp,gamma0*radius)*((1-s1)/2*BesselK(pp-1,gamma0*r)+(1+s1)/2*BesselK(pp+1,gamma0*r))*sin(pp*theta+phil)
//Ht = -A*omega*g_EPSILON*n1*n1*radius/(gamma0*a)*BesselJ(pp,kappa*radius)/BesselK(pp,gamma0*radius)*((1-s1)/2*BesselK(pp-1,gamma0*r)-(1+s1)/2*BesselK(pp+1,gamma0*r))*cos(pp*theta+phil)
//Hz = -A*beta0/(omega*mue0)*s*BesselJ(pp,kappa*radius)/BesselK(pp,gamma0*radius)*BesselK(gamma0*r)*sin(pp*theta+phil)

// calcualate function of eigenmode equation for given mode and given parameters
Proc funciton_calculate(modename)
	String modename=g_mode
	Prompt modename,"Name of the mode",popup,"hybrid;HE;EH;TE;TM;HE1;HEp;EHp;TETM"
	PauseUpdate;Silent 1
	
	func_function_calculate(modename)
End

Function func_function_calculate(modename,pp)
	String modename
	Variable pp
	
	SVAR g_paramwv,g_funcwv
	Wave wv=$g_paramwv
	Variable wl,n1,n2,betamin,betamax
	String cmd

	n1=wv[%'n1']
	n2=wv[%'n2']
	wl=wv[%'lambda']
	wv[%'p']=pp
	SetParamwv_recalc(wl,n1,n2)
	
	betamin=wv[%'betamin0']
	betamax=wv[%'betamax0']
	SetScale/I x betamin,betamax,"", $g_funcwv
	func_function_calculate0(modename)
End

// calculate without parameter update
Function func_function_calculate0(modename)
	String modename
	
	String cmd
	SVAR g_funcwv,g_paramwv
	sprintf cmd,"%s =func_%s_0(%s,x)",g_funcwv,modename,g_paramwv
	Execute cmd
End

/////// graphs
//Window funcgraph_all() : Graph
Proc graph_func_all()
	PauseUpdate; Silent 1		// building window...
	String cmd
	Display /W=(358,44,1098,675)
	AppendToGraph $(g_funcwv+"_HE1"),$(g_funcwv+"_HEp"),$(g_funcwv+"_EHp"),$(g_funcwv+"_TETM")
	AppendToGraph $(g_funcwv+"_hybrid"),$(g_funcwv+"_TE"),$(g_funcwv+"_TM")
	
//	Display /W=(358,44,1098,675) func_StepIndexFiber_HE1,func_StepIndexFiber_HEp,func_StepIndexFiber_EHp
//	AppendToGraph func_StepIndexFiber_TETM,func_StepIndexFiber_TE,func_StepIndexFiber_TM
//	AppendToGraph func_StepIndexFiber_hybrid
	DoWindow/C graph_all

	ModifyGraph gfSize=18
	cmd="ModifyGraph lSize("+g_funcwv+"_TE)=2";Execute cmd
	cmd="ModifyGraph lSize("+g_funcwv+"_TM)=2";Execute cmd
	cmd="ModifyGraph lSize("+g_funcwv+"_hybrid)=2";Execute cmd
	cmd="ModifyGraph lStyle("+g_funcwv+"_TE)=2";Execute cmd
	cmd="ModifyGraph lStyle("+g_funcwv+"_TM)=2";Execute cmd
	cmd="ModifyGraph lStyle("+g_funcwv+"_hybrid)=2";Execute cmd
	cmd="ModifyGraph rgb("+g_funcwv+"_HE1)=(0,0,0)";Execute cmd
	cmd="ModifyGraph rgb("+g_funcwv+"_HEp)=(65535,16385,16385)";Execute cmd
	cmd="ModifyGraph rgb("+g_funcwv+"_EHp)=(2,39321,1)";Execute cmd
	cmd="ModifyGraph rgb("+g_funcwv+"_TETM)=(0,0,65535)";Execute cmd
	cmd="ModifyGraph rgb("+g_funcwv+"_hybrid)=(65535,32768,32768)";Execute cmd
	cmd="ModifyGraph rgb("+g_funcwv+"_TE)=(39321,1,31457)";Execute cmd
	cmd="ModifyGraph rgb("+g_funcwv+"_TM)=(48059,48059,48059)";Execute cmd

	ModifyGraph zero(left)=1
	SetAxis left -0.5,0.5
	Legend/C/N=text0/J/F=0/A=MC/X=32.15/Y=36.17 "\\s(func_StepIndexFiber_HE1) HE1\r\\s(func_StepIndexFiber_HEp) HEp\r\\s(func_StepIndexFiber_EHp) EHp"
	AppendText "\\s(func_StepIndexFiber_TETM) TETM\r\\s(func_StepIndexFiber_TE) TE\r\\s(func_StepIndexFiber_TM) TM\r\\s(func_StepIndexFiber_hybrid) hybrid"
End

Function func_ab1(beta0)
	Variable/D beta0
	SVAR g_paramwv
	return(func_ab1_0($g_paramwv,beta0))
End Function

Function/D func_ab1_0(wv,beta0)
	Wave wv
	Variable/D beta0
	Variable pp,uu,ww,res1,res2
	Variable k0,n1,n2,j1,j2,k1,k2,e0,e1
	n1=wv[%'n1']
	n2=wv[%'n2']
	k0=2*pi/wv[%'lambda']
	pp=wv[%'p']
	uu=u_func(beta0)
	ww=w_func(beta0)
	j1=BesselJ(pp,uu)
	j2=dBesselJ(pp,uu)
	k1=Besselk(pp,ww)
	k2=dBesselk(pp,ww)
	res1=beta0*pp*(1/(uu*uu)+1/(ww*ww))/(j2/(uu*j1)+k2/(ww*k1))
	res2=0
//	res2=1/pp/beta0*((n1*n1*j2/(uu*j1)+n2*n2*k2/(ww*k1)))/(1/(uu*uu)+1/(ww*ww))*k0*k0
//	e0=(BesselJ(pp-1,uu)-BesselJ(pp+1,uu))/2/(uu*BesselJ(pp,uu))
//	e1=-(BesselK(pp-1,ww)+BesselK(pp+1,ww))/2/(ww*BesselK(pp,ww))
//	res1=beta0*pp*(1/(uu*uu)+1/(ww*ww))/(e0+e1)
//	res2=1/pp/beta0*(e0*n1*n1+e1*n2*n2)/(1/(uu*uu)+1/(ww*ww))*k0*k0
//	return((e0+e1)*(n1*n1*e0+n2*n2*e1)-pp*pp*(1/(uu*uu)+1/(ww*ww))^2*beta0*beta0/(k0*k0))

	return(res1-res2)
End

// calculate dispersion : wavelength vs beta
Proc initialize_calculate_dispersion(start,mode,nmode)
	String mode=g_mode
	Variable start=g_wl1,nmode=1
	Prompt mode,"Name of the mode",popup,"hybrid;HE;EH;TE;TM;HE1;HEp;EHp;TETM"
	Prompt start,"staring wavelength"
	Prompt nmode,"mode number"
	PauseUpdate;Silent 1

	SetParamwv(start,$g_paramwv[%'n1'],$g_paramwv[%'n2'],$g_paramwv[%'radius'],nmode)
	g_wl1=start
	Func_ShowFunction(mode)
End

Proc init_calc_dispersion_omg(start,mode,nmode)
	String mode=g_mode
	Variable start=g_om2,nmode=1
	Prompt mode,"Name of the mode",popup,"hybrid;HE;EH;TE;TM;HE1;HEp;EHp;TETM"
	Prompt start,"staring wavelength"
	Prompt nmode,"mode number"
	PauseUpdate;Silent 1

	SetParamwv(2*pi/start,$g_paramwv[%'n1'],$g_paramwv[%'n2'],$g_paramwv[%'radius'],nmode)
	g_om2=start
	Func_ShowFunction(mode)
End

Proc calculate_dispersion_LambdaBeta(wvname,mode,start,stop,usecsr,stoperror,pdisp)
	String wvname,mode=g_mode
	Variable start=g_wl1,stop=g_wl2,usecsr=1,stoperror,pdisp=2
	Prompt wvname, "wave name"
	Prompt mode,"Name of the mode",popup,"hybrid;HE;EH;TE;TM;HE1;HEp;EHp;TETM"
	Prompt start,"staring wavelength"
	Prompt stop,"ending wavelength"
	Prompt usecsr,"bracket with cursor ?",popup,"yes;no"
	Prompt stoperror, "stop on error ?",popup,"yes;no"
	Prompt pdisp,"display graph ?",popup,"no;yes;append"
	PauseUpdate; Silent 1
	
	Make/O $wvname
	SetScale/I x start,stop,"nm", $wvname
	g_wl1=start
	g_wl2=stop
	calculate_dispersion_wave(wvname,mode,usecsr,0,stoperror,pdisp)
End

// dispersion for normalized omega-beta; set radius 1
Proc calculate_dispersion_OmegaBeta(wvname,mode,start,stop,usecsr,stoperror,pdisp)
	String wvname,mode=g_mode
	Variable start=0.01,stop=2,usecsr=1,stoperror=2,pdisp=2
	Prompt wvname, "wave name"
	Prompt mode,"Name of the mode",popup,"hybrid;HE;EH;TE;TM;HE1;HEp;EHp;TETM"
	Prompt start,"staring omega"
	Prompt stop,"ending omega"
	Prompt usecsr,"bracket with cursor ?",popup,"yes;no"
	Prompt stoperror, "stop on error ?",popup,"yes;no"
	Prompt pdisp,"display graph ?",popup,"no;yes;append"
	PauseUpdate; Silent 1
	
	Make/O $wvname
	SetScale/I x 2*pi/stop,2*pi/start,"nm", $wvname
	calculate_dispersion_wave(wvname,mode,usecsr,1,stoperror,pdisp)
	Make/O omegawave
	SetScale/I x, start,stop,"",omegawave
End

Proc calculate_dispersion_wave(wname,mode,usecsr,xmode,stoperror,pdisp)
	String wname,mode=g_mode
	Variable usecsr=1,xmode=0,stoperror=2,pdisp=2
	Prompt wname, "wave name"
	Prompt mode,"Name of the mode",popup,"hybrid;HE;EH;TE;TM;HE1;HEp;EHp;TETM"
	Prompt usecsr,"bracket with cursor ?",popup,"yes;no"
	Prompt stoperror,"stop on error ?",popup,"yes;no"
	Prompt pdisp,"display graph ?",popup,"no;yes;append"
	PauseUpdate; Silent 1
	
	Variable i,n,x0,dx,xx,n1,n2,beta0,betamin,betamax,pp
	Variable tmp_usecsr=usecsr,lambda,ret
	n=DimSize($wname,0)
	x0=DimOffset($wname,0)
	dx=DimDelta($wname,0)
	n1=$g_paramwv[%'n1']
	n2=$g_paramwv[%'n2']
	pp=$g_paramwv[%'p']
	i=0
	Variable delta=g_delta
	do
		if(xmode==0)
			lambda=x0+i*dx // x is wavelength
		else
			lambda=2*pi/(x0+i*dx)//x is normlaized omega
		endif
		$g_paramwv[%'lambda']=lambda // wavelength
		SetParamwv_recalc(lambda,n1,n2)
		beta0=$g_paramwv[%'beta']
		if(tmp_usecsr==1)
			betamin=xcsr(A,g_graphname)
			betamax=xcsr(B,g_graphname)
			tmp_usecsr=2
		else
			betamin=beta0*(1-delta)
			if(betamin<$g_paramwv[%'betamin0'])
				betamin=$g_paramwv[%'betamin0']
			endif
			betamax=beta0*(1+delta)
			if(betamax>$g_paramwv[%'betamax0'])
				betamax=$g_paramwv[%'betamax0']
			endif
		endif
		Proc_FindRootFunc(mode,pp,betamin,betamax,2,1,stoperror)
		$wname[i]=$g_paramwv[%'beta']
		i=i+1
	while(i<n)
//	if(pdisp==2)
//		Display
//	endif
End

Proc Dispersion_OmegaBetaAll(wname,mode,pmode,start,stop,nmax,pdisp)
	String wname,mode=g_mode
	Variable start=0.4,stop=2,nmax=5
	Variable pmode=1,pdisp
	Prompt wname, "wave name"
	Prompt mode,"Name of the mode",popup,"hybrid;HE;EH;TE;TM;HE1;HEp;EHp;TETM"
	Prompt pmode,"mode number"
	Prompt start,"staring omega"
	Prompt stop,"ending omega"
	Prompt nmax,"maximum number of mode"
	Prompt pdisp,"display graph ?",popup,"no;yes;append"
	PauseUpdate; Silent 1
	
	Make/O/N=(128,nmax) $wname
	SetScale/I x start,stop,"", $wname
	DispersionAll_wave(wname,mode,pmode,2,pdisp)
End

Function DispersionAll_wave(wname,modename,pmode,xmode,pdisp)
	String wname,modename
	Variable pmode,xmode,pdisp
//	Prompt wname,"wave name"
//	Prompt nmax,"maximum number of mode"
//	Prompt modename,"Name of the mode",popup,"hybrid;HE;EH;TE;TM;HE1;HEp;EHp;TETM"
//	Prompt xmode,"x is ?",popup,"wavelength;norm. omega"
//	PauseUpdate;Silent 1
	
	Variable i,n,x0,dx,xx,n1,n2,beta0,betamin,betamax,pp,nmax,nsol
	Variable lambda,ret
	SVAR g_paramwv
	SVAR g_mode
	Wave prm=$g_paramwv
	Wave dest=$wname
	
	Make/D/O solwv
	Wave solwv
	solwv=NAN
	
	n1=prm[%'n1']
	n2=prm[%'n2']
	pp=pmode
	prm[%'p']=pmode
	g_mode=modename
	n=DimSize(dest,0)
	x0=DimOffset(dest,0)
	dx=DimDelta(dest,0)
	nmax=DimSize(dest,1)

	i=0
	if(pdisp==2)
		Display
	Endif
	do
		if(xmode==1)
			lambda=x0+i*dx // x is wavelength
		else
			lambda=2*pi/(x0+i*dx)//x is normlaized omega
		endif
		prm[%'lambda']=lambda // wavelength
		SetParamwv_recalc(lambda,n1,n2)
		nsol=Func_FindRootAll(modename)
		dest[i][]=solwv[q+1]
		i+=1
	while(i<n)

	if(pdisp>=2)
		i=0
		Variable ny=DimSize(dest,1)
		do 
			AppendToGraph dest[][i]
			i+=1
		while(i<ny)
	Endif
End

// swap omega(x)-k(y) (calculated by DispersionAll_wave)=> k(y)-omega(k) 
Function SwapOmKToKOm(wvname,fdisp)
	String wvname
	Variable fdisp
	
	Variable nx,ny,index
	nx=DimSize($wvname,0)
	ny=DimSize($wvname,1)
	String destk,desto
	Wave orig=$wvname
	if(fdisp==1)
		Display
	Endif
	index=0
	Do
		destk=wvname+"_k_"+num2istr(index)
		desto=wvname+"_o_"+num2istr(index)
		Duplicate/O orig,$destk,$desto
		ReDimension/N=(nx) $desto,$destk
		Wave wdesto=$desto
		Wave wdestk=$destk
		wdesto=x
		wdestk=orig[p][index]
		index+=1
			if(fdisp==1)
				AppendToGraph wdesto vs wdestk
			endif
	while(index<ny)
End

Function SetCutoff()
	NVAR g_wl1,g_wl2
	NVAR g_om1,g_om2
	SVAR g_paramwv

	Wave paramwv=$g_paramwv
	Make/O/D cutoff1,cutoff2,cutoff_om1,cutoff_om2
	SetScale/I x g_wl1,g_wl2,"",cutoff1,cutoff2
	cutoff1=2*pi/x*paramwv[%'n1']
	cutoff2=2*pi/x*paramwv[%'n2']
	SetScale/I x g_om1,g_om2,"",cutoff_om1,cutoff_om2
	cutoff_om1=x*paramwv[%'n1']
	cutoff_om2=x*paramwv[%'n2']
End

//////////////// for complex beta
Function/C/D u_func0c(wv,beta0)
	Wave wv
	Variable/C/D beta0
	return (u_func00c(beta0,wv[%'n1'],wv[%'lambda'],wv[%'radius']))
End function

Function/C/D w_func0c(wv,beta0)
	Wave wv
	Variable/C/D beta0
	return w_func00c(beta0,wv[%'n2'],wv[%'lambda'],wv[%'radius'])
End function

Function/C/D u_func00c(beta0,n,lambda,radius)
	Variable/C/D beta0
	Variable/D n,lambda,radius
	Variable/C/D res
	res=sqrt((2*pi*n/lambda)*(2*pi*n/lambda)-beta0*beta0)*radius
//	if(imag(res)<0)
//		res=-res
//	endif
	return(res)
End function

// note 2*pi/lambda)^2-beta^2
Function/C/D w_func00c(beta0,n,lambda,radius)
	Variable/C/D beta0
	Variable/D n,lambda,radius
	Variable/C/D res
	res=sqrt((2*pi*n/lambda)*(2*pi*n/lambda)-beta0*beta0)*radius
//	if(imag(res)<0)
//		res=-res
//	endif
	return res
End function

Function/C/D func_chybrid_0(wv,beta0)
	Wave wv
	Variable/C/D beta0
	Variable/D n1,n2,pp,k0
	Variable/C/D e0,e1,uu,ww
	uu=u_func0c(wv,beta0)
	ww=w_func0c(wv,beta0)
	n1=wv[%'n1']
	n2=wv[%'n2']
	pp=wv[%'p']
	k0=2*pi/wv[%'lambda']
	e0=(BesselJ(pp-1,uu)-BesselJ(pp+1,uu))/2/(uu*BesselJ(pp,uu))
	e1=(CBesselH1(pp-1,ww)-CBesselH1(pp+1,ww))/2/(ww*CBesselH1(pp,ww))
//	e1=(CBesselH2(pp-1,ww)-CBesselH2(pp+1,ww))/2/(ww*CBesselH2(pp,ww))
//	return((e0+e1)*(n1*n1/(n2*n2)*e0+e1)-pp*pp*(1/(uu*uu)+1/(ww*ww))*(n1*n1/(n2*n2*uu*uu)+1/(ww*ww)))
	return((e0-e1)*(n1*n1*e0-n2*n2*e1)-pp*pp*(1/(uu*uu)-1/(ww*ww))^2*beta0*beta0/(k0*k0))
//	Return(n1*n1/(n2*n2)*(-BesselJ(1,uu))*ww*CBesselH1(0,ww)-CBesselH1(1,ww)*uu*BesselJ(0,uu))
End

Function/C/D func_chybrid_0m(wv,m,beta0)
	Wave wv
	Variable/C/D beta0
	Variable m
	Variable/D n1,n2,pp,k0
	Variable/C/D e0,e1,uu,ww
	uu=u_func0c(wv,beta0)
	ww=w_func0c(wv,beta0)
	n1=wv[%'n1']
	n2=wv[%'n2']
	pp=wv[%'p']
	k0=2*pi/wv[%'lambda']
	e0=(BesselJ(pp-1,uu)-BesselJ(pp+1,uu))/2/(uu*BesselJ(pp,uu))
	e1=(CBesselH1m(pp-1,m,ww)-CBesselH1m(pp+1,m,ww))/2/(ww*CBesselH1m(pp,m,ww))
//	e1=(CBesselH2(pp-1,ww)-CBesselH2(pp+1,ww))/2/(ww*CBesselH2(pp,ww))
//	return((e0+e1)*(n1*n1/(n2*n2)*e0+e1)-pp*pp*(1/(uu*uu)+1/(ww*ww))*(n1*n1/(n2*n2*uu*uu)+1/(ww*ww)))
	return((e0-e1)*(n1*n1*e0-n2*n2*e1)-pp*pp*(1/(uu*uu)-1/(ww*ww))^2*beta0*beta0/(k0*k0))
//	Return(n1*n1/(n2*n2)*(-BesselJ(1,uu))*ww*CBesselH1(0,ww)-CBesselH1(1,ww)*uu*BesselJ(0,uu))
End

Function/C/D func_chybrid_w0(wv,ww)
	Wave wv
	Variable/C/D ww
	Variable/D n1,n2,pp,k0
	Variable/C/D e0,e1,uu,beta0
	n1=wv[%'n1']
	n2=wv[%'n2']
	pp=wv[%'p']
	k0=2*pi/wv[%'lambda']
	beta0=sqrt(k0^2*n2^2-ww^2)
	uu=u_func0c(wv,beta0)
//	ww=w_func0c(wv,beta0)
	e0=(BesselJ(pp-1,uu)-BesselJ(pp+1,uu))/2/(uu*BesselJ(pp,uu))
	e1=(CBesselH1(pp-1,ww)-CBesselH1(pp+1,ww))/2/(ww*CBesselH1(pp,ww))
//	e1=(CBesselH2(pp-1,ww)-CBesselH2(pp+1,ww))/2/(ww*CBesselH2(pp,ww))
//	return((e0+e1)*(n1*n1/(n2*n2)*e0+e1)-pp*pp*(1/(uu*uu)+1/(ww*ww))*(n1*n1/(n2*n2*uu*uu)+1/(ww*ww)))
	return((e0-e1)*(n1*n1*e0-n2*n2*e1)-pp*pp*(1/(uu*uu)-1/(ww*ww))^2*beta0*beta0/(k0*k0))
//	Return(n1*n1/(n2*n2)*(-BesselJ(1,uu))*ww*CBesselH1(0,ww)-CBesselH1(1,ww)*uu*BesselJ(0,uu))
End

Function/C/D func_chybrid_w0m(wv,m,ww)
	Wave wv
	Variable/C/D ww
	Variable m
	Variable/D n1,n2,pp,k0
	Variable/C/D e0,e1,uu,beta0
	n1=wv[%'n1']
	n2=wv[%'n2']
	pp=wv[%'p']
	k0=2*pi/wv[%'lambda']
	beta0=sqrt(k0^2*n2^2-ww^2)
	uu=u_func0c(wv,beta0)
//	ww=w_func0c(wv,beta0)
	e0=(BesselJ(pp-1,uu)-BesselJ(pp+1,uu))/2/(uu*BesselJ(pp,uu))
	e1=(CBesselH1m(pp-1,m,ww)-CBesselH1m(pp+1,m,ww))/2/(ww*CBesselH1m(pp,m,ww))
//	e1=(CBesselH2(pp-1,ww)-CBesselH2(pp+1,ww))/2/(ww*CBesselH2(pp,ww))
//	return((e0+e1)*(n1*n1/(n2*n2)*e0+e1)-pp*pp*(1/(uu*uu)+1/(ww*ww))*(n1*n1/(n2*n2*uu*uu)+1/(ww*ww)))
	return((e0-e1)*(n1*n1*e0-n2*n2*e1)-pp*pp*(1/(uu*uu)-1/(ww*ww))^2*beta0*beta0/(k0*k0))
//	Return(n1*n1/(n2*n2)*(-BesselJ(1,uu))*ww*CBesselH1(0,ww)-CBesselH1(1,ww)*uu*BesselJ(0,uu))
End

Function CBesselH1m(nu,m,z)
	Variable m,nu
	Variable/C/D z
	
	Variable/C/D res
	Variable mm,mm1
	if(mod(nu,2)==0)
		mm=m
		mm1=m-1
	else
		mm=-m*(-1)^m
		mm1=-(m-1)*(-1)^(m-1)
	endif
	res=-mm1*CBesselH1(nu,z)-(-1)^nu*mm*CBesselH2(nu,z)	
	return(res)
End

Function/C/D func_chybrid(wv,beta_re,beta_im)
	Wave wv
	Variable/D beta_re,beta_im
	return(func_chybrid_0(wv,cmplx(beta_re,beta_im)))
End

Function/D func_chybrid_re(wv,beta_re,beta_im)
	Wave wv
	Variable/D beta_re,beta_im
	return(real(func_chybrid_0(wv,cmplx(beta_re,beta_im))))
End

Function/D func_chybrid_im(wv,beta_re,beta_im)
	Wave wv
	Variable/D beta_re,beta_im
	return(imag(func_chybrid_0(wv,cmplx(beta_re,beta_im))))
End

Function/C/D func_cTE_0(wv,beta0)
	Wave wv
	Variable/C/D beta0
	Variable/D n1,n2,pp,k0
	Variable/C/D uu,ww
	uu=u_func0c(wv,beta0)
	ww=w_func0c(wv,beta0)
	n1=wv[%'n1']
	n2=wv[%'n2']
	pp=wv[%'p']
	k0=2*pi/wv[%'lambda']
	Return((BesselJ(1,uu))*ww*CBesselH1(0,ww)-CBesselH1(1,ww)*uu*BesselJ(0,uu))
End

Function/C/D func_cTE(wv,beta_re,beta_im)
	Wave wv
	Variable/D beta_re,beta_im
	return(func_cTE_0(wv,cmplx(beta_re,beta_im)))
End

Function/D func_cTE_re(wv,beta_re,beta_im)
	Wave wv
	Variable/D beta_re,beta_im
	return(real(func_cTE_0(wv,cmplx(beta_re,beta_im))))
End

Function/D func_cTE_im(wv,beta_re,beta_im)
	Wave wv
	Variable/D beta_re,beta_im
	return(imag(func_cTE_0(wv,cmplx(beta_re,beta_im))))
End

Function/C/D func_cTM_0(wv,beta0)
	Wave wv
	Variable/C/D beta0
	Variable/D n1,n2,pp,k0
	Variable/C/D uu,ww
	uu=u_func0c(wv,beta0)
	ww=w_func0c(wv,beta0)
	n1=wv[%'n1']
	n2=wv[%'n2']
	pp=wv[%'p']
	k0=2*pi/wv[%'lambda']
	Return(n1*n1/(n2*n2)*(BesselJ(1,uu))*ww*CBesselH1(0,ww)-CBesselH1(1,ww)*uu*BesselJ(0,uu))
End

Function/C/D func_cTM(wv,beta_re,beta_im)
	Wave wv
	Variable/D beta_re,beta_im
	return(func_cTM_0(wv,cmplx(beta_re,beta_im)))
End

Function/D func_cTM_re(wv,beta_re,beta_im)
	Wave wv
	Variable/D beta_re,beta_im
	return(real(func_cTM_0(wv,cmplx(beta_re,beta_im))))
End

Function/D func_cTM_im(wv,beta_re,beta_im)
	Wave wv
	Variable/D beta_re,beta_im
	return(imag(func_cTM_0(wv,cmplx(beta_re,beta_im))))
End

// find roots
Function Func_FindRootCmplx(modename,m,beta0re,beta0im,showgr,fquiet)
	String modename
	Variable/D beta0re,beta0im
	Variable showgr,fquiet
	Variable m

	SVAR g_paramwv
	Wave W_Root,W_YatRoot
	Variable re_start=0,re_end=1,im_start=0,im_end=1,zminmax=1
	Wave paramwv=$g_paramwv
	if(showgr==1)
		func_ShowFunctionCmplx(modename,m,"test0",re_start,re_end,im_start,im_end,zminmax)
	Endif
	FindRoots/Q/X={beta0re,beta0im} func_chybrid_re,paramwv,func_chybrid_im,paramwv
	if(V_root==0)
		paramwv[%'beta_re']=W_Root[0]
		paramwv[%'beta_im']=W_root[1]
		paramwv[%'beta0_re']=W_Root[0]
		paramwv[%'beta0_im']=W_root[1]
		if(fquiet !=1)
			printf "beta=(%e,%e), residual=(%e,%e)\r",W_Root[0],W_Root[1],W_YatRoot[0],W_YatRoot[1]
		endif
	else
		print "no roots found, error code=",V_flag
	endif
End

Function Func_FindRootCmplxCsr(modename,m,showgr,fquiet)
	String modename
	Variable showgr,fquiet
	Variable m

	Variable/D beta0re,beta0im
	if(strlen(CsrInfo(A,"SolGraph_C"))>0)
		beta0re=hcsr(A,"SolGraph_C")
		beta0im=vcsr(A,"SolGraph_C")
		Func_FindRootCmplx(modename,m,beta0re,beta0im,showgr,fquiet)
	Endif
End

Function Func_disp(wv0,modename,kzstart,kzstop)
	String wv0,modename
//	Variable wlstart,wlstop
	Variable kzstart,kzstop
	
	String wv0_re=wv0+"_re",wv0_im=wv0+"_im"
	Variable nx=128,i
	Make/O/N=(nx) $wv0_re,$wv0_im
	Wave wv_re=$wv0_re,wv_im=$wv0_im
//	SetScale/I x wlstart,wlstop,"", wv_re,wv_im
	SetScale/I x kzstart,kzstop,"", wv_re,wv_im
	SVAR g_paramwv
	Wave paramwv=$g_paramwv
	Variable kx0
	Variable m=0
	
	i=0
//	paramwv[%'lambda']=wlstart
	kx0=(DimOffset(wv_re,0)+i*DimDelta(wv_re,0))
	paramwv[%'lambda']=2*pi/(DimOffset(wv_re,0)+i*DimDelta(wv_re,0))
	Func_FindRootCmplx(modename,m,kx0/2,0,2,2)
	Func_FindRootCmplxCsr(modename,m,2,1)
	wv_re[i]=paramwv[%'beta_re']
	wv_im[i]=paramwv[%'beta_im']

	i=1
//	i=0
	Do
//		paramwv[%'lambda']=DimOffset(wv_re,0)+i*DimDelta(wv_0,0)
		kx0=(DimOffset(wv_re,0)+i*DimDelta(wv_re,0))
		paramwv[%'lambda']=2*pi/(DimOffset(wv_re,0)+i*DimDelta(wv_re,0))

//		kx0=2*pi/paramwv[%'lambda']
		Func_FindRootCmplx(modename,m,paramwv[%'beta0_re'],paramwv[%'beta0_im'],2,1)
//		Func_FindRootCmplx(modename,kx0/2,0,2,2)
		wv_re[i]=paramwv[%'beta_re']
		wv_im[i]=paramwv[%'beta_im']
		i+=1
	while(i<nx)
	Display wv_re,wv_im
End

// show transendal equation graphically
Proc Proc_ShowFunctionCmplx(mode,m,wv0,re_start,re_end,im_start,im_end,zminmax)
	String mode,wv0
	Variable m
	Variable re_start=0,re_end=2,im_start=0,im_end=2,zmimax=1
	Prompt mode,popup,"hybrid;TE;TM"
	PauseUpdate; Silent 1
	
	func_ShowFunctionCmplx(mode,wv0,re_start,re_end,im_start,im_end,zminmax)
End
	
Function func_ShowFunctionCmplx(mode,m,wv0,re_start,re_end,im_start,im_end,zminmax)
	String mode
	Variable m
	String  wv0
	Variable re_start,re_end,im_start,im_end,zminmax
	SVAR g_paramwv
	
	String wv0_re=wv0+"_re",wv0_im=wv0+"_im"
	String grname
	Make/O/C/N=(128,128) $wv0
	Make/O/N=(128,128) $wv0_re,$wv0_im
	Wave/C wv=$wv0
	Wave wv_re=$wv0_re,wv_im=$wv0_im
	SetScale/I x re_start,re_end,"", wv,wv_re,wv_im
	SetScale/I y im_start,im_end,"", wv,wv_re,wv_im
	
	String cmd
	sprintf cmd,"%s=func_c%s_0m(%s,%d,cmplx(x,y))",wv0,mode,g_paramwv,m
//	wv=func_chybrid_0($g_paramwv,cmplx(x,y))
	Execute cmd
	wv_re=real(wv)
	wv_im=imag(wv)
	grname="SolGraph_re"
	if(strlen(WinList(grname,";",""))==0)
		Display /W=(35,44,430,252)
		AppendImage wv_re
		ModifyImage $wv0_re ctab= {-zminmax,zminmax,RedWhiteBlue,0}
		AppendMatrixContour wv_re
		DoWindow/C $grname
	else
		DoWindow/F $grname
		ModifyImage $wv0_re ctab= {-zminmax,zminmax,RedWhiteBlue,0}
	endif
	grname="SolGraph_im"
	if(strlen(WinList(grname,";",""))==0)
		Display /W=(432,44,827,252)
		AppendImage wv_im
		ModifyImage $wv0_im ctab= {-zminmax,zminmax,RedWhiteBlue,0}
		AppendMatrixContour wv_im
		DoWindow/C $grname
	else
		DoWindow/F $grname
		ModifyImage $wv0_im ctab= {-zminmax,zminmax,RedWhiteBlue,0}
	endif
	DoUpdate
	func_ShowContour0(wv0)
End

Function func_ShowContour0(wvname)
	String wvname
	
	String contourWin
	String traceName,names,xName,yName
	String grname="SolGraph_C"
	
	If(strlen(WinList(grname,";",","))==0)
		Display/W=(40,275,435,483)
	endif

// real part
	contourWin="SolGraph_re"
	DoWindow/F $contourWin
	traceName=wvname+"_re=0"
	if(waveExists(TraceNameToWaveRef(contourWin,traceName))==0)
		yName=traceName+".y"
		if(strsearch(TraceNameList(grname,";",1),yName,0,2)>=0)
			DoWindow/F $grname
			RemoveFromGraph  $yName
		endif
	else
		names= WMDuplicateTraceWave(contourWin,traceName)
		xName= StringFromList(0,names,",")
		yName= StringFromList(1,names,",")
		DoWindow/F $grname
		If(strsearch(TraceNameList("",";",1),yName,0,2)<=0)	
			AppendToGraph $yName vs $xName
			DoWindow/C $grname
		else
			DoWindow/F $grname
		endif
	endif
// imag part

	contourWin="SolGraph_im"
	DoWindow/F $contourWin
	traceName=wvname+"_im=0"
	if(waveExists(TraceNameToWaveRef(contourWin,traceName))==0)
		yName=traceName+".y"
		if(strsearch(TraceNameList(grname,";",1),yName,0,2)>=0)
			DoWindow/F $grname
			RemoveFromGraph  $yName
		endif
	else
		names= WMDuplicateTraceWave(contourWin,traceName)
		xName= StringFromList(0,names,",")
		yName= StringFromList(1,names,",")
		DoWindow/F $grname
		If(strsearch(TraceNameList("",";",1),yName,0,2)<=0)
			AppendToGraph $yName vs $xName
			ModifyGraph rgb($yName)=(0,0,65535)
		endif
	endif
End
////// in terms of w
Function func_ShowFunctionCmplxw(mode,m,wv0,re_start,re_end,im_start,im_end,zminmax)
	String mode
	String  wv0
	Variable m
	Variable re_start,re_end,im_start,im_end,zminmax
	SVAR g_paramwv
	
	String wv0_re=wv0+"_re",wv0_im=wv0+"_im"
	String grname
	Make/O/C/N=(128,128) $wv0
	Make/O/N=(128,128) $wv0_re,$wv0_im
	Wave/C wv=$wv0
	Wave wv_re=$wv0_re,wv_im=$wv0_im
	SetScale/I x re_start,re_end,"", wv,wv_re,wv_im
	SetScale/I y im_start,im_end,"", wv,wv_re,wv_im
	
	String cmd
	sprintf cmd,"%s=func_c%s_w0m(%s,%d,cmplx(x,y))",wv0,mode,g_paramwv,m
//	wv=func_chybrid_0($g_paramwv,cmplx(x,y))
	Execute cmd
	wv_re=real(wv)
	wv_im=imag(wv)
	grname="SolGraph_re"
	if(strlen(WinList(grname,";",""))==0)
		Display /W=(35,44,430,252)
		AppendImage wv_re
		ModifyImage $wv0_re ctab= {-zminmax,zminmax,RedWhiteBlue,0}
		AppendMatrixContour wv_re
		DoWindow/C $grname
	else
		DoWindow/F $grname
		ModifyImage $wv0_re ctab= {-zminmax,zminmax,RedWhiteBlue,0}
	endif
	grname="SolGraph_im"
	if(strlen(WinList(grname,";",""))==0)
		Display /W=(432,44,827,252)
		AppendImage wv_im
		ModifyImage $wv0_im ctab= {-zminmax,zminmax,RedWhiteBlue,0}
		AppendMatrixContour wv_im
		DoWindow/C $grname
	else
		DoWindow/F $grname
		ModifyImage $wv0_im ctab= {-zminmax,zminmax,RedWhiteBlue,0}
	endif
	DoUpdate
	func_ShowContour0(wv0)
End

// Plot vector from X and Y 2D wave
Proc FieldArrowPlotXY(scale,num)
	Variable scale=100,num=21
	Func_FieldArrowPlotXY(scale,num)
End

Function Func_FieldArrowPlotXY(scale,num)
	Variable scale,num
	SVAR g_paramwv
	Wave wv=$g_paramwv

	Func_Show_Field_XY(num)

	String xdata="wfield_Ex",ydata="wfield_Ey"
	ArrowPlotXY(scale,xdata,ydata)
End

Function ArrowPlotXY(scale,xdata,ydata)
	Variable scale
	String xdata,ydata	
//	PauseUpdate; Silent 1

//	wave wxwave=$xdata,wywave=$ydata
	Variable nx=DimSize($xdata,0),ny=DimSize($xdata,1)
	Duplicate/O $xdata,wxtemp
	Duplicate/O $ydata,wytemp
	Duplicate/O $xdata,xcoordtemp
	Duplicate/O $xdata,ycoordtemp
	xcoordtemp=x
	ycoordtemp=y
	Redimension/N=(nx*ny) wxtemp
	Redimension/N=(nx*ny) wytemp
	Redimension/N=(nx*ny) xcoordtemp
	Redimension/N=(nx*ny) ycoordtemp
	Make/O/N=(nx*ny,2) wtempdata
	wtempdata[][0]=sqrt(wxtemp[p]*wxtemp[p]+wytemp[p]*wytemp[p])*scale
	wtempdata[][1]=atan2(wytemp[p],wxtemp[p])
	
	String grname="vectorGraph"
	If(strlen(winlist(grname,";",""))==0)
		Display ycoordtemp vs xcoordtemp
		DoWindow/C $grname
	Else
		DoWindow/F $grname
	endif
	
	ModifyGraph mode(ycoordtemp) = 3        // Marker mode
	ModifyGraph arrowMarker(ycoordtemp) = {wtempdata, 1, 10, 1, 1}
	ModifyGraph height={Aspect,1}
	ModifyGraph tick=3,noLabel=2,standoff=0
	ModifyGraph axThick=0

End

Proc FieldFromCursor_betaomega(modename,pp)
	String modename
	Variable pp=$g_paramwv[%'p']
	Prompt modename,"mode name",popup,"hybrid;HE;EH;TE;TM;HE1;HEp;EHp;TETM"
	Prompt pp,"mode number"
	PauseUpdate;Silent 
	
	FFieldFromCursor_betaomega(modename,pp)
End

Function FFieldFromCursor_betaomega(modename,pp)
	String modename
	Variable pp
	
//	SVAR g_graphname
//	DoWindow/F $g_graphname
	Variable beta0 = vcsr(A),omega=hcsr(A)
	Variable lambda0=2*pi/omega
	print omega,lambda0,beta0
	
	SVAR g_paramwv
	SVAR g_mode

	g_mode=modename
	Wave paramwv=$g_paramwv
	Variable radius=paramwv[%'radius']
	paramwv[%'lambda']=lambda0*radius
	paramwv[%'p']=pp
	SetBeta(beta0)
	Variable phil

	if(stringmatch(g_mode,"TE")==1)
		phil=90
		paramwv[%'phil']=phil*pi/180
	endif
	if(stringmatch(g_mode,"TM")==1)
		phil=0
		paramwv[%'phil']=phil*pi/180
	endif
End

Function LambdaFromOmega(orig)
	String orig
	
	String dest=orig+"_lambda"
	Wave worig=$orig
	Variable n
	n=DimSize(worig,0)
	Duplicate/O worig $dest
	Wave wdest=$dest
	Redimension/N=(n) wdest
	Wdest=2*pi/x
End

Function/S mode_modename(mode)
	Variable mode;
	String modestr="hybrid;HE;EH;TE;TM;HE1;HEp;EHp;TETM"
	String modename
	modename=StringFromList(mode,modestr,";")
	return modename
End