#pragma rtGlobals=1		// Use modern global access method.
#include "JMGeneralTextDataLoad2"
#include "wname"
#include "MatrixOperations2"

// LoadSpiceData by J. Motohisa
// Macro to load spice/spectre data
//
// ver 0.1 2008/08/14: write LoadSpiceData2 based on LoadColumnDataToMatrix (MatrixOperations2)
// ver 0.2 2013/07/30: JMGeneralTextDataLoad2 used, merge CadenceProc

////////////////////////////////////////
// file loaders
Macro LoadSpiceData2(wvname,filename,pathName,icol,ndata)
	String wvname="M",filename,pathName="home"
	Variable icol=2,ndata=1
	Prompt icol,"Column number to load ?"
	Prompt ndata,"number of data in one row"
	
	Silent 1; PauseUpDate
	Variable/D ref,xmin,xmax,nrow
	String wn,buffer,extstr,dwname

//	open file dialogue to load data
//	extstr = FileTypeStr()
	extstr=".dat"

	if (strlen(fileName)<=0)
//		Open /D/R/P=$pathName/T="sGBWTEXT" ref
		Open /D/R/T=(extstr) ref
		fileName= S_fileName
	endif
	print fileName
	// load scale data
	LoadWave/G/D /O/K=0/N=dummy/P=$pathName/Q/L={0,0,0,1,1} fileName
	dwname = StringFromList(0,S_waveNames,";")
//	LoadWave/G/D /O/K=0/N=dummy/P=$pathName/Q fileName
//	dwname = StringFromList(1,S_waveNames,";")
	WaveStats/Q $dwname
	xmin=V_min;xmax=V_max

	LoadWave/G/D/O/K=0/V={"\t, "," $",0,0}/N=dummy/L={0,0,0,icol,1}/Q/P=$pathName fileName
	wn = StringFromList(0,S_waveNames,";")
	Duplicate/O $wn,$wvname
//	print S_WaveNames
//	Duplicate/O dummy0,$wvname
	nrow=numpnts($wvname)/ndata
	Redimension/N=(ndata,nrow) $wvname
//	LoadSpiceData20(wvname,filename,PathName,icol,ndata)
//	LoadColumnDataToMatrix(wvname,filename,Pathname,icol,data)
	SetScale/I x,xmin,xmax,"V",$wvname
	SetScale y,0,1,"V",$wvname
	SetScale d 0,0,"A", $wvname
End Macro

Macro load_DC_csv(fname,pname,wvname,index,xunit,yunit,fquiet,fdisp)
	String fname,pname,wvname
	Variable index,fquiet=1,xunit=2,yunit=3,fdisp=1
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt wvname,"Wave Name (blank=file name)"
	Prompt index,"wave index"
	Prompt xunit,"unit for x-axis",popup,"sec;V;I;_none_"
	Prompt yunit,"unit for y-axis",popup,"sec;V;I;_none_"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	Prompt fdisp,"display ?",popup,"yes;no"
	PauseUpdate;silent 1
	
	Variable nlwave,ref
	String extName=".csv"
	if (strlen(fName)<=0)
		Open /D/R/P=$pName/T=extName ref // windows
		fName= S_fileName
//		print fname
	endif

	if(strlen(wvname)==0)
		wvname=wname(fname)
		index=0
	else
		wvname=wvname+num2istr(index)
	endif

	nlwave=JMGeneralDatLoaderFunc2(fname,pname,extName,index,"","",0,1)
	FWavesToMatrix(wvname+"_","",wvname,1,nlwave,2)

	Variable x0,dx
	x0=DimOffset($wvname,0)
	dx=DimDelta($wvname,0)
	SetScale/P x x0,dx,num2unit(xunit,"V"), $wvname
	SetScale d 0,0,num2unit(yunit,"I"), $wvname

	if(fdisp==1)
		MatrixWavePlot(wvname,1,1,"_none_")
	Endif
End

// load transient signal: 
Macro load_tran_csv(fname,pname,wvname,startindex,xunit,yunit,fquiet,fdisp)
	String fname,pname,wvname
	Variable startindex,fquiet=1,xunit=1,yunit=2,fdisp=1
	Prompt fname,"File Name"
	Prompt pname,"Path Name"
	Prompt wvname,"Wave Name (blank=file name)"
	Prompt startindex,"wave index"
	Prompt xunit,"unit for x-axis",popup,"sec;V;I;_none_"
	Prompt yunit,"unit for y-axis",popup,"sec;V;I;_none_"
	Prompt fquiet,"quiet ?",popup,"yes;no"
	Prompt fdisp,"display ?",popup,"yes;no"
	PauseUpdate;silent 1
	
	Variable nlwave,ref,ind0
	String extName=".csv"
	String suffixlist=""
	if (strlen(fName)<=0)
		Open /D/R/P=$pName/T=extName ref // windows
		fName= S_fileName
//		print fname
	endif

	if(strlen(wvname)==0)
		wvname=wname(fname)
		startindex=0
	else
		wvname=wvname+num2istr(startindex)
	endif

	LoadWave/J/D/N=dummy/W/P=$pName/Q fName
	if(V_flag==0)
		return(-1)
	endif
	nlwave=V_flag
	ind0=0
	
	Variable x0,dx
	
	do
		suffixlist=suffixlist+suffixDSO2(ind0,num2unit(xunit,"T"))+";"
		suffixlist=suffixlist+suffixDSO2(ind0,num2unit(yunit,"V"))+";"
		ind0+=1
	while (ind0*2<nlwave)
	
	JMGeneralDatLoaderFunc2(fname,pname,extName,startindex,"",suffixlist,-1,1)
//	FWavesToMatrix(wvname+"_","",wvname,1,nlwave,2)
	String xwvname=wvname+suffixDSO1(0,num2unit(xunit,"T"))
	String ywvname=wvname+suffixDSO1(0,num2unit(yunit,"V"))
	x0=DimOffset($wvname,0)
	dx=DimDelta($wvname,0)

	if(fdisp==1)
		Display
	Endif
	
	ind0=0
	do
		xwvname=wvname+suffixDSO1(ind0,num2unit(xunit,"T"))
		ywvname=wvname+suffixDSO1(ind0,num2unit(yunit,"V"))
		SetScale/P x x0,dx,num2unit(xunit,""), $xwvname,$ywvname
		SetScale d 0,0,num2unit2(xunit), $xwvname
		SetScale d 0,0,num2unit2(yunit), $ywvname

		if(fdisp==1)
			AppendToGraph $ywvname vs $xwvname
		Endif
		ind0+=1
	while(ind0*2<nlwave)
End

// left compatibility with CadenceProcs
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
////////////////////////////////////////

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

Macro FindLevelsInGraph(grname,destw,level,fdisp)
	String grname="_none_"
	String destw
	Variable level,fdisp=1
	Prompt grname,"graph name",popup,"_none_;"+WinList("*",";","WIN:1")
	Prompt destw,"destination wave name"
	Prompt level,"level to find"
	Prompt fdisp,"display graph ?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	Variable index=0
	String trname,wlist,xwname,units
	Make/O/N=1 $destw
	wlist=TraceNameList(grname,";",1)
	do
		trname=StringFromList(index,wlist)
		xwname=XWaveName(grname,trname)
		units=WaveUnits($xwname,1)
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
	
	SetScale/P d,0,0,units,$destw
	if(fdisp==1)
		Display $destw
	endif
End

// calculate 10%/90% transition width
Macro FindTransWidthGraph(grname,destw,highlevel,lowlevel,posneg,fdisp)
	String grname="_none_"
	String destw="trans"
	Variable  highlevel=1,lowlevel=0
	Variable posneg=2,fdisp=1
	Prompt grname,"graph name",popup,"_none_;"+WinList("*",";","WIN:1")
	Prompt destw,"destination wave name"
	Prompt highlevel,"level high"
	Prompt lowlevel,"level low"
	Prompt posneg,"Positive or Negative edge?",popup,"positive;negative"
	Prompt fdisp,"display graph ?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	Variable index=0,level_start,level_stop
	String trname,wlist,xwname,destw_start,destw_stop
	destw_start=destw+"_start"
	destw_stop=destw+"_stop"
	
	if(posneg==1)
		level_start=(highlevel -lowlevel)*0.1+level_low
		level_stop=(highlevel-lowlevel)*0.9+level_low
	else
		level_start=(highlevel -lowlevel)*0.9+lowlevel
		level_stop=(highlevel-lowlevel)*0.1+lowlevel
	endif

	FindLevelsInGraph(grname,destw_start,level_start,2)
	FindLevelsInGraph(grname,destw_stop,level_stop,2)
	Duplicate/O $destw_stop,$destw
	$destw=$destw_stop-$destw_start

	if(fdisp==1)
		Display $destw
	endif
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

//
Function/S num2unit(xunit,def)
	Variable xunit
	String def
	
	switch(xunit)
		case 1:
			return "T"
		case 2:
			return "V"
		case 3:
			return "I"
		default :
			return def
	endswitch
End

Function/S num2unit2(xunit)
	Variable xunit
	
	switch(xunit)
		case 1:
			return "sec"
		case 2:
			return "V"
		case 3:
			return "A"
		default :
			return ""
	endswitch
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

Function/S suffixDSO1(ind0,unitstr)
	Variable ind0
	String unitstr
	String s
	sprintf s,"_%d_%s",ind0,unitstr
	return(s)
End

Function/S suffixDSO2(ind0,unitstr)
	Variable ind0
	String unitstr
	String s
	sprintf s,"%d_%s",ind0,unitstr
	return(s)
End