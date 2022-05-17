#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Arrow (vector) plot of the XY data
// scale: parameter related to the length of the arrow

Function FFieldArrowPlotXY(xdata,ydata,scale,num)
	String xdata,ydata
	Variable scale,num

	Variable nx=DimSize($xdata,0),ny=DimSize($xdata,1)
	Duplicate/O $xdata,wxtemp
	Duplicate/O $ydata,wytemp
	Duplicate/O $xdata,xcoordtemp
	Duplicate/O $xdata,ycoordtemp
	xcoordtemp=x
        ycoordtemp=y
        Redimension/N=(nx*ny) wxtemp
        Redimension/N=(nx*ny) wytemp
        Redimension/N=(nx*ny) xcoordtemp
        Redimension/N=(nx*ny) ycoordtemp
        Make/O/N=(nx*ny,2) wtempdata
        wtempdata[][0]=sqrt(wxtemp[p]*wxtemp[p]+wytemp[p]*wytemp[p])*scale
        wtempdata[][1]=atan2(wytemp[p],wxtemp[p])

        String grname="vectorGraph"
        If(strlen(winlist(grname,";",""))==0)
                Display ycoordtemp vs xcoordtemp
                DoWindow/C $grname
        Else
                DoWindow/F $grname
        endif

	ModifyGraph mode(ycoordtemp) = 3        // Marker mode
	ModifyGraph arrowMarker(ycoordtemp) = {wtempdata, 1, 10, 1, 1}
        ModifyGraph height={Aspect,1}
        ModifyGraph tick=3,noLabel=2,standoff=0
        ModifyGraph axThick=0

End
