#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Calculation of QE following:
// Yang-Seok Yoo, Tae-Moo Roh, Jong-Ho Na, Sung Jin Son, and Yong-Hoon Cho
// Citation: Appl. Phys. Lett. 102, 211107 (2013); doi: 10.1063/1.4807485

// wv_int : integrated intensity wave name
// wv_exc : exictation intensity wave name

// I_exc = P_1*sqrt(I) + P_2*I + P_3*I^{3/2}
// fit using I_exc/sqrt(I) vs sqrt(I)

Function FQEFit_Yoo_step1(wv_int,wv_exc)
	String wv_int,wv_exc

	Wave wwv_int=$wv_int
	Wave wwv_exc=$wv_exc

	String xwv = wv_int+"_sqrt"
	Duplicate/O wwv_int,$xwv
	Wave wxwv=$xwv
	wxwv=sqrt(wwv_int)
	
	String ywv = wv_exc+"_QEfit"
	Duplicate/O wwv_exc,$ywv
	Wave wywv=$ywv
	wywv=wwv_exc/wxwv

	Display wywv vs wxwv
	ModifyGraph mode($ywv)=3,marker($ywv)=19
	ModifyGraph rgb($ywv)=(0,0,0)
	ShowInfo
End

Function FQEFit_Yoo_step2(wv_int,wv_exc)
	String wv_int,wv_exc

	Wave wwv_int=$wv_int
	Wave wwv_exc=$wv_exc

	String xwv = wv_int+"_sqrt"
	Wave wxwv=$xwv
	String ywv = wv_exc+"_QEfit"
	Wave wywv=$ywv
	String eta=wv_int+"_eta"
	
//	CurveFit/Q/H="1000" poly 4, wywv_orig[pcsr(A),pcsr(B)] /X=wxwv /D
	CurveFit/Q poly 3, wywv[pcsr(A),pcsr(B)] /X=wxwv /D
	Wave W_coef
	Variable coef=W_coef[1] // 
	Print coef
	Duplicate/O wywv,$eta
	Wave weta=$eta
	weta=wwv_int*coef/wwv_exc
	Display weta vs wwv_exc
	ModifyGraph mode=3,marker=19
	Edit weta
End
