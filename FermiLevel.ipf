#pragma rtGlobals=1		// Use modern global access method.
#include "PhysicalConstants"
#include "MaterialParameters"
#include "BandGaps"

// Calculation of Fermi energy and carrier concentration in semiconductors
// requires FermiIntegral.xop
//
//	08/09/12 ver. 0.1a2 by J. Motohisa
//
//	revision history
//		08/09/12 ver 0.1a2
//		08/07/27 ver 0.1c1 initial version

Proc InitFermi()
	PauseUpdate;Silent 1
	String cmd,fermi_param_wave="fermi_param"
	
	String/G g_fermi_param_wave=fermi_param_wave
	Make/D/O/N=11 g_fermi_param_waves
// make waves
	cmd="Make/O/D/N=10 "+g_fermi_param_wave;execute cmd
	cmd="SetDimLabel 0,0,'temp' "+g_fermi_param_wave;execute cmd  // temperature
	cmd="SetDimLabel 0,1,'Egap' "+g_fermi_param_wave;execute cmd  // band gap energy
	cmd="SetDimLabel 0,2,'edos_CB' "+g_fermi_param_wave;execute cmd  // effective density of states in CB
	cmd="SetDimLabel 0,3,'Nd' "+g_fermi_param_wave;execute cmd  // donor density
	cmd="SetDimLabel 0,4,'Edonor' "+g_fermi_param_wave;execute cmd  // donor level (measured from CB edge)
	cmd="SetDimLabel 0,5,'g_D' "+g_fermi_param_wave;execute cmd  // donoe level degeneracy factor
	cmd="SetDimLabel 0,6,'edos_VB' "+g_fermi_param_wave;execute cmd  // effective density of states in CB
	cmd="SetDimLabel 0,7,'Na' "+g_fermi_param_wave;execute cmd  // donor density
	cmd="SetDimLabel 0,8,'Eacceptor' "+g_fermi_param_wave;execute cmd  // donor level (measured from CB edge)
	cmd="SetDimLabel 0,9,'g_A' "+g_fermi_param_wave;execute cmd  // donoe level degeneracy factor
	cmd="SetDimLabel 0,10,'Efermi' "+g_fermi_param_wave;execute cmd  // Fermi Level
	
	init_materials()
End Proc

Macro FermiLevelBulk(mat, temp, aND,aNA)
	Variable temp=300,aND=1e24,aNA=0
	String mat="GaAs"
	Prompt mat,"material",popup,"GaAs;"
	Prompt temp,"temperature"
	Prompt aND,"donor density (m^-3)"
	Prompt aNA,"acceptor density (m^-3)"	
	PauseUpdate; Silent 1

	Variable edos_CB,edos_VB,EFermi
	Variable e1,e2,eps,itr
	String paramv,fEg
	paramv="param_"+mat
	fEg="EgT_"+mat

	$g_fermi_param_wave[%'temp']=temp
	$g_fermi_param_wave[%'Egap']=$fEg(temp)
	$g_fermi_param_wave[%'edos_CB']=EffectiveDOS(temp,$paramv[%'ems_DOS_CB'])
	$g_fermi_param_wave[%'Nd']=aND
	$g_fermi_param_wave[%'Edonor']=$paramv[%'Edonor']
	$g_fermi_param_wave[%'g_D']=$paramv[%'g_D']
	$g_fermi_param_wave[%'edos_VB']=EffectiveDOS(temp,$paramv[%'ems_DOS_VB'])
	$g_fermi_param_wave[%'Na']=aNA
	$g_fermi_param_wave[%'Eacceptor']=$paramv[%'Eacceptor']
	$g_fermi_param_wave[%'g_A']=$paramv[%'g_A']
	
//	edos_CB=EffectiveDOS(temp,$paramv[%'ems_DOS_CB'])
//	edos_VB=EffectiveDOS(temp,$paramv[%'ems_DOS_VB'])

  //  printf("enter Nd (cm^-3),temperature(K): ");
  //  fscanf("",&aND,&temp);
  
  //  aND = aND*1.d6;
  //  EDonor = -6.d-3;
	FermiLevelBulk0()
End Macro

Function/D F_FermiLevelBulk0()
	Variable/D temp
	Silent 1;PauseUpdate
	Variable/D eps
	SVAR g_fermi_param_wave
//	e1 = -100.e-3;
//	e2 = 50.e0;
	eps = 1.e-7;
//	itr = 30;
	FindRoots/Q/B=1/T=(eps) f_charges,$g_fermi_param_wave
	return(V_root)
End Function

Macro FermiLevelBulk0()
	Variable/D temp
	Silent 1;PauseUpdate
	Variable/D eps
//	e1 = -100.e-3;
//	e2 = 50.e0;
	eps = 1.e-7;
//	itr = 30;
	FindRoots/Q/B=1/T=(eps) f_charges,$g_fermi_param_wave
	$g_fermi_param_wave[%'Efermi'] = V_root
	print "Fermi Energy =",V_root
	print "Electron conc.=",n_electron0($g_fermi_param_wave[%'temp'],V_root,$g_fermi_param_wave[%'edos_CB'])
	print "Hole conc.=",p_hole0($g_fermi_param_wave[%'temp'],-V_root-$g_fermi_param_wave[%'Egap'],$g_fermi_param_wave[%'edos_VB'])
	print "ionized donor conc.=",f_NDi($g_fermi_param_wave[%'temp'],V_root,$g_fermi_param_wave[%'Edonor'],$g_fermi_param_wave[%'g_D'])*$g_fermi_param_wave[%'Nd']
	print "ionized acceptor conc.=",f_NAi($g_fermi_param_wave[%'temp'],V_root,$g_fermi_param_wave[%'Eacceptor'],$g_fermi_param_wave[%'Egap'],$g_fermi_param_wave[%'g_A'])*$g_fermi_param_wave[%'Na']
End Macro

Macro SchottkyDiagram(mat,temp,aND,aNA)
	Variable temp=300,aND=1e24,aNA=0
	String mat="GaAs"
	Prompt mat,"material",popup,"GaAs;"
	Prompt temp,"temperature"
	Prompt aND,"donor density (m^-3)"
	Prompt aNA,"acceptor density (m^-3)"	
	PauseUpdate; Silent 1
	
	Variable edos_CB,edos_VB,EFermi,n_intrinsic,EFi
	Variable e1,e2,eps,itr
	String paramv,fEg
//	String w_ene,w_electron,w_hole,w_impurity
	paramv="param_"+mat
	fEg="EgT_"+mat

	$g_fermi_param_wave[%'temp']=temp
	$g_fermi_param_wave[%'Egap']=$fEg(temp)
	$g_fermi_param_wave[%'edos_CB']=EffectiveDOS(temp,$paramv[%'ems_DOS_CB'])
	$g_fermi_param_wave[%'Nd']=aND
	$g_fermi_param_wave[%'Edonor']=$paramv[%'Edonor']
	$g_fermi_param_wave[%'g_D']=$paramv[%'g_D']
	$g_fermi_param_wave[%'edos_VB']=EffectiveDOS(temp,$paramv[%'ems_DOS_VB'])
	$g_fermi_param_wave[%'Na']=aNA
	$g_fermi_param_wave[%'Eacceptor']=$paramv[%'Eacceptor']
	$g_fermi_param_wave[%'g_A']=$paramv[%'g_A']
	
//	n_intrinsic = F_FermiLevelBulk0()
	Efi=$g_fermi_param_wave[%'Egap']/2+g_KBC*$g_fermi_param_wave[%'temp']/g_EC/2*ln($g_fermi_param_wave[%'edos_VB']/$g_fermi_param_wave[%'edos_CB'])
	Make/D/O w_ene,w_electron,w_hole,w_impurity
	SetScale/I x, -Efi ,0.1,"eV",w_electron
	SetScale/I x,-$g_fermi_param_wave[%'Egap'],-Efi,w_hole
	SetScale/I x,-$g_fermi_param_wave[%'Egap']-0.1,0.1,w_impurity
	w_electron=n_electron0($g_fermi_param_wave[%'temp'],x,$g_fermi_param_wave[%'edos_CB'])
	w_hole = p_hole0($g_fermi_param_wave[%'temp'],-x-$g_fermi_param_wave[%'Egap'],$g_fermi_param_wave[%'edos_VB'])
	w_impurity  = f_NDi($g_fermi_param_wave[%'temp'],x,$g_fermi_param_wave[%'Edonor'],$g_fermi_param_wave[%'g_D'])*$g_fermi_param_wave[%'Nd']
	w_impurity -= f_NAi($g_fermi_param_wave[%'temp'],x,$g_fermi_param_wave[%'Eacceptor'],$g_fermi_param_wave[%'Egap'],$g_fermi_param_wave[%'g_A'])*$g_fermi_param_wave[%'Na']
	w_impurity = abs(w_impurity)
//	Display w_electron,w_hole,w_impurity
	ModifyGraph log(left)=1
	ModifyGraph rgb(w_impurity)=(1,4,52428)
End Macro


// Effective Density of States

Function/D EffectiveDOS(temp, ems_DOS)
	Variable/D temp,ems_DOS
	Variable a
	NVAR g_MEL,g_HBAR,g_KBC
	a=sqrt(ems_dos*g_MEL*temp*g_KBC/(2*PI))/g_HBAR
	return(2*a*a*a)
End Function

///* Electron concentration : ene = Ec -EF */
Function/D n_electron0(temp, ene, effdos)
	Variable temp,ene,effdos
	Variable eta
	NVAR g_KBC,g_EC
	eta = ene*g_EC/(g_KBC*temp)
	return(effdos*FermiIntegralpHalf(eta))
End Function

Function n_electron(mat,temp, ene)
	Variable temp,ene
	String mat

	String paramv="param_"+mat
	Variable effdos,ems_DOS
	Wave paramwv=$paramv
	ems_DOS=paramwv[%'ems_DOS_CB']
	effdos=EffectiveDOS(temp, ems_DOS)
	return(n_electron0(temp,ene,effdos))
End Function

// Hole concentration : ene = Ev-EF =Ec - Eg - EF
Function p_hole0(temp, ene, effdos)
	Variable temp,ene,effdos
	Variable eta
	NVAR g_KBC,g_EC
	eta = ene*g_EC/(g_KBC*temp)
	return(effdos*FermiIntegralpHalf(eta))
End Function

Function p_hole(mat,temp, ene)
	Variable temp,ene
	String mat
	
	String paramv="param_"+mat
	Variable effdos,ems_DOS,bandgap
	Wave paramwv=$paramv
	ems_DOS=paramwv[%'ems_DOS_VB']
	bandgap=paramwv[%'Eg']
	return(p_hole0(temp,-bandgap-ene,effdos))
End Function

//* Hole concentration (2) : ene = Ev-EF, Ev is take as the reference */
Function p_hole2(temp, ene,ems_DOS)
	Variable temp,ene,ems_DOS
	Variable effdos
	effdos=EffectiveDOS(temp, ems_dos);
	return(p_hole0(temp,-ene,effdos));
End Function

Function Fermi_Dirac(temp, ene)
	Variable temp,ene
	NVAR g_KBC,g_EC
	return(1/(1+exp(ene*g_EC/(temp*g_KBC))));
End Function

Function f_NDi(temp,Efermi,Edonor,g_D)
	Variable temp,Efermi,Edonor,g_D
	Variable a
	NVAR g_KBC,g_EC
	a=(Efermi+Edonor)*g_EC/(g_KBC*temp)
	return(1/(1+g_D*exp(a)))
End Function
  
Function f_NAi(temp,Efermi,Eaccept,Egap,g_A)
	Variable temp,Efermi,Eaccept,Egap,g_A
	Variable a
	NVAR g_KBC,g_EC
	a=(Efermi+Egap-Eaccept)*g_EC/(g_KBC*temp)
	return(1/(1+g_A*exp(-a)))
End Function

Function n_intrinsic(temp, ems_dos_CV, ems_dos_VB, Eg)
	Variable temp,ems_dos_CV,ems_dos_VB,Eg
	NVAR g_EC,g_KBC
	return(sqrt(ems_dos_CV*ems_dos_VB)*exp(-Eg*g_EC/(2*g_KBC*temp)))
End Function

Function f_charges0(temp,Ene,Egap,edos_CB,Nd,Edonor,g_D,edos_VB,Na,Eacceptor,g_A)
	Variable temp,Ene,Egap,edos_CB,Nd,Edonor,g_D,edos_VB,Na,Eacceptor,g_A
	Variable a,b
	a=Nd*f_NDi(temp,Ene,Edonor,g_D)+p_hole0(temp, -Ene-Egap, edos_VB)
	b=Na*f_NAi(temp,Ene,Eacceptor,Egap,g_A)+n_electron0(temp,Ene,edos_CB)
	return(a-b)
End Function

Function/D f_charges(w,ene)
	wave w
	variable ene
	return(f_charges0(w[%'temp'],Ene,w[%'Egap'],w[%'edos_CB'],w[%'Nd'],w[%'Edonor'],w[%'g_D'],w[%'edos_VB'],w[%'Na'],w[%'Eacceptor'],w[%'g_A']))
End Function

