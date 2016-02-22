#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "MCAsub"

Macro ReadMCA8000D(fileName,pathName,waveName,flag,timediv)
	String fileName,pathName="home",waveName
	Variable flag=2,timediv=1e-12
	Prompt flag,"swap channel ?",popup,"no;yes"

	Silent 1; PauseUpDate

	Variable /D ref
	Variable IFlag,INo,ISeg,IReal,ILive,IStach,ISize
	
	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=".mca" ref
		fileName= S_fileName
	endif
	print fileName

	if (strlen(waveName)<1)
		waveName="chn"+wname(fileName)
	endif

//	LoadWave /N=dummywave/P=$pathName /B=columnInfoStr /C /D /E=editCmd  /F={...} /G /H /J /K=k  /L={...} /M /O   /Q/ /T /U={...} /V={...} /W] fileName
	LoadWave /N=dummywave/P=$pathName/J/D/K=0/L={0,12,8192,0,0} filename
// swap
//	waveName = GetStrFromList(S_waveNames,0,";")
	if(flag==2) then
		Duplicate/O dummywave0,tmpwave
		tmpwave = -x
		Sort tmpwave tmpwave,dummywave0
		KillWaves/Z tmpwave
	endif
//
	Duplicate/O dummywave0,$waveName

End