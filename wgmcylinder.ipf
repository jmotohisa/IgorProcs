#pragma rtGlobals=1		// Use modern global access method.

// wgmclyder.ipf
// whispering garelly mode in a dielectric cylinder

//	2011/03/13	ver0.1	first version
//

Macro tmmode(n,nr)
	Variable n=1,nr=3.3
	PauseUpdate;Silent 1
	
	m1=tm_mode(n,nr,cmplx(x,y))
//	if (n==0)
//		m1=-nr*besselj(1, cmplx(x,y)*nr)*besselh(0,1, cmplx(x,y)) + besselj(0, cmplx(x,y)*nr)* besselh(1,1, cmplx(x,y))
//	else
//		m1=nr *(besselj(-1 + n, cmplx(x,y)*nr) - besselj(1 + n, cmplx(x,y)*nr)) *besselh(n,1,cmplx(x,y)) 
//		m1-= besselj(n, cmplx(x,y)*nr)*(besselh(-1 + n,1, cmplx(x,y)) - besselh(1 + n, 1,cmplx(x,y)))
//	endif
End

Macro temode(n,nr)
	Variable n=1,nr=3.4
	PauseUpdate;Silent 1
	
	m1=te_mode(n,nr,cmplx(x,y))
//	if (n==0)
//		m1=-besselj(1, cmplx(x,y)*nr)*besselh(0,1, cmplx(x,y)) +  nr*besselj(0, cmplx(x,y)*nr)*besselh(1,1, cmplx(x,y))
//	else
//		m1=(besselj(-1 + n, cmplx(x,y)*nr) - besselj(1 + n, cmplx(x,y)*nr))*besselh(n,1,cmplx(x,y)) - nr*besselj(n, cmplx(x,y)*nr)* (besselh(-1 + n,1, cmplx(x,y)) - besselh(1 + n,1, cmplx(x,y)))
//  endif
End

Function/C tm_mode(n,nr,xx)
	Variable n,nr
	Variable/C xx
	Variable/C res
	if (n==0)
		res=-nr*besselj(1, xx*nr)*besselh(0,1, xx) + besselj(0, xx*nr)* besselh(1,1, xx)
  	else
		res=nr *(besselj(-1 + n, xx*nr) - besselj(1 + n, xx*nr)) *besselh(n,1,xx) 
		res-= besselj(n, xx*nr)*(besselh(-1 + n,1, xx) - besselh(1 + n, 1,xx))
	endif
	return(res)
End
	
Function/C te_mode(n,nr,xx)
	Variable n,nr
	Variable/C xx
	Variable/C res
	if (n==0)
		res=-besselj(1, xx*nr)*besselh(0,1, xx) +  nr*besselj(0, xx*nr)*besselh(1,1, xx)
	else
		res=(besselj(-1 + n, xx*nr) - besselj(1 + n, xx*nr))*besselh(n,1,xx) 
		res-= nr*besselj(n, xx*nr)* (besselh(-1 + n,1, xx) - besselh(1 + n,1, xx))
	endif
	return(res)
End
	
Function/C besselh(n,m,xx)
	Variable n,m
	Variable/C xx
	if(m==1)
		return(cmplx(real(besselj(n,xx))-imag(bessely(n,xx)),imag(besselj(n,xx))+real(bessely(n,xx))))
	else
		return(cmplx(real(besselj(n,xx))+imag(bessely(n,xx)),imag(besselj(n,xx))-real(bessely(n,xx))))
	endif
End Function

Function/C field(nr,n,ka,xx,yy)
	Variable nr,n,xx,yy
	Variable/C ka
	
	Variable/C res
	Variable rr,th
	rr=sqrt(xx*xx+yy*yy)
	th=atan2(yy,xx)
	if(rr<=1)
		res=besselj(n,nr*ka*rr)/besselj(n,nr*ka)*exp(cmplx(0,th)*n)
	else
		res=besselh(n,1,ka*rr)/besselh(n,1,ka)*exp(cmplx(0,th)*n)
	endif
	return(res)
End

Function/C field2(nr,n,ka_re,ka_im,xx,yy)
	Variable nr,n,xx,yy
	Variable ka_re,ka_im
	
	return(field(nr,n,cmplx(ka_re,ka_im),xx,yy))
End

Function/C field3(nr,n,ka,rr)
	Variable nr,n,rr
	Variable/C ka
	
	Variable/C res
	if(rr<=1)
		res=besselj(n,nr*ka*rr)/besselj(n,nr*ka)
	else
		res=besselh(n,1,ka*rr)/besselh(n,1,ka)
	endif
	return(res)
end

Macro show_field_tm(m,n)
	Variable m,n=3.6
	PauseUpdate;Silent 1
	
	bes2=real(field(n,m,cmplx(tm1_real[m-1],tm1_imag[m-1]),x,y))
	bes3=imag(field(n,m,cmplx(tm1_real[m-1],tm1_imag[m-1]),x,y))
End

Macro show_field_te(m,n)
	Variable m,n=3.6
	PauseUpdate;Silent 1
	
	bes2=real(field(n,m,cmplx(te1_real[m-1],te1_imag[m-1]),x,y))
	bes3=imag(field(n,m,cmplx(te1_real[m-1],te1_imag[m-1]),x,y))
End
