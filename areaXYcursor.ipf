#pragma rtGlobals=1		// Use modern global access method.
//#include <Readback ModifyStr>
#include "JMProcs"

// areaXYcursor.ipf
//	funciton to integrate between cursor
//	11/03/15 ver. 0.4 by J. Motohisa
//
//	revision history
//		06/02/07	ver 0.1	first version
//		06/04/15	ver 0.2	add "macro AreaCsr_AllTrace"
//		10/10/22	ver 0.3	Integrate all Ranges in case of no cursors on trace, bug related to areaXY fixed
//		11/03/15	ver 0.4	compatible with 2-Dimensional wave, changed into function
//		16/12/05	ver 0.4.1 xwave name can contatin special characters
// To Do: 

Macro DoAreaCsr_AllTrace(destwv,nmwv)
	string destwv,nmwv
	PauseUpdate; Silent 1
	
	Make/O $destwv
	Make/O/T $nmwv
	AreaCsr_AllTrace(destwv,nmwv)
End

Function AreaCsr_AllTrace(destwv,nmwv)
	string destwv,nmwv
	PauseUpdate; Silent 1
	
	String gr=WinName(0,1),s0
	String trlist=TraceNameList(gr,";",1),w0,xwv,tinfo,w00
	Variable i=0,xmin,xmax,n=ItemsInList(trlist)
	Variable val,p1,p2,ni
	Make/O/N=(n) $destwv
	Make/O/N=(n)/T $nmwv
	Wave w_destwv=$destwv
	Wave/T w_nmwv=$nmwv
	if(strlen(CsrInfo(A))>0)
		xmin=hcsr(A,gr)
	endif
	if(strlen(CsrInfo(B))>0)
		xmax=hcsr(B,gr)
	endif
	do
		w0=StringFromList(i,trlist,";")
		w00=NameOfWave(TraceNameToWaveRef(gr,w0))
		wave w_w00=$w00
		if(strlen(CsrInfo(A))<=0)
			xmin=DimOffset($w00,0)
		endif
		if(strlen(CsrInfo(B))<=0)
			xmax=DimOffset($w00,0)+DimDelta($W00,0)*DimSIze($w00,0)
		endif
		w_nmwv[i]=w0
		xwv=PossiblyQuoteName(XWaveOfWave(gr,w0,0))
		
		tinfo=StringByKey("YRANGE",TraceInfo(gr,w0,0))
		If(WaveDims($w00)==2)
			p1=strsearch(tinfo,"[",inf,3)
			p2=strsearch(tinfo,"]",inf,3)
			s0=tinfo[p1+1,p2-1]
			ni=str2num(s0)
			Duplicate/O $w00,dummy
			Redimension/N=(DimSize(dummy,0)) dummy
			dummy=w_w00[p][ni]
			w0="dummy"
		endif
		if(strlen(xwv)==0)
			w_destwv[i]=area($w0,xmin,xmax)
		else
//			val=areaXY($xwv,$w0,xmin,xmax)
			w_destwv[i]=areaXY($xwv,$w0,xmin,xmax)
		endif
		i+=1
	while(i<n)
	AppendToTable $destwv,$nmwv
	return(1)
End

Function farea_cursor0()
	return(farea_cursor(WinName(0,1),0))
End	

Function farea_cursor(gr,instance)
	String gr//=WinList("*",";","WIN:1")
	Variable instance
	PauseUpdate;Silent 1
	
	String ywv,xwv
	ywv=CsrWave(A,gr)
//	print gr,ywv,instance
	xwv=XWaveOfWave(gr,ywv,instance)
//	print xwv,ywv
	if(strlen(xwv)==0)
		return(farea_cursor_gr(gr,$ywv))
	else
		return(fareaXY_cursor_gr(gr,$xwv,$ywv))
	endif
End

Function fareaXY_cursor_gr(gr,xwv,ywv)
	Wave xwv,ywv
	String gr
	return(areaXY(xwv,ywv,xwv[pcsr(A,gr)],xwv[pcsr(B,gr)]))
End

Function farea_cursor_gr(gr,ywv)
	Wave ywv
	String gr
	return(area(ywv,hcsr(A,gr),hcsr(B,gr)))
End

Function MyAreaXY(ywv,xwv)
	Wave ywv,xwv
	Variable n=DimSize(ywv,0)
	Variable i=0,res=0
	do
		res=res+(xwv[i]+xwv[i+1])*(ywv[i+1]-ywv[i])/2
		i+=1
	while(i<n-1)
	return(res)
End
