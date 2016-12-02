#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// SpectralAnalysis.ipf
// menu for spectra analysis
// 16/12/02 ver 0.01 by J. Motohisa
//
// revision nistory
//	16/12/02 ver 0.01: first version
//
// To Do:
//

#include "LoadSPEdata2"
#include "GraphPlus"
#include "areaXYcursor"

Menu "Spect"
	Submenu "Load"
		"MultiSPELoad/1"
		"SPELoad2"
	End
	Submenu "Graphs"
		"Display Spectra/2",DSODisplay()
		"Make Traces Different/3",ShowKBColorizePanel()
		"Y offset",AutoYoffset()
	End
	Submenu "Analysis"
		"Integrate Spectra on a graph/4",DoAreaCsr_AllTrace()
	End
End