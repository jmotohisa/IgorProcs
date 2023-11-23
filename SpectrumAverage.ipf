#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// SpectrumAverage.ipf : take aveage of the spectrum (to find peak position)
// by J. Motohisa

// ver 0.01a: 15/06/03 first commitment

Function SpectrumAverage0(ywave,target,xstart,xend)
	String  ywave,target
	Variable xstart,xend
	
	Wave ywv=$ywave
	Duplicate/O ywv,$target
	Wave tw=$target
	Variable c
	tw=tw*x
	if(xstart==0&xend==0)
		c=area(tw)/area(ywv)
	else
		c=area(tw,xstart,xend)/area(ywv,xstart,xend)
	endif
	return(c)
End

Function SpectrumAverageXY0(xwave,ywave,target,xstart,xend)
	String  ywave,xwave,target
	Variable xstart,xend
	
	Variable c
	if(strlen(xwave)==0)
		c=SpectrumAverage0(ywave,target,xstart,xend)
	else
		Wave ywv=$ywave
		Wave xwv=$xwave
		Duplicate/O ywv,$target
		Wave tw=$target
		tw=tw*xwv;
		if(xstart==0&xend==0)
			c=areaXY(xwv,tw)/areaXY(xwv,ywv)
		else
			c=areaXY(xwv,tw,xstart,xend)/areaXY(xwv,ywv,xstart,xend)
		endif
	endif
	return(c)
End

Function SpectrumAverage(ywave,xstart,xend)
	Wave  ywave
	Variable xstart,xend
	Wave dummy
	Duplicate/O ywave,dummy
	Return(SpectrumAverage0(NameofWave(ywave),"dummy",xstart,xend))
End

Function SpectrumAverageXY(xwave,ywave,xstart,xend)
	Wave  ywave,xwave
	Variable xstart,xend
	Wave dummy
	Duplicate/O ywave,dummy
	Return(SpectrumAverageXY0(NameofWave(xwave),NameofWave(ywave),"dummy",xstart,xend))
End

Function SpectrumAverageonGraph(grname,dest)
	String grname,dest
	
	Variable xstart=hcsr(A)
	Variable xend=hcsr(B)
	
	String trnames=TraceNameList(grname,";",1)
	String twave
	Variable i
	i=0
	Make/O $dest
	Wave wdest=$dest
	do
		twave=StringFromList(i,trnames,";")
		if(strlen(twave)==0)
			break
		endif
//		Wave wtwave=$twave
		wdest[i]=SpectrumAverage0(twave,"dummy",xstart,xend)
		i+=1
	while(1)
	Redimension/N=(i) wdest
End

Function SpectrumAverageXYonGraph(grname,dest)
	String grname,dest
	
	Variable xstart=hcsr(A)
	Variable xend=hcsr(B)
	
	String trnames=TraceNameList(grname,";",1)
	String txwave,tywave
	Variable i
	i=0
	Make/O $dest
	Wave wdest=$dest
	do
		tywave=StringFromList(i,trnames,";")
		if(strlen(tywave)==0)
			break
		endif
//		Wave wtwave=$twave
		wdest[i]=SpectrumAverageXY0(txwave,tywave,"dummy",0,0)
		i+=1
	while(1)
	Redimension/N=(i) wdest
End
