#pragma rtGlobals=1		// Use modern global access method.
#include "JMGeneralTextDataLoad"

Function initLoadMie()
	String/g g_wnloadSphere="mieSphereWName"
	String/g g_wnloadSphereAngle="mieSphereAngleWName"
	String/g g_wnloadCylinder="mieCylinderWName"
	String/g g_wnloadCylinderAngle="mieCylinderAngleWName"
	String wlist
	Variable nwv

	wlist=";radius;wavelength;n_real;n_imag;qext;qsca;qback;qabs;gsca"
	JMGeneralDatLoaderInit(g_wnloadSphere,wlist)

	wlist=";;s11;pol;s33;s34"
	JMGeneralDatLoaderInit(g_wnloadSphereAngle,wlist)

	wlist=";radius;wavelength;n_real;n_imag;qscpar;qscper;qexpar;qexper;qabspar;qabsper"
	JMGeneralDatLoaderInit(g_wnloadCylinder,wlist)

	wlist=";;t11;pol;t33;t34"
	JMGeneralDatLoaderInit(g_wnloadCylinderAngle,wlist)
End

Macro LoaadMieSphere(fname,pname,suffix,dispTable,dispGraph,col)
	String fname,pname="home"
	Variable suffix,dispTable=2,dispGraph=2,col=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	
	JMGeneralDatLoader(fname,pname,g_wnLoadSphere,suffix,col,dispTable,dispGraph)
End

Macro LoaadMieSphereAngle(fname,pname,suffix,dispTable,dispGraph)
	String fname,pname="home"
	Variable suffix,dispTable=2,dispGraph=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	
	JMGeneralDatLoader(fname,pname,g_wnLoadSphereAngle,suffix,1,dispTable,dispGraph)
End

Macro LoaadMieCylinder(fname,pname,suffix,dispTable,dispGraph,col)
	String fname,pname="home"
	Variable suffix,dispTable=2,dispGraph=2,col
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	
	JMGeneralDatLoader(fname,pname,g_wnLoadCylinder,suffix,col,dispTable,dispGraph)
End

Macro LoaadMieCylinderAngle(fname,pname,suffix,dispTable,dispGraph)
	String fname,pname="home"
	Variable suffix,dispTable=2,dispGraph=2
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt dispTable, "Display Table ?",popup,"yes;no"
	Prompt dispGraph, "Display Graph ?",popup,"yes;no"
	
	JMGeneralDatLoader(fname,pname,g_wnLoadCylinderAngle,suffix,1,dispTable,dispGraph)
End

