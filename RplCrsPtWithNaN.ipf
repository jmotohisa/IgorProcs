#pragma rtGlobals=1		// Use modern global access method.//// pickup x and y values from multiple waves in a graph//// ver 0.4 12/04/25//// ver 0.2 RplCrsPtWithAvr added// ver 0.3 11/09/15 RplCrsPtWithAvr2 added// ver 0.4 12/04/25 RplCrsPtWithAvr2 is now compatible with matrix wave (WaveDims=2)Menu "Macros"	"-"	"Initialize RplCrsPtWithNaN/1", InitRplNaN()	"RplCrsPtWithNaN/2", RplCrsPtWithNaN()	"RplCrsPtWithAvr/3", RplCrsPtWithAvr()	"RplCrsPtWithAvr2/4", RplCrsPtWithAvr2()	"Undo/5",UndoRplNaN()//	"-"//	"RplCrsPtWithAvr3/6", RplCrsPtWithAvr3()	"-"	EndMacro DefineGrobal_PickupCsrPt()	String/G g_destwx,g_destwy,g_destwn	Variable/G g_numpointsEnd MacroMacro InitRplNaN(destwx,destwy,destwn)	String graphname,destwx="rplx",destwy="rply",destwn="rplnm"	Prompt destwx,"Destination wave for x-value"	Prompt destwy,"Destination wave for y-value"	Prompt destwn,"oringal wave name"	PauseUpdate; Silent 1		Make/D/O/N=1 $destwx,$destwy	Make/T/O/N=1 $destwn		g_destwx = destwx	g_destwy = destwy	g_destwn = destwn	g_numpoints = 0End MacroMacro RplCrsPtWithNaN()	PauseUpdate; Silent 1	String wv,wv2	Variable xpnt		g_numpoints +=1	Redimension/N=(g_numpoints) $g_destwx	Redimension/N=(g_numpoints) $g_destwy	Redimension/N=(g_numpoints) $g_destwn	wv=CsrWave(A)	String csrref=StringByKey("TNAME",CsrInfo(A))	Variable index2	index2=NumberByKey(wv,csrref,"#")	xpnt = pcsr(A)//	print wv,xpnt	if(WaveDims($wv)==1)		$g_destwx[g_numpoints-1] = xpnt		$g_destwy[g_numpoints-1] = vcsr(A)		$g_destwn[g_numpoints-1] = wv		$wv[xpnt]=NaN	else		if(WaveDims($wv)==2)			$g_destwx[g_numpoints-1] = xpnt			$g_destwy[g_numpoints-1] = vcsr(A)			$g_destwn[g_numpoints-1] = wv			$wv[xpnt][index2]=NaN		endif	endifEnd MacroMacro RplCrsPtWithAvr()	PauseUpdate; Silent 1	String wv	Variable xpnt,np		g_numpoints +=1	Redimension/N=(g_numpoints) $g_destwx	Redimension/N=(g_numpoints) $g_destwy	Redimension/N=(g_numpoints) $g_destwn	wv=CsrWave(A)	xpnt = pcsr(A)//	print wv,xpnt	$g_destwx[g_numpoints-1] = xpnt	$g_destwy[g_numpoints-1] = vcsr(A)	$g_destwn[g_numpoints-1] = wv	$wv[xpnt]=($wv[xpnt-1]+$wv[xpnt+1])/2End MacroMacro UndoRplNaN()	PauseUpdate; Silent 1	String wv	Variable xpnt		wv=$g_destwn[g_numpoints]	xpnt = $g_destwx[g_numpoints]	$wv[xpnt] = $g_destwy[g_numpoints]	g_numpoints -=1	Redimension/N=(g_numpoints) $g_destwx	Redimension/N=(g_numpoints) $g_destwy	Redimension/N=(g_numpoints) $g_destwnEnd MacroMacro DispRplTable()	PauseUpdate; Silent 1	Edit $g_destwx,$g_destwy,$g_destwnEnd MacroMacro UndoRplNanAtNum(xpnt)	Variable xpnt	PauseUpdate;Silent 1	String wv		wv=$g_destwn[xpnt]	$wv[xpnt] = $g_destwy[xpnt]End MacroMacro RplCrsPtWithAvr2_0() /// Obsolete routine	PauseUpdate; Silent 1	String wv	Variable xpnt,xpnt1,xpnt2,np,index,ypnt1,ypnt2	//	g_numpoints +=1//	Redimension/N=(g_numpoints) $g_destwx//	Redimension/N=(g_numpoints) $g_destwy//	Redimension/N=(g_numpoints) $g_destwn	if(strlen(CsrInfo(A))<=0 || strlen(CsrInfo(B))<=0)		return	endif	wv=CsrWave(A)	xpnt1 = pcsr(A)	xpnt2 = pcsr(B)//	print wv,xpnt//	$g_destwx[g_numpoints-1] = xpnt//	$g_destwy[g_numpoints-1] = vcsr(A)//	$g_destwn[g_numpoints-1] = wv	ypnt1 = vcsr(A)	ypnt2 = vcsr(B)	if(xpnt1>xpnt2)		xpnt=xpnt1		xpnt1=xpnt2		xpnt2=xpnt		ypnt2 = vcsr(A)		ypnt1 = vcsr(B)	endif	xpnt=xpnt1	do		$wv[xpnt]=ypnt1+(ypnt2-ypnt1)/(xpnt2-xpnt1)*(xpnt-xpnt1)		xpnt+=1	while(xpnt<xpnt2)End Macro/// As of 2012/04/25, spectral dip appears at xpnt=649 and 1070, so tweak them by taking averageFunction tweakaSpectrum0(wvname,index)	String wvname	Variable index		Wave wv=$wvname	if(WaveDims(wv)==1)		wv[index]=(wv[index+1]+wv[index-1])/2	else		if(WaveDims(wv)==2)			wv[index][]=(wv[index+1][q]+wv[index-1][q])/2		endif	endif	EndFunction tweakaSpectrum(wvname)	String wvname	Variable index		tweakaSpectrum0(wvname,649)	tweakaSpectrum0(wvname,1070)End///Function RplCrsPtWithAvr2()	String wv	Variable xpnt,xpnt1,xpnt2,np,index,ypnt1,ypnt2		if(strlen(CsrInfo(A))<=0 || strlen(CsrInfo(B))<=0)		return 0	endif	wv=CsrWave(A)	Wave ww=$wv	xpnt1 = pcsr(A)	xpnt2 = pcsr(B)	ypnt1 = vcsr(A)	ypnt2 = vcsr(B)	if(xpnt1>xpnt2)		xpnt=xpnt1		xpnt1=xpnt2		xpnt2=xpnt		ypnt2 = vcsr(A)		ypnt1 = vcsr(B)	endif	xpnt=xpnt1	String csrref=StringByKey("TNAME",CsrInfo(A)),s2	Variable index0,index2	if(strlen(csrref)==strlen(wv))		index2=0	else		index2=NumberByKey(wv,csrref,"#")	endif	if(WaveDims($wv)==1)		do			ww[xpnt]=ypnt1+(ypnt2-ypnt1)/(xpnt2-xpnt1)*(xpnt-xpnt1)			xpnt+=1		while(xpnt<xpnt2)	else		if(waveDims($wv)==2)//			print index2			do				ww[xpnt][index2]=ypnt1+(ypnt2-ypnt1)/(xpnt2-xpnt1)*(xpnt-xpnt1)				xpnt+=1			while(xpnt<xpnt2)		endif	endifEnd