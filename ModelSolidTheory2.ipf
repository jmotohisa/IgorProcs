#pragma rtGlobals=1		// Use modern global access method.

// ModelSolidTheory2.ipf
//
// Procedure for calculation of the band line-ups in heterostructures
// based on Model Solid Theory (C. van de Walle, PRB 39, 1871 (1989).)
//   note: This procedure is not compatible with previouis "ModelSolidTheory.ipf" 
//			because of the globals defined in the latter.
//
//	05/12/21 ver. 0.2a by J. Motohisa
//
//	revision history
//		05/12/01 ver. 0.1a: first version
//		05/12/21 ver. 0.2a:Macro for strained GaInP QW added

#include "HOrbitalStrain"
#include "MaterialParameters"
#include "Bandgaps"

Macro init_MST(wv,sw)
	String wv="tempwv",sw="strainwv"
	Prompt wv, "wave name for results"
	Prompt sw, "Wave name for strore strain tensor"
	PauseUpdate;Silent 1
	
	String/G g_wv=wv,g_sw=sw
	Make/O/D/N=4 $wv
	Make/O/D/N=6 $sw
	init_materials()
End

// band alignment for given strain tensor
// default parameters are for InAs@0K and (001) surface
Macro BandAlignmentMST(wv,th,Ev_avr,Eg,delta,ac,av,bb,dd,sw)
	String wv=g_wv,sw=g_sw
	Variable th=pi/2
	Variable Ev_avr=-6.67,Eg=0.42,delta=0.38,ac=-5.08,av=1.00,bb=-1.55,dd=-3.10
	Prompt wv,"Wave name for results"
	Prompt th,"substrate orientation (angle,rad)"
	Prompt Ev_avr,"Ev_avr (without strain)"
	Prompt Eg,"Bandgap"
	Prompt delta,"delta"
	Prompt ac,"deformation potential ac"
	Prompt av,"deformation potential av"
	Prompt bb,"deformation potential b"
	Prompt dd,"deformation potential d"
	Prompt sw,"Strain Tensor wave name"
	PauseUpdate;Silent 1

	Variable dEv_avr,etemp
	OSHamiltonian_Eigv_cc(wv,th,av,bb,dd,delta,sw)
	dEv_avr=Ev_avr+av*($sw[0]+$sw[1]+$sw[2])
	$wv+=dEv_avr
	$wv[3]=Ev_avr+delta/3+Eg+ac*($sw[0]+$sw[1]+$sw[2])
	if($sw[0]>0)
		etemp=$wv[0]
		$wv[0]=$wv[1]
		$wv[1]=etemp
	endif
End

// band aligment for Ga_xIn_{1-x}As with biaxial strain
Macro BandAlignmentMST_GaInAsQW(wv,xGa,th,temp,a0_sub,sw)
	String wv=g_wv,sw=g_sw
	Variable xGa=0,th=pi/2,temp=0,a0_sub=param_GaAs[%'a0']
	Prompt wv,"Wave name for results"
	Prompt xGa,"Ga content"
	Prompt th,"substrate orientation (angle,rad)"
	Prompt temp,"temperature (K)"
	Prompt a0_sub,"lattice constant of substrate (A)"
	Prompt sw,"Strain Tensor wave name"
	PauseUpdate;Silent 1
	
	Variable a0,epsxx,c11,c12,c44,delta0,Ev_avr,Eg,ac,av,bb,dd
//	String sw="strainwv2"
	
//	Parameter for Ga_xIn_{1-x}As
	a0=ParamTernAlloy(xGa,param_GaAs[%a0],param_InAs[%a0],0)
	c11=ElasticStiffnessTernAlloy(xGa,param_GaAs[%'c11'],param_GaAs[%'a0'],param_InAs[%'c11'],param_InAs[%'a0'])
	c12=ElasticStiffnessTernAlloy(xGa,param_GaAs[%'c12'],param_GaAs[%'a0'],param_InAs[%'c12'],param_InAs[%'a0'])
	c44=ElasticStiffnessTernAlloy(xGa,param_GaAs[%'c44'],param_GaAs[%'a0'],param_InAs[%'c44'],param_InAs[%'a0'])
	ac=ParamTernAlloy(xGa,param_GaAs[%'ac'],param_InAs[%'ac'],0)
	av=ParamTernAlloy(xGa,param_GaAs[%'av'],param_InAs[%'av'],0)
	bb=ParamTernAlloy(xGa,param_GaAs[%'b'] ,param_InAs[%'b'] ,0)
	dd=ParamTernAlloy(xGa,param_GaAs[%'d'] ,param_InAs[%'d'] ,0)
	Eg=EgdT_GaInAs(xGa,temp) // temperature dependent bandgap is used
//	Eg=param_InAs[%Eg]
	delta0=ParamTernAlloy(xGa,param_GaAs[%'delta'],param_InAs[%'delta'],0)
	Ev_Avr=FEvAvr(xGa,param_GaAs[%'Evavr'],param_GaAs[%'a0'],param_GaAs[%'av'],param_InAs[%'Evavr'],param_InAs[%'a0'],param_InAs[%'av'])
//	Ev_avr=(1-xGa)*(Ev_avr_InAs)+(xGa)*(Ev_avr_GaAs)+3*xGa*(1-xGa)*(-av_GaAs+av_InAs)*(a0_GaAs-a0_InAs)/a0

	epsxx=(a0_sub-a0)/a0
//	print a0,a0_sub,epsxx
//	print th,c11,c12,c44,dd_cubic(th,c11,c12,c44),gg_cubic(th,c11,c12,c44)
	Strain_Biaxial(sw,epsxx,dd_cubic(th,c11,c12,c44),gg_cubic(th,c11,c12,c44))
	BandAlignmentMST(wv,th,Ev_avr,Eg,delta0,ac,av,bb,dd,sw)
End

// band aligment for Ga_xIn_{1-x}P with biaxial strain
Macro BandAlignmentMST_GaInPQW(wv,xGa,th,temp,a0_sub,sw)
	String wv=g_wv,sw=g_sw
	Variable xGa=0,th=pi/2,temp=0,a0_sub=param_GaP[%'a0']
	Prompt wv,"Wave name for results"
	Prompt xGa,"Ga content"
	Prompt th,"substrate orientation (angle,rad)"
	Prompt temp,"temperature (K)"
	Prompt a0_sub,"lattice constant of substrate (A)"
	Prompt sw,"Strain Tensor wave name"
	PauseUpdate;Silent 1
	
	Variable a0,epsxx,c11,c12,c44,delta0,Ev_avr,Eg,ac,av,bb,dd
//	String sw="strainwv2"
	
//	Parameter for Ga_xIn_{1-x}P
	a0=ParamTernAlloy(xGa,param_GaP[%a0],param_InP[%a0],0)
	c11=ElasticStiffnessTernAlloy(xGa,param_GaP[%'c11'],param_GaP[%'a0'],param_InP[%'c11'],param_InP[%'a0'])
	c12=ElasticStiffnessTernAlloy(xGa,param_GaP[%'c12'],param_GaP[%'a0'],param_InP[%'c12'],param_InP[%'a0'])
	c44=ElasticStiffnessTernAlloy(xGa,param_GaP[%'c44'],param_GaP[%'a0'],param_InP[%'c44'],param_InP[%'a0'])
	ac=ParamTernAlloy(xGa,param_GaP[%'ac'],param_InP[%'ac'],0)
	av=ParamTernAlloy(xGa,param_GaP[%'av'],param_InP[%'av'],0)
	bb=ParamTernAlloy(xGa,param_GaP[%'b'] ,param_InP[%'b'] ,0)
	dd=ParamTernAlloy(xGa,param_GaP[%'d'] ,param_InP[%'d'] ,0)
	Eg=Egd_GaInP(xGa)-Egd_GaInP(0)+EgT_InP(temp) // temperature INdependent bandgap is used	
//	Eg=EgdT_GaInP(xGa,temp) // temperature dependent bandgap is used
//	Eg=param_InP[%Eg]
	delta0=ParamTernAlloy(xGa,param_GaP[%'delta'],param_InP[%'delta'],0)
	Ev_Avr=FEvAvr(xGa,param_GaP[%'Evavr'],param_GaP[%'a0'],param_GaP[%'av'],param_InP[%'Evavr'],param_InP[%'a0'],param_InP[%'av'])
//	Ev_avr=(1-xGa)*(Ev_avr_InP)+(xGa)*(Ev_avr_GaP)+3*xGa*(1-xGa)*(-av_GaP+av_InP)*(a0_GaP-a0_InP)/a0

	epsxx=(a0_sub-a0)/a0
//	print a0,a0_sub,epsxx
//	print th,c11,c12,c44,dd_cubic(th,c11,c12,c44),gg_cubic(th,c11,c12,c44)
	Strain_Biaxial(sw,epsxx,dd_cubic(th,c11,c12,c44),gg_cubic(th,c11,c12,c44))
	BandAlignmentMST(wv,th,Ev_avr,Eg,delta0,ac,av,bb,dd,sw)
End

// band aligment for GaAs{y}P{1-y} with biaxial strain
Macro BandAlignmentMST_GaAsPQW(wv,yAs,th,temp,a0_sub,sw)
	String wv=g_wv,sw=g_sw
	Variable yAs=0,th=pi/2,temp=0,a0_sub=param_GaP[%'a0']
	Prompt wv,"Wave name for results"
	Prompt yAs,"Ga content"
	Prompt th,"substrate orientation (angle,rad)"
	Prompt temp,"temperature (K)"
	Prompt a0_sub,"lattice constant of substrate (A)"
	Prompt sw,"Strain Tensor wave name"
	PauseUpdate;Silent 1
	
	Variable a0,epsxx,c11,c12,c44,delta0,Ev_avr,Eg,ac,av,bb,dd
//	String sw="strainwv2"
	
//	Parameter for Ga_xIn_{1-x}P
	a0=ParamTernAlloy(yAs,param_GaAs[%a0],param_GaP[%a0],0)
	c11=ElasticStiffnessTernAlloy(yAs,param_GaAs[%'c11'],param_GaAs[%'a0'],param_GaP[%'c11'],param_GaP[%'a0'])
	c12=ElasticStiffnessTernAlloy(yAs,param_GaAs[%'c12'],param_GaAs[%'a0'],param_GaP[%'c12'],param_GaP[%'a0'])
	c44=ElasticStiffnessTernAlloy(yAs,param_GaAs[%'c44'],param_GaAs[%'a0'],param_GaP[%'c44'],param_GaP[%'a0'])
	ac=ParamTernAlloy(yAs,param_GaAs[%'ac'],param_GaP[%'ac'],0)
	av=ParamTernAlloy(yAs,param_GaAs[%'av'],param_GaP[%'av'],0)
	bb=ParamTernAlloy(yAs,param_GaAs[%'b'] ,param_GaP[%'b'] ,0)
	dd=ParamTernAlloy(yAs,param_GaAs[%'d'] ,param_GaP[%'d'] ,0)
	Eg=Egd_GaAsP(yAs)-Egd_GaAsP(1)+EgT_GaAs(temp) // temperature INdependent bandgap is used	
//	Eg=EgdT_GaInP(yAs,temp) // temperature dependent bandgap is used
//	Eg=param_InP[%Eg]
	delta0=ParamTernAlloy(yAs,param_GaAs[%'delta'],param_GaP[%'delta'],0)
	Ev_Avr=FEvAvr(yAs,param_GaAs[%'Evavr'],param_GaAs[%'a0'],param_GaAs[%'av'],param_GaP[%'Evavr'],param_GaP[%'a0'],param_GaP[%'av'])
//	Ev_avr=(1-yAs)*(Ev_avr_InP)+(yAs)*(Ev_avr_GaP)+3*yAs*(1-yAs)*(-av_GaP+av_InP)*(a0_GaP-a0_InP)/a0

	epsxx=(a0_sub-a0)/a0
//	print a0,a0_sub,epsxx
//	print th,c11,c12,c44,dd_cubic(th,c11,c12,c44),gg_cubic(th,c11,c12,c44)
	Strain_Biaxial(sw,epsxx,dd_cubic(th,c11,c12,c44),gg_cubic(th,c11,c12,c44))
	BandAlignmentMST(wv,th,Ev_avr,Eg,delta0,ac,av,bb,dd,sw)
End



// calculate band offset from the position of each band
// substrate is not strained

// calculated for a wave with name specified by "wv"
Proc BandOffset_MST0(g_wvCV,Ev_avr_sub,Eg_sub,delta0_sub)
	String wv=g_wv
	Variable Ev_avr_sub=param_GaAs[%'Evavr'],Eg_sub=param_GaAs[%'Eg'],delta0_sub=param_GaAs[%'delta'] // GaAs
//	Variable Ev_avr_sub=param_InP[%'Evavr'],Eg_sub=param_InP[%'Eg'],delta0_sub=param_InP[%'delta'] // InP
	PauseUpdate;Silent 1
	
	$wv[0] -= (Ev_avr_sub+delta0_sub/3)
	$wv[1] -= (Ev_avr_sub+delta0_sub/3)
	$wv[2] -= (Ev_avr_sub-delta0_sub*2/3)
	$wv[3] -= (Ev_avr_sub+delta0_sub/3+Eg_sub)
End

// Calculated for given wave names
Proc BandOffset_MST(wvCV,wvHH,wvLH,wvSO,Ev_avr_sub,Eg_sub,delta0_sub)
	String wvCV,wvHH,wvLH,wvSO
	Variable Ev_avr_sub=param_GaAs[%'Evavr'],Eg_sub=param_GaAs[%'Eg'],delta0_sub=param_GaAs[%'delta'] // GaAs
//	Variable Ev_avr_sub=param_InP[%'Evavr'],Eg_sub=param_InP[%'Eg'],delta0_sub=param_InP[%'delta'] // InP
	PauseUpdate;Silent 1
	
	$wvHH-= (Ev_avr_sub+delta0_sub/3)
	$wvLH-= (Ev_avr_sub+delta0_sub/3)
	$wvSO-= (Ev_avr_sub-delta0_sub*2/3)
	$wvCV-=(Ev_avr_sub+delta0_sub/3+Eg_sub)
End

// band offset: substrate is GaAs
Proc BandOffset_sub_GaAs(wvCV,wvHH,wvLH,wvSO, Eg_sub)
	String wvCV,wvHH,wvLH,wvSO
	Variable Eg_sub=param_GaAs[%'Eg']
	PauseUpdate;Silent 1
	
	$wvHH-= (param_GaAs[%'Evavr'] + param_GaAs[%'delta']/3)
	$wvLH-= (param_GaAs[%'Evavr'] + param_GaAs[%'delta']/3)
	$wvSO-= (param_GaAs[%'Evavr'] - param_GaAs[%'delta']*2/3)
	$wvCV-= (param_GaAs[%'Evavr'] + param_GaAs[%'delta']/3 + Eg_sub)
End

// band offset: substrate is InP
Proc BandOffset_sub_InP(wvCV,wvHH,wvLH,wvSO, Eg_sub)
	String wvCV,wvHH,wvLH,wvSO
	Variable Eg_sub=param_InP[%'Eg']
	PauseUpdate;Silent 1
	
	$wvHH-= (param_InP[%'Evavr'] + param_InP[%'delta']/3)
	$wvLH-= (param_InP[%'Evavr'] + param_InP[%'delta']/3)
	$wvSO-= (param_InP[%'Evavr'] - param_InP[%'delta']*2/3)
	$wvCV-= (param_InP[%'Evavr'] + param_InP[%'delta']/3 + Eg_sub)
End

// Ev_avr in Model Solid Theory
Function/D FEvAvr(xx,Ev1,aa1,av1,Ev2,aa2,av2)
	Variable xx,Ev1,aa1,av1,Ev2,aa2,av2
	Return(xx*Ev1+(1-xx)*Ev2+3*xx*(1-xx)*(-av1+av2)*(aa1-aa2)/paramTernAlloy(xx,aa1,aa2,0))
End

///// template for calculation of alloy-contentn dependence
Proc content_dependence_template()
	PauseUpdate;silent 1
	Variable i,npoint,xGa
	Make/O/D Elh_GaInP, Ehh_GaInP,ESO_GaInP,Ec_GaInP,dElh_GaInP,dEhh_GaInP,dESO_GaInP,dEc_GaInP,Eg_GaInP_unstrained,Eghh_GaInP,Eglh_GaInP
	SetScale/I x 0,0.3,"",Elh_GaInP, Ehh_GaInP,ESO_GaInP,Ec_GaInP,dElh_GaInP,dEhh_GaInP,dESO_GaInP,dEc_GaInP,Eg_GaInP_unstrained,Eghh_GaInP,Eglh_GaInP
	SetScale d 0,0,"eV",Elh_GaInP, Ehh_GaInP,ESO_GaInP,Ec_GaInP,dElh_GaInP,dEhh_GaInP,dESO_GaInP,dEc_GaInP,Eg_GaInP_unstrained,Eghh_GaInP,Eglh_GaInP

	i=0;npoint=DimSize(Elh_GaInP,0)
	do
		xGa=i*DimDelta(Elh_GaInP,0)+DimOffset(Elh_GaInP,0)
		BandAlignmentMST_GaInPQW("tempwv",xGa,atan(1/sqrt(2)),0,param_InP[%a0],"strainwv")
		Elh_GaInP[i]=tempwv[0]
		Ehh_GaInP[i]=tempwv[1]
		ESO_GaInP[i]=tempwv[2]
		Ec_GaInP[i]=tempwv[3]
		i+=1
	while(i<npoint)
	dElh_GaInP=(param_InP[%Evavr]+param_InP[%delta]/3)-Elh_GaInP
	dEhh_GaInP=(param_InP[%Evavr]+param_InP[%delta]/3)-Ehh_GaInP
	dESO_GaInP=(param_InP[%Evavr]-2*param_InP[%delta]/3)-ESO_GaInP
	dEc_GaInP=Ec_GaInP-(param_InP[%Evavr]+param_InP[%delta]/3+EgT_InP(0))
	Eg_GaInP_unstrained=Egd_GaInP(x)-Egd_GaInP(0)+EgT_InP(0)
	Eghh_GaInP=Ec_GaInP-Ehh_GaInP
	Eglh_GaInP=Ec_GaInP-Elh_GaInP
	Display Elh_GaInP, Ehh_GaInP,ESO_GaInP,Ec_GaInP
	Display dElh_GaInP,dEhh_GaInP,dESO_GaInP,dEc_GaInP
	Display Eg_GaInP_unstrained,Eghh_GaInP,Eglh_GaInP
End
////////////////////////////////

////////////////////////////////////////////// under debug
// some special orientation
Macro BandAlignmentMST111(wv,Ev_avr,Eg,delta,ac,av,bb,dd,sw)
	String wv="tempwv",sw="strainwv"
	Variable Ev_avr=-6.67,Eg=0.4105,delta=0.38,ac=-5.08,av=1.00,bb=-1.55,dd=-3.10
	Prompt wv,"Wave name for results"
	Prompt Ev_avr,"Ev_avr"
	Prompt Eg,"Bandgap"
	Prompt delta,"delta"
	Prompt ac,"deformation potential ac"
	Prompt av,"deformation potential av"
	Prompt bb,"deformation potential b"
	Prompt dd,"deformation potential d"
	Prompt sw,"Strain Tensor wave name"
	PauseUpdate;Silent 1
//	Ev_avr_InAs:= -6.67; delta0_InAs:= 0.38; Eg_InAs:= 0.4105
//	ac_InAs:= -5.08; av_InAs:= 1.00; b_InAs:= -1.55; d_InAs:= -3.10;
	
	Variable pp,qq,rr,ss,dEv_avr
	pp=p_epsilon111(av,bb,dd,$sw[0],$sw[1],$sw[2],$sw[3],$sw[4],$sw[5])
	qq=q_epsilon111(av,bb,dd,$sw[0],$sw[1],$sw[2],$sw[3],$sw[4],$sw[5])
	rr=r_epsilon111(av,bb,dd,$sw[0],$sw[1],$sw[2],$sw[3],$sw[4],$sw[5])
	ss=s_epsilon111(av,bb,dd,$sw[0],$sw[1],$sw[2],$sw[3],$sw[4],$sw[5])
//	print pp,qq,rr,ss
	OSHamiltonian111ccorig(wv,pp,qq,rr,ss,delta)
	dEv_avr=Ev_avr+av*($sw[0]+$sw[1]+$sw[2])
	$wv+=dEv_avr
	$wv[3]=Ev_avr+delta/3+Eg+ac*($sw[0]+$sw[1]+$sw[2])
End
