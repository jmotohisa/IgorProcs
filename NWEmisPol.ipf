#pragma rtGlobals=1		// Use modern global access method.

#include "dBessel"

// Emission Polarization in nanowires
// H. E. Ruda and A. Shik, J. Appl. Phys. 100 024314 (2006).

Function/C dx_PolEmissionNW(ka,eps0,eps)
	Variable ka,eps0,eps
	Variable z=ka*sqrt(eps),z0=ka*sqrt(eps0)

	return(Sqrt(eps)* (dBesselJ(1, z)*HankelH1(1, z) - BesselJ(1, z) *dHankelH1(1, z))/ (Sqrt(eps0)*dBesselJ(1, z)*HankelH1(1, z0) - Sqrt(eps)*BesselJ(1, z)* dHankelH1(1, z0)))
End

Function/C dz_PolEmissionNW(ka,eps0,eps) 
	Variable ka,eps0,eps
	Variable z=ka*sqrt(eps),z0=ka*sqrt(eps0)

	return(Sqrt(eps) *(BesselJ(1, z) *HankelH1(0, z) - BesselJ(0, z)*HankelH1(1, z))/ (Sqrt(eps)*BesselJ(1, z)*HankelH1(0, z0) - Sqrt(eps0)*BesselJ(0, z)* HankelH1(1, z0)))
End

Function PolEmissionNW(ka,eps0,eps)
	Variable ka,eps0,eps
	Variable dzdx
	dzdx=cabs(dz_PolEmissionNW(ka, eps0, eps)/dx_PolEmissionNW(ka, eps0, eps))
	dzdx=2/3*dzdx*dzdx
	return((1/3+dzdx-1)/(1/3+dzdx+1))
End

Function/C HankelH1(m,z)
	Variable m
	Variable/C z
	return(cmplx(BesselJ(m,z),BesselY(m,z)))
End

Function/C dHankelH1(m,z)
	Variable m
	Variable/C z
	return(cmplx(dCBesselJ(m,z),dCBesselY(m,z)))
End
