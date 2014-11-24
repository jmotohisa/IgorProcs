#pragma rtGlobals=1		// Use modern global access method.
#include <XY Pair To Waveform>

// ModifyWaves.ipf
//	Set of functions for modification of waves
//	 includes: 
//		linearize (convert XY pair to waveform)
//		chanage number of points (using interpolation)
//		extract (extract part of waves taking into account scaling)
//
//	11/04/21 ver. 0.1a by J. Motohisa
//
//	revision history
//		11/04/21	ver 0.1a first version

// convert XY pair to waveform data (linearization)
// in procedure "XY pair to Waveform"
//	Function XYToWave1(xWave, yWave, wWaveName, numPoints)
//	Function XYToWave2(xWave, yWave, wWaveName, numPoints)
//
// also take a look at "LinearizeSpectram" in GlueSpectra.ipf procedure

// Conversion with given delta
Function XYToWave1delta(xWave, yWave, wWaveName, delta)
	Wave xWave							// x wave in the XY pair
	Wave yWave							// y wave in the XY pair
	String wWaveName					// name to use for new waveform wave
	Variable delta					// number of points for waveform

	Variable numPoints
	WaveStats/Q xWave
	numPoints=floor((V_max-V_min)/delta+0.5)
	XYToWave1(xWave, yWave, wWaveName, numPoints)
End

Function XYToWave2delta(xWave, yWave, wWaveName, delta)
	Wave xWave							// x wave in the XY pair
	Wave yWave							// y wave in the XY pair
	String wWaveName					// name to use for new waveform wave
	Variable delta					// number of points for waveform

	Variable numPoints
	WaveStats/Q xWave
	numPoints=floor((V_max-V_min)/delta+0.5)
	XYToWave2(xWave, yWave, wWaveName, numPoints)
End

// Change number of points by interpolation
Function ChangeNumPointsWave(orig,dest,numPoints)
	Wave orig
	String dest
	Variable numpoints
	
	String xwv
	if(strlen(dest)==0)
		dest=NameOfWave(orig)+"_DUP"
	endif
	xwv=dest+"_temp"
	Wave wxwv=$xwv
	Duplicate/O orig,wxwv
	wxwv=x
	XYToWave1(wxwv,orig,dest,NumPoints)
	KillWaves wxwv
End

//////////
// modify scaling  if DimDelta<0
Function ArrangeScaling(dest)
	Wave dest
	
	Variable delta=DimDelta(dest,0)
	if(delta>0)
		return -1
	endif
	Variable xstart=DimOffset(dest,0),xend=DimOffset(dest,0)+(DimSize(dest,0)-1)*delta
	String wn=NameOfWave(dest)+"_temp"
	Duplicate dest,$wn
	Wave ww=$wn
	ww=x
	Sort ww ww,dest
	SetScale/I x,xend,xstart,WaveUnits(dest,0),dest
	KillWaves ww
	return 0
End

// Extract part of waves, consdering scaling
// WaveExtract1 : between x values
// WaveExtract2 : between x points

Function WaveExtract1(orig,dest,xstart,xstop)
	Wave orig
	String dest
	Variable xstart,xstop
	
	Variable dd=DimDelta(orig,0),temp
//	Duplicate/O orig,$dest
	if(xstart<xstop)
		temp=xstart
		xstart=xstop
		xstop=temp
	Endif
	Extract/O orig,$dest,x>=xstart && x<=xstop
	SetScale/P x,xstart,dd,WaveUnits(orig,0),$dest 
End

Function WaveExtract2(orig,dest,nstart,nstop)
	Wave orig
	String dest
	Variable nstart,nstop
	
	Variable dd=DimDelta(orig,0),nn=numpnts(orig),x0=DimOffset(orig,0)
	Variable xstart=DimOffset(orig,0)+dd*nstart
	Extract/O orig,$dest,x>=nstart*dd+x0 && x<=nstop*dd+x0
	SetScale/P x,xstart,dd,WaveUnits(orig,0),$dest
End

Function WaveExtractCsr(dest)
	String dest
	
	String ca=CsrWave(A),cb=CsrWave(B)
	String orig
	Variable nstart,nstop,temp
	
	if(strlen(ca)==0 && strlen(cb)==0)
		return 0
	endif
	
	if(strlen(ca)!=0)
		orig=ca
		nstart=pcsr(A)
	else
		orig=cb
		nstart=0
	endif
	
	if(strlen(cb)!=0)
		nstop=pcsr(B)
	else
		nstop=numpnts($orig)
	endif
	
	if(nstart>nstop)
		temp=nstart
		nstart=nstop
		nstop=temp
	endif
		
	if(strlen(dest)==0)
		dest=orig+"_DUP"
	endif
	WaveExtract2($orig,dest,nstart,nstop)
	AppendToGraph $dest;ModifyGraph lsize($dest)=2
End
	
Macro ExtractFromMarquee
End