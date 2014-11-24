#pragma rtGlobals=1		// Use modern global access method.

// Fitting of IV in diodes
// by J. Motohisa

//	revision history
//	ver 0.1	11/09/21	start writing procedure

// initialize
Macro Initial_diodefit(prefix,namewave,I0wave,nvalwave,Rswave,Rshwave)
	String prefix="IV"
	String namewave="IVWname_diode",I0wave="I0_diode"
	String nvalwave="n_diode",Rswave="Rs_diode",Rshwave="Rsh_diode"
	PauseUpdate; Silent 1
	
	String/G g_prefix=prefix
	String/G g_wvname
	String/G g_namewave=namewave,g_I0wave=I0wave,g_nvalwave=nvalwave
	String/G g_Rswave=Rswave,g_Rshwave=Rshwave
	String/G g_tablename="DiodeFitResults"

	Make/O/D param_diode
	SetDimLabel 0,0,'V',param_diode // V	oltage
	SetDimLabel 0,1,'I0',param_diode // I_0
	SetDimLabel 0,2,'fact',param_diode // q/(kB*T*n)
	SetDimLabel 0,3,'Rs',param_diode // series resistance
	
	Make/O/T/N=1 $namewave
	Make/O/N=1 $I0wave,$rswave,$nvalwave,$Rshwave
	Edit $namewave,$I0wave,$rswave,$nvalwave,$Rshwave
	if(strsearch(WinList("*",";","WIN:4"),g_tablename,0)==0)
		DoWindow/F $g_tablename
	else
		DoWindow/C $g_tablename
	endif
End

// step 1: display graph
Macro DoFitDiode(wvname)
	String wvname
	Prompt wvname,"IV wave name",popup,WaveList(g_prefix+"*",";","")
	PauseUpdate;Silent 1
	
	String legtxt=wvname
	String gname="GraphIV_"+wvname
	Display $wvname
	if(strsearch(WinList("*",";","WIN:1"),gname,0)==0)
		DoWindow/F $gname
	else
		DoWindow/C $gname
	endif
	ModifyGraph gfSize=18
	TextBox/C/N=text0/F=0/A=MC legtxt
	Label bottom "Voltage (\U)"
	Label left "Current (\U)"
	ModifyGraph rgb($wvname)=(0,0,65535)
	ShowInfo
	g_wvname=wvname
End

Macro DoFitDiode2(wvname,Rshflag)
	String wvname=g_wvname
	Variable Rshflag=1
	Prompt wvname,"IV wave name",popup,WaveList(g_prefix+"*",";","")
	Prompt Rshflag,"with Shunt resistance ?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	Variable nn=DimSize($g_namewave,0)
	Variable nval
	
	if(Rshflag==1) // with shunt resistance
		if (strlen(CsrWave(A))>0 && strlen(CsrWave(B))>0) // Cursors are on trace?
			CurveFit/Q/NTHR=0 fitfunc_Idiode_FactRsRsh W_coef $wvname [pcsr(A),pcsr(B)] /D
		else
			CurveFit/Q/NTHR=0 fitfunc_Idiode_FactRsRsh  W_coef $wvname [pcsr(A),pcsr(B)] /D
		endif
	else
		if (strlen(CsrWave(A))>0 && strlen(CsrWave(B))>0) // Cursors are on trace?
			CurveFit/Q/NTHR=0 fitfunc_Idiode_FactRs W_coef $wvname [pcsr(A),pcsr(B)] /D
		else
			CurveFit/Q/NTHR=0 fitfunc_Idiode_FactRs W_coef $wvname /D
		endif
	endif
	DisplayFItResults(wvname,Rshflag)
//	TextBox/C/N=text0/F=0/A=MC legtxt
//	Redimension/N=(nn+1) $g_namewave,$g_I0wave,$g_nvalwave,$g_Rswave,$g_Rshwave
//	DoWindow/F $g_tablename
End

Macro DisplayFitResults(wvname,rshflag)
	String wvname=g_wvname
	Variable Rshflag=1
	Prompt wvname,"IV wave name",popup,WaveList(g_prefix+"*",";","")
	Prompt Rshflag,"with Shunt resistance ?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	Variable nn=DimSize($g_namewave,0)
	Variable nval
	String legtxt
	
	if(Rshflag==1)
		nval=1/W_coef[1]/0.0258
		print "I0=",W_coef[0], "n=",nval,"Rs=",W_coef[2],"Rsh=",W_coef[3]
		sprintf legtxt,"%s, I0=%e, n=%f, Rs=%f, Rsh=%f",wvname,W_coef[0],nval,W_coef[2],W_coef[3]
		$g_namewave[nn-1]=wvname
		$g_I0wave[nn-1]=W_coef[0]
		$g_nvalwave[nn-1]=nval
		$g_Rswave[nn-1]=W_coef[2]
		$g_Rshwave[nn-1]=W_coef[3]
	else
		nval=1/W_coef[1]/0.0258
		print "I0=",W_coef[0], "n=",nval,"Rs=",W_coef[2]
		sprintf legtxt,"%s, I0=%e, n=%f, Rs=%f",wvname,W_coef[0],nval,W_coef[2]
		$g_namewave[nn-1]=wvname
		$g_I0wave[nn-1]=W_coef[0]
		$g_nvalwave[nn-1]=nval
		$g_Rswave[nn-1]=W_coef[2]
		$g_Rshwave[nn-1]=NaN
	endif
	TextBox/C/N=text0/F=0/A=MC legtxt
	Redimension/N=(nn+1) $g_namewave,$g_I0wave,$g_nvalwave,$g_Rswave,$g_Rshwave
	DoWindow/F $g_tablename
End

// ideal diode
Function/D func_Idiode_fact(volt,I0,fact)
	Variable/D volt,I0,fact
	return(I0*(exp(volt*fact)-1))
End

Function func_Idiode_FactRs(volt,I0,fact,Rs)
	Variable volt,I0,fact,Rs

	Wave param_diode
	Variable low=0,high=0.1
	param_diode[%'volt']=volt
	param_diode[%'I0']=I0
	param_diode[%'fact']=fact
	param_diode[%'Rs']=Rs
	FindRoots/Q/L=(low) func_Idiode1,param_diode
	return(V_root)
End 

//
Function/D func_Idiode1(wv,current)
	Variable current
	Wave wv
	return(current-func_Idiode_fact(wv[0]-wv[3]*current,wv[1],wv[2]))
End

// fit function for diode + series resistance
Function fitfunc_Idiode_FactRs(w,volt) : FitFunc
	Wave w
	Variable volt

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = func_Idiode_factRs(x,I0,fact,Rp)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ volt
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = I0
	//CurveFitDialog/ w[1] = fact
	//CurveFitDialog/ w[2] = Rs

	return func_Idiode_factRs(volt,w[0],w[1],w[2])
End

// fit function fro diode + series resistance + shunt resistance
Function fitfunc_Idiode_FactRsRsh(w,volt) : FitFunc
	Wave w
	Variable volt

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(volt) = func_Idiode_factRs(volt,I0,fact,Rp)+volt/Rs
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ volt
	//CurveFitDialog/ Coefficients 4
	//CurveFitDialog/ w[0] = I0
	//CurveFitDialog/ w[1] = fact
	//CurveFitDialog/ w[2] = Rs
	//CurveFitDialog/ w[3] = Rsh

	return func_Idiode_factRs(volt,w[0],w[1],w[2])+volt/w[3]
End

// n-value from lov(I)-V plot
Macro DofitDiode_nvalog1(wvname)
	String wvname
	Prompt wvname,"IV wave name",popup,WaveList(g_prefix+"*",";","")
	PauseUpdate;Silent 1
	
	String legtxt=wvname
	String gname="GraphIV_"+wvname+"_log"
	String wvname_log=wvname+"log"
	Duplicate/O $wvname,$wvname_log
	$wvname_log=log($wvname)
	Display $wvname_log
	if(strsearch(WinList("*",";","WIN:1"),gname,0)==0)
		DoWindow/F $gname
	else
		DoWindow/C $gname
	endif
	ModifyGraph gfSize=18
	TextBox/C/N=text0/F=0/A=MC legtxt
	Label bottom "Voltage (\U)"
	Label left "log(Current)"
	ModifyGraph rgb($wvname_log)=(0,0,65535)
	ShowInfo
	g_wvname=wvname_log
End

Macro DofitDiode_nvalog2(wvname)
	String wvname=g_wvname
	Variable Rshflag=1
	Prompt wvname,"IV wave name",popup,WaveList(g_prefix+"*"+"log",";","")
	PauseUpdate; Silent 1
	
	Variable nn=DimSize($g_namewave,0)
	Variable nval
	
	if (strlen(CsrWave(A))>0 && strlen(CsrWave(B))>0) // Cursors are on trace?
		CurveFit/Q/NTHR=0 line $wvname [pcsr(A),pcsr(B)] /D
	else
		CurveFit/Q/NTHR=0 line $wvname /D
	endif
		nval=1/W_coef[1]/0.0258*log(exp(1))
	print "n=",nval
	sprintf legtxt,"%s, n=%f",wvname,nval

	$g_namewave[nn-1]=wvname
	$g_I0wave[nn-1]=NaN
	$g_nvalwave[nn-1]=nval
	$g_Rswave[nn-1]=NaN
	$g_Rshwave[nn-1]=NaN

	TextBox/C/N=text0/F=0/A=MC legtxt
	Redimension/N=(nn+1) $g_namewave,$g_I0wave,$g_nvalwave,$g_Rswave,$g_Rshwave
	DoWindow/F $g_tablename

End
