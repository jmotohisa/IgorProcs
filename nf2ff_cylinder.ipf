#pragma rtGlobals=1		// Use modern global access method.
//#include "matrixOperations2"
#include "JMGeneralTextDataLoad2"

// Since t-depdnence is exp(j*ometa*t) (not exp(-j*omega*t) ) in meep, 
// "i" should be replaced with "-i" in nf2ff routine.
//  and field should be complex.
// as of January 6, 2012, bugs are not fixed yet

Macro init_NF2FFCylinder(res,padr,padz)
	Variable padr=51,padz=50,res=50
	Prompt res,"resolution"
	Prompt padr,"R0 position from PML"
	Prompt padz,"Z1/Z2 position from PML"
	PauseUpdate; Silent 1
	
	Variable index=0
	Variable nz,nr,dpml=1
	String wlist="er;ep;ez;hr;hp;hz",wv 
	do
		wv=StringFromList(index,wlist,";")	
		if(exists(wv))
			nz=DimSize($wv,0)
			nr=DimSize($wv,1)
			SetScale/I x -nz/2/res,nz/2/res,"",$wv
			SetScale/I y 0,nr/res,"", $wv		
		endif
		index+=1
	while(index<6)
	
	Make/O/N=13 param
	SetDimLabel 0,0,'k0',param
	SetDimLabel 0,1,'res',param
	SetDimLabel 0,2,'padz',param
	SetDimLabel 0,3,'padr',param
	SetDimLabel 0,4,'nz1',param
	SetDimLabel 0,5,'nz2',param
	SetDimLabel 0,6,'nrr',param
	SetDimLabel 0,7,'dr',param
	SetDimLabel 0,8,'dz',param
	SetDimLabel 0,9,'R0',param
	SetDimLabel 0,10,'nz',param
	SetDimLabel 0,11,'nr',param
	SetDimLabel 0,12,'dpml',param

	Variable k0=2*pi/(850/150)
	Variable,nz1,nz2,nrr,dr,dz,R0
	padz=padz+dpml*res
	padr=padr+dpml*res
	nz1=padz
	nz2=nz-padz
	nrr=nr-padr
	dr=DimDelta(er,1)
	dz=DimDelta(er,0)
	R0=dr*nrr

	param[%'k0']=k0
	param[%'res']=res
	param[%'padz']=padz
	param[%'padr']=padr
	param[%'nz1']=nz1
	param[%'nz2']=nz2
	param[%'nrr']=nrr
	param[%'dr']=dr
	param[%'dz']=dz
	param[%'R0']=R0
	param[%'nr']=nr
	param[%'nz']=nz
	param[%'dpml']=dpml
	MakeWaves()
	
// initializer for check routine
	nameWavesForDebug()
	CheckNL0IntegInit()
	CheckNL12IntegInit()
End

Function MakeWaves()
//	PauseUpdate; Silent 1
	Variable nw=91
	Make/O/D/C/N=(nw) Ntheta0res,Ntheta1res,Ntheta2res
	Make/O/D/C/N=(nw) Nphi0res,Nphi1res,Nphi2res
	Make/O/D/C/N=(nw)Ltheta0res,Ltheta1res,Ltheta2res
	Make/O/D/C/N=(nw) Lphi0res,Lphi1res,Lphi2res
	
	Make/O/D/N=(nw) Ntheta0_re,Ntheta1_re,Ntheta2_re
	Make/O/D/N=(nw) Nphi0_re,Nphi1_re,Nphi2_re
	Make/O/D/N=(nw) Ltheta0_re,Ltheta1_re,Ltheta2_re
	Make/O/D/N=(nw) Lphi0_re,Lphi1_re,Lphi2_re

	Make/O/D/N=(nw) Ntheta0_im,Ntheta1_im,Ntheta2_im
	Make/O/D/N=(nw) Nphi0_im,Nphi1_im,Nphi2_im
	Make/O/D/N=(nw) Ltheta0_im,Ltheta1_im,Ltheta2_im
	Make/O/D/N=(nw) Lphi0_im,Lphi1_im,Lphi2_im
	
	Make/O/D/N=(nw) rcs
	
	SetScale/I x 0,90,"", Ntheta0res,Ntheta1res,Ntheta2res,Nphi0res,Nphi1res,Nphi2res
	SetScale/I x 0,90,"", Ltheta0res,Ltheta1res,Ltheta2res,Lphi0res,Lphi1res,Lphi2res
	SetScale/I x 0,90,"", Ntheta0_re,Ntheta1_re,Ntheta2_re,Nphi0_re,Nphi1_re,Nphi2_re
	SetScale/I x 0,90,"", Ltheta0_re,Ltheta1_re,Ltheta2_re,Lphi0_re,Lphi1_re,Lphi2_re
	SetScale/I x 0,90,"", Ntheta0_im,Ntheta1_im,Ntheta2_im,Nphi0_im,Nphi1_im,Nphi2_im
	SetScale/I x 0,90,"", Ltheta0_im,Ltheta1_im,Ltheta2_im,Lphi0_im,Lphi1_im,Lphi2_im,rcs
End

Function nameWavesForDebug()
	Make/O/T/N=9 Ntheta0Load,Ntheta1Load,Ntheta2Load
	Ntheta0Load[0]=""
	Ntheta0Load[1]="Ntheta0re"
	Ntheta0Load[2]="Ntheta0im"
	Ntheta0Load[3]="Lphi0re"
	Ntheta0Load[4]="Lphi0im"
	Ntheta0Load[5]="Nphi0re"
	Ntheta0Load[6]="Nphi0im"
	Ntheta0Load[7]="Ltheta0re"
	Ntheta0Load[8]="Ltheta0im"

	Ntheta1Load[0]=""
	Ntheta1Load[1]="Ntheta1re"
	Ntheta1Load[2]="Ntheta1im"
	Ntheta1Load[3]="Lphi1re"
	Ntheta1Load[4]="Lphi1im"
	Ntheta1Load[5]="Nphi1re"
	Ntheta1Load[6]="Nphi1im"
	Ntheta1Load[7]="Ltheta1re"
	Ntheta1Load[8]="Ltheta1im"

	Ntheta2Load[0]=""
	Ntheta2Load[1]="Ntheta2re"
	Ntheta2Load[2]="Ntheta2im"
	Ntheta2Load[3]="Lphi2re"
	Ntheta2Load[4]="Lphi2im"
	Ntheta2Load[5]="Nphi2re"
	Ntheta2Load[6]="Nphi2im"
	Ntheta2Load[7]="Ltheta2re"
	Ntheta2Load[8]="Ltheta2im"
End

Macro SetPads(padr,padz)
	Variable padr=51,padz=50
	Prompt padr,"R0 position from PML"
	Prompt padz,"Z1/Z2 position from PML"
	PauseUpdate; Silent 1;
	
	Variable res=param[%'res'],dpml=param[%'dpml'],nz=param[%'nz'],nr=param[%'nr']
	Variable dr=param[%'dr']
//	nz=DimSize(er,0)
//	nr=DimSize(er,1)
	padz=padz+res*dpml
	padr=padr+res*dpml
	param[%'padz']=padz
	param[%'padr']=padr
	param[%'nz1']=padz
	param[%'nz2']=nz-padz
	param[%'nrr']=nr-padr
	param[%'R0']=(nr-padr)*dr
End

//// basic function for integration
Function/C/D integZ(wv,theta,k0,R0,mm)
	Wave wv
	Variable theta,k0,R0,mm

	Wave tmp2,tmp3
	Variable i1,i2,bj,rr0
	
	Duplicate/O wv,tmp2,tmp3
	rr0=k0*R0*sin(theta*Pi/180)
	bj=besselJ(mm,rr0)
	tmp2=wv*cos(k0*x*cos(theta*pi/180))*bj
	tmp3=wv*sin(k0*x*cos(theta*pi/180))*bj
	i1=area(tmp2)
	i2=area(tmp3)
	return(cmplx(i1,i2))
End

Function/C/D integR(wv,theta,zz,k0,mm)
	Wave wv
	Variable theta,zz,k0,mm

	Wave param,tmp2,tmp3
	Variable i1,i2
	Variable/D aa
	
	Duplicate/O wv,tmp2,tmp3
	tmp2=besselJ(mm,k0*x*sin(theta*Pi/180))*wv*x
	aa=area(tmp2)
	i1=aa*cos(k0*zz*cos(theta*pi/180))
	i2=aa*sin(k0*zz*cos(theta*pi/180))
	return(cmplx(i1,i2))
End

/////// prepare wave for integration
Function/S setIntegWaveZ(twv,dwv,nrr,nz1,nz2)
	String twv,dwv
	Variable nrr,nz1,nz2

	String cmd,wn1
	if(!exists(twv))
		return("")
	endif
	
//	sprintf cmd,"MatrixToWaves(\"%s\",%d)",twv,nrr
//	execute(cmd)
//	wn1 = twv+"_"+num2str(nrr)
	Duplicate/O/R=[nz1,nz2][nrr,nrr] $twv,$dwv
	return(dwv)
End

Function/S setIntegWaveR(twv,dwv,nrr,nz0)
	String twv,dwv
	Variable nrr,nz0

	String cmd,wn1
	if(!exists(twv))
		return("")
	endif
	
	MatrixTranspose $twv
//	sprintf cmd,"MatrixToWaves(\"%s\",%d)",twv,nz0
//	execute(cmd)
//	MatrixTranspose $twv

//	wn1 = twv+"_"+num2str(nz0)
//	Duplicate/O/R=[0,nrr] $wn1,$dwv
//	Duplicate/O/R=[nz0,nz0][0,nrr] $twv,$dwv
	Duplicate/O/R=[0,nrr][nz0,nz0] $twv,$dwv
	MatrixTranspose $twv
	return(dwv)
End

///////////
Function/C/D Ntheta0(theta,md)
	Variable theta
	Variable md
	
	String twv="hp"
	String dwv0="tmp1",dwv
	Wave param
	Variable nrr,nz1,nz2,k0,R0

	k0=param[%'k0']
	nz1=param[%'nz1']
	nz2=param[%'nz2']
	nrr=param[%'nrr']
	R0=param[%'R0']

	if(md != 0)
		dwv=setIntegWaveZ(twv,dwv0,nrr,nz1,nz2)
	else
		dwv=dwv0
	endif
	if(exists(twv)>0)
		return(integZ($dwv,theta,k0,R0,0)*(-2*pi*R0)*sin(theta*Pi/180))
	else
		return(0)
	endif
End

Function/C/D Ltheta0(theta,md)
	Variable theta
	Variable md
		
	String twv="ep"
	String dwv0="tmp1",dwv
	Wave param
	Variable nrr,nz1,nz2,k0,R0

	k0=param[%'k0']
	nz1=param[%'nz1']
	nz2=param[%'nz2']
	nrr=param[%'nrr']
	R0=param[%'R0']

	if(md != 0)
		dwv=setIntegWaveZ(twv,dwv0,nrr,nz1,nz2)
	else
		dwv=dwv0
	endif
	if(exists(twv)>0)
		return(integZ($dwv,theta,k0,R0,0)*(2*pi*R0)*sin(theta*Pi/180))
	else
		return(0)
	endif
End

Function/C/D Ntheta1(theta,md)
	Variable theta
	Variable md
	
	String twv="hp"
	String dwv0="tmp1",dwv
	Wave param
	Variable nrr,nz1,nz2,k0,R0,dz

	k0=param[%'k0']
	nz1=param[%'nz1']
	nz2=param[%'nz2']
	nrr=param[%'nrr']
	R0=param[%'R0']
	dz=param[%'dz']

	Variable nz0=nz1,zz
	zz=dz*(nz0-(nz1+nz2)/2)
	if(md != 0)
		dwv=setIntegWaveR(twv,dwv0,nrr,nz0)
	else
		dwv=dwv0
	endif
	if(exists(twv)>0)
		return(integR($dwv,theta,zz,k0,1)*2*pi*cos(theta*pi/180)*cmplx(0,-1))
	else
		return(0)
	endif
End
	
Function/C/D Ntheta2(theta,md)
	Variable theta
	Variable md
	
	String twv="hp"
	String dwv0="tmp1",dwv
	Wave param
	Variable nrr,nz1,nz2,k0,R0,dz

	k0=param[%'k0']
	nz1=param[%'nz1']
	nz2=param[%'nz2']
	nrr=param[%'nrr']
	R0=param[%'R0']
	dz=param[%'dz']

	Variable nz0=nz2,zz
	zz=dz*(nz0-(nz1+nz2)/2)
	if(md != 0)
		dwv=setIntegWaveR(twv,dwv0,nrr,nz0)
	else
		dwv=dwv0
	endif
	if(exists(twv)>0)
		return(-integR($dwv,theta,zz,k0,1)*2*pi*cos(theta*pi/180)*cmplx(0,1))
	else
		return(0)
	endif
End

Function/C/D Ltheta1(theta,md)
	Variable theta
	Variable md
	
	String twv="ep"
	String dwv0="tmp1",dwv
	Wave param
	Variable nrr,nz1,nz2,k0,R0,dz

	k0=param[%'k0']
	nz1=param[%'nz1']
	nz2=param[%'nz2']
	nrr=param[%'nrr']
	R0=param[%'R0']
	dz=param[%'dz']

	Variable nz0=nz1,zz
	zz=dz*(nz0-(nz1+nz2)/2)
	if(md != 0)
		dwv=setIntegWaveR(twv,dwv0,nrr,nz0)
	else
		dwv=dwv0
	endif
	if(exists(twv)>0)
		return(-integR($dwv,theta,zz,k0,1)*2*pi*cos(theta*pi/180)*cmplx(0,1))
	else
		return(0)
	endif
End
	
Function/C/D Ltheta2(theta,md)
	Variable theta
	Variable md
	
	String twv="ep"
	String dwv0="tmp1",dwv
	Wave param
	Variable nrr,nz1,nz2,k0,R0,dz

	k0=param[%'k0']
	nz1=param[%'nz1']
	nz2=param[%'nz2']
	nrr=param[%'nrr']
	R0=param[%'R0']
	dz=param[%'dz']

	Variable nz0=nz2,zz
	zz=dz*(nz0-(nz1+nz2)/2)
	if(md != 0)
		dwv=setIntegWaveR(twv,dwv0,nrr,nz0)
	else
		dwv=dwv0
	endif
	if(exists(twv)>0)
		return(integR($dwv,theta,zz,k0,1)*2*pi*cos(theta*pi/180)*cmplx(0,1))
	else
		return(0)
	endif
End

Function/C/D Nphi0(theta,md)
	Variable theta
	Variable md
	
	String twv="hz"
	String dwv0="tmp1",dwv=""
	Wave param
	Variable nrr,nz1,nz2,k0,R0

	k0=param[%'k0']
	nz1=param[%'nz1']
	nz2=param[%'nz2']
	nrr=param[%'nrr']
	R0=param[%'R0']

	if(md != 0)
		dwv=setIntegWaveZ(twv,dwv0,nrr,nz1,nz2)
	else
		dwv=dwv0
	endif
	if(exists(twv)>0)
		return(-integZ($dwv,theta,k0,R0,1)*(2*pi*R0)*cmplx(0,1))
	else
		return(0)
	endif
End

Function/C/D Lphi0(theta,md)
	Variable theta
	Variable md
	
	String twv="ez"
	String dwv0="tmp1",dwv
	Wave param
	Variable nrr,nz1,nz2,k0,R0

	k0=param[%'k0']
	nz1=param[%'nz1']
	nz2=param[%'nz2']
	nrr=param[%'nrr']
	R0=param[%'R0']

	if(md != 0)
		dwv=setIntegWaveZ(twv,dwv0,nrr,nz1,nz2)
	else
		dwv=dwv0
	endif
	if(exists(twv)>0)
		return(integZ($dwv,theta,k0,R0,1)*(2*pi*R0)*cmplx(0,1))
	else
		return(0)
	endif
End

Function/C/D Nphi1(theta,md)
	Variable theta
	Variable md
	
	String twv="hr"
	String dwv0="tmp1",dwv
	Wave param
	Variable nrr,nz1,nz2,k0,R0,dz

	k0=param[%'k0']
	nz1=param[%'nz1']
	nz2=param[%'nz2']
	nrr=param[%'nrr']
	R0=param[%'R0']
	dz=param[%'dz']

	Variable nz0=nz1,zz
	zz=dz*(nz0-(nz1+nz2)/2)
	if(md != 0)
		dwv=setIntegWaveR(twv,dwv0,nrr,nz0)
	else
		dwv=dwv0
	endif
	if(exists(twv)>0)
		return(-integR($dwv,theta,zz,k0,1)*2*pi*cmplx(0,1))
	else
		return(0)
	endif
End

Function/C/D Nphi2(theta,md)
	Variable theta
	Variable md
	
	String twv="hr"
	String dwv0="tmp1",dwv
	Wave param
	Variable nrr,nz1,nz2,k0,R0,dz

	k0=param[%'k0']
	nz1=param[%'nz1']
	nz2=param[%'nz2']
	nrr=param[%'nrr']
	R0=param[%'R0']
	dz=param[%'dz']

	Variable nz0=nz2,zz
	zz=dz*(nz0-(nz1+nz2)/2)
	if(md != 0)
		dwv=setIntegWaveR(twv,dwv0,nrr,nz0)
	else
		dwv=dwv0
	endif
	if(exists(twv)>0)
		return(integR($dwv,theta,zz,k0,1)*2*pi*cmplx(0,1))
	else
		return(0)
	endif
End

Function/C/D Lphi1(theta,md)
	Variable theta
	Variable md
	
	String twv="er"
	String dwv0="tmp1",dwv
	Wave param
	Variable nrr,nz1,nz2,k0,R0,dz

	k0=param[%'k0']
	nz1=param[%'nz1']
	nz2=param[%'nz2']
	nrr=param[%'nrr']
	R0=param[%'R0']
	dz=param[%'dz']

	Variable nz0=nz1,zz
	zz=dz*(nz0-(nz1+nz2)/2)
	if(md != 0)
		dwv=setIntegWaveR(twv,dwv0,nrr,nz0)
	else
		dwv=dwv0
	endif
	if(exists(twv)>0)
		return(integR($dwv,theta,zz,k0,1)*2*pi*cmplx(0,-1))
	else
		return(0)
	endif
End

Function/C/D Lphi2(theta,md)
	Variable theta,md
	
	String twv="er"
	String dwv0="tmp1",dwv
	Wave param
	Variable nrr,nz1,nz2,k0,R0,dz

	k0=param[%'k0']
	nz1=param[%'nz1']
	nz2=param[%'nz2']
	nrr=param[%'nrr']
	R0=param[%'R0']
	dz=param[%'dz']

	Variable nz0=nz2,zz
	zz=dz*(nz0-(nz1+nz2)/2)
	if(md != 0)
		dwv=setIntegWaveR(twv,dwv0,nrr,nz0)
	else
		dwv=dwv0
	endif
	if(exists(twv)>0)
		return(-integR($dwv,theta,zz,k0,1)*2*pi*cmplx(0,1))
	else
		return(0)
	endif
End

Macro DoCalculation()
	PauseUpdate; Silent 1
	
	Variable th=0
	String cmd,s
	s="Ntheta0";cmd=s+"res="+s+"(th,1)";execute cmd;cmd=s+"res="+s+"(x,0)";execute cmd
	s="Ntheta1";cmd=s+"res="+s+"(th,1)";execute cmd;cmd=s+"res="+s+"(x,0)";execute cmd
	s="Ntheta2";cmd=s+"res="+s+"(th,1)";execute cmd;cmd=s+"res="+s+"(x,0)";execute cmd
	s="Nphi0";cmd=s+"res="+s+"(th,1)";execute cmd;cmd=s+"res="+s+"(x,0)";execute cmd
	s="Nphi1";cmd=s+"res="+s+"(th,1)";execute cmd;cmd=s+"res="+s+"(x,0)";execute cmd
	s="Nphi2";cmd=s+"res="+s+"(th,1)";execute cmd;cmd=s+"res="+s+"(x,0)";execute cmd
	s="Ltheta0";cmd=s+"res="+s+"(th,1)";execute cmd;cmd=s+"res="+s+"(x,0)";execute cmd
	s="Ltheta1";cmd=s+"res="+s+"(th,1)";execute cmd;cmd=s+"res="+s+"(x,0)";execute cmd
	s="Ltheta2";cmd=s+"res="+s+"(th,1)";execute cmd;cmd=s+"res="+s+"(x,0)";execute cmd
	s="Lphi0";cmd=s+"res="+s+"(th,1)";execute cmd;cmd=s+"res="+s+"(x,0)";execute cmd
	s="Lphi1";cmd=s+"res="+s+"(th,1)";execute cmd;cmd=s+"res="+s+"(x,0)";execute cmd
	s="Lphi2";cmd=s+"res="+s+"(th,1)";execute cmd;cmd=s+"res="+s+"(x,0)";execute cmd
	
	Nthetares=Ntheta0res+(-Ntheta1res+Ntheta2res)
	Nphires=(Nphi0res-Nphi1res+Nphi2res)
	Lthetares=Ltheta0res+(-Ltheta1res+Ltheta2res)
	Lphires=(Lphi0res-Lphi1res+Lphi2res)
	Etheta=-(Lphires+Nthetares);Ephi=Lthetares-Nphires
	rcs=(cabs(Etheta)^2+cabs(Ephi)^2)*param[%'k0']^2/(8*pi)
End

Macro DoCalculateNL()
	PauseUpdate; Silent 1;
	String wvnm
	CalculateReIm("Ntheta0")
	CalculateReIm("Ntheta1")
	CalculateReIm("Ntheta2")
	CalculateReIm("Nphi0")
	CalculateReIm("Nphi1")
	CalculateReIm("Nphi2")
	CalculateReIm("Ltheta0")
	CalculateReIm("Ltheta1")
	CalculateReIm("Ltheta2")
	CalculateReIm("Lphi0")
	CalculateReIm("Lphi1")
	CalculateReIm("Lphi2")
	DoWindow/F GraphNL1
//	DoWindow/F GraphNL2
End

Function CalculateReIm(wvnm)
	String wvnm
//	PauseUpdate; silent 1;
	Wave wvre=$(wvnm+"_re")
	Wave wvim=$(wvnm+"_im")
	Wave wvor=$(wvnm+"res")
	wvre=real(wvor)
	wvim=imag(wvor)
End

Window GraphNL1() : Graph
	PauseUpdate; Silent 1		// building window...
	Display /W=(735,275,1282,618) Ntheta0_re,Ntheta0_im,Ntheta1_re,Ntheta1_im,Ntheta2_re
	AppendToGraph Ntheta2_im,Lphi0_re,Lphi0_im,Lphi1_re,Lphi1_im,Lphi2_re,Lphi2_im
	ModifyGraph gfSize=18
	ModifyGraph lStyle(Ntheta0_im)=2,lStyle(Ntheta1_im)=2,lStyle(Ntheta2_im)=2,lStyle(Lphi0_im)=2
	ModifyGraph lStyle(Lphi1_im)=2,lStyle(Lphi2_im)=2
	ModifyGraph rgb(Ntheta0_re)=(0,0,0),rgb(Ntheta0_im)=(0,0,0),rgb(Ntheta1_re)=(2,39321,1)
	ModifyGraph rgb(Ntheta1_im)=(2,39321,1),rgb(Ntheta2_re)=(39321,1,31457),rgb(Ntheta2_im)=(39321,1,31457)
	ModifyGraph rgb(Lphi0_re)=(65535,32768,58981),rgb(Lphi0_im)=(65535,32768,58981)
	ModifyGraph rgb(Lphi1_re)=(65535,32768,32768),rgb(Lphi1_im)=(65535,32768,32768)
	ModifyGraph rgb(Lphi2_re)=(16385,65535,65535),rgb(Lphi2_im)=(16385,65535,65535)
	Legend/C/N=text0/J/F=0/A=MC/X=18.56/Y=20.83 "\\s(Ntheta0_re) N\\B\\F'Symbol'q\\F'Helvetica'0\\M\r\\s(Ntheta1_re) N\\B\\F'Symbol'q\\F'Helvetica'1\\M"
	AppendText "\\s(Ntheta2_re) N\\B\\F'Symbol'q\\F'Helvetica'2\\M\r\\s(Lphi0_re) L\\B\\F'Symbol'f\\F'Helvetica'0\\M\r\\s(Lphi1_re) L\\B\\F'Symbol'f\\F'Helvetica'1\\M"
	AppendText "\\s(Lphi2_re) L\\B\\F'Symbol'f\\F'Helvetica'2\\M"
EndMacro

Window GraphNL2() : Graph
	PauseUpdate; Silent 1		// building window...
	Display /W=(584,44,1131,388) Nphi0_re,Nphi0_im,Nphi1_re,Nphi1_im,Nphi2_re,Nphi2_im
	AppendToGraph Ltheta0_re,Ltheta0_im,Ltheta1_re,Ltheta1_im,Ltheta2_re,Ltheta2_im
	ModifyGraph gfSize=18
	ModifyGraph lStyle(Nphi0_im)=2,lStyle(Nphi1_im)=2,lStyle(Nphi2_im)=2,lStyle(Ltheta0_im)=2
	ModifyGraph lStyle(Ltheta1_im)=2,lStyle(Ltheta2_im)=2
	ModifyGraph rgb(Nphi0_re)=(65535,32768,32768),rgb(Nphi0_im)=(65535,32768,32768)
	ModifyGraph rgb(Nphi1_re)=(16385,65535,65535),rgb(Nphi1_im)=(16385,65535,65535)
	ModifyGraph rgb(Nphi2_re)=(65535,16385,16385),rgb(Nphi2_im)=(65535,16385,16385)
	ModifyGraph rgb(Ltheta0_re)=(0,0,65535),rgb(Ltheta0_im)=(0,0,65535),rgb(Ltheta1_re)=(48059,48059,48059)
	ModifyGraph rgb(Ltheta1_im)=(48059,48059,48059),rgb(Ltheta2_re)=(0,65535,0),rgb(Ltheta2_im)=(0,65535,0)
	Legend/C/N=text0/J/F=0/A=MC/X=-36.01/Y=-24.15 "\\s(Nphi0_re) N\\B\\F'Symbol'f\\F'Helvetica'0\\M\r\\s(Nphi1_re) N\\B\\F'Symbol'f\\F'Helvetica'1\\M"
	AppendText "\\s(Nphi2_re) N\\B\\F'Symbol'f\\F'Helvetica'2\\M\r\\s(Ltheta0_re) L\\B\\F'Symbol'q\\F'Helvetica'0\\M\r\\s(Ltheta1_re) L\\B\\F'Symbol'q\\F'Helvetica'1\\M"
	AppendText "\\s(Ltheta2_re) L\\B\\F'Symbol'q\\F'Helvetica'2\\M"
EndMacro

///// obsolete routine begin
Macro LoadNL(num,fname,pname)
	Variable num=0
	String fname,pname="home"
	PauseUpdate; Silent 1

	Variable ref
	if (strlen(fName)<=0)
		Open /D/R/P=$pName/T=".DAT" ref // windows
		fName= S_fileName
		print fname
	endif
	
//	Open /R/P=$pName/T=".dat" ref as fName

//	LoadWave/G/D/L={0,0,0,1,8}/N=$"dummy"/W/P=$pName/Q fName
	LoadWave/J/D/N=$"dummy"/W/P=$pName/Q fName
	if(V_flag==0)
		return
	endif
	Variable index=0
	String orig1,orig2,dest1,dest2,destlist="Ntheta;Lphi;Nphi;Ltheta",calc1,calc2
	Display
	do
		orig1=StringFromList(1+index*2,S_WaveNames,";")
		orig2=StringFromList(1+index*2+1,S_WaveNames,";")
		calc1=StringFromList(index,destlist,";")+num2str(num)+"_re"
		calc2=StringFromList(index,destlist,";")+num2str(num)+"_im"
		dest1=calc1+"_load"
		dest2=calc2+"_load"
		Duplicate/O $orig1,$dest1
		Duplicate/O $orig2,$dest2
//		$dest1-=$calc1
//		$dest2-=$calc2
		Append $dest1,$dest2
		index+=1
	while (index<4)

End
///// obsolete rotutine end

Macro Bringto()
	if(strsearch(WinList("*",";","WIN:1"),"GraphNL1",0)<0)
		GraphNL1()
	else
		DoWindow/F GraphNL1
	endif
	Append $("Ntheta"+num2str(num)+"_re_load")
	Append $("Ntheta"+num2str(num)+"_im_load")
	Append $("Lphi"+num2str(num)+"_re_load")
	Append $("Lphi"+num2str(num)+"_im_load")

	if(strsearch(WinList("*",";","WIN:1"),"GraphNL2",0)<0)
		GraphNL2()
	else
		DoWindow/F GraphLN2
	endif
	Append $("Nphi"+num2str(num)+"_re_load")
	Append $("Nphi"+num2str(num)+"_im_load")
	Append $("Ltheta"+num2str(num)+"_re_load")
	Append $("Ltheta"+num2str(num)+"_im_load")
End

// to check Ntheta/Lphi/Nphi/Ltheta
Macro LoadNLthphi0(fname,pname,suffix,dispTable,dispGraph)
	String fname,pname="home"
	Variable suffix,dispTable=2,dispGraph=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	
	JMGeneralDatLoader(fname,pname,"Ntheta0Load",suffix,-1,dispTable,dispGraph)
End

Macro LoadNLthphi1(fname,pname,suffix,dispTable,dispGraph)
	String fname,pname="home"
	Variable suffix,dispTable=2,dispGraph=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	
	JMGeneralDatLoader(fname,pname,"Ntheta1Load",suffix,-1,dispTable,dispGraph)
End

Macro LoadNLthphi2(fname,pname,suffix,dispTable,dispGraph)
	String fname,pname="home"
	Variable suffix,dispTable=2,dispGraph=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	
	JMGeneralDatLoader(fname,pname,"Ntheta2Load",suffix,-1,dispTable,dispGraph)
End

Function CheckNLthphi(num,orig,doCalculate,gnameBase)
	Variable num,doCalculate
	String orig,gNameBase
	
	String cmd,gnre,gnim
	String wvre,wvim,wvre1,wvim1
	if(doCalculate)
		cmd=orig+"res="+orig+"(x,1)"
		execute cmd
		CalculateReIm(orig)
	endif
	wvre=orig+"_re"
	wvim=orig+"_im"
	wvre1=orig+"re_"+num2str(num)
	wvim1=orig+"im_"+num2str(num)
	gnre=gnameBase+"_re"
	gnim=gnameBase+"_im"
	if(strsearch(WinList("*",";","WIN:1"),gnre,0)<0)
		Display/W=(35,44,430,252) $wvre,$wvre1
		ModifyGraph rgb($wvre)=(0,0,0)
		DoWindow/C $gnre
	else
		DoWindow/F $gnre
	endif
	if(strsearch(WinList("*",";","WIN:1"),gnim,0)<0)
		Display/W=(34,275,429,483) $wvim,$wvim1
		ModifyGraph rgb($wvim)=(0,0,0)
		DoWindow/C $gnim
	else
		DoWindow/F $gnim
	endif
	return(0)
End

Macro CheckNtheta0(num,doCalculate)
	Variable num,doCalculate
	PauseUpdate; Silent 1;
	
	String orig,wvre,wvim,wvre1,wvim1
	CheckNLthphi(num,"Ntheta0",doCalculate,"GraphNtheta0")
End

Macro CheckNtheta1(num,doCalculate)
	Variable num,doCalculate
	PauseUpdate; Silent 1;
	
	String orig,wvre,wvim,wvre1,wvim1
	CheckNLthphi(num,"Ntheta1",doCalculate,"GraphNtheta1")
End

Macro CheckNtheta2(num,doCalculate)
	Variable num,doCalculate
	PauseUpdate; Silent 1;
	
	String orig,wvre,wvim,wvre1,wvim1
	CheckNLthphi(num,"Ntheta2",doCalculate,"GraphNtheta2")
End

Macro CheckLphi0(num,doCalculate)
	Variable num,doCalculate
	PauseUpdate; Silent 1;
	
	String orig,wvre,wvim,wvre1,wvim1
	CheckNLthphi(num,"Lphi0",doCalculate,"GraphLphi0")
End

Macro CheckLphi1(num,doCalculate)
	Variable num,doCalculate
	PauseUpdate; Silent 1;
	
	String orig,wvre,wvim,wvre1,wvim1
	CheckNLthphi(num,"Lphi1",doCalculate,"GraphLphi1")
End

Macro CheckLphi2(num,doCalculate)
	Variable num,doCalculate
	PauseUpdate; Silent 1;
	
	String orig,wvre,wvim,wvre1,wvim1
	CheckNLthphi(num,"Lphi2",doCalculate,"GraphLphi2")
End

Macro CheckNphi0(num,doCalculate)
	Variable num,doCalculate
	PauseUpdate; Silent 1;
	
	String orig,wvre,wvim,wvre1,wvim1
	CheckNLthphi(num,"Nphi0",doCalculate,"GraphNphi0")
End

Macro CheckNphi1(num,doCalculate)
	Variable num,doCalculate
	PauseUpdate; Silent 1;
	
	String orig,wvre,wvim,wvre1,wvim1
	CheckNLthphi(num,"Nphi1",doCalculate,"GraphNphi1")
End

Macro CheckNphi2(num,doCalculate)
	Variable num,doCalculate
	PauseUpdate; Silent 1;
	
	String orig,wvre,wvim,wvre1,wvim1
	CheckNLthphi(num,"Nphi2",doCalculate,"GraphNphi2")
End

Macro CheckLtheta0(num,doCalculate)
	Variable num,doCalculate
	PauseUpdate; Silent 1;
	
	String orig,wvre,wvim,wvre1,wvim1
	CheckNLthphi(num,"Ltheta0",doCalculate)
End

Macro CheckLtheta1(num,doCalculate)
	Variable num,doCalculate
	PauseUpdate; Silent 1;
	
	String orig,wvre,wvim,wvre1,wvim1
	CheckNLthphi(num,"Ltheta1",doCalculate)
End

Macro CheckLtheta2(num,doCalculate)
	Variable num,doCalculate
	PauseUpdate; Silent 1;
	
	String orig,wvre,wvim,wvre1,wvim1
	CheckNLthphi(num,"Ltheta2",doCalculate)
End

// check field
Macro Loadfield0(fname,pname,suffix,dispTable,dispGraph)
	String fname,pname="home"
	Variable suffix,dispTable=2,dispGraph=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	
	JMGeneralDatLoader(fname,pname,"field0Load",suffix,1,dispTable,dispGraph)
End

Macro Loadfield1(fname,pname,suffix,dispTable,dispGraph)
	String fname,pname="home"
	Variable suffix,dispTable=2,dispGraph=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	
	JMGeneralDatLoader(fname,pname,"field1Load",suffix,1,dispTable,dispGraph)
End

Macro Loadfield2(fname,pname,suffix,dispTable,dispGraph)
	String fname,pname="home"
	Variable suffix,dispTable=2,dispGraph=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	
	JMGeneralDatLoader(fname,pname,"field2Load",suffix,1,dispTable,dispGraph)
End

// check integration
Macro LoadNL0integ(fname,pname,suffix,dispTable,dispGraph)
	String fname,pname="home"
	Variable suffix,dispTable=2,dispGraph=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	
	JMGeneralDatLoader(fname,pname,"NF2FFDebug1",suffix,1,dispTable,dispGraph)
End

Macro LoadNL12integ(fname,pname,suffix,dispTable,dispGraph)
	String fname,pname="home"
	Variable suffix,dispTable=2,dispGraph=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	
	JMGeneralDatLoader(fname,pname,"NF2FFDebug2",suffix,1,dispTable,dispGraph)
End

Macro CheckNtheta0Integ(num,theta0)
	Variable num,theta0=30
	PauseUpdate; Silent 1
	
	String wv_ht0re="ht0re_"+num2str(num),wv_ez0re="ez0re_"+num2str(num)
	String wv_jm0="jm0"+"_"+num2str(num)
	String wv_zzzzre="zzzzre"+"_"+num2str(num),wv_zzzzim="zzzzim"+"_"+num2str(num)
	
	print Ntheta0(theta0,1)
	Duplicate/O $wv_ht0re,check0,check1
//	Display $wv_ht0re,tmp1 // check field

	check0=$wv_ht0re*$wv_jm0*$wv_zzzzre
	check1=$wv_ht0re*$wv_jm0*$wv_zzzzim
	Display check0,check1,tmp2,tmp3;
	print area(check0)*param[%'R0']*2*pi*sin(theta0*pi/180),area(check1)*param[%'R0']*2*pi*sin(theta0*pi/180)
end	

Macro CheckLphi0Integ(num,theta0)
	Variable num,theta0=30
	PauseUpdate; Silent 1
	
	String wv_ht0re="ht0re_"+num2str(num),wv_ez0re="ez0re_"+num2str(num)
	String wv_jm0="jm0"+"_"+num2str(num)
	String wv_jmp1z="jmp1z"+"_"+num2str(num),wv_jmm1z="jmm1z"+"_"+num2str(num)
	String wv_zzzzre="zzzzre"+"_"+num2str(num),wv_zzzzim="zzzzim"+"_"+num2str(num)
	
	print Lphi0(theta0,1)
	Duplicate/O $wv_ez0re,check0,check1
//	Display $wv_ez0re,tmp1 // check field

	check0=$wv_ez0re*($wv_jmp1z-$wv_jmm1z)/2*$wv_zzzzre
	check1=$wv_ez0re*($wv_jmp1z-$wv_jmm1z)/2*$wv_zzzzim
	Display check0,check1,tmp2,tmp3;
	print area(check1)*param[%'R0']*2*pi,area(check0)*param[%'R0']*2*pi
end

Function CheckNL0IntegInit()
//	PauseUpdate; Silent 1
	String wns="NF2FFDebug1"
	Wave/T wn=$wns
	Make/T/N=11/O wn
	wn[0]=""
	wn[1]=""
	wn[2]="ht0re"
	wn[3]="ht0im"
	wn[4]="ez0re"
	wn[5]="ez0im"
	wn[6]="jm0"
	wn[7]="jmp1z"
	wn[8]="jmm1z"
	wn[9]="zzzzre"
	wn[10]="zzzzim"
End

Function CheckNL12IntegInit()
//	PauseUpdate; Silent 1
	String wns="NF2FFDebug2"
	Wave/T wn=$wns
	Make/T/N=10/O  wn
	wn[0]=""
	wn[1]=""
	wn[2]="ht00re"
	wn[3]="ht00im"
	wn[4]="er00re"
	wn[5]="er00im"
	wn[6]="jmp1r"
	wn[7]="jmm1r"
	wn[8]="rrrrre"
	wn[9]="rrrrim"
End

Macro LoadNF2FFResult(fname,pname,suffix,dispTable,dispGraph)
	String fname,pname="home"
	Variable suffix,dispTable=2,dispGraph=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	// theta dependence assumed
	String wn
	JMGeneralDatLoader(fname,pname,"NF2FFResult",suffix,2,dispTable,dispGraph)
	wn="rcs_"+num2str(suffix)
	Display $wn
End
