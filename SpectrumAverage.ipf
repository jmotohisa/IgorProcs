#pragma rtGlobals=3		// Use modern global access method and strict wave access.

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

Function SpectrumAverageXY0(ywave,xwave,target,xstart,xend)
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