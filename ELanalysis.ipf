#pragma rtGlobals=1		// Use modern global access method.
#include "AreaXYCursor"

// Macro for quick EL analysis
// 11/03/15 ver  0.01 by J. Motohisa
//
//	revision history
//		11/03/15	ver 0.01	first version, quick hack

//
// #include "LoadSPEdata2"
// #include "LoadPLData"
// #include "LoadDelftData"

// // IL from glued spectra in combination with DS operation

// DSOFwavesToMatrix("data",3,"","glue_il01")
// DSOInvertPolarity(11,"",2)  // invert polarity
// DSOFWaveAverage("data",11,"","il01_I") // current by taking average
// DSOFIntegWave0("data",3,"","","il01_L") // integrate EL spectrum
// Display il01_L vs il01_I // display EL vs Current


Macro DisplayEL(index)
	Variable index
	PauseUpdate;Silent 1
	
	String bname,lwv,lwvx
	bname=tmpnm[index]
	lwv=data0[index]+"_1"
	lwvx=data0[index]+"_0"
	
	Display /W=(407,44,759,494)
	MatrixWavePlot(lwv,2,1,lwvx)
	Label left "EL Intensity (\u cps)";Label bottom "Wavelength (nm)"
	TextBox/C/N=text0/F=0/A=MC "11/02/07\r"+bname
	ModifyGraph gfSize=18
	DoWindow/C $("G_"+bname+"_EL")

	AreaCsr_AllTrace("L"+bname,"N"+bname)
End

Macro DisplayIV(index,suffix)
	Variable index
	String suffix="_0_0"
	PauseUpdate;Silent 1
	
	String bname=tmpnm[index]
	String iwv=bname+"_0_0"
	Display /W=(760,44,1095,495)
	AppendToGraph $iwv
	Label left "Current (\\U)";Label bottom "Voltage (\\U)"
	TextBox/C/N=text0/F=0/A=MC "11/02/07\r"+bname
	ModifyGraph gfSize=18
	ModifyGraph log(left)=1
	DoWindow/C $("G_"+bname+"_IV")
End

Macro DisplayIL(index,suffix)
	Variable index
	String suffix="_0_0"
	PauseUpdate;Silent 1
	
	String lwv,iwv,bname
	bname=tmpnm[index]
	lwv="L"+bname
	iwv=bname+"_0_0"
	Display /W=(1110,44,1446,497) $iwv vs $lwv
	AppendToGraph/T $iwv
	ModifyGraph gfSize=18
	ModifyGraph rgb($iwv#1)=(0,0,65535)
	Label left "Current (\\U)"
	Label bottom "EL intensity (\\u cps)"
	Label top "Voltage (\\U)"
	TextBox/C/N=text0/F=0/A=MC/X=-24.40/Y=44.89 "11/02/07\r"+bname
	ModifyGraph swapXY=1
	
	DoWindow/C $("G_"+bname+"_IL")
End

Macro Plot_all(index,suffix)
	Variable index
	String suffix="_0_0"
	PauseUpdate; Silent 1
	
	String name
	DisplayEL(index)
	DisplayIV(index,suffix)
	DisplayIL(index,suffix)
	NewLayout/P=landscape
	name="G_"+tmpnm[index]+"_EL"
	AppendToLayout $name
	name=("G_"+tmpnm[index]+"_IV")
	AppendToLayout $name
	name=("G_"+tmpnm[index]+"_IL")
	AppendToLayout $name
	Tile
End

Macro Display_all(bname)
	String bname
	PauseUpdate; Silent 1
	
	string cmd
	cmd="G_"+bname+"_EL()";Execute cmd
	cmd="G_"+bname+"_IV()";Execute cmd
	cmd="G_"+bname+"_IL()";Execute cmd
End