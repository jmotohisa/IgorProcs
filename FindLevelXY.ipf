#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function FindLevelXY(yWv,xWv,levelToFind)
	String yWv,xWv
	Variable levelToFind
	
	// assume iwvname and lwavename are sorted
	Wave ydata=$yWv
	Wave xdata=$xWv

	FindLevel yData, levelToFind
 // Compute point number (not X) in yData before Y crossing.
	Variable p1=x2pnt(yData,V_LevelX-deltaX(yData)/2)

// Compute slope of line between the two X,Y points before and after the yData level crossing.
	Variable m=(V_LevelX-pnt2x(yData,p1))/(pnt2x(yData,p1+1)-pnt2x(yData,p1))

// Use the point-slope equation of a line to interpolate the xData value at the level crossing.
	Variable xAtYlevel= xData[p1] + m * (xData[p1+1] -xData[p1] ) //point-slope equation
	return(xAtYlevel)
End
