#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Muller's method: find a complex root of an analytic function
// taken from IgorExchange: http://www.igorexchange.com/node/552

Function/C Muller(pwcplx, x0, x1, x2, fin)	//	modified from Igor Exchange code snippet by Bech
	wave/C pwcplx		// ADDED complex parameter wave for input function
	Variable/C x0,x1,x2		// initial values for root iteration
	FUNCREF myprotofunc fin	// ADDED flexibility in changing input function without changing code
	Variable tol=1e-9,nmax=100,k=2                // tol = tolerance; nmax = max iterations (adjust to taste)
	Make /C/D/O/N=(nmax+3) xx=0,wf=0	// temporary waves [keep when debugging]; renamed 'wf'
	xx[0]=x0;  xx[1]=x1;  xx[2]=x2		// initial values in waves
	wf[0] = fin(pwcplx,x0);  wf[1] = fin(pwcplx,x1);  wf[2] = fin(pwcplx,x2)	// and their function values
	Do
		xx[k+1] = Muller_step(xx[k],xx[k-1],xx[k-2],wf[k],wf[k-1],wf[k-2])
		wf[k+1] = fin(pwcplx,xx[k+1])	// Muller requires only one functional eval /iteration
		k += 1
	While ((k<nmax+3) && (cabs(xx[k]-xx[k-1]) > tol))
	// deletepoints k+1,nmax-k+2, xwave,fwave	 // delete "unused" points and keep waves for debug
	Variable /C root = xx[k]
	Killwaves xx,wf				// delete waves (normal operation)
	Return root
End

Function/C Muller_step(xk,xk1,xk2,fk,fk1,fk2)	               // from Numerical Recipes, 2nd ed.
	Variable/C xk,xk1,xk2,fk,fk1,fk2			               // initial values
	Variable/C q,A,B,C						       // use complex quantities (/c flag)
	q = (xk-xk1)/(xk1-xk2)
	A = q*fk-q*(1+q)*fk1+q^2*fk2
	B = (2*q+1)*fk - (1+q)^2*fk1 + q^2*fk2
	C = (1+q)*fk
	Variable/c  d = Sqrt(Cmplx(B^2-4*A*C,0))	               // it's this step that can make a real guess go complex
	if (Magsqr(B+d) > Magsqr(B-d))
		Return xk - (xk-xk1)*2*C/(B+d)
	else
		Return xk - (xk-xk1)*2*C/(B-d)
	endif
End

//------------------------------------------------------------------------------------------------------------------------------------
function/C myprotofunc(parmw, cx)
	wave/C		parmw
	variable/C	cx
end
//------------------------------------------------------------------------------------------------------------------------------------
function/C fTM(pwC, xi)	              //	new parameter wave argument
	wave/C pwC	              //	complex parameter wave
	variable/C xi	              //	xi = sigma*d
	variable/C	Kb	=	pwC[0]
	variable/C	Ka	=	pwC[1]
	variable/C	Kd	=	pwC[2]
	variable	rho	=	real(pwC[3])
	variable	d	=	real(pwC[4])	
	return	atan( (Ka/Kb)*sqrt( (Ka-Kb)*(rho/xi)^2 - 1 ) )  + atan( (Ka/Kd)*sqrt( (Ka-Kd)*(rho/xi)^2 - 1 ) ) - xi
end

//-------- original posted by bech
Function/C Muller_bech(x0,x1,x2)
	Variable/c x0,x1,x2                                                    // initial values for root iteration
	Variable tol=1e-9,nmax=100,k=2                                // tol = tolerance; nmax = max iterations (adjust to taste)
	Make /c/d/o/n=(nmax+3) xx=0,f=0			        // temporary waves [keep when debugging]
	xx[0]=x0;  xx[1]=x1;  xx[2]=x2				        // initial values in waves
	f[0] = myfunc_bech(x0);  f[1] = myfunc_bech(x1);  f[2] = myfunc_bech(x2)		// and their function values
	Do
		xx[k+1] = Muller_step(xx[k],xx[k-1],xx[k-2],f[k],f[k-1],f[k-2])
		f[k+1] = myfunc_bech(xx[k+1])				       // Muller requires only one functional eval /iteration
		k += 1
	While ((k<nmax+3) && (cabs(xx[k]-xx[k-1]) > tol))
	// deletepoints k+1,nmax-k+2, xwave,fwave	       // delete "unused" points and keep waves for debug
	Variable /c root = xx[k]
	Killwaves xx,f							       // delete waves (normal operation)
	Return root
End

Function/c myfunc_bech(z)								//  your analytic function  
	Variable/c z
//	Return z^3+1								// FindRoots could actually do this one 
	Return Sqrt(z+Cmplx(1,1))-2					// but it can't do this one
End