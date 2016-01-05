#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Loadsqwlictl.ipf
// by J. Motohisa
// load calculated results of pcsmatrix

//	2015/02/17	initial version

#include "JMGeneralTextDataLoad2"
#include "DataSetOperations"

Function Loadsqwlibctl_init()
	Variable use_DSO=1
	String dsetnm="data"
	Variable DSOindex=FDSO_getIndex()
	NVAR g_DSOindex

//	String/G g_JMGTD_wname
	
	String prefix,suffixlist
	if(use_DSO==1)
	// create data set
		FDSOinit0(dsetnm)
//		FDSOinit(dsetnm,prefix,suffixlist)
		DSOCreate0(0,1)
		dsetnm=dsetnm+num2istr(FDSO_getIndex()-1)
//	DSOCreate0(dsetindex,1) 
//	dsetnm=dsname0+num2istr(dsetindex)
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

Function load_pc1d(prefix)
	String prefix
	
	Variable use_DSO=1
	String suffixlist=";pos;psi;Ec;Ev;nelec;phole;jn;jp;SRH;AUGER;RAD;OPT"
	JMGeneralDatLoaderFunc2("","",".dat",1,prefix,suffixlist,1,"m","eV",0)
	if(use_DSO==1)
		FDSOAppend(prefix)
	endif
End

// some examples
// JMGeneralDatLoader2("","",".dat",1,"cp",";pos;psi;Ec;Ev;nelec;phole;jn;jp;SRH;AUGER;RAD;OPT",1,"m","eV",0)
// JMGeneralDatLoader2("","",".dat",1,"cp",";pos;psi;Ec;Ev;nelec;phole;rho",1,"m","eV",0)
// JMGeneralDatLoader2("","",".dat",1,"cp",";pos;psi;Ec;Ev;nelec;phole;;",1,"m","eV",0)
//        x       potential       EcEdge  EvEdge  electron        hole    Jn      Jp      SRH     AUGER   RAD
