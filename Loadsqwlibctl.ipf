#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Loadsqwlictl.ipf
// by J. Motohisa
// load calculated results of pcsmatrix

//	2016/01/05	ver 0.1a	modified to work with DataSetOperations
//	2015/02/17	ver 0.01	initial version

#include "JMGeneralTextDataLoad2"
#include "DataSetOperations"

Function Loadsqwlibctl_init(use_DSO)
	Variable use_DSO
	
	Variable/g g_use_DSO=use_DSO
	String dsetnm="data"
	
	dsetnm=JMGTDLinit(use_DSO,dsetnm)
	if(use_DSO)
		Redimension/N=1 $dsetnm
	endif
End

//! read 1D column data
// xscale:
// 1: no-scaling information
// 2: uniform mesh
// 3: non-uniform mesh
// xscale_col: default to 1

// load data from a single column in a file:
Function/S Loadsqw_1Dsub1(fileName,pathName,bwname,index,suffix,datpos,xscale,xunit,yunit)
	String fileName,pathName,bwname,suffix,xunit,yunit
	Variable index,datpos,xscale
	
	String extName=".dat"
	Variable fquiet=1
	String suffixlist
	Variable scalenum
	
	if(xscale<=0)
	endif
	
	JMGeneralDatLoaderFunc2(fileName,pathName,extName,index,bwname,suffixlist,scalenum,xunit,yunit,fquiet)
End

Function load_sqw_emsapprox(fname,pname,prefix,index)
	String fname,pname,prefix
	Variable index
	
	NVAR g_use_DSO
	String suffixlist=";well_width;Ee1;E_hh1;E_e1hh1;eh_overlap"
	String dname
	Variable nlwave
	nlwave=JMGeneralDatLoaderFunc2(fname,pname,".dat",index,prefix,suffixlist,1,"m","eV",0)
	dname=prefix+num2istr(index)
	if(g_use_DSO==1)
		FDSOAppend(dname,index)
	endif
End

Function load_pc1d(fname,pname,prefix,index)
	String fname,pname,prefix
	Variable index
	
	NVAR g_use_DSO
	String suffixlist=";pos;psi;Ec;Ev;nelec;phole;jn;jp;SRH;AUGER;RAD;OPT"
	String dname
	Variable nlwave
	nlwave=JMGeneralDatLoaderFunc2(fname,pname,".dat",index,prefix,suffixlist,1,"m","eV",0)
	dname=prefix+num2istr(index)
	if(g_use_DSO==1)
		FDSOAppend(dname,index)
	endif
End

// some examples
// JMGeneralDatLoader2("","",".dat",1,"cp",";pos;psi;Ec;Ev;nelec;phole;jn;jp;SRH;AUGER;RAD;OPT",1,"m","eV",0)
// JMGeneralDatLoader2("","",".dat",1,"cp",";pos;psi;Ec;Ev;nelec;phole;rho",1,"m","eV",0)
// JMGeneralDatLoader2("","",".dat",1,"cp",";pos;psi;Ec;Ev;nelec;phole;;",1,"m","eV",0)
//        x       potential       EcEdge  EvEdge  electron        hole    Jn      Jp      SRH     AUGER   RAD
