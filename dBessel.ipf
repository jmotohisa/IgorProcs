#pragma rtGlobals=1		// Use modern global access method.

// Hunckel functions and delivative of bessel functions

Function/D/C BesselH1(pp,xx)
	Variable pp,xx
	return(cmplx(BesselJ(pp,xx),BesselY(pp,xx)))
End Function

Function/D/C BesselH2(pp,xx)
	Variable pp,xx
	return(cmplx(BesselJ(pp,xx),-BesselY(pp,xx)))
End Function

Function/D/C CBesselH1(pp,xx)
	Variable pp
	Variable/C/D xx
	return(BesselJ(pp,xx)+cmplx(0,1)*BesselY(pp,xx))
End Function

Function/D/C CBesselH2(pp,xx)
	Variable pp
	Variable/C/D xx
	return(BesselJ(pp,xx)+cmplx(0,-1)*BesselY(pp,xx))
End Function

// real
Function/D dBesselJ(pp,xx)
	Variable pp,xx
	return((BesselJ(pp-1,xx)-BesselJ(pp+1,xx))/2)
End Function

Function/D dBesselY(pp,xx)
	Variable pp,xx
	return((BesselY(pp-1,xx)-BesselY(pp+1,xx))/2)
End Function

Function/D dBesselK(pp,xx)
	Variable pp,xx
	return(-(BesselK(pp-1,xx)+BesselK(pp+1,xx))/2)
End Function

// complex
Function/C/D dCBesselJ(m,z)
	Variable m
	Variable/C z
	return((besselj(m-1,z)-besselj(m+1,z))/2)
End

Function/C/D dCBesselY(m,z)
	Variable m
	Variable/C z
	return((bessely(m-1,z)-bessely(m+1,z))/2)
End

Function/C/D dCBesselK(m,z)
	Variable m
	Variable/C z
	return(-(besselk(m-1,z)+besselk(m+1,z))/2)
End

Function/C/D dCBesselI(m,z)
	Variable m
	Variable/C z
	return((besselI(m-1,z)+besselI(m+1,z))/2)
End

Function/C/D dCBesselH1(m,z)
	Variable m
	Variable/C z
	return(dCBesselJ(m,z)+cmplx(0,1)*dCBesselY(m,z))
End

Function/C/D dCBesselH2(m,z)
	Variable m
	Variable/C z
	return(dCBesselJ(m,z)+cmplx(0,-1)*dCBesselY(m,z))
End
