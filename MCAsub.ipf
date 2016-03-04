#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//	MCAsub.ipf
//	for analysis of TCSPC data
//	16/02/23 ver. 0.02 by J. Motohisa
//
//	revision history
//		16/02/22	ver 0.01	extracted from loadMCAChnfile.ipf
//		16/02/23	ver 0.02	code added from IgorExchange for fitting and deconvolution of IRF

// note: more pricely, data starts with <<DATA>> and ended with <<END>>

Macro ScaleChn(waveName,gain,range)
	String waveName
	Variable/D gain=10,range = 50
	Prompt waveName,"waveName",popup,WaveList("chn*", ";", "")
	Prompt gain,"TAC Gain"
	Prompt range,"TAC Range (nsec)"
	
	Silent 1; PauseUpDate

	Variable/D dt
	
	WaveStats/Q $waveName
	dt = range/ gain*1e-9/V_npnts
	SetScale /P x,0,dt,"sec",$waveName
End Macro

Macro DisplayChn(waveName)
	String waveName
	Prompt waveName,"waveName",popup,WaveList("chn*", ";", "")
	
	Silent 1; PauseUpDate
	Display $waveName
	ModifyGraph log(left)=1
End Macro

Macro DisplayChnAll()
	Silent 1; PauseUpDate
	variable index=0
	String chnlist = WaveList("chn*",";","")
	String waveName
	do
		waveName = GetStrFromList(chnlist,index,";")
		if(strlen(waveName) ==0)
			break
		endif
		DisplayChn(waveName)
		index +=1
	while(1)
End Macro

Macro ShiftXChn(waveName,x0,gain,range)
	String waveName
	Variable/D x0=0,gain=10,range = 50
	Prompt waveName,"waveName",popup,WaveList("chn*", ";", "")
	Prompt x0,"Number of x points for shift (from 0)"
	Prompt gain,"TAC Gain"
	Prompt range,"TAC Range (nsec)"
	
	Silent 1; PauseUpDate

	Variable/D dt

	WaveStats/Q $waveName
	dt = range/ gain*1e-9/V_npnts
	x0 = -x0*dt
	SetScale /P x,x0,dt,"sec",$waveName
End Macro

Macro DupAndSmChn(waveName)
	String waveName
	Prompt waveName,"chn wave name to duplicate and smooth",popup,WaveList("chn*", ";", "")

	Silent 1; PauseUpDate
	
	String tmp,str
	
	tmp = waveName + "_s"
	duplicate/O $waveName,$tmp
	
	Smooth 5,$tmp
	Display /W=(5,42,617,439) $tmp
	ModifyGraph log(left)=1
	SetAxis bottom 5e-10,3e-09
	str = "\s("+tmp+") " + tmp + "\r"
	Tag/N=text0/F=0/X=90.04/Y=-30.07/L=0 $tmp, 0,str

	ShowInfo
End Macro

Macro TRPLfit(waveName,k0flag,apflag,aflag)
// fitting by single exponential with k0=0
	String waveName
	Variable k0flag=2,aflag=1,apflag = 1
	Prompt waveName,"wave name",popup,WaveList("chn*", ";", "WIN:")
	Prompt k0flag,"Set K0 to be 0",popup,"yes;no"
	Prompt apflag,"Append as new fit results?",popup,"yes;no"
	Prompt aflag,"Display Fit Results ?",popup,"yes;no"

	Silent 1; PauseUpDate
	
// curve fit result a0+a1*exp(-t/tau)
	String str_tau,str_a0,str_a1
	String str_textbox,str_fitres="fitres",annonlist,str
	Variable/D tauinv
	Variable index = 0

	annonlist = AnnotationList("")
	do
		str = str_fitres + num2istr(index)
		if(strsearch(annonlist,str,0)<0)
			break
		endif
		index +=1
	while(1)
	
	if(k0flag==1)
		K0=0
		CurveFit/Q/H="100" exp $waveName(xcsr(A),xcsr(B)) /D
		tauinv = 1/W_coef[2]*1e12
//		str_a0 = MakeValueReportString(W_coef[0],0,0,"",1)
		str_a1 = MakeValueReportString(W_coef[1],0,0,"",1)
		str_tau = MakeValueReportString(tauinv,0,0,"psec",1)
		str_textbox = "tau = " + str_tau + "\r"
//		str_textbox = str_textbox + "a0=" + str_a0 + "\r"
		str_textbox = str_textbox + "a1=" + str_a1
	else
		CurveFit/Q exp $waveName(xcsr(A),xcsr(B)) /D
		tauinv = 1/W_coef[2]*1e12
		str_a0 = MakeValueReportString(W_coef[0],0,0,"",1)
		str_a1 = MakeValueReportString(W_coef[1],0,0,"",1)
		str_tau = MakeValueReportString(tauinv,0,0,"psec",1)
		str_textbox = "tau = " + str_tau + "\r"
		str_textbox = str_textbox + "a0=" + str_a0 + "\r"
		str_textbox = str_textbox + "a1=" + str_a1
	endif
//	Print "number of iteration is = "//,V_FitNumIters

	if(apflag==1 %| index==0) then
		Textbox/N=$str/F=0/A=MC/X=26.52/Y=28.30 str_textbox
	else
		index -=1
		str = str_fitres + num2istr(index)
		Textbox/C/N=$str/F=0/A=MC/X=26.52/Y=28.30 str_textbox
	endif

	if(aflag==1)
		AppendFitResults(waveName,index)
	endif
End Macro

Macro TRPLfit2(waveName,k0flag,apflag,aflag)
// fitting by double exponential
	String waveName
	Variable k0flag=2,aflag=1,apflag = 1
	Prompt waveName,"wave name",popup,WaveList("chn*", ";", "WIN:")
	Prompt k0flag,"Set K0 to be 0",popup,"yes;no"
	Prompt apflag,"Append as new fit results?",popup,"yes;no"
	Prompt aflag,"Display Fit Results ?",popup,"yes;no"

	Silent 1; PauseUpDate
	
// curve fit result a0+a1*exp(-t/tau1) + a2 * exp(-t/tau2)
	String str_tau1, str_tau2,str_a0,str_a1,str_a2
	String str_textbox,str_fitres="fitres",annonlist,str
	Variable/D tau1inv,tau2inv
	Variable index = 0

	annonlist = AnnotationList("")
	do
		str = str_fitres + num2istr(index)
		if(strsearch(annonlist,str,0)<0)
			break
		endif
		index +=1
	while(1)
	
	if(k0flag==1)
		K0=0
		CurveFit/Q/H="10000" dblexp $waveName(xcsr(A),xcsr(B)) /D
		tau1inv = 1/W_coef[2]*1e12
		tau2inv = 1/W_coef[4]*1e12
//		str_a0 = MakeValueReportString(W_coef[0],0,0,"",1)
		str_a1 = MakeValueReportString(W_coef[1],0,0,"",1)
		str_tau1 = MakeValueReportString(tau1inv,0,0,"psec",1)
		str_a2 = MakeValueReportString(W_coef[3],0,0,"",1)
		str_tau2 = MakeValueReportString(tau2inv,0,0,"psec",1)
		str_textbox = "tau1 = " + str_tau1 + "\r"
		str_textbox = str_textbox + "tau2 = " + str_tau2 + "\r"
//		str_textbox = str_textbox + "a0=" + str_a0 + "\r"
		str_textbox = str_textbox + "a1=" + str_a1 + "\r"
		str_textbox = str_textbox + "a2=" + str_a2
	else
		CurveFit/Q dblexp $waveName(xcsr(A),xcsr(B)) /D
		tau1inv = 1/W_coef[2]*1e12
		tau2inv = 1/W_coef[4]*1e12
		str_a0 = MakeValueReportString(W_coef[0],0,0,"",1)
		str_a1 = MakeValueReportString(W_coef[1],0,0,"",1)
		str_tau1 = MakeValueReportString(tau1inv,0,0,"psec",1)
		str_a2 = MakeValueReportString(W_coef[3],0,0,"",1)
		str_tau2 = MakeValueReportString(tau2inv,0,0,"psec",1)
		str_textbox = "tau1 = " + str_tau1 + "\r"
		str_textbox = str_textbox + "tau2 = " + str_tau2 + "\r"
		str_textbox = str_textbox + "a0=" + str_a0 + "\r"
		str_textbox = str_textbox + "a1=" + str_a1 + "\r"
		str_textbox = str_textbox + "a2=" + str_a2
	endif
//	Print "number of iteration is = "//,V_FitNumIters

	if(apflag==1 %| index==0) then
		Textbox/N=$str/F=0/A=MC/X=26.52/Y=28.30 str_textbox
	else
		index -=1
		str = str_fitres + num2istr(index)
		Textbox/C/N=$str/F=0/A=MC/X=26.52/Y=28.30 str_textbox
	endif

	if(aflag==1)
		AppendFit2Results(waveName,index)
	endif
End Macro

Macro DefineGrobal_ExpFit()
	String/G g_graphname
	String/G g_stdwave
	String/G g_origWaveList
	String/G g_dstwave
	Variable/G g_ymin,g_ymax,g_offset
EndMacro

Macro InitExpFit(waveName)
| initialization for Exponential Fit
|	String grname=WinName(0, 1)
	String waveName=WaveName("",0,1)
|	Prompt grname,"Graph to create multiple axes",popup,WinList("*",";","WIN:1")
	Prompt swave,"Wave name to fit",popup,WaveList("chn*",";","")
|	Prompt gnewname,"New graph name"
	PauseUpdate; Silent 1
	
	String grname
	
	grname = "ExpFit:"+waveName
	g_stdwave=waveName
	g_graphname=grname
|	g_origWaveList=WaveList("*",";","WIN:"+grname)
	Display /W=(3,41,636,476) $waveName
	DoWindow/C "ExpFit:"+waveName
EndMacro

Macro ExpFit_Step1(waveName,grname,smflag)

End Macro

Macro AppendFitResults(waveName,index)
	String waveName
	Variable index
	Prompt waveName,"wave name",popup,WaveList("chn*", ";", "WIN:")
	Prompt index,"index"
	
	String wave2
	
	wave2 = "fit0_" + num2istr(index) + "_"+ waveName
	Duplicate/O $waveName,$wave2
	
	$wave2 = W_coef[0] + W_coef[1] * exp(-W_coef[2]*x)	
	if(strsearch(WaveList("*",";","WIN:"),wave2,0)<0) 
		AppendToGraph $wave2
		ModifyGraph rgb($wave2)=(0,0,65535)
	endif
End Macro

Macro AppendFit2Results(waveName,index)
	String waveName
	Variable index
	Prompt waveName,"wave name",popup,WaveList("chn*", ";", "WIN:")
	
	String wave2
	
	wave2 = "fit0_" + num2istr(index) + "_"+ waveName
	Duplicate/O $waveName,$wave2
	
	$wave2 = W_coef[0] + W_coef[1] * exp(-W_coef[2]*x) + W_coef[3] * exp(-W_coef[4]*x)
	if(strsearch(WaveList("*",";","WIN:"),wave2,0)<0) 
		AppendToGraph $wave2
		ModifyGraph rgb($wave2)=(0,0,65535)
	endif
End Macro

///////////////////////////////////////////// 
 // taken from http://www.igorexchange.com/node/4201

Function MakeGraph()
	// assumes that waves IRF and Decay_1 already exist in current dataFolder
	string sDecayWave = "Decay_1"
	string sIRFWave = "IRF"
	// Reference these waves
	wave wDecay = $sDecayWave
	wave wIRF = $sIRFWave
	// Make the plot and assign trace names
	Display wIRF/TN=IRF, wDecay/TN=Decay
	ModifyGraph mode=2, rgb(IRF)=(0,0,65280)
	ModifyGraph log(left)=1, mirror(left)=1, minor(left)=1
	ModifyGraph mirror=1, minor=1
	// display and set cursors
	ShowInfo 
	WaveStats/Q wDecay
	Cursor/A=1/H=2 A, Decay, V_maxloc
	Cursor/A=1/H=2 B, Decay, 2500
End
 
Function TCSPC_Fit()
	// assumes that waves IRF and Decay_1 already exist in current dataFolder
	string sDecayWave = "Decay_1"
	string sIRFWave = "IRF"
	// Reference these waves
	wave wDecay = $sDecayWave
	wave wIRF = $sIRFWave
	// Make a normalised IRF wave
	Duplicate/O wIRF, wIRF_N
	variable vSum = sum(wIRF, -inf, inf)
	wIRF_N[] /= vSum
	// Make Fit-related waves
	Duplicate/O wDecay,wWeight
	wWeight[] = 1 / sqrt(wWeight[p]) // weighting is from shot noise - set to 1/stdev for each data point
	Make/O/N=5 W_coef, W_sigma
	Make/O/N=1 W_fitConstants // the x-axis offset
	// run non-convolution curve fit first to effectively get a set of starting parameters
	W_coef[0] = 0 // hold offset at zero
 
//	This would be for a single exponentail fit:	
//	CurveFit/H="100"/NTHR=0/L=(pcsr(B)-pcsr(A)+1) exp_XOffset, kwCWave=W_coef, wDecay[pcsr(A),pcsr(B)] /D /R /W=wWeight
 
//	This is for a double exponential fit:
	CurveFit/H="10000"/NTHR=0/L=(pcsr(B)-pcsr(A)+1) dblexp_XOffset, kwCWave=W_coef, wDecay[pcsr(A),pcsr(B)] /D /R /W=wWeight
 
	string sFitDecay="fit_"+sDecayWave
	wave wFit=$sFitDecay
	ModifyGraph rgb($sFitDecay)=(0,65280,0)
	Make/O/N=5 wFitParams
	wFitParams[]=W_coef[p]
	FuncFit/NTHR=0/L=(pcsr(B)-pcsr(A)+1) TCSPC_Convolution,wFitParams, wDecay[pcsr(A),pcsr(B)] /D /R /W=wWeight
End
 
Function TCSPC_Convolution(wFitParams,yw,xw) : FitFunc
	Wave wFitParams,yw,xw
	wave wIRF_N
	// make exponential decay wave
	Make/O/N=(pcsr(B) - pcsr(A) + 1) wExpDecay
	wExpDecay[] = wFitParams[0] + wFitParams[1] * exp(- x / wFitParams[2])
// 	This is for 2-exponential fit only:
	wExpDecay[] += wFitParams[3] * exp(- x / wFitParams[4])
 
	//Convolve with IRF
	Convolve wIRF_N, wExpDecay
	//assign the result (note: offset due to cursor fit range)
	yw[] = wExpDecay[p + pcsr(A)]
End