#pragma rtGlobals=1		// Use modern global access method.
#include "areaXYcursor"
#include "FindLevelXY"
#include "MatrixOperations2"

// collection of macro for LED analysis
// by J. Motohisa

//	revision history
//	ver 0.1	11/06/04-10	start writing procedure

// analysis of I-L

// Basic procedure

// spwv0: spectral wave ( default: ???_1)
// wlwv0: wavelength wave (default: ???_0)
// ivwv0 : I-V wave (default: ???_0_0)
Function ShowIL(spwv0,wlwv0,ivwv0)
	String spwv0,wlwv0,ivwv0
	
	MatrixWavePlotFunc(spwv0,1,1,wlwv0)
//	MakeMeshDataForNonUnifMesh("W14_0","W14_l")
	String lwv0="LW"+spwv0
	AreaCsr_AllTrace(lwv0,"LnW"+spwv0)
	print WaveExists($lwv0),WaveExists($ivwv0)
	Display $lwv0 vs $ivwv0
End

Macro WaveIntegrateIntesity(wvname,dest,start,stop)
	String wvname,dest
	Variable start=-1,stop=-1
	PauseUpdate; Silent 1
End

Macro ILplottemp(prefix)	
	String prefix
	MatrixWavePlot("W"+prefix+"_1",1,1,"W"+prefix+"_0")
	AreaCsr_AllTrace("LW"+prefix,"LnW"+prefix)
	DisplayILfunc(prefix,1)
End

Function DisplayILfunc(prefix,iflag)
	String prefix
	Variable iflag
	
	String lwvn="LW"+prefix,iwvn="il"+prefix+"_0_0"
	Wave Lwv=$lwvn
	Wave Iwv=$iwvn
	if(iflag==2)
		AppendToGraph Lwv vs Iwv
	else
		Display Lwv vs Iwv
	Endif
End

Macro DisplayIL(prefix,iflag)
	String prefix
	Variable iflag=1
	Prompt prefix,"prefix"
	Prompt iflag,"display or append",popup,"display;append"
	PauseUpdate; Silent 1
	DisplayILfunc(prefix,iflag)
End

// anlalysis of Rs and n-factor

Macro InitializeRsAnalysis(prefix,namewave,rswave,nvalwave)
	String prefix="IV",
	String namewave="IVWname_LED",rswave="Rs_LED",nvalwave="n_LED"
	PauseUpdate;Silent 1

	String/G g_prefix=prefix
	String/G g_wvname
	String/G g_namewave=namewave,g_rswave=rswave,g_nvalwave=nvalwave
	String/G g_tablename="IVAnalysisResults"
	
	Make/O/T/N=1 $namewave
	Make/O/N=1 $rswave,$nvalwave
	Edit $namewave,$rswave,$nvalwave
	if(strsearch(WinList("*",";","WIN:4"),g_tablename,0)==0)
		DoWindow/F $g_tablename
	else
		DoWindow/C $g_tablename
	endif
End

// step 1 :display graph
Macro DoanalizeRs(wvname)
	String wvname
	Prompt wvname,"IV wave name",popup,WaveList(g_prefix+"*",";","")
	PauseUpdate;Silent 1
	
	String xwvname="x"+wvname,didv="d"+wvname,legtxt=wvname
	String gname="GraphIV_"+wvname
	Duplicate/O $wvname,$xwvname
	SetScale d 0,1,"V", $xwvname
	$xwvname=x
	Differentiate $xwvname/X=$wvname /D=$didv
	$didv*=$wvname
	Display/W=(679,44,1230,502) $didv vs $wvname
	DoWindow/C $gname
	AppendToGraph/R $xwvname vs $wvname
	ModifyGraph gfSize=24
	TextBox/C/N=text0/F=0/A=MC legtxt
	Label bottom "Current (\U)"
	Label left "I dV/dI (\U)"
	Label right "Voltage (\U)"
	ModifyGraph rgb($xwvname)=(0,0,65535)
	ShowInfo
	g_wvname=wvname
End

// step2: after put cursol on didv curve (red)
Macro DoanalizeRs2(wvname)
	String wvname=g_wvname
	Prompt wvname,"IV wave name",popup,WaveList(g_prefix+"*",";","")
	PauseUpdate; Silent 1
	
	String xwvname="x"+wvname,didv="d"+wvname,legtxt,fitwvname="fit_d"+wvname
	Variable nn=DimSize($g_namewave,0)
	g_wvname=wvname
	
	if (strlen(CsrWave(A))>0 && strlen(CsrWave(B))>0) // Cursors are on trace?
//		CurveFit/Q/NTHR=0/TBOX=768 line  $didv [pcsr(A),pcsr(B)] /X=$wvnamae /D
		CurveFit/X=1/Q/NTHR=0 line  $didv [pcsr(A),pcsr(B)] /X=$wvname /D
		print "Rs=",W_coef[1], "n=",W_coef[0]/0.026
		sprintf legtxt,"%s, Rs=%f, n=%f",wvname,W_coef[1],W_coef[0]/0.026
		TextBox/C/N=text0/F=0/A=MC legtxt
	
		$g_namewave[nn-1]=wvname
		$g_rswave[nn-1]=W_coef[1]
		$g_nvalwave[nn-1]=W_coef[0]/0.026
		Redimension/N=(nn+1) $g_namewave,$g_rswave,$g_nvalwave
		DoWindow/F $g_tablename
		ModifyGraph lstyle($xwvname)=2,rgb($xwvname)=(0,0,0)
		ModifyGraph lstyle($xwvname)=0,rgb($xwvname)=(0,0,65535)
		ModifyGraph lstyle($fitwvname)=3,rgb($fitwvname)=(0,0,0)
		ModifyGraph tick=2,mirror(bottom)=1
		ModifyGraph lblMargin(left)=26,lblMargin(right)=23
		ModifyGraph manTick(bottom)={0,5,-3,0},manMinor(bottom)={4,50}
	else
		print "Put cursor on dI/dv plot (red)."
	endif
End

Macro AppendFit_VI(wvname,I0,nval,rs,appendf)
	String wvname=g_wvname
	Variable i0=12e-8,nval=7,rs=60
	Variable appendf=1
	Prompt wvname,"IV wave name",popup,WaveList(g_prefix+"*",";","")
	Prompt i0,"I0"
	Prompt nval,"n value"
	Prompt rs, "Rs"
	Prompt appendf,"append ?",popup,"yes;no"
	PauseUpdate; Silent 1

	String wvname_fit2=wvname+"_fit2",wvname_fit2_v=wvname+"_fit2_v"
	g_wvname=wvname
	Duplicate/O $wvname,$wvname_fit2
	$wvname_fit2=func_Idiode_FactRs(x,I0,1/(nval*0.0258),rs)
	Duplicate/O $wvname_fit2,$wvname_fit2_v
	$wvname_fit2_v=x
	if(appendf==1)
		Append/R $wvname_fit2_v vs $wvname_fit2
		ModifyGraph lStyle($wvname_fit2_v)=1,lsize=2
		ModifyGraph rgb($wvname_fit2_v)=(0,0,0)
	endif
End

Function FindIntensityAtCurrent(iwvname,lwvname,levelToFind)
	String iwvname,lwvname
	Variable levelToFind
	
	return(FindLevelXY(iwvname,lwvname,levelToFind))
End
