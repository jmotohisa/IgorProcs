#pragma rtGlobals=1		// Use modern global access method.
Function WL1D_AA(w,x)
// fitting for 1D localization based on Altshuler-Aronov theory
// fitting should be applied to (G(B)-G(0))/(e^2/h)*L, 
// where L is the sample length in micron unit
// fit results: w[0]: W, w[1]: L_\phi (unit in micron)
//
	Wave w; Variable x
	
	Variable val
	if(x==0)
		val=0
	else
		val = -2e6/sqrt((1/(w[1]*w[1]*1e-12)+1/(sqrt(3)*1.05e-34/(1.602e-19*x*w[0]*1e-6))^2))+2*w[1]
	endif
	return val
end
