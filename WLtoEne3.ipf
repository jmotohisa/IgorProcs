#pragma rtGlobals=1		// Use modern global access method.
#include "JMGraphStyles"

// wavelength to energy conversion
// to be used with "LoadSPEdata2"
// in dataset

//	revision history
//		10/05/29	ver 0.1	first version
//		12/02/11	ver 0.2	WLtoEneInDataSet is converted to function

Macro WLtoEneInDataSetDef(ind0,xwvnm_orig,xwvnm_dest)
	String xwvnm_orig="0",xwvnm_dest="eV"
	Variable ind0
	Prompt ind0,"index of the dataset"
	Prompt xwvnm_orig,"original wavelength wave (suffix)"
	Prompt xwvnm_dest,"destination energy wave (suffix)"
	PauseUpdate; Silent 1
	WLtoEneInDataSet(g_DSOname,ind0,xwvnm_orig,xwvnm_dest)
End Macro

Function WLtoEneInDataSet(dsetnm,ind0,xwvnm_orig,xwvnm_dest)
	String dsetnm
	String xwvnm_orig,xwvnm_dest
	Variable ind0
	SVAR g_DSOname
//	String dsetnm=g_dsetnm
//	String xwvnm_orig="0",xwvnm_dest="eV"
//	Prompt dsetnm,"Dataset name to plot"//,popup,WaveList("*",";","")
//	Prompt ind0,"index of the dataset"
//	Prompt xwvnm_orig,"original wavelength wave (suffix)"
//	Prompt xwvnm_dest,"destination energy wave (suffix)"
//	PauseUpdate;Silent 1

//	dsetnm=g_dsetnm
	
	Variable numwave,index=0
	String targetw,destw
	g_DSOname=dsetnm
	
	dsetnm=dsetnm+num2istr(ind0)
	Wave/T wv_dsetnm=$dsetnm
//	Wave wv_destw
	numwave=numpnts($dsetnm)
	do
		targetw=wv_dsetnm(index)+"_"+xwvnm_orig
		destw=wv_dsetnm(index)+"_"+xwvnm_dest
		Duplicate/O $targetw,$destw
		Wave wv_destw=$destw
		wv_destw = 1239.8/wv_destw
		index+=1
	while(index<numwave)	
End

Function WLtoEneDS0(prefix)
	String prefix
	
	String wv0=prefix+"_0"
	String wveV=prefix+"_eV"
	Wave wwv0=$wv0
	Duplicate/O wwv0,$wveV
	Wave wwveV=$wveV
	wwveV=1239.8/wwveV
End
