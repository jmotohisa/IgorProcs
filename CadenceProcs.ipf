#pragma rtGlobals=1		// Use modern global access method.
#include "wname"
#include "StrRpl"

// CadenceProcs.ipf by J. Motohisa
//
// ver 0.1: 11/08/30-09/02: initial version

// OBSOLETE: 2013/07/30 : this Proc is merged into LoadSpiceData
// do not use this procedure and LoadSpiceData at the same time
//

Macro LoadSpectreCSV1(fileName,pathName,wantToDisp,xunit,yunit)
	String fileName
	String pathName
	Variable wantToDisp=1,xunit=1,yunit=2
	Prompt wantToDisp, "Do you want to display graphs?", popup, "Yes;No"
	Prompt xunit,"unit for x-axis",popup,"sec;V;I;_none_"
	Prompt yunit,"unit for x-axis",popup,"sec;V;I;_none_"
	PauseUpdate; Silent 1
	
	Variable ref
	if (strlen(fileName)<=0)
		if(CmpStr(IgorInfo(2), "Macintosh") == 0)
//			Open /D/R/P=$pathName/T="sGBWTEXT" ref // MacOS
			Open /D/R/P=$pathName/T=".csv" ref // windows
		else
			Open /D/R/P=$pathName/T=".csv" ref // windows
		endif
		fileName= S_fileName
		print filename
	endif
//	LoadWave/J/D/W/A/K=0/Q/P=$pathName fileName
//	LoadWave/J/D/W/A=dummy/K=0/P=$pathName fileName
	LoadWave/J/D/A=dummy/K=0/L={1,1,0,0,0}/P=$pathName fileName
	if(V_flag==0)
		return
	endif

	if(wantToDisp==1)
		Display /W=(3,41,636,476)
	endif
	
	String xname0,yname0,xnorig,ynorig,xname,yname,destw0
	xname0=num2unit(xunit,"X")
	yname0=num2unit(yunit,"Y")
	destw0=strrpl(wname(fileName),"-","_")
	Variable index=0
	
	do
		xnorig=StringFromList(index*2,S_waveNames)
		if(strlen(xnorig)<=0)
			break
		endif
		ynorig=StringFromList(index*2+1,S_waveNames)
		xname=xname0+destw0+"_"+num2str(index)
		yname=yname0+destw0+"_"+num2str(index)
		Duplicate/O $xnorig,$xname
		Duplicate/O $ynorig,$yname
		SetScale d 0,0,num2unit2(xunit), $xname
		SetScale d 0,0,num2unit2(yunit), $yname
		KillWaves $xnorig,$ynorig
		if(wantToDisp==1)
			Append $yname vs $xname
		endif
		index+=1
	while(1)
End

// find final output in a graph
Macro FinalVals(grname,destw,avnum)
	String grname="_none_"
	String destw
	Variable avnum=100
	Prompt grname,"graph name",popup,"_none_;"+WinList("*",";","WIN:1")
	Prompt destw,"destination wave name"
	Prompt avnum,"number to average"
	PauseUpdate; Silent 1
	
	Variable index=0,num
	String trname,wlist,xwname
	Make/O/N=1 $destw
	wlist=TraceNameList(grname,";",1)
	do
		trname=StringFromList(index,wlist)
		xwname=XWaveName(grname,trname)
		if(strlen(trname)==0)
			break
		endif
		num=numpnts($trname)
		Redimension/N=(index+1) $destw
		if(strlen(xwname)==0)
			$destw[index]=faverage($trname,DimOffset($trname,0)+DimDelta($trname,0)*(num-avnum),DimOffset($trname,0)+DimDelta($trname,0)*(num-1))
		else
			$destw[index]=faverageXY($xwname,$trname,$xwname[num-avnum],$xwname[num-1])
		endif
		index+=1
	while(1)

End

//Macro EstimateV(wv0,ftime,avnum)
//	String wv0="res12_0"
//	Variable ftime=1e-6
//	Variable avnum=100
//	PauseUpdate;Silent 1
//	
//	String xwv="T"+wv0,ywv="V"+wv0
//	FindLevel/Q/P $xwv,ftime
//	if(V_Flag !=0)
//		return
//	endif
//	print faverageXY($xwv,$ywv,$xwv[V_levelX-avnum],$xwv[V_levelX])
//End

// find levels in a graph
Macro FindLevelsInGraph(grname,destw,level)
	String grname="_none_"
	String destw
	Variable level
	Prompt grname,"graph name",popup,"_none_;"+WinList("*",";","WIN:1")
	Prompt destw,"destination wave name"
	Prompt level,"level to find"
	PauseUpdate; Silent 1
	
	Variable index=0
	String trname,wlist,xwname
	Make/O/N=1 $destw
	wlist=TraceNameList(grname,";",1)
	do
		trname=StringFromList(index,wlist)
		xwname=XWaveName(grname,trname)
		if(strlen(trname)==0)
			break
		endif
		Redimension/N=(index+1) $destw
		FindLevel/Q/P $trname,level
		$destw[index]=$xwname[V_levelX]
//		FindLevel/Q $trname,level
//		$destw[index]=V_levelX
//		$destw[index]=interp(V_levelX,$xwname,$xwname)
		index+=1
	while(1)

End

Function FEstimateV(wv0,ftime,avnum)
	String wv0
	Variable ftime
	Variable avnum
	PauseUpdate;Silent 1
	
	String xwv="T"+wv0,ywv="V"+wv0,cmd
	Wave wxwv=$xwv,wywv=$ywv
	NVAR V_Flag,V_levelX
	cmd="FindLevel/Q/P "+xwv+",$ftime"
	Execute cmd
//	print V_levelX
//	if(V_Flag !=0)
//		return 0
//	endif
	return faverageXY(wxwv,wywv,wxwv[V_levelX-avnum],wxwv[V_levelX])
End

Function FEstimateV2(wv0,avnum)
	String wv0
	Variable avnum
	PauseUpdate;Silent 1
	
	String xwv="T"+wv0,ywv="V"+wv0,cmd
	Wave wxwv=$xwv,wywv=$ywv
	NVAR V_Flag,V_levelX
	Variable num=numpnts(wywv)
	return faverageXY(wxwv,wywv,wxwv[num-avnum-1],wxwv[num-1])
End

Macro makeres(wv)
	String wv="08"
	PauseUpdate; Silent 1
	
	String xwv0="Tres"+wv,ywv0="Vres"+wv,dest="res"+wv
	String xwv,ywv
	String wlist = WaveList(xwv0+"*",";","")
	Variable index=0,avnum,num
	Make/O/N=1 $dest
	do
		xwv=StringFromList(index,wlist)
		if(strlen(xwv)==0)
			break
		endif
		ywv=ywv0+xwv[strlen(xwv0),strlen(xwv)-1]
		avnum=100
		num=numpnts($xwv)
		Redimension/N=(index+1) $dest
		$dest[index]=faverageXY($xwv,$ywv,$xwv[num-avnum-1],$xwv[num-1])
		index+=1
	while(1)
End

Function/S num2unit(xunit,def)
	Variable xunit
	String def
	if(xunit==1)
		return "T"
	else
		if(xunit==2)
			return "V"
		else
			if(xunit==3)
				return "I"
			else
				return def
			endif
		endif
	endif
End

Function/S num2unit2(xunit)
	Variable xunit
	String def
	if(xunit==1)
		return "sec"
	else
		if(xunit==2)
			return "V"
		else
			if(xunit==3)
				return "A"
			else
				return ""
			endif
		endif
	endif
End

Macro AreaXYinGraph(grname,destw)
	String grname="_none_"
	String destw
	Prompt grname,"graph name",popup,"_none_;"+WinList("*",";","WIN:1")
	Prompt destw,"destination wave name"
	PauseUpdate; Silent 1
	
	Variable index=0
	String trname,wlist,xwname
	Make/O/N=1 $destw
	wlist=TraceNameList(grname,";",1)
	do
		trname=StringFromList(index,wlist)
		xwname=XWaveName(grname,trname)
		if(strlen(trname)==0)
			break
		endif
		Redimension/N=(index+1) $destw
		if(strlen(xwname)==0)
			$destw[index]=area($trname)
		else
			$destw[index]=areaXY($xwname,$trname)
		endif
		index+=1
	while(1)

End
