#pragma rtGlobals=1		// Use modern global access method.

// Fermi-Dirac Integral
// see J. S. Blackmore, Solid-State Electron 25, No. 11, pp.1067-1076 (1982).

Function/D invFermiDiracIntphalf(u)
	Variable u
	Variable u2,u3,u4
	u2=1.2089939655123523*u^(2./3.)
	u3=(0.244+1.08*u2)
	u4=ln(u)/(1.-u*u)+ u2/(1.+1/(u3*u3))
	return(u4)
End Function