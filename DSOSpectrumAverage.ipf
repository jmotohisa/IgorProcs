#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "DataSetOperations"
#include "SpectrumAverage"

Function DSOSpectrumAverage(dsetnm0,ind0,xwave0,ywave0,xstart,xend,dest)
	String dsetnm0,xwave0,ywave0,dest
	Variable ind0,xstart,xend
	
	Variable i=0,numwave
	String dsetnm=dsetnm0+num2istr(ind0)
	Wave/T wdsetnm=$dsetnm
	numwave=numpnts(wdsetnm)
	Make/N=(numwave)/O $dest
	Wave wdest = $dest
	String target,xwave,ywave
	Do
		target=wdsetnm[i]
		if(strlen(ywave0)>0)
			ywave=target+"_"+ywave0
		else
			ywave=target
		endif
		print ywave
		if(strlen(xwave0)>0)
			xwave=target +"_" + xwave0			
			wdest[i]=SpectrumAverageXY0(xwave,ywave,"dummy",xstart,xend)
		else
			wdest[i]=SpectrumAverage0(ywave,"dummy",xstart,xend)
		Endif
		i+=1
	while(i<numwave)

End