#pragma rtGlobals=1		// Use modern global access method.

// MadMaxProcs.ipf
// by J. Motohisa
// Collections of macros for "MadMax" program
// requires "xrd.ipf"and "wname.ipf"

// 2012/05/22 ver 0.02a: a lot of modification
// 2012/03/13 ver 0.01: first version

#include "XRD"
#include "wname"
//#include "StrRpl"

Macro InitMadMaxProcs()
	PauseUpdate; Silent 1
//	String g_pathName
	NewPath/C/O/M="MadMax data folder ?" MadMaxPath
	init_materials()
End

Function/S LoadMadMax0(fileName,pathName,wnm,suffix)
	String fileName,pathName,wnm,suffix

	Variable ref
	String xwvs,ywvs
	Wave dest=$wnm
	
	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=suffix ref
		fileName= S_fileName
//		print filename
	endif
	
	LoadWave/G/D/N=$"dummy"/W/P=$pathName/Q fileName
	if(V_flag==0)
		return("")
	endif
	xwvs=StringFromList(0,S_WaveNames,";")		
	ywvs=StringFromList(1,S_WaveNames,";")
	Wave xwv=$xwvs
	Wave ywv=$ywvs
	WaveStats/Q xwv
	SetScale/I x,V_min,V_max,"",ywv
	Duplicate/O ywv,$wnm
	
	Variable len=strlen(fileName)
	String fn=fileName[0,len-5]
	Return(fn)
End

// load sim and nom file
Macro LoadMadMax(basename,pathName)
	String basename,pathName="MadMaxPath"
	Prompt basename,"base file name"
	Prompt pathName,"path name for MadMax data",popup,"MadMaxPath;_New_"
	PauseUpdate; Silent 1
	
	String exp_name=basename+"_exp"
	String nom_name=basename+"_nom"
	String sim_name=basename+"_sim"
	String fileName,s,fnb
	Variable ref
	
	if(strlen(pathName)==0)
		pathName="MadMaxPath"
	endif
	
	PathInfo $pathName
	if(V_Flag==0)
		NewPath/C/O/M="MadMax data folder ?" MadMaxPath
		pathName="MadMaxPath"
	endif
	
	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=".sim.exp.nom" ref
		fileName= S_fileName
//		print filename
	endif
	fnb=wname(fileName[0,strlen(fileName)-5])
	
	Display
//	fileName=fnb+".exp"
//	s=LoadMadMax0(fileName,pathName,exp_name,".exp")
//	if(strlen(s)>0)
//		print "EXP file loaded"
//		AppendToGraph $exp_name
//	endif
	fileName=fnb+".sim"
	s=LoadMadMax0(fileName,pathName,sim_name,".sim")
	if(strlen(s)>0)
		print "SIM file loaded"
//		print s
		AppendToGraph $sim_name
		ModifyGraph rgb($sim_name)=(0,0,65280)
	endif
	fileName=fnb+".nom"
	s=LoadMadMax0(fileName,pathName,nom_name,".nom")
	if(strlen(s)>0)
		print "NOM file loaded"
		print fnb
		AppendToGraph $nom_name
		ModifyGraph rgb($nom_name)=(0,65280,0)
	endif
	ModifyGraph log(left)=1
End

Macro LoadMadMaxAll(basename,pathName)
	String basename,pathName="MadMaxPath"
	Prompt basename,"base file name"
	Prompt pathName,"path name for MadMax data",popup,"MadMaxPath;_New_"
	PauseUpdate; Silent 1
	
	String exp_name=basename+"_exp"
	String nom_name=basename+"_nom"
	String sim_name=basename+"_sim"
	String fileName,s,fnb
	Variable ref
	
	if(strlen(pathName)==0)
		pathName="MadMaxPath"
	endif
	
	PathInfo $pathName
	if(V_Flag==0)
		NewPath/C/O/M="MadMax data folder ?" MadMaxPath
		pathName="MadMaxPath"
	endif
	
	if (strlen(fileName)<=0)
		Open /D/R/P=pathName/T=".sim.exp.nom" ref
		fileName= S_fileName
//		print filename
	endif
	fnb=wname(fileName[0,strlen(fileName)-5])
	
	Display
	fileName=fnb+".exp"
	s=LoadMadMax0(fileName,pathName,exp_name,".exp")
	if(strlen(s)>0)
		print "EXP file loaded"
		AppendToGraph $exp_name
	endif
	fileName=fnb+".sim"
	s=LoadMadMax0(fileName,pathName,sim_name,".sim")
	if(strlen(s)>0)
		print "SIM file loaded"
//		print s
		AppendToGraph $sim_name
		ModifyGraph rgb($sim_name)=(0,0,65280)
	endif
	fileName=fnb+".nom"
	s=LoadMadMax0(fileName,pathName,nom_name,".nom")
	if(strlen(s)>0)
		print "NOM file loaded"
		print fnb
		AppendToGraph $nom_name
		ModifyGraph rgb($nom_name)=(0,65280,0)
	endif
	ModifyGraph log(left)=1
End

Macro SaveAsExp(wvname,filename,rev)
	String wvname
	String filename
	Variable rev=2
	Prompt wvname,"wave name", popup,WaveList("*",";","")
	Prompt filename,"exp file name"
	Prompt rev,"revsere wave ?",popup,"yes;no"
	
	SaveAsExp0($wvname,filename,rev)
End

Function SaveAsExp0(wv,name,rev)
	Wave wv
	String name
	Variable rev
	
	Variable x0,dx
	String fname=name+".exp"
	
	Wave tmpxwv,tmpywv
	Duplicate/O wv,tmpxwv,tmpywv

// check if the unit is "deg"
	String unit=StringByKey("XUNITS",WaveInfo(tmpxwv,0))
	if(cmpstr(unit,"deg")==0)
		x0=DimOffset(tmpxwv,0)
		dx=DimDelta(tmpxwv,0)
	else
		if(cmpstr(unit,"sec")==0)
			x0=(DimOffset(tmpxwv,0))/3600
			dx=DimDelta(tmpxwv,0)/3600
		else
			print "unit not clear"
			x0=DimOffset(tmpxwv,0)
			dx=DimDelta(tmpxwv,0)
		endif
	endif
	SetScale/P x,x0,dx,"deg",tmpxwv,tmpywv

// find peak posistion
	if(rev==1)
		Reverse/P tmpxwv,tmpywv
	endif
	// find peak position
	WaveStats/Q tmpxwv
	Variable minlevel=V_max*0.9
	FindPeak/Q/M=(minlevel) tmpxwv
	Variable peakpos=V_PeakLoc
	
	//rescale wave
	x0=x0-peakpos
	SetScale/P x,x0,dx,"deg",tmpxwv,tmpywv
	tmpxwv=x
//	Save/J/M="\r\n"/F/O tmpxwv,tmpywv as fname
	PathInfo MadMaxPath
	if(V_FLAG==0)
		NewPath/C/O/M="MadMax data folder ?" MadMaxPath
	endif
	Save/J/M="\r\n"/F/O/P=MadMaxPath tmpxwv,wv as fname
	return(0)
End
