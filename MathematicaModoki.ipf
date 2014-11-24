#pragma rtGlobals=1		// Use modern global access method.

//	mathematica modoki files
// 	idea on 2012/12/06

Macro JMinitMathModoki()
	String/G g_JM_plotWinName="JMPlotWindow"
	String/G g_JM_plotWaveName="JMPlotWave"
End

Macro JMPlot(cmd,x0,xn)
	String cmd="besselJ(1,x)"
	Variable x0=0,xn=5
	PauseUpdate; Silent 1
	
	String JM_plotWindowName=g_JM_plotWinName
	String JM_plotWaveName=g_JM_plotWaveName
	
	Make/O/D $JM_plotWaveName
	SetScale/I x,x0,xn,"",$JM_plotWaveName
	String cmd2=JM_plotWaveName + "="+cmd
	Execute cmd2
	If(strlen(winlist(JM_plotWindowName,";",""))==0)
		Display $JM_plotWaveName
		DoWindow/C $JM_plotWindowName
	Else
		DoWindow/F $JM_plotWindowName
	Endif
En