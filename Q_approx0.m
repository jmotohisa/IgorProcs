function/D y=Q_approx0(V,Vgs,Vt,deltaVt,Vth,Q0,Cox)
% unified approximated formula for Q (eq. 13 in Iniguez et al., Trans. ED)
	a=2*Cox*Vth*Vth/Q0
	b=2*Vth*ln(1+exp((Vgs-Vt+deltaVt-V)/(2*Vth)))
	y=Cox*(sqrt(a*a+b*b)-a))
endfunction
