#pragma rtGlobals=1		// Use modern global access method.#include "JMColorTable"// LoadSniderResult.ipf// by J. Motohisa// load single (and multiple) calculation results of Snider's "1D Poisson" simulator//// Snider's "1D Poisson" can be downloaded from http://www.nd.edu/~gsnider///// requires following Igor Procedures : // 2005/02/24 ver 0.1 : first version (preliminary)// Things to do//	- Extention to non-uniform mesh//	- Automatically colorize traces//	- Option to overwrite waves of exsiting simulation result index//	- Fill appropriate values in appropriate regions into waves for qnautized energy //	- Option to load multiple-gate voltage data//	- (Mutliple) load option for potenital and wavefunctions simultanously//	- Display wavefunctions with qnautized enery offset//	- Display electron/hole/ionized imprity density//	- More display option//	- Load (and reformat) .ex file and/or .status file into notebook#include <Strings as Lists>//#include "wname"//#include "MatrixOperations2"Macro LoadPotential(fileName,pathName,index,wantToDisp)	String fileName	String pathName="home"	Variable wantToDisp=1,index=0	Prompt filename,"File Name"	Prompt pathName,"Path Name"	Prompt index,"data index"	Prompt wantToDisp, "Do you want to display graphs?", popup, "Yes;No"	Silent 1; PauseUpDate		String wvnm,dwvnm	Variable ref	Variable xmin,xmax,index2		if (strlen(fileName)<=0)		Open /D/R/P=$pathName/T=".out" ref		fileName= S_fileName		print filename	endif// Load potential and electron/hole/impurity density	LoadWave/J/D/W/N=$"dummy"/K=0/P=$pathName/L={0,1,0,0,8} fileName	if(V_flag==0)		return	endif//	print S_wavenames		index2=0// position wave	wvnm="pos_"+num2istr(index)	dwvnm=StringFromList(index2, S_wavenames)	$dwvnm*=1e-10	WaveStats/Q $dwvnm	xmin=V_min	xmax=V_max	SetScale/I x,xmin,xmax,"m",$dwvnm	SetScale y,0,1,"m",$dwvnm	Rename $dwvnm,$wvnm//	Killwaves $dwvnm	index2+=1// Conduction band	wvnm="Ec_"+num2istr(index)	dwvnm=StringFromList(index2, S_wavenames)	SetScale/I x,xmin,xmax,"m",$dwvnm	SetScale y,0,1,"eV",$dwvnm	Rename $dwvnm,$wvnm	index2+=1// Valence band	wvnm="Ev_"+num2istr(index)	dwvnm=StringFromList(index2, S_wavenames)	SetScale/I x,xmin,xmax,"m",$dwvnm	SetScale y,0,1,"eV",$dwvnm	Rename $dwvnm,$wvnm	index2+=1// Electric Field	wvnm="Efield_"+num2istr(index)	dwvnm=StringFromList(index2, S_wavenames)	SetScale/I x,xmin,xmax,"m",$dwvnm	SetScale y,0,1,"Vm",$dwvnm	Rename $dwvnm,$wvnm	index2+=1// Fermi Energy	wvnm="Ef_"+num2istr(index)	dwvnm=StringFromList(index2, S_wavenames)	SetScale/I x,xmin,xmax,"m",$dwvnm	SetScale y,0,1,"eV",$dwvnm	Rename $dwvnm,$wvnm	index2+=1// Electron concentration	wvnm="n_"+num2istr(index)	dwvnm=StringFromList(index2, S_wavenames)	SetScale/I x,xmin,xmax,"m",$dwvnm	SetScale y,0,1,"cm3",$dwvnm	Rename $dwvnm,$wvnm	index2+=1// Hole concentration	wvnm="p_"+num2istr(index)	dwvnm=StringFromList(index2, S_wavenames)	SetScale/I x,xmin,xmax,"m",$dwvnm	SetScale y,0,1,"cm3",$dwvnm	Rename $dwvnm,$wvnm	index2+=1// Nd-Na	wvnm="NdNa_"+num2istr(index)	dwvnm=StringFromList(index2, S_wavenames)	SetScale/I x,xmin,xmax,"m",$dwvnm	SetScale y,0,1,"cm3",$dwvnm	Rename $dwvnm,$wvnm	index2+=1// Load Quantized Energy// LoadWave/J/D/W/K=0/L={0,0,0,8,0} filename//	LoadWave/J/D/N=$"dummy"/K=0/P=$pathName/L={0,1,0,8,0} fileName	LoadWave/J/D/W/K=0/N=$"dummy"/L={0,0,0,8,0}/P=$pathName fileName	if(V_flag==0)		return	endif	index2=0	do		dwvnm=StringFromList(index2, S_wavenames)		if(strlen(dwvnm)==0)			break		endif		wvnm="Ene_"+num2istr(index)+"_"+num2istr(index2)		SetScale/I x,xmin,xmax,"m",$dwvnm//		SetScale y,0,1,"",$dwvnm		Rename $dwvnm,$wvnm		index2+=1	while(1)// Display	if(wantToDisp==1)		DisplayResult(index)	endifEnd//// loading wavefunction//Macro LoadWaveFunction(fileName,pathName,index,wantToDisp)	String fileName	String pathName="home"	Variable wantToDisp=1,index=0	Prompt filename,"File Name"	Prompt pathName,"Path Name"	Prompt index,"data index"	Prompt wantToDisp, "Do you want to display graphs?", popup, "Yes;No"	Silent 1; PauseUpDate		String wvnm,dwvnm,wvnm2	Variable ref	Variable xmin,xmax,index2		if (strlen(fileName)<=0)		Open /D/R/P=$pathName ref		fileName= S_fileName		print filename	endif	LoadWave/J/D/N=$"dummy"/K=0/L={0,1,0,0,0}/P=$pathName fileName//	LoadWave/J/D/N=$"dummy"/W/K=0/L={0,1,0,0,0}/P=$pathName fileName	if(V_flag==0)		return	endif//	print S_wavenames		index2=0// position wave	wvnm="poswv_"+num2istr(index)	dwvnm=StringFromList(index2, S_wavenames)	$dwvnm*=1e-10	WaveStats/Q $dwvnm	xmin=V_min	xmax=V_max	SetScale/I x,xmin,xmax,"m",$dwvnm	SetScale y,0,1,"m",$dwvnm	Rename $dwvnm,$wvnm	index2+=1// Conduction band	do		dwvnm=StringFromList(index2, S_wavenames)		if(strlen(dwvnm)==0)			break		endif		wvnm="psi_"+num2istr(index)+"_"+num2istr(index2-1)//		wvnm2="psi2_"+num2istr(index)+"_"+num2istr(index2)		SetScale/I x,xmin,xmax,"m",$dwvnm//		SetScale y,0,1,"",$dwvnm		Rename $dwvnm,$wvnm//		Duplicate $wvnm,$wvnm2//		$wvnm2=$wvnm2^2		index2+=1	while(1)	if(wantToDisp==1)		DisplayWavefunction(index,1)	endifEndMacro DisplayResult(index)	Variable index	PauseUpdate;Silent 1		DisplayPotential(index)End//// Display//	potentialMacro DisplayPotential(index)	Variable index	PauseUpdate;Silent 1		String poswvnm,wvnm,wnlist,cmd	Variable index2	Display /W=(3,44,474,338)	poswvnm="pos_"+num2istr(index)	wvnm="Ec_"+num2istr(index)	Append $wvnm vs $poswvnm	cmd="ModifyGraph rgb("+wvnm +")=(0,0,0)";Execute cmd	wvnm="Ev_"+num2istr(index)	Append $wvnm vs $poswvnm	cmd="ModifyGraph rgb("+wvnm +")=(0,0,0)";Execute cmd	wvnm="Ef_"+num2istr(index)	Append $wvnm vs $poswvnm	cmd="ModifyGraph lstyle("+wvnm +")=2";Execute cmd		wnlist=WaveList("Ene_"+num2istr(index)+"*",";", "")	index2=0	do		wvnm=StringFromList(index2, wnlist)		if(strlen(wvnm)==0)			break		endif		Append $wvnm vs $poswvnm		cmd="ModifyGraph gaps("+wvnm+")=0"		Execute cmd		index2+=1	while(1)	Legend/N=text0/F=0/A=MC/X=-38.04/Y=39.31	Label left "potential (\\U)"	Label bottom "position (\\U)"End//	wavefunctionMacro DisplayWavefunction(index,appendmode)	Variable index,appendmode=1	Prompt appendmode, "Append to potential Profile ?", popup, "Yes;No"	PauseUpdate;Silent 1		String poswvnm,wvnm,wnlist,cmd,dcmd,enewv,cc	Variable index2,ofs	if(appendmode!=1)		Display /W=(3,41,636,476)	Endif	ScalePsi2(index,0.5)	poswvnm="poswv_"+num2istr(index)	wnlist=WaveList("psi2_"+num2istr(index)+"*",";", "")	print wnlist	index2=0	do		wvnm=StringFromList(index2, wnlist)		if(strlen(wvnm)==0)			break		endif//		enewv="Ene"+wvnm[4,strlen(wvnm)]		print enewv		WaveStats/Q $enewv		ofs=V_max//		Append $wvnm vs $poswvnm		cc= "rgb("+wvnm+")="+JMRGBcolor(index2)		cmd="Append "+wvnm+" vs "+poswvnm+";ModifyGraph gaps("+wvnm+")=0"		cmd=cmd+",offset("+wvnm+")={0,"+num2str(ofs)+"},"+cc		cc= ", rgb("+enewv+")="+JMRGBcolor(index2)		cmd=cmd+cc		Execute cmd		index2+=1	while(1)//	Legend/N=text1/F=0/A=MC/X=-38.04/Y=39.31	if(appendmode==1)//		Label right "psi"	else		Label left "potential (\\U)"		Label bottom "position (\\U)"	endifEndMacro ScalePsi2(index,factor)	Variable index,factor=0.5	PauseUpdate;Silent 1		Variable index2,ymax=0	String wvnm,wvnm2,wnlist	wnlist=WaveList("psi_"+num2istr(index)+"*",";", "")//create psi^2 and find maximum	wnlist=WaveList("psi_"+num2istr(index)+"*",";", "")	index2=0	do		wvnm=StringFromList(index2, wnlist)		if(strlen(wvnm)==0)			break		endif		wvnm2="psi2"+wvnm[3,strlen(wvnm)]		//print wvnm2		duplicate/O $wvnm,$wvnm2		$wvnm2=$wvnm*$wvnm		WaveStats/Q $wvnm2		if(ymax<V_max)			ymax=V_max		endif		index2+=1	while(1)// scale psi^2	wnlist=WaveList("psi2_"+num2istr(index)+"*",";", "")	index2=0	do		wvnm=StringFromList(index2, wnlist)		if(strlen(wvnm)==0)			break		endif		$wvnm/=(ymax/factor)		index2+=1	while(1)//		Append $wvnm vs $poswvnm//		cmd=dcmd+wvnm+" vs "+poswvnm+";ModifyGraph gaps("+wvnm+")=0"//		Execute cmdEndMacro LoadSniderResultAll(pathName,startindex,wantToDisp)	String pathName="_New Path_"	Variable wantToDisp=1,startindex	Prompt pathName, "Name of path containing text files", popup PathList("*", ";", "")+"_New Path_"	Prompt startindex,"Starting Index"	Prompt wantToDisp, "Do you want to display graphs?", popup, "Yes;No"	Silent 1; PauseUpDate		String fileName,ftype=".out"	Variable index=startindex	if (CmpStr(PathName, "_New Path_") == 0)		// user selected new path ?		NewPath/O data			// this brings up dialog and creates or overwrites path		PathName = "data"	endif		do		fileName = IndexedFile($pathName, index,ftype)		if(strlen(fileName)==0)			break		endif		Print "loding file ",filename		LoadPotential(fileName,pathName,index,wantToDisp)		index+=1	while(1)		if(Exists("temporaryPath"))		KillPath temporaryPath	endifEnd