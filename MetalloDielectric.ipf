#pragma rtGlobals=1		// Use modern global access method.
#include "PhysicalConstants"
#include "dBessel"

//	Calculation of minimum gain in cyrlindrical metallodielectric cavity
//	based on "Low threshold gain metal coated laser nanoresonators" 
//	Amit Mizrahi, Vitaliy Lomakin, Boris A. Slutsky, Maziar P. Nezhad, Liang Feng, and Yeshaiahu Fainman 
//	June 1, 2008 / Vol. 33, No. 11 / OPTICS LETTERS 1261 
//
//	revision history
//		?/?/?		ver 0.01	first version
//		11/02/05	ver 0.1		data folder operation, bug fixed

Menu "MetalloDielectric"
	"Initialize...",init_metallodielectric("TE")
	"-"
	"Set parameters...",JMMDSetMDparamsProc()
	"Show Graph...",JMMDShowFuncvalGraphProc()
	Submenu "Find Solution..."
		"with current params",JMMDGetBetaEpsGimProc()
		"with initial value at cursor",JMMDGetBetaGainCsrProc()
		"-"
		"with new params", JMMDCalcBetaEpsGimProc2()
	End
	SubMenu "Create Graph..."
		"vs R",MD_NWRdep()
		"vs Delta",MD_Deltadep()
		"vs Rout",MD_Routdep()
	End
End

Function Init_metallodielectric(modename)
	String modename//="TM"
	Prompt modename,"mode",popup,"TE;TM;HE"
	PauseUpdate;Silent 1

	String cmd
//	Wave MDparams,MDbessels
	String savDF= GetDataFolder(1)
	Execute "init_PhysicalConstants()"

	NewDataFolder/O/S root:Packages
	if( DataFolderExists("JMMetalloDielectric") )
		SetDataFolder JMMetalloDielectric
	else 
		NewDataFolder/S JMMetalloDielectric
	endif
	
	String/G g_modename=modename
	
	Make/O/D/N=19 MDparams
	SetDimLabel 0,0,'r', MDparams //r: radius of NW
	SetDimLabel 0,1,'rout', MDparams //n2: radius of NW+sheild
	SetDimLabel 0,2,'lambda', MDparams //lambda: wavelength
	SetDimLabel 0,3,'betamin',MDparams //minimum beta
	SetDimLabel 0,4,'betamax',MDparams //maximum beta
	SetDimLabel 0,5,'p',MDparams //mode number p
	SetDimLabel 0,6,'betamin0',MDparams //minimum beta
	SetDimLabel 0,7,'betamax0',MDparams //maximum beta
	SetDimLabel 0,8,'beta',MDparams //solution of beta
	SetDimLabel 0,9,'gain',MDparams //solution of gain = 4*pi*imag(sqrt(epsG))/lambda
	SetDimLabel 0,10,'epsG',MDparams //epsilon of gain section (real part)
	SetDimLabel 0,11,'epsGim',MDparams //epsilon of gain section (real part) (imag part of epsilon of gain section)
	SetDimLabel 0,12,'epsS',MDparams //epsilon of sheidl (real part)
	SetDimLabel 0,13,'epsSim',MDparams //epsilon of sheidl (imag part,tentatively 0)
	SetDimLabel 0,14,'epsM',MDparams //epsilon of metal (real part, negative)
	SetDimLabel 0,15,'epsMim',MDparams //epsilon of metal (imag part, negative)
	SetDimLabel 0,16,'epsGimmin',MDparams // minimum of imarinary part of epsG)
	SetDimLabel 0,17,'epsGimmax',MDparams //maximam of imarinary part of epsG)
//	SetDimLabel 0,17,'s0', MDparams //
//	SetDimLabel 0,18,'lambda_c',MDparams //cutoff wavelength
	
	Make/O/C/D/N=21 MDbessels
	SetDimLabel 0,0,'u', MDbessels //u
	SetDimLabel 0,1,'v', MDbessels //v
	SetDimLabel 0,2,'v2',MDbessels //v2
	SetDimLabel 0,3,'w', MDbessels //w
	SetDimLabel 0,4,'jmu',   MDbessels // besselJ(m,u)
	SetDimLabel 0,5,'kmv',   MDbessels // besselK(m,v)
	SetDimLabel 0,6,'imv',   MDbessels // besselI(m,v)
	SetDimLabel 0,7,'kmv2',  MDbessels // besselK(m,v2)
	SetDimLabel 0,8,'imv2',  MDbessels // besselI(m,v2)
	SetDimLabel 0,9,'kmw',   MDbessels // besselK(m,w)
	SetDimLabel 0,10,'djmu', MDbessels // DbesselJ(m,u)
	SetDimLabel 0,11,'dkmv', MDbessels // DbesselK(m,v)
	SetDimLabel 0,12,'dimv', MDbessels // DbesselI(m,v)
	SetDimLabel 0,13,'dkmv2',MDbessels // DbesselK(m,v2)
	SetDimLabel 0,14,'dimv2',MDbessels // DbesselI(m,v2)
	SetDimLabel 0,15,'dkmw', MDbessels // DbesselK(m,w)
	SetDimLabel 0,16,'beta', MDbessels //beta
	SetDimLabel 0,17,'beta2',MDbessels //beta2
	SetDimLabel 0,18,'TE',MDbessels // TE mode value
	SetDimLabel 0,19,'TM',MDbessels // TM mode value
	SetDimLabel 0,20,'HE',MDbessels // HE mode value

// default parameters	
	MDparams[%'lambda']=1550
	MDparams[%'r']=250
	MDparams[%'rout']=300
	MDparams[%'epsG']=12.9
	MDparams[%'epsS']=2.1
	MDparams[%'epsM']=-95.9
	MDparams[%'epsMim']=-11
	MDparams[%'p']=0
	
	JMMDSetMinMax(MDparams[%'epsG'],MDparams[%'epsS'])

	Make/O/N=(128,128) funcval_re,funcval_im
	SetScale/I x MDparams[%'betamin'],MDparams[%'betamax'],"", funcval_re,funcval_im
	SetScale/I y MDparams[%'epsGimmin'],MDparams[%'epsGimmax'],"", funcval_re,funcval_im
	JMMDCalcFuncval(modename)
	 JMMDShowFuncvalGraph(0.1)
	
	SetDataFolder savDF // Restore current DF. 
End

Function JMMDSetMinMax(epsG,epsS)
	Variable epsG,epsS
	PauseUpdate;Silent 1

	String savDF= GetDataFolder(1)
	Wave MDparams
	
	SetDataFolder root:Packages:JMMetalloDielectric
	MDparams[%'betamin']=0 //sqrt(epsS)
	MDparams[%'betamax']=sqrt(epsG)
	MDparams[%'epsGimmin']=0
	MDparams[%'epsGimmax']=0.2

	SetDataFolder savDF // Restore current DF. 
	return(1)
End

Proc JMMDSetMDparamsProc(wl,r,rout,epsG,epsS,epsM,epsMim,pp,modename,fshow)
//	Variable wl=816,n1=3.66,n2=3.56,radius=115,pp=1
	Variable wl=root:Packages:JMMetalloDielectric:MDparams[%'lambda'],r=root:Packages:JMMetalloDielectric:MDparams[%'r'],rout=root:Packages:JMMetalloDielectric:MDparams[%'rout']
	Variable epsG=root:Packages:JMMetalloDielectric:MDparams[%'epsG'],epsS=root:Packages:JMMetalloDielectric:MDparams[%'epsS']
	Variable epsM=root:Packages:JMMetalloDielectric:MDparams[%'epsM'],epsMim=root:Packages:JMMetalloDielectric:MDparams[%'epsMim']
	Variable pp=root:Packages:JMMetalloDielectric:MDparams[%'p']
	Variable fshow
	String modename=root:Packages:JMMetalloDielectric:g_modename
	Prompt wl,"wavelength (nm)"
	Prompt r,"NW radius (nm)"
	Prompt rout, "outer radius (nm)"
	Prompt epsG, "epsilon of NW"
	Prompt epsS, "epsilon of sheild"
	Prompt epsM, "real part of epsilon of metal"
	Prompt epsMim, "imag part of epsilon of metal"
	Prompt pp,"mode number"
	Prompt modename,"mode",popup,"TE;TM;HE"
	Prompt fshow,"Show function graph ?",popup,"yes;no"
	
	PauseUpdate;Silent 1;
	
	String savDF= GetDataFolder(1)
	SetDataFolder root:Packages:JMMetalloDielectric
	MDparams[%'lambda']=wl
	MDparams[%'r']=r
	MDparams[%'rout']=rout
	MDparams[%'epsG']=epsG
	MDparams[%'epsS']=epsS
	MDparams[%'epsM']=epsM
	MDparams[%'epsMim']=epsMim
	MDparams[%'p']=pp
	g_modename=modename
	
	JMMDSetMinMax(epsG,epsS)
	JMMDRescaleFuncval(MDparams[%'betamin'],MDparams[%'betamax'],MDparams[%'epsGimmin'],MDparams[%'epsGimmax'],modename)
	if(fshow==1)
		JMMDCalcFuncval(modename)
		JMMDShowFuncvalGraph(0.1)
	endif
//	SetMDparams_recalc(wl,n1,n2)
	SetDataFolder savDF // Restore current DF. 
End

Function/C/D u_funcC00(beta0,eps,r)
	Variable/D beta0,r
	Variable/C eps
	return(sqrt(eps-beta0*beta0))
End

Function/C/D w_funcC00(beta0,eps,r)
	Variable/D beta0,r
	Variable/C eps
	return(sqrt(beta0*beta0-eps))
End

// metallodielectric cavity (te-mode)  
//
Function/C te_md000()
	Variable/C u,v,v2,w,jmu,kmv,imv,kmv2,imv2,kmw,djmu,dkmv,dimv,dkmv2,dimv2,dkmw,xx
	Wave MDparams
	Wave/C MDbessels

	u =MDBessels[%'u']
	v =MDBessels[%'v']
	v2=MDBessels[%'v2']
	w =MDBessels[%'w']
	jmu  =MDbessels[%'jmu']
	kmv  =MDbessels[%'kmv']
	imv  =MDbessels[%'imv']
	kmv2 =MDbessels[%'kmv2']
	imv2 =MDbessels[%'imv2']
	kmw  =MDbessels[%'kmw']
	djmu =MDbessels[%'djmu']
	dkmv =MDbessels[%'dkmv']
	dimv =MDbessels[%'dimv']
	dkmv2=MDbessels[%'dkmv2']
	dimv2=MDbessels[%'dimv2']
	dkmw =MDbessels[%'dkmw']
	dkmw=dkmw/kmw
	kmw=1
	xx =      imv*djmu*kmv2*dkmw*v*v2 - imv2*dkmw*(jmu*dkmv*u + djmu*kmv*v)*v2 + dimv2*jmu*dkmv*kmw*u*w
	xx = xx + dimv2*djmu*kmv*kmw*v*w - imv*djmu*dkmv2*kmw*v*w + dimv*jmu*u*(kmv2*dkmw*v2 - dkmv2*kmw*w);

	MDbessels[%'TE']=xx
  	return(xx)
End

Function/C te_md00(beta0,r0,ro0,wl,eg,es,em)
	Variable beta0,r0,ro0,wl
	Variable/C eg,es,em
	JMMDCalculateBessels(beta0,r0,ro0,wl,eg,es,em)
	return(te_md000())
End

Function/D func_TE_Re(wv,beta0,epsGim)
	Wave wv
	Variable beta0,epsGim
	return(real(te_md00(beta0,wv[%'r'],wv[%'rout'],wv[%'lambda'],cmplx(wv[%'epsG'],epsGim),wv[%'epsS'],cmplx(wv[%'epsM'],wv[%'epsMim']))))
End function
	
Function/D func_TE_Im(wv,beta0,epsGim)
	Wave wv
	Variable beta0,epsGim
	return(imag(te_md00(beta0,wv[%'r'],wv[%'rout'],wv[%'lambda'],cmplx(wv[%'epsG'],epsGim),wv[%'epsS'],cmplx(wv[%'epsM'],wv[%'epsMim']))))
End function

// metallodielectric cavity (tm-mode)
//
Function/C tm_md000(eg,es,em)
	Variable/C eg,es,em
	Variable/C u,v,v2,w,jmu,kmv,imv,kmv2,imv2,kmw,djmu,dkmv,dimv,dkmv2,dimv2,dkmw,xx
	Wave/C MDbessels
	
	u =MDBessels[%'u']
	v =MDBessels[%'v']
	v2=MDBessels[%'v2']
	w =MDBessels[%'w']
	jmu  =MDbessels[%'jmu']
	kmv  =MDbessels[%'kmv']
	imv  =MDbessels[%'imv']
	kmv2 =MDbessels[%'kmv2']
	imv2 =MDbessels[%'imv2']
	kmw  =MDbessels[%'kmw']
	djmu =MDbessels[%'djmu']
	dkmv =MDbessels[%'dkmv']
	dimv =MDbessels[%'dimv']
	dkmv2=MDbessels[%'dkmv2']
	dimv2=MDbessels[%'dimv2']
	dkmw =MDbessels[%'dkmw']
	dkmw=dkmw/kmw
	kmw=1
	
	xx =     em*dkmw*(es*jmu*(dimv*kmv2 - imv2*dkmv)*u + eg*djmu*(-(imv2*kmv) + imv*kmv2)*v)*v2
	xx = xx+ es*kmw*(es*jmu*(-(dimv*dkmv2) + dimv2*dkmv)*u + eg*djmu*(dimv2*kmv - imv*dkmv2)*v)*w
	MDbessels[%'TM']=xx
	return(xx)
End

Function/C tm_md00(beta0,r0,ro0,wl,eg,es,em)
	Variable beta0,r0,ro0,wl
	Variable/C eg,es,em
	JMMDCalculateBessels(beta0,r0,ro0,wl,eg,es,em)
  	return(tm_md000(eg,es,em))
End

Function/D func_TM_Re(wv,beta0,epsGim)
	Wave wv
	Variable beta0,epsGim
	return(real(tm_md00(beta0,wv[%'r'],wv[%'rout'],wv[%'lambda'],cmplx(wv[%'epsG'],epsGim),wv[%'epsS'],cmplx(wv[%'epsM'],wv[%'epsMim']))))
End function

Function/D func_TM_Im(wv,beta0,epsGim)
	Wave wv
	Variable beta0,epsGim
	return(imag(tm_md00(beta0,wv[%'r'],wv[%'rout'],wv[%'lambda'],cmplx(wv[%'epsG'],epsGim),wv[%'epsS'],cmplx(wv[%'epsM'],wv[%'epsMim']))))
End function

// hybrid mode
Function/C he_md000()
End

Function/C he_md00_1(beta0,m,r0,ro0,wl,eg,es,em)
	Variable beta0,r0,ro0,wl,m
	Variable/C eg,es,em
	Wave MDparams
	Wave/C MDbessels
//
	Variable/C beta2=beta0*beta0
	Variable/C u,v,v2,w,jmu,kmv,imv,kmv2,imv2,kmw,djmu,dkmv,dimv,dkmv2,dimv2,dkmw,xx,yy
	Variable/C u2,v20,v22,w2,u3,v03,v23,w3,jmu2,kmw2,kmv22,imv22,dimv20,dimv22,imv20,kmv20
	Variable/C u2_v20_2,v22_w2_2,uvv2w2,te,tm
	String var,cmd
	
	MDparams[%'p']=m
	JMMDCalculateBessels(beta0,r0,ro0,wl,eg,es,em)

	u =MDBessels[%'u']
	v =MDBessels[%'v']
	v2=MDBessels[%'v2']
	w =MDBessels[%'w']
	jmu  =MDbessels[%'jmu']
	kmv  =MDbessels[%'kmv']
	imv  =MDbessels[%'imv']
	kmv2 =MDbessels[%'kmv2']
	imv2 =MDbessels[%'imv2']
	kmw  =MDbessels[%'kmw']
	djmu =MDbessels[%'djmu']
	dkmv =MDbessels[%'dkmv']
	dimv =MDbessels[%'dimv']
	dkmv2=MDbessels[%'dkmv2']
	dimv2=MDbessels[%'dimv2']
	dkmw =MDbessels[%'dkmw']
	dkmw=dkmw/kmw
	kmw=1

	u2=u*u
	v20=v*v
	v22=v2*v2
	w2=w*w
	uvv2w2=u2*v20*v22*w2

	u3=u*u*u
	v03=v*v*v
	v23=v2*v2*v2
	w3=w3*w3*w3

	jmu2=jmu*jmu
	kmw2=kmw*kmw
	imv20=imv*imv
	kmv20=kmv*kmv
	kmv22=kmv2*kmv2
	imv22=imv2*imv2

	dimv20=dimv*dimv
	dimv22=dimv2*dimv2
	
	u2_v20_2=(eg-es)*(eg-es)
	v22_w2_2=(-es + em)*(-es + em)
	
	xx=beta2*jmu2*(imv2*kmv - imv*kmv2)^2*kmw2*m^2*u2_v20_2*v22_w2_2
	xx=xx - (imv2*kmv - imv*kmv2)*(em*jmu2*dkmw*u2_v20_2*v23*w2*(imv2*kmv*dkmw*v2 - imv*kmv2*dkmw*v2 - dimv2*kmv*kmw*w + imv*dkmv2*kmw*w) - eg*djmu*kmw2*u2*v03*(dimv*jmu*kmv2*u + imv*djmu*kmv2*v - imv2*(jmu*dkmv*u + djmu*kmv*v))*v22_w2_2)

	yy=dimv20*jmu*kmv22*kmw*u^4*v20*v22_w2_2 + imv22*dkmv*kmw*u3*v20*(jmu*dkmv*u + djmu*kmv*v)*v22_w2_2

	yy=yy - dimv*kmw*u2*v*(v22 - w2)*(-(kmv2*(2*dimv2*jmu*kmv*(u2 + v20)*v2*w2 + imv*djmu*kmv2*u*v20*(v22 - w2))) + imv2*(djmu*kmv*kmv2*u*v20*(v22 - w2) + 2*jmu*(kmv*dkmv2*(u2 + v20)*v2*w2 + kmv2*dkmv*u2*v*(v22 - w2))))

	yy=yy - jmu*(u2 + v20)*v2*w2*(-(dimv22*kmv20*kmw*(u2 + v20)*v2*w2) + imv20*dkmv2*(u2 + v20)*v2*w*(kmv2*dkmw*v2 - dkmv2*kmw*w) + imv*dimv2*(2*kmv*dkmv2*kmw*(u2 + v20)*v2*w2 + kmv2*(-(kmv*dkmw*(u2 + v20)*v22*w) + 2*dkmv*kmw*u2*v*(v22 - w2))))

	yy=yy - imv2*(dimv2*jmu*kmv20*dkmw*u2_v20_2*v23*w3 + imv*(djmu*kmv2*dkmv*kmw*u3*v03*v22_w2_2 - jmu*dkmv2*(u2 + v20)*v2*w2*(kmv*dkmw*(u2 + v20)*v22*w + 2*dkmv*kmw*u2*v*(v22 - w2))))

	xx=beta2*m^2*(xx-es*jmu*kmw*yy)

	te=te_md000()
	tm=tm_md000(eg,es,em)
	return(xx/uvv2w2+te*tm)
End

Function/C he_md00(beta0,m,r0,ro0,wl,eg,es,em)
	Variable beta0,r0,ro0,wl,m
	Variable/C eg,es,em
	Wave MDparams
	Wave/C MDbessels
//
	Variable/C beta2=beta0*beta0
	Variable/C u,v,v2,w,jmu,kmv,imv,kmv2,imv2,kmw,djmu,dkmv,dimv,dkmv2,dimv2,dkmw,xx,yy
	Variable/C u2,v02,v22,w2,u3,v03,v23,w3,jmu2,kmw2,kmv22,imv22,dimv20,dimv22 //,imv20,kmv20
	Variable/C uv2,uv22,v2w2,v2w22,uvv2w2,te,tm
	Variable/C imv2kmv2,dimv2dkmv2
	Variable/C he,he1,he2,he3,he4,he5

	String var,cmd
	
	MDparams[%'p']=m
	JMMDCalculateBessels(beta0,r0,ro0,wl,eg,es,em)

	u =MDBessels[%'u']
	v =MDBessels[%'v']
	v2=MDBessels[%'v2']
	w =MDBessels[%'w']
	jmu  =MDbessels[%'jmu']
	kmv  =MDbessels[%'kmv']
	imv  =MDbessels[%'imv']
	kmv2 =MDbessels[%'kmv2']/kmv
	imv2 =MDbessels[%'imv2']/imv
	kmw  =MDbessels[%'kmw']
	djmu =MDbessels[%'djmu']
	dkmv =MDbessels[%'dkmv']/kmv
	dimv =MDbessels[%'dimv']/imv
	dkmv2=MDbessels[%'dkmv2']/kmv
	dimv2=MDbessels[%'dimv2']/imv
	dkmw =MDbessels[%'dkmw']/kmw
	kmw=1

	u2=u*u
	v02=v*v
	v22=v2*v2
	w2=w*w
	uvv2w2=u2*v02*v22*w2

	u3=u*u*u
	v03=v*v*v
	v23=v2*v2*v2
	w3=w*w*w

	jmu2=jmu*jmu
	kmw2=kmw*kmw
//	imv20=imv*imv
//	kmv20=kmv*kmv
	kmv22=kmv2*kmv2
	imv22=imv2*imv2

	dimv20=dimv*dimv
	dimv22=dimv2*dimv2
      imv2kmv2 = imv2 - kmv2
      dimv2dkmv2 = dimv2 - dkmv2
	
	uv2=(eg-es)*r0*r0/(wl*wl)*(4*pi*pi)
	uv22=uv2*uv2/(wl*wl)*(4*pi*pi)
	v2w2=ro0*ro0*(-es + em)/(wl*wl)*(4*pi*pi)
	v2w22=v2w2*v2w2
	
	he= m*m*beta2*jmu2*imv2kmv2*imv2kmv2*uv2*uv2*v2w2*v2w2
	he1=(dimv*kmv2 - imv2*dkmv)*u2*u*v02*v2w2*v2w2*((dimv*kmv2 - imv2*dkmv)*jmu*u - djmu*v*imv2kmv2)
	he2=2*jmu*(dimv2*kmv2 - imv2*dkmv2)*(dimv-dkmv)*u2*uv2*v*v2*v2w2*w2
	he3= jmu*dimv2dkmv2*uv2*v22*w2*uv2*(imv2kmv2*dkmw*v2*w - dimv2dkmv2*w2)
	he= he - es*jmu*(he1 +he2 - he3)
	he4=eg*djmu*u2*v02*v*(-(dimv*jmu*kmv2*u) +imv2*jmu*dkmv*u + djmu*imv2kmv2*v)*v2w2*v2w2
	he5=em*jmu2*dkmw*uv2*uv2*v22*v2*w2*(imv2kmv2*dkmw*v2 - dimv2dkmv2*w)
	he= he- imv2kmv2*(he4 + he5);
	
	te= (( dimv*kmv2  - imv2 *dkmv)*jmu*u - djmu*imv2kmv2*v)*dkmw*v2 +  w*((-dimv*dkmv2 + dimv2*dkmv)*jmu*u + djmu*dimv2dkmv2*v)
	tm = em*dkmw*v2*(es*jmu*u*( dimv*kmv2  - imv2 *dkmv) - eg*djmu*imv2kmv2*v )+ es*w*(es*jmu*u*(-dimv*dkmv2 + dimv2*dkmv)+ eg*djmu*dimv2dkmv2*v)

//	return(beta2*m*m*xx+te*tm*uvv2w2)
	return(beta2*m*m*he/w2+te*tm*u2*v02*v22)
End

Function/D func_HE_Re(wv,beta0,epsGim)
	Wave wv
	Variable beta0,epsGim
	return(real(he_md00(beta0,wv[%'p'],wv[%'r'],wv[%'rout'],wv[%'lambda'],cmplx(wv[%'epsG'],epsGim),wv[%'epsS'],cmplx(wv[%'epsM'],wv[%'epsMim']))))
End function

Function/D func_HE_Im(wv,beta0,epsGim)
	Wave wv
	Variable beta0,epsGim
	return(imag(he_md00(beta0,wv[%'p'],wv[%'r'],wv[%'rout'],wv[%'lambda'],cmplx(wv[%'epsG'],epsGim),wv[%'epsS'],cmplx(wv[%'epsM'],wv[%'epsMim']))))
End function

/////////////////////
Proc JMMDRescaleFuncval(betamin,betamax,epsGimmin,epsGimmax,modename)
	Variable betamin=MDparams[%'betamin'],betamax=MDparams[%'betamax']
	Variable epsGimmin=MDparams[%'epsGimmin'],epsGimmax=MDparams[%'epsGimmax']
	String modename
	Prompt modename,"mode",popup,"TE;TM;HE"
	PauseUpdate;Silent 1
	
	MDparams[%'betamin']=betamin
	MDparams[%'betamax']=betamax
	MDparams[%'epsGimmin']=epsGimmin
	MDparams[%'epsGimmax']=epsGimmax
	
	SetScale/I x betamin,betamax,"",funcval_re,funcval_im
	SetScale/I y epsGimmin,epsGimmax,"",funcval_re,funcval_im
//	JMMDCalcFuncval(modename)
End

Function JMMDCalcFuncval(modename)
	String modename
	Prompt modename,"mode",popup,"TE;TM;HE"
	Wave MDparams	

	String cmd
	cmd="funcval_re=func_"+modename+"_re("+NameOfWave(MDparams)+",x,y)";Execute cmd
	cmd="funcval_im=func_"+modename+"_im("+NameOfWave(MDparams)+",x,y)";Execute cmd
	return(1)
End Macro

Proc JMMDShowFuncValGraphProc(scale)
	Variable scale=0.1
	PauseUpdate; Silent 1
	JMMDShowFuncvalGraph(scale)
End

Function JMMDShowFuncvalGraph(scale)
	Variable scale
	
	if(strsearch(WinList("*",";",""),"fgraph_re",0)<0)
		Display /W=(225,44,728,475); AppendImage funcval_re
		DoWindow/C fgraph_re
	else
		DoWindow/F fgraph_re
	Endif
	if(scale>0)
		ModifyImage funcval_re ctab= {-(scale),(scale),BlueBlackRed,0}
	else
		ModifyImage funcval_re ctab= {*,*,BlueBlackRed,0}
	endif

	if(strsearch(WinList("*",";",""),"fgraph_im",0)<0)
		Display /W=(728,44,1232,475); AppendImage funcval_im
		DoWindow/C fgraph_im
	else
		DoWindow/F fgraph_im
	Endif
	if(scale>0)
		ModifyImage funcval_im ctab= {-(scale),(scale),BlueBlackRed,0}
	else
		ModifyImage funcval_im ctab= {*,*,BlueBlackRed,0}
	endif
	return(0)
End

///////
// find solutions
///////
Proc JMMDGetBetaEpsGimProc0(modename,beta_ini,epsGim_ini,fquiet)
	Variable beta_ini=3,epsGim_ini=0.05,fquiet=1
	String modename
	Prompt modename,"mode",popup,"TE;TM;HE"
	Prompt beta_ini,"beta"
	prompt epsGim_ini,"epsGim"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate;Silent 1
	
	String cmd
	String savDF=GetDataFolder(1)
	SetDataFolder root:Packages:JMMetalloDielectric
	if(fquiet==2)
		cmd="FindRoots"
	else
		cmd="FindRoots/Q"
	endif
	cmd=cmd+"/X={"+num2str(beta_ini)+","+num2str(epsGim_ini)+"} func_"+modename+"_re,"+NameOfWave(MDparams)+",func_"+modename+"_im,"+NameOfWave(MDparams)
	Execute/Z cmd
	if(V_flag==0)
		MDparams[%'beta']=W_root[0]
		MDparams[%'epsGim']=W_root[1]
		MDparams[%'gain']=EpsToGain(cmplx(MDparams[%'epsG'],MDparams[%'epsGim']),MDparams[%'lambda'])
	else
		print "Root not fund. V_flag=",V_flag
		MDparams[%'beta']=0
		MDparams[%'epsGim']=0
		MDparams[%'gain']=0
	Endif
	SetDataFolder savDF // Restore current DF. 
End

Proc JMMDGetBetaEpsGimProc(modename,beta_ini,epsGim_ini)
	Variable beta_ini=3,epsGim_ini=0.05
	String modename=root:Packages:JMMetalloDielectric:g_modename
	Prompt modename,"mode",popup,"TE;TM;HE"
	Prompt beta_ini,"beta"
	prompt epsGim_ini,"epsGim"
//	Prompt fquiet,"quiet ?",popup,"yes;no"
	PauseUpdate;Silent 1
	JMMDGetBetaEpsGimProc0(modename,beta_ini,epsGim_ini,1)
	print "beta=",root:Packages:JMMetalloDielectric:MDparams[%'beta'],"imag(eg)=",root:Packages:JMMetalloDielectric:MDparams[%'epsGim']
End

Proc JMMDGetBetaGainCsrProc()
//	PauseUpdate;Silent 1
	Variable beta_ini=hcsr(A), epsGim_ini=vcsr(A)
	Variable beta0,epsGim,xx,yy
	String imgnm=CsrWave(A)
	String savDF=GetDataFolder(1)
	
	SetDataFolder root:Packages:JMMetalloDielectric
	JMMDGetBetaEpsGimProc(g_modename,beta_ini,epsGim_ini)
	beta0=MDparams[%'beta']
	epsGim=MDparams[%'epsGim']
	xx=(beta0 - DimOffset($imgnm ,0))/DimDelta($imgnm,0)
	yy=(epsGim - DimOffset($imgnm,1 ))/DimDelta($imgnm,1)
//	print xx,yy
//	Cursor/I A $(imgnm) xx,yy
	Cursor/I A $(imgnm) beta0,epsGim
	SetDataFolder savDF
End

Proc JMMDCalcBetaEpsGim2(wl,r,rout,epsG,epsS,epsM,epsMim,pp,modename,fshow)
//	Variable wl=816,n1=3.66,n2=3.56,radius=115,pp=1
	Variable wl=root:Packages:JMMetalloDielectric:MDparams[%'lambda'],r=root:Packages:JMMetalloDielectric:MDparams[%'r'],rout=root:Packages:JMMetalloDielectric:MDparams[%'rout']
	Variable epsG=root:Packages:JMMetalloDielectric:MDparams[%'epsG'],epsS=root:Packages:JMMetalloDielectric:MDparams[%'epsS']
	Variable epsM=root:Packages:JMMetalloDielectric:MDparams[%'epsM'],epsMim=root:Packages:JMMetalloDielectric:MDparams[%'epsMim']
	Variable pp=root:Packages:JMMetalloDielectric:MDparams[%'p']
	Variable fshow=1
	String modename=root:Packages:JMMetalloDielectric:g_modename
	Prompt wl,"wavelength (nm)"
	Prompt r,"NW radius (nm)"
	Prompt rout, "outer radius (nm)"
	Prompt epsG, "epsilon of NW"
	Prompt epsS, "epsilon of sheild"
	Prompt epsM, "real part of epsilon of metal"
	Prompt epsMim, "imag part of epsilon of metal"
	Prompt pp,"mode number"
	Prompt modename,"mode",popup,"TE;TM;HE"
	Prompt fshow,"Show function graph ?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	Variable beta_ini,epsGim_ini
	Variable autoAbortSecs
	root:Packages:JMMetalloDielectric:g_modename=modename
	JMMDSetMDparamsProc(wl,r,rout,epsG,epsS,epsM,epsMim,pp,modename,fshow)
	if (UserCursorAdjust("fgraph_im",autoAbortSecs) != 0)
		return -1 
	endif
	if (strlen(CsrWave(A))>0) 
// Cursors are on trace?
		Execute "JMMDGetBetaGainCsrProc()"
	endif 
End 
//	JMMDGetBetaEpsGim0(modename,beta_ini,epsGim_ini,1)
//End

// does not work 
Function JMMDGetBetaEpsGim(modename,beta_ini,epsGim_ini)
	Variable beta_ini,epsGim_ini
	String modename
	Prompt modename,"mode",popup,"TE;TM;HE"
	Prompt beta_ini,"beta"
	prompt epsGim_ini,"epsGim"

	Variable fquiet=1
	Wave MDparams
	Execute "JMMDGetBetaEpsGimProc(modename,beta_ini,epsGim_ini)"
//	print "beta=",root:Packages:JMMetalloDielectric:MDparams[%'beta'],"imag(eg)=",root:Packages:JMMetalloDielectric:MDparams[%'epsGim']
End
//

// Debugging
Proc JMMDGetMinimumGain0(modename)
	String modename=root:Packages:JMMetalloDielectric:g_modename
	Prompt modename,"mode",popup,"TE;TM;HE"
	PauseUpdate;Silent 1
	
	String cmd
	Variable beta_ini=3,epsGim_ini=0.05
	JMMDGetBetaEpsGim(modename,beta_ini,epsGim_ini)
End
//

// does not work
Function JMMDGetBetaGainCsr()
//	PauseUpdate;Silent 1
	SVAR g_modename
	Wave MDparams
	Variable beta_ini=hcsr(A), epsGim_ini=vcsr(A)
	Variable beta0,epsGim,xx,yy
	String imgnm=CsrWave(A)
	String savDF=GetDataFolder(1)
	
	SetDataFolder root:Packages:JMMetalloDielectric
	JMMDGetBetaEpsGim(g_modename,beta_ini,epsGim_ini)
	beta0=MDparams[%'beta']
	epsGim=MDparams[%'epsGim']
	xx=(beta0 - DimOffset($imgnm ,0))/DimDelta($imgnm,0)
	yy=(epsGim - DimOffset($imgnm,1 ))/DimDelta($imgnm,1)
//	print xx,yy
//	Cursor/I A $(imgnm) xx,yy
	Cursor/I A $(imgnm) beta0,epsGim
	SetDataFolder savDF
End

Function/C JMMDCalculateBessels(beta0,r0,ro0,wl,eg,es,em)
	Variable beta0,r0,ro0,wl
	Variable/C eg,es,em
//	Variable/C u,v,v2,w
	PauseUpdate; Silent 1
	Variable p,r,ro,beta2
	Wave/C MDbessels
	Wave MDparams
	
	String savDF= GetDataFolder(1)
	SetDataFolder root:Packages:JMMetalloDielectric
	
	r=r0/wl*2*pi
	ro=ro0/wl*2*pi
	beta2=beta0*beta0
	
	MDbessels[%'u'] =r *sqrt(eg-beta2);
	MDbessels[%'v'] =r *sqrt(beta2-es);
	MDbessels[%'v2']=ro*sqrt(beta2-es);
	MDbessels[%'w'] =ro*sqrt(beta2-em);
	
	p=MDparams[%'p']
	MDbessels[%'jmu']  = besselj(p,MDbessels[%'u']);
	MDbessels[%'kmv']  = besselk(p,MDbessels[%'v']);
	MDbessels[%'imv']  = besseli(p,MDbessels[%'v']);
	MDbessels[%'kmv2'] = besselk(p,MDbessels[%'v2']);
	MDbessels[%'imv2'] = besseli(p,MDbessels[%'v2']);
	MDbessels[%'kmw']  = besselk(p,MDbessels[%'w']);
	MDbessels[%'djmu'] =dCbesselj(p,MDbessels[%'u']);
	MDbessels[%'dkmv'] =dCbesselk(p,MDbessels[%'v']);
	MDbessels[%'dimv'] =dCbesseli(p,MDbessels[%'v']);
	MDbessels[%'dkmv2']=dCbesselk(p,MDbessels[%'v2']);
	MDbessels[%'dimv2']=dCbesseli(p,MDbessels[%'v2']);
	MDbessels[%'dkmw'] =dCbesselk(p,MDbessels[%'w']);
	
	SetDataFolder savDF
	return(1)
End

Function EpsToGain(eps,lambda)
	Variable/C eps
	Variable lambda
	return(4*pi*imag(sqrt(eps))/lambda)
End

////////////////////
//	create graph (vs R/Delta/R)

// as a function of r (radius of NW) with fixed Rout
Macro MD_NWRdep(rstart,rend,nstep,Rout,wvnm,wantToDisp)
	Variable rstart=root:Packages:JMMetalloDielectric:MDparams[%'r']
	Variable rend=root:Packages:JMMetalloDielectric:MDparams[%'rout']
	Variable rout=root:Packages:JMMetalloDielectric:MDparams[%'rout']
	Variable nstep=101
	Variable wantToDisp=1
	String wvnm="Rout"
	Prompt rstart,"starting NW radius"
	Prompt rend,"ending NW radius"
	Prompt nstep,"number of steps"
	Prompt Rout,"Rout (outer radius)"
	Prompt wvnm,"base wave name"
	Prompt wantToDisp,"Display graph ?",popup,"yes;no"
	PauseUpdate;Silent 1
	
	Variable i,rr,drr,beta_root,gain_root,epsGim_root,beta_ini,epsGim_ini
	String wvgain=wvnm+"_gain",wvbeta=wvnm+"_beta",wvepsgim=wvnm+"_epsGim"
	String modename=root:Packages:JMMetalloDielectric:g_modename
	
	root:Packages:JMMetalloDielectric:MDparams[%'rout']=Rout
	beta_ini=root:Packages:JMMetalloDielectric:MDparams[%'beta']
	epsGim_ini=root:Packages:JMMetalloDielectric:MDparams[%'epsGim']

	drr=(rend-rstart)/(nstep-1)
	Make/O/N=(nstep) $wvbeta,$wvgain,$wvepsgim
	SetScale/I x rstart,rend,$wvbeta,$wvgain,$wvepsgim
	do
		rr=rstart+drr*i
		root:Packages:JMMetalloDielectric:MDparams[%'r']=rr
//		JMMDSetMinMax(MDparams[%'epsG'],MDparams[%'epsS'])

//		JMMDSetMDparamsProc(wl,rr,rout,epsG,epsS,epsM,epsMim,pp,modename,2)
		JMMDGetBetaEpsGimProc0(modename,beta_ini,epsGim_ini,1)
		beta_root=root:Packages:JMMetalloDielectric:MDparams[%'beta']
		gain_root=root:Packages:JMMetalloDielectric:MDparams[%'gain']
		epsGim_root=root:Packages:JMMetalloDielectric:MDparams[%'epsGim']
		$wvbeta[i]=beta_root
		$wvgain[i]=gain_root
		$wvepsgim[i]=epsGim_root
		beta_ini=beta_root
		epsGim_ini=epsGim_root
		i+=1
	while(i<nstep)
	if(wantToDisp==1)
		Display $wvepsGim
		Append/R $wvbeta
		ModifyGraph gfSize=16
		ModifyGraph rgb($wvepsGim)=(0,0,65535)
	Endif
End

// calculate epsGim and gain as a function of thickness of dielectic shield with fixed Rout
Macro MD_Deltadep(dstart,dend,nstep,Rout,wvnm,wantToDisp)
	Variable dstart=root:Packages:JMMetalloDielectric:MDparams[%'rout']-root:Packages:JMMetalloDielectric:MDparams[%'r']
	Variable dend=100,nstep=101
	Variable Rout=root:Packages:JMMetalloDielectric:MDparams[%'rout']
	Variable wantToDisp=1
	String wvnm="Rout"
	Prompt dstart,"starting shield thickness"
	Prompt dend,"ending shield thickness"
	Prompt nstep,"number of steps"
	Prompt Rout,"Rout (outer radius)"
	Prompt wvnm,"base wave name"
	Prompt wantToDisp,"Display graph ?",popup,"yes;no"
	PauseUpdate;Silent 1
	
	Variable rr,i,dd,beta_root,gain_root,epsGim_root,beta_ini,epsGim_ini
	String wvgain=wvnm+"_gain",wvbeta=wvnm+"_beta",wvepsgim=wvnm+"_epsGim"
	String modename=root:Packages:JMMetalloDielectric:g_modename
	
	root:Packages:JMMetalloDielectric:MDparams[%'rout']=Rout
	beta_ini=root:Packages:JMMetalloDielectric:MDparams[%'beta']
	epsGim_ini=root:Packages:JMMetalloDielectric:MDparams[%'epsGim']
	
	dd=(dend-dstart)/(nstep-1)
	Make/O/N=(nstep) $wvbeta,$wvgain,$wvepsgim
	SetScale/I x dstart,dend,$wvbeta,$wvgain,$wvepsgim
	Rout=root:Packages:JMMetalloDielectric:MDparams[%'rout']
	Print "Rout=",Rout
	i=0
	do
		rr=Rout-(dstart+dd*i)
		root:Packages:JMMetalloDielectric:MDparams[%'r']=rr
//		JMMDSetMinMax(MDparams[%'epsG'],MDparams[%'epsS'])

//		JMMDSetMDparamsProc(wl,rr,rout,epsG,epsS,epsM,epsMim,pp,modename,2)
		JMMDGetBetaEpsGimProc0(modename,beta_ini,epsGim_ini,1)
		beta_root=root:Packages:JMMetalloDielectric:MDparams[%'beta']
		gain_root=root:Packages:JMMetalloDielectric:MDparams[%'gain']
		epsGim_root=root:Packages:JMMetalloDielectric:MDparams[%'epsGim']
		$wvbeta[i]=beta_root
		$wvgain[i]=gain_root
		$wvepsgim[i]=epsGim_root
		beta_ini=beta_root
		epsGim_ini=epsGim_root
		i+=1
	while(i<nstep)
	if(wantToDisp==1)
		Display $wvepsGim
		Append/R $wvbeta
		ModifyGraph gfSize=16
		ModifyGraph rgb($wvepsGim)=(0,0,65535)
	Endif
End

// calculate epsGim and gain as a function of Rout of dielectic shield with r
Macro MD_Routdep(rstart,rend,nstep,rr,wvnm,wantToDisp)
	Variable rstart=root:Packages:JMMetalloDielectric:MDparams[%'r']
	Variable rend=root:Packages:JMMetalloDielectric:MDparams[%'rout']
	Variable nstep=101
	Variable rr=root:Packages:JMMetalloDielectric:MDparams[%'r']
	String wvnm
	Variable wantToDisp=1
	Prompt rstart,"starting outer radius"
	Prompt rend,"ending outer radius"
	Prompt nstep,"number of steps"
	Prompt rr,"radius of NW"
	Prompt wvnm,"base wave name"
	Prompt wantToDisp,"Display graph ?",popup,"yes;no"
	PauseUpdate;Silent 1
	
	Variable i,rr0,drr,beta_root,gain_root,epsGim_root,beta_ini,epsGim_ini,rout
	String wvgain=wvnm+"_gain",wvbeta=wvnm+"_beta",wvepsgim=wvnm+"_epsGim"
	String modename=root:Packages:JMMetalloDielectric:g_modename
	
	root:Packages:JMMetalloDielectric:MDparams[%'r']=rr
	beta_ini=root:Packages:JMMetalloDielectric:MDparams[%'beta']
	epsGim_ini=root:Packages:JMMetalloDielectric:MDparams[%'epsGim']
	
	drr=(rend-rstart)/(nstep-1)
	Make/O/N=(nstep) $wvbeta,$wvgain,$wvepsgim
	SetScale/I x rstart,rend,$wvbeta,$wvgain,$wvepsgim
	do
		root:Packages:JMMetalloDielectric:MDparams[%'rout']=rstart+drr*i
//		JMMDSetMinMax(MDparams[%'epsG'],MDparams[%'epsS'])
//		JMMDSetMDparamsProc(wl,rr,rout,epsG,epsS,epsM,epsMim,pp,modename,2)
		JMMDGetBetaEpsGimProc0(modename,beta_ini,epsGim_ini,1)
		
		beta_root=root:Packages:JMMetalloDielectric:MDparams[%'beta']
		gain_root=root:Packages:JMMetalloDielectric:MDparams[%'gain']
		epsGim_root=root:Packages:JMMetalloDielectric:MDparams[%'epsGim']
		$wvbeta[i]=beta_root
		$wvgain[i]=gain_root
		$wvepsgim[i]=epsGim_root

		beta_ini=beta_root
		epsGim_ini=epsGim_root
		i+=1
	while(i<nstep)
	if(wantToDisp==1)
		Display $wvepsGim
		Append/R $wvbeta
		ModifyGraph gfSize=16
		ModifyGraph rgb($wvepsGim)=(0,0,65535)
	Endif
End

Macro MD_ShowFuncvalCsr0(type)
	Variable type=1
	Prompt type,"which variable",popup,"R;Delta;Rout"
	PauseUpdate; Silent 1
	
	String savDF= GetDataFolder(1)
	SetDataFolder root:Packages:JMMetalloDielectric
	String modename=root:Packages:JMMetalloDielectric:g_modename

	if(type==1)
		root:Packages:JMMetalloDielectric:MDparams[%'r']=hcsr(A)
	else
		if (type==2)
			root:Packages:JMMetalloDielectric:MDparams[%'r']=root:Packages:JMMetalloDielectric:MDparams[%'rout']-csr(A)
		else
			if(type==3)
				root:Packages:JMMetalloDielectric:MDparams[%'rout']=csr(A)
			endif
		endif
	endif
	JMMDCalcFuncval(modename)
	SetDataFolder savDF
End

Function UserCursorAdjust(graphName,autoAbortSecs)
	String graphName 
	Variable autoAbortSecs 
	DoWindow/F $graphName // Bring graph to front 
	if (V_Flag == 0) // Verify that graph exists 
		Abort "UserCursorAdjust: No such graph." 
		return -1 
	endif 
	NewPanel /K=2 /W=(187,368,437,531) as "Pause for Cursor" 
	DoWindow/C tmp_PauseforCursor // Set to an unlikely name 
	AutoPositionWindow/E/M=1/R=$graphName // Put panel near the graph 
	DrawText 21,20,"Adjust the cursors for initial value then" 
	DrawText 21,40,"press Continue." 
	Button button0,pos={80,58},size={92,20},title="Continue" 
	Button button0,proc=UserCursorAdjust_ContButtonProc
	Variable didAbort= 0 
	if( autoAbortSecs == 0 ) 
		PauseForUser tmp_PauseforCursor,$graphName 
	else
		SetDrawEnv textyjust= 1 
		DrawText 162,103,"sec" 
		SetVariable sv0,pos={48,97},size={107,15},title="Aborting in " 
		SetVariable sv0,limits={-inf,inf,0},value= _NUM:10 
		Variable td= 10,newTd 
		Variable t0= ticks 
		Do 
			newTd= autoAbortSecs - round((ticks-t0)/60) 
			if( td != newTd ) 
				td= newTd 
				SetVariable sv0,value= _NUM:newTd,win=tmp_PauseforCursor 
				if( td <= 10 )
					SetVariable sv0,valueColor= (65535,0,0),win=tmp_PauseforCursor 
				endif 
			endif 
			if( td <= 0 ) 
				DoWindow/K tmp_PauseforCursor 
				didAbort= 1 
				break 
			endif 
			PauseForUser/C tmp_PauseforCursor,$graphName 
		while(V_flag) 
	endif
	return didAbort 
End 

Function UserCursorAdjust_ContButtonProc(ctrlName) : ButtonControl 
	String ctrlName 
	DoWindow/K tmp_PauseforCursor
End 

