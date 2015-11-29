#pragma rtGlobals=1		// Use modern global access method and strict wave access.

// EquationSolverTemplate.ipf
// template procedure to get solution of equation and plot as a funciton of a parameter

//	15/11/29 version 0.1 by J. Motohisa

// usage: 
// (1)
//	(i)copy all the procedures into procedure window or another procedure
//	(ii) Replace "TEMPLATE" and "TEMPLATE0" with other appropriate name
//	(iii) Insert main body of the function into "FuncSolve_TEMPLATE0"
//	(iv) invoke "init1_TEMPLATE" and  define parameters into a wave "paramwv_TEMPLATE".
//		If necessary, give approrpiate parameter name into "paramwv_name_TEMPLATE."
//	(v) Create wave (say, wave0) and scale it appropriately
//	(vi) invoce function as
//		(a)wave0=Fsolution_TEMPLATE(x,index,"TEMPLATE","paramwv_TEMPLATE",low,high,fquite,stoperror)
//		where "index" is an index for a parameter

// (2)
//	(i) copy "FuncSolve_TEPLATE0" into a procedure window or other procedure file
//	(ii) Replace "TEMPLATE0" to "TEMPLATE"
//	(iii) Insert main body of the function into "FuncSolve_TEMPLATE"
//	(iv) follow explanations (iv)-(vi) above

// note: Loading this procedure will give you an error untill "FuncSolve_TEMPLATE" is defined

Function FuncSolve_TEMPLATE0(wv,xx)
	Variable xx
	Wave wv
	Variable res
	// main body of the function 
	return(res)
End

Function init1_TEMPLATE()
//	Variable/G g_xmin,g_xmax
	Make paramwv_TEMPLATE
	Make/T paramwv_name_TEMPLATE
	Edit paramwv_name_TEMPLATE,paramwv_TEMPLATE
End

Function init2_TEMPLATE()
	Variable numparams
	SetDimLabels("paramwv_TEMPLATE","paramwv_name_TEMPLATE",numparams)
End

// replate TEMPLATE with funcdtion name

Function Fsolution_TEMPLATE(val,index,funcname,paramwv,low,high,fquiet,stoperror)
	Variable val,index
	String funcname
	String paramwv
	Variable low,high
	Variable fquiet,stoperror
	
	NVAR V_Root
	String cmd
	wave wparamwv=$paramwv
	Variable y1,y2,res
	wparamwv[index]=val
	y1=FuncSolve_TEMPLATE(wparamwv,low)
	y2=FuncSolve_TEMPLATE(wparamwv,high)
	if(y1*y2<0)
		sprintf cmd,"FindRoots/Q/L=(%e)/H=(%e) FuncSolve_%s,%s",low,high,funcname,paramwv
		Execute cmd
//	FindRoots/L=(low)/H=(high) $funcname,$paramwv
		if(fquiet !=1)
			print "solution=",V_root,", residual=",res
		endif
		return(V_Root)
	else
		print "cannot be bracketed for low=",low, ", high=", high
		print low,y1,high,y2
		if(stoperror==1)
			Abort
		endif
		return(NaN)
	endif
End

Function Fsolution2_TEMPLATE(funcname,paramwv,low,high,fquiet,stoperror)
	String funcname
	String paramwv
	Variable low,high
	Variable fquiet,stoperror
	
	NVAR V_Root
	Wave wparamwv=$paramwv
	String cmd
	Variable y1,y2,res
//	y1=FuncSolve_TEMPLATE(wparamwv,low)
//	y2=FuncSolve_TEMPLATE(wparamwv,high)
	// hopefully it works, but it does not actually
	sprintf cmd,"y1=%s(%s,%e)",funcname,paramwv,low
	Execute cmd
	sprintf cmd,"y2=%s(%s,%e)",funcname,paramwv,high
	Execute cmd
	if(y1*y2<0)
		sprintf cmd,"FindRoots/Q/L=(%e)/H=(%e) FuncSolve_%s,%s",low,high,funcname,paramwv
		Execute cmd
//	FindRoots/L=(low)/H=(high) $funcname,$paramwv
		if(fquiet !=1)
			print "solution=",V_root,", residual=",res
		endif
		return(V_Root)
	else
		print "cannot be bracketed for low=",low, ", high=", high
		print low,y1,high,y2
		if(stoperror==1)
			Abort
		endif
		return(NaN)
	endif
End

Function SetDimLabels(paramwv,paramwv_name,numparams)
	String paramwv,paramwv_name
	Variable numparams
	PauseUpdate; Silent 1
	
	Wave wparamwv=$paramwv
	Wave/T wparamwv_name=$paramwv_name
	Variable index
	String cmd
	if(numparams==0)
		numparams=DimSize(wparamwv,0)
	endif
	
	do
		sprintf cmd,"SetDimLabel 0,%d,'%s',%s",index,wparamwv_name[index],paramwv
		Execute cmd
		index+=1
	while(index<numparams)
End