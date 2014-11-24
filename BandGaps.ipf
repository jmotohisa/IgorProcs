#pragma rtGlobals=1		// Use modern global access method.

///////////////////////////////////////////////////////////
// BandGaps.ipf
// by J. Motohisa
// Band Gap Energy of Various Semiconductors
// ver 0.1 2005/01/16
// ver 0.11 2005/01/31 : add some binary compounds
// ver 0.12 2005/11/02 : add temperature dependent GaInAs bandgap
// ver 0.13 2005/12/21 : add temperature dependent GaP and GaInP bandgap,
// ver 0.14 2010/12/09 : added GaN, AlN, and InN  and their alloys (WZ)

// supported materials
//	GaAs, InP, InAs, InP, GaN, AlN, InN
//	Al_{x}Ga_{1-x}As, GaInAs, AlGaN, AlInN, GaInN
//	Ga_{x}In_{1-x}As_{y}P_{1-y}

// functions:
// EgT_GaAs(temp) : Temperature dependent band gap in GaAs
// EgT_InP(temp) : Temperature dependent band gap in InP
// EgT_InAs(temp) : Temperature dependent band gap in InAs
// EgT_GaP(temp) : Temperature dependent direct band gap in GaP
// EgT_GaN(temp) : Temperature dependent direct band gap in GaP
// EgT_AlN(temp) : Temperature dependent direct band gap in GaP
// EgT_InN(temp) : Temperature dependent direct band gap in GaP

// Egd_AlGaAs(x) : direct gap of Al_{x}Ga_{1-x}As at RT
// Egd_GaInAs(x) : direct gap of Ga_{x}In_{1-x}As at RT
// Egd_GaInP(x) : direct gap of Ga_{x}In_{1-x}P at RT
// Egd_GaAsP(y) : direct gap of GaAs_{y}P_{1-y} at RT
// Egd_InAsP(y) : direct gap of InAs_{y}P_{1-y} at RT
// Egd_AlInAs(x) : direct gap of Al_{x}In_{1-x}As at RT
// Egd_AlInP(x) : direct gap of Al_{x}In_{1-x]As at RT
// Egd_AlGaN(x) : direct gap of Al_{x}Ga_{1-x]N at RT
// Egd_AlInN(x) : direct gap of Al_{x}In_{1-x]N at RT
// Egd_GaInN(x) : direct gap of Ga_{x}In_{1-x]N at RT
// Egd_GaInAsP(x,y) : direct gap of Ga_{x}In_{1-x}As_{y}P_{1-y}
// Egd_AlGaInAs(x,y) : direct gap of Al_{x}Ga_{y}In_{1-x-y}As
// xGa_GaInAsP_on_InP(y) : gallium content of Ga_{x}In_{1-x}As_{y}P_{1-y} lattice matched to InP

// EgT_GaInAs(x,temp)
// EgT_GaInP(x,temp)
//

// See bottom of procedure for references

// Varshini equation
Function Varshini(temp,e0,aa,bb)
	Variable temp,e0,aa,bb
	Return(e0-aa*temp^2/(bb+temp))
End

// binary compounds: temperature dependence
Function EgT_GaAs(temp)
	Variable temp
	//reference: Heterostructure Lasers
	Return(varshini(temp,1.519,5.405e-4,204))
End

Function EgT_InP(temp)
	Variable temp
	//reference: Heterostructure Lasers
	Return(varshini(temp,1.421,3.63e-4,162))
End

Function EgT_InAs(temp)
	Variable temp
	//reference: Heterostructure Lasers
	Return(varshini(temp,0.420, 2.50e-4, 75))
End

Function EgT_GaP(temp)
	Variable temp
	//reference: Heterostructure Lasers
	Return(varshini(temp,2.338, 5.771e-4, 372)) // Indirect band gap
End

Function EgT_GaN(temp)
	Variable temp
	//reference:  JAP
	Return(varshini(temp,3.510, 0.909e-3, 830)) // Indirect band gap
End

Function EgT_AlN(temp)
	Variable temp
	//reference:  JAP
	Return(varshini(temp,2.338, 1.799e-3, 1462)) // Indirect band gap
End

Function EgT_InN(temp)
	Variable temp
	//reference:  JAP
	Return(varshini(temp,0.78, 0.245e-3, 624)) // Indirect band gap
End

//////
// ternary alloy
Function Egd_AlGaAs(xAl)
	Variable xAl
	Variable Eg
// ref: Heterostructure Lasers
//	if(xAl<0.45)
//		Eg=1.424+xAl*1.247
//	else
//		Eg=1.424+xAl*1.247+1.147*(xAl-0.45)^2
//	endif
// ref: Kishino, in Semiconductor Lasers (in Japanese) <- Landolt-Bornstein
	Eg=1.420+1.087*xAl+0.438*xAl^2
	return(Eg)
End

Function Egd_GaInAs(xGa)
	Variable xGa
	Variable Eg
// ref: Heterostructure Lasers
//	Eg=0.36+1.064*xGa
// ref: III/V alloy semiconductors
	Eg=1.42*xGa+0.36*(1-xGa)+0.6*xGa*(xGa-1) //= 0.36+ 0.46* xGa + 0.6 *xGa^2
// ref: Kishino, in Semiconductor Lasers (in Japanese)
// ref: Takeda, in InP book
//	Eg=0.324+0.7*xGa+0.4*xGa^2
// ref: M. Sugawara et al., PRB (1993)
//	Eg=0.36+0.624*xGa+0.446*xGa^2
// My equation
//	Eg=0.36*(1-xGa)+1.424*xGa-0.4*xGa*(1-xGa)	
	return(Eg)
End

Function EgdT_GaInAs(xGa,temp)
	Variable xGa,temp
	Variable Eg
// ref: III/V alloy semiconductors (bowing parameters), properties of InGaAs
//	Eg=1.42*xGa+0.36*(1-xGa)+0.6*xGa*(xGa-1) //= 0.36+ 0.46* xGa + 0.6 *xGa^2
	Eg=EgT_GaAs(temp)*xGa+EgT_InAs(temp)*(1-xGa)+ 0.6*xGa*(xGa-1)
	return(Eg)
End

Function Egd_GaInP(xGa)
	Variable xGa
	Variable Eg
// ref: Heterostructure Lasers
// ref: Kishino, in Semiconductor Lasers (in Japanese)
	Eg=1.351+0.643*xGa+0.786*xGa^2
	return(Eg)
End

Function EgdT_GaInP(xGa,temp)
	Variable xGa,temp
	Variable Eg
// ref: Heterostructure Lasers
// ref: Kishino, in Semiconductor Lasers (in Japanese)
	Eg=EgT_GaP(temp)*xGa+EgT_InP(temp)*(1-xGa)+ 0.786*xGa*(xGa-1)
	return(Eg)
End

Function Egd_GaAsP(yAs)
	Variable yAs
	Variable Eg
// ref: Heterostructure Lasers
//	Eg=1.424+1.150*(1-yAs)+0.176*(1-yAs)^2
// same as following formula
// ref: Kishino, in Semiconductor Lasers (in Japanese)
	Eg=2.750-1.502*yAs+0.176*yAs^2
	return(Eg)
End

Function Egd_InAsP(yAs)
	Variable yAs
	Variable Eg
// ref: Heterostructure Lasers
//	Eg=0.360+0.891*(1-yAs)+0.101*(1-yAs)^2
// ref: Kishino, in Semiconductor Lasers (in Japanese)
	Eg=1.351-1.315*yAs+0.32*yAs^2
// ref: Takeda, in InP book, same as Kishino
//	Eg=0.356+0.675*(1-yAs)+0.32*(1-yAs)^2
	return(Eg)
End

Function Egd_AlInAs(xAl)
	Variable xAl
	Variable Eg
//ref: Heterostructure Lasers
	Eg=0.360+2.01*xAl+0.698*xAl^2
// ref: Kishino
	Eg=0.36+2.35*xAl + 0.24*xAl^2
// ref: Takeda
	Eg=0.37+1.91*xAl+0.74*xAl^2
	return(Eg)
End

Function Egd_AlInP(xAl)
	Variable xAl
	Variable Eg
// ref: Kishino
	Eg=1.351+2.23*xAl
// ref: Takeda
//	Eg=0.37+1.91*xAl+0.74*xAl^2
	return(Eg)
End

Function Egd_AlGaN(xAl)
	Variable xAl
	Variable Eg
// ref: JAP
	Eg=xAl*6.25+(1-xAl)*3.510+(xAl-1)*xAl*0.7
	return(Eg)
End

Function Egd_AlInN(xAl)
	Variable xAl
	Variable Eg
// ref: JAP
	Eg=xAl*6.25+(1-xAl)*0.78+(xAl-1)*xAl*2.5
	return(Eg)
End

Function Egd_GaInN(xGa)
	Variable xGa
	Variable Eg
// ref: JAP
	Eg=xGa*3.510+(1-xGa)*0.78+(xGa-1)*xGa*1.4
	return(Eg)
End

/////////////////
// quaternary alloys
Function Egd_GaInAsP(xGa,yAs)
	Variable xGa,yAs
	Variable Eg
// basic equation
//	Ga_{x} In_{1-x} As_{y} P_{1-y} 
//	= x*y* Eg_{GaAs} +(1-x)*y* Eg_{InAs} + x*(1-y)*EG_{GaP} +(1-x)*(1-y)* Eg_{InP}
//	+ x*(x-1)*(y* C_{GaInAs}+(1-y)* C_{GaInP})
//	+y*(y-1)*(x* C_{GaAsP} +(1-x)* C_{InAsP} )
//
// ref: estimation from binary alloy, based on parameters listed in Semiconductor parameters
//	Eg=xGa*yAs*1.424+xGa*(1-yAs)*2.78+(1-xGa)*(1-yAs)*1.351+yAs*(1-xGa)*0.356
//	Eg+=xGa*(xGa-1)*(yAs*0.4+(1-yAs)*0.786)
//	Eg+=yAs*(yAs-1)*(xGa*0.176+(1-xGa)*0.32)
// ref: estimation from binary alloy, based on parameters listed in III-V Alloy Semiconductors
//	Eg=xGa*yAs*1.42+xGa*(1-yAs)*2.74+(1-xGa)*(1-yAs)*1.35+yAs*(1-xGa)*0.36
//	Eg+=xGa*(xGa-1)*(yAs*0.6+(1-yAs)*0.5)
//	Eg+=yAs*(yAs-1)*(xGa*0.21+(1-xGa)*0.28)
// ref: Takeda, InP book
//	Eg=1.35+0.668*xGa-1.068*yAs+0.758*xGa^2+0.078*yAs^2
//	Eg+=-0.069*xGa*yAs-0.322*xGa^2*yAs+0.03*xGa*yAs^2
// ref: Utaka ( sign of xGa^2 term should be +)
//	Eg=1.35+0.668*xGa-1.17*yAs+0.758*xGa^2+0.18*yAs^2
//	Eg+=-0.069*xGa*yAs-0.322*xGa^2*yAs+0.03*xGa*yAs^2
// ref: Semiconductor Lasers
	Eg=1.35 + 0.672*xGa-1.091*yAs+0.758*xGa^2 + 0.101*yAs^2 +0.111*xGa*yAs
 	Eg+= - 0.580*xGa^2*yAs - 0.159*xGa*yAs^2 + 0.268*xGa^2*yAs^2
//
	return(Eg)
End

Function xGa_GaInAsP_on_InP(yAs)
	Variable yAs
	Return(0.1896*yAs/(0.4176-0.0125*yAs))
End

Function Egd_AlGaInAs(xAl,yGa)
	Variable xAl,yGa
	Variable Eg
// ref: Kishino
// ref: Takeda
	Eg=0.36+2.093*xAl+0.629*yGa+0.577*xAl^2+0.436*yGa^2
	Eg+=1.013*xAl*yGa-2.0*xAl*yGa*(1-xAl-yGa)
	return(Eg)
End


// references
// Semiconductor Lasers (in Japanese)
// III/V Alloy Semiconductors (in Japanese)
// Heterostructure Lasers
//