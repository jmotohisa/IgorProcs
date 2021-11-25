#pragma rtGlobals=1		// Use modern global access method.
//
// pickup x and y values of a wave pointed by cursol 
//
Menu "Macros"
	"Initialize Pickup/1", InitPickupCsrPt()
	"Pickup Cursol Point/2", PickupCsrPt()
	"Display Pickup Results/3",DispPickup()
	"-"
End

Macro DefineGrobal_PickUpCrsPt()
	String/G g_graphname, g_ywave,g_xwave,g_destwx,g_destwy
	Variable/G g_numpoints
End Macro

Macro InitPickupCsrPt(graphname,ywave,destwx,destwy)
	String graphname,ywave,destwx="destx",destwy="desty"
	Prompt graphname,"Graph pickup cursol point",popup,WinList("*",";","WIN:1")
	Prompt ywave,"Y wave name",popup,WaveList("*",";","WIN:"+graphname)
//	Prompt xwave,"x wave name",popup,"_Calculation;"+WaveList("*",";","WIN:"+graphname)
	Prompt destwx,"Destination wave for x-value"
	Prompt destwy,"Destination wave for y-value"
	PauseUpdate; Silent 1
	
	String xwave

	if(strlen(VariableList("g_numpoints",";",4))==0)
		DefineGrobal_PickUpCrsPt()
	endif
	DoWindow/F graphname
	ShowInfo
	xwave = xWaveName("",ywave)
	if(strlen(xwave)==0)
		Cursor/P A,$ywave,leftx($ywave)
	endif
	
	Make/D/O/N=1 $destwx,$destwy
	
	g_graphname = graphname
	g_ywave = ywave
	g_xwave = xwave
	g_destwx = destwx
	g_destwy = destwy
	g_numpoints = 0
	
End Macro

Macro PickupCsrPt()
	PauseUpdate; Silent 1
	
	g_numpoints +=1
	Redimension/N=(g_numpoints) $g_destwx
	Redimension/N=(g_numpoints) $g_destwy
	$g_destwx[g_numpoints-1] = hcsr(A)
	$g_destwy[g_numpoints-1] = vcsr(A)
End Macro

Macro DispPickup()
	Display $g_destwy vs $g_destwx
	ModifyGraph mode=3,marker=19
End

Function/s xWaveOfTrace(graphname,ywave,instance) // return x-wave name of the trace
	String graphname,ywave
	Variable instance
	
	String info = TraceInfo(graphname,ywave,instance),xwave=""
	Variable st
	st = strsearch(info,";",0)
	if(st==6)
		return xwave
	endif
	xwave = info[6,st-1]
	return xwave
End

