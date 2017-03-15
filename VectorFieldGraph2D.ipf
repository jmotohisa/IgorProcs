#pragma rtGlobals=1		// Use modern global access method.

// VectorFieldGraph2D.ipf
// based on example "Arrow Plot.pxp"
//
//	10/07/22 ver. 0.02a by J. Motohisa
//
//	revision history
//		10/07/22 ver 0.01a: first version
//		11/04/08 ver 0.01b: minor bug fixed
//		17/03/07 ver 0.02a: window reuse with

Macro XYWavesToVect(xwvnm,ywvnm,bname,scale)
	String xwvnm,ywvnm,bname
	Variable Scale=1
	PauseUpdate; Silent 1
	
	Variable i,j,rows=DimSize($xwvnm, 0),cols= DimSize($xwvnm, 1)
	String wx=  bname+"_X"
	String wy=  bname+"_Y"
	String wa=  bname+"_A"

//	String dfSav= GetDataFolder(1)
//	SetDataFolder GetWavesDataFolder(w,1)
	Make/O/N=(rows*cols) $wx
	Make/O/N=(rows*cols) $wy
	Make/O/N=(rows*cols,3) $wa

	SetDimLabel 1,2,headLen,$wa
	
	$wx= DimOffset($xwvnm, 0) +mod(p,rows) *DimDelta($xwvnm,0)
//	$wx= DimOffset($xwvnm, 0) +floor(p/rows) *DimDelta($xwvnm,0)
	$wy= DimOffset($xwvnm, 1) +floor(p/rows) *DimDelta($xwvnm,1)
	
	$wa[][0]= sqrt($xwvnm[p]^2+$ywvnm[p]^2)*scale
	$wa[][1]= atan2($ywvnm[p],$xwvnm[p])
	$wa[][2]= 1+2*sqrt($wa[P][0])
End

Macro ShowVectorFieldGraphXY(xwvnm,ywvnm,bname,scale,grname)
	String xwvnm,ywvnm,bname,grname
	Variable scale=1
	PauseUpdate;Silent 1
	
	String wx=  bname+"_X"
	String wy=  bname+"_Y"
	String wa=  bname+"_A"
	String cmd

	XYWavesToVect(xwvnm,ywvnm,bname,scale)
	if(strlen(WinList(grname,";",""))==0)
		Display /W=(27,103,563,525) $wy vs $wx
		if(strlen(grname)!=0)
			DoWindow/C $grname
		Endif
	else
		DoWindow/F $grname
	endif

//	DoWindow/C ArrowMarkerMethodGraph
	ModifyGraph mode=3,marker=19,msize=1		// default marker used when arrow too small
	ModifyGraph rgb=(0,0,0)
	cmd="ModifyGraph arrowMarker("+ wy+")={"+wa+",1,5,0.5,1};"
	Execute cmd
//	ModifyGraph arrowMarker(a_Y)={a_A,1,5,0.5,1}
//	AppendImage fake1
End

// below are taken from "ArrowPlot.ipf"

// Create synthetic data for arrow plot demo. Data is complex matrix of
// magnetic field from a number of 
Function MakeFakeData()
	Make/O/C/N=(20,20) fake1= 0
	SetScale x,0,1,"m",fake1
	SetScale y,0,1,"m",fake1		// one meter square
	
	AddWireField(fake1,0.3,0.7,1)
	AddWireField(fake1,0.4,0.7,1)
	AddWireField(fake1,0.5,0.7,1)
	AddWireField(fake1,0.5,0.4,-1)
	AddWireField(fake1,0.5,0.3,-1)
	AddWireField(fake1,0.5,0.2,-1)
End



// B(webers/m^2)= u0*i/(2*pi*r); i in amps, r in meters
// B(gauss)= 10^4*(weber/m^2)
// u0= 4*pi*10^-7 w/(amp-meter)


Function AddWireField(w,xpos,ypos,current)
	Wave/C w					// 2D complex wave of x and y mag field components
	Variable xpos,ypos			// position in plane of wire
	Variable current			// mag and direction of current (amps)
	
	Variable i,j,nrows=DimSize(w, 0),ncols= DimSize(w, 1)

	
	for(i=0;i<nrows;i+=1)
		for(j=0;j<ncols;j+=1)
			Variable x= DimOffset(w, 0) + i *DimDelta(w,0)
			Variable y= DimOffset(w, 1) + j *DimDelta(w,1)
			Variable dx= x-xpos
			Variable dy= y-ypos
			
			Variable r= sqrt(dx^2+dy^2)
			//r= (r==0) ? 0 : 2*abs(current)/r
			r= (r<1e-8) ? 0 : 2*abs(current)/r
			Variable theta= atan2(dy,dx)+((current>0) ? pi/2 : -pi/2)
			Variable/C c= cmplx(r,theta)
			w[i][j] += p2rect(c)
		endfor
	endfor
End

Function CWaveToVect(w,bname,scale)
	Wave/C w					// 2D complex wave of x and y mag field components
	String bname				// base name of output waves
	Variable scale				// multiplier for arrow length
	
	Variable i,j,rows=DimSize(w, 0),cols= DimSize(w, 1)

	String dfSav= GetDataFolder(1)
	SetDataFolder GetWavesDataFolder(w,1)
	
	Make/O/N=(rows*cols) $bname+"_X"
	Wave wx=  $bname+"_X"
	Make/O/N=(rows*cols) $bname+"_Y"
	Wave wy=  $bname+"_Y"
	Make/O/N=(rows*cols,3) $bname+"_A"
	Wave wa=  $bname+"_A"

	SetDimLabel 1,2,headLen,wa
	
	wx= DimOffset(w, 0) +mod(p,rows) *DimDelta(w,0)
	wy= DimOffset(w, 1) +floor((p/cols)) *DimDelta(w,1)
	
	wa[][0]= real(r2polar(w[p]))*scale
	wa[][1]= imag(r2polar(w[p]))
	wa[][2]= 1+2*sqrt(wa[P][0])
end


// Creates a Legend of sorts using drawing tools. To adjust position, select the whole
// thing and drag (using arrow tool in drawing toolbar).
Function AppendArrowLegend(x0,y0,aLen,phys,units)
	Variable x0,y0		// location in Points of top left of legend
	Variable aLen		// length of arrow in Points
	Variable phys		// physical quantity represented by aLen
	String units			// units
	
	SetDrawEnv xcoord= abs,ycoord= abs
	DrawRect x0-10,y0-10,x0+aLen+10,y0+30
	SetDrawEnv xcoord= abs,ycoord= abs,arrow= 1,arrowlen= 1+2*sqrt(aLen)
	DrawLine x0,y0,x0+aLen,y0
	String s
	sprintf s,"%g %s",phys,units
	SetDrawEnv xcoord= abs,ycoord= abs,textxjust= 1,textyjust= 2,fname= "default"
	DrawText x0+aLen/2,y0+10,s
End

Function MaxMag(cw)
	Wave/C cw
	
	Duplicate cw,maxmag_TMP
	
	Redimension/R maxmag_TMP
	maxmag_TMP= sqrt(magsqr(cw))
	WaveStats/Q maxmag_TMP
	KillWaves maxmag_TMP
	
	return V_Max
end


Proc DemoArrowMarkerMethod()
	DoWindow/F ArrowMarkerMethodGraph
	if( V_Flag )
		return 0		// graph already exists
	endif
	MakeFakeData()
	CWaveToVect(fake1,"a",.5)	// creates a_X, a_Y, a_A

	Display /W=(27,103,563,525) a_Y vs a_X
	DoWindow/C ArrowMarkerMethodGraph
	ModifyGraph mode=3,marker=19,msize=1		// default marker used when arrow too small
	ModifyGraph rgb=(0,0,0)
	ModifyGraph arrowMarker(a_Y)={a_A,1,5,0.5,1}
	AppendImage fake1
	ModifyImage fake1 ctab= {*,*,BlueRedGreen,0}
	AppendArrowLegend(72*6.0,72*0.5,50,100,"gauss")
End

Window ArrowMarkerMethodGraph() : Graph
	PauseUpdate; Silent 1		// building window...
	Display /W=(70,54,606,476) a_Y vs a_X
	AppendImage fake1
	ModifyImage fake1 ctab= {*,*,BlueRedGreen,0}
	ModifyGraph mode=3
	ModifyGraph marker=19
	ModifyGraph rgb=(0,0,0)
	ModifyGraph msize=1
	ModifyGraph arrowMarker(a_Y)={a_A,1,5,0.5,1}
	ModifyGraph mirror=0
	SetDrawLayer UserFront
	SetDrawEnv xcoord= abs,ycoord= abs
	DrawRect 390,52,460,92
	SetDrawEnv xcoord= abs,ycoord= abs,arrow= 1,arrowlen= 15.1421
	DrawLine 400,62,450,62
	SetDrawEnv xcoord= abs,ycoord= abs,fname= "default",textxjust= 1,textyjust= 2
	DrawText 425,72,"100 gauss"
EndMacro

Window ArrowMarkerMethodGraph2() : Graph
	PauseUpdate; Silent 1		// building window...
	Display /W=(27,103,563,525) a_Y vs a_X
	AppendImage fake1
	ModifyImage fake1 ctab= {*,*,BlueRedGreen,0}
	ModifyGraph mode=3
	ModifyGraph marker=19
	ModifyGraph rgb=(0,0,0)
	ModifyGraph msize=1
	ModifyGraph arrowMarker(a_Y)={a_A,1,5,0.5,1}
	ModifyGraph mirror=0
EndMacro
