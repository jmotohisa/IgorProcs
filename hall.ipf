#pragma rtGlobals=1		// Use modern global access method.
#include <Strings as Lists>
#include "loadDelftdata"

// hall.ipf
// by J. Motohisa
// 
// load (gate-dependent) Hall measurement data and calculate hall concentration and mobility
// data is aquired using "MeasureDelft" program with three different measurement configurations
//
// requires: "loadDelftData"
//		note: LoadDelftData requires "JEG Tools" (http://www.his.com/jguyer/) for MatrixOperations2

// 2001/11/06 ver 0.01: first (saved) version
// 2001/07/03 ver 0.02: hall2 version
// 2007/03/27 ver 0.03: hall3 version and above are merged

//initialization

Macro initHall()
	String/G g_swavenames,g_destw0
End

// configuration 1:
// number of measurement 4:(I+,B=0), (I-,B=0), (I+ with B), (I+ with B)

// configuration 2:
// number of measurement 4:(I+,B=0), (I+,with B), (I- with B), (I-,B=0)

// configureation 3:
// number of measurement 2x2: ((I+,B=0), (I-,B=0)), (I+ with B), (I- with B)

Macro HallMeasDataLoad_config1(fileName,pathName,mag,current,ratio,numdat)
	String fileName
	String pathName="home"
	variable mag=0.3,current=1e-6,ratio=4,numdat=2
	Silent 1; PauseUpDate
	
	String dwname,xwname,ywname,destw,destw0,wnames,cmdstr
	String vdp0,vhp0,vdm0,vhm0,vdpb,vhpb,vdmb,vhmb
	String sigma,ns,mue
	Variable ref
	Variable index,index1,index2
	
	halldataload(fileName,pathName,numdat)
	destw0=g_destw0
	wvnms=g_swavenames
	RenameForHall_config1(destw0,wvnms,numdat)
	CalcHall(destw0,mag,current,ratio)
End

//
Macro HallMeasDataLoad_config2(fileName,pathName,mag,current,ratio,numdat)
	String fileName
	String pathName="home"
	variable mag=0.3,current=1e-6,ratio=4,numdat=2
	Silent 1; PauseUpDate
	
	String dwname,xwname,ywname,destw,destw0,wnames,cmdstr
	String vdp0,vhp0,vdm0,vhm0,vdpb,vhpb,vdmb,vhmb
	String sigma,ns,mue
	Variable ref
	Variable index,index1,index2
	
	halldataload(fileName,pathName,numdat)
	destw0=g_destw0
	wvnms=g_swavenames
	RenameForHall_config2(destw0,wvnms,numdat)
	CalcHall(destw0,mag,current,ratio)
End

Macro HallMeasDataLoad_config3(basename,pathName,mag,current,ratio,numdat)
	String basename="w0"
	String pathName="home"
	variable mag=0.3,current=1e-6,ratio=4,numdat=2
	PauseUpdate; Silent 1

	String filename="",wvnms

// for b=0 data
	halldataload(fileName,pathName,numdat)
	wvnms=g_swavenames
	RenameForHallB0(basename,wvnms,numdat)

// for finite B data
	halldataload(fileName,pathName,numdat)
	wvnms=g_swavenames
	RenameForHallBF(basename,wvnms,numdat)

	CalcHall(basename,mag,current,ratio)

End Macro

//// common routines
Macro halldataload(fileName,pathName,numdat)
	String fileName
	String pathName="home"
	Variable numdat=2
	
	String dwname,xwname,ywname,destw,destw0,wnames,cmdstr
	String vdp0,vhp0,vdm0,vhm0,vdpb,vhpb,vdmb,vhmb
	String sigma,ns,mue
	Variable ref
	Variable index,index1,index2
	
	if (strlen(fileName)<=0)
		Open /D/R/P=$pathName/T=".DAT" ref // specific to windows
		fileName= S_fileName
	endif
	
	LoadWave/G/D/N=$"dummy"/W/P=$pathName/Q fileName
	if(V_flag==0)
		return
	endif
//	print S_wavenames
	
	g_destw0=strrpl(wname(fileName),"-","_")
//	print destw0
	index=0
	index1=0

	do
		dwname = GetStrFromList(S_waveNames,index,";")
		if(strlen(dwname)==0)
			break
		endif
//		print dwname
		xwname=GetStrFromList(S_waveNames,index+1,";")
		index2=0
		wnames=""
		do
			if(index2==numdat)
				break
			endif
			ywname=GetStrFromList(S_waveNames,index+2+index2,";")
			wnames=wnames+","+ywname
			index2+=1
		while(1)
		print xwname,wnames
		cmdstr="Sort "+xwname+","+xwname+wnames
		Execute cmdstr
		WaveStats/Q $xwname
		index2=0
		do
			if(index2==numdat)
				break
			endif
			ywname=GetStrFromList(S_waveNames,index+2+index2,";")
			SetScale/I x,V_min/1000,V_max/1000,"V",$ywname //assmues unit in mV in measuredelft aquisition
			SetScale y,0,1,"V",$ywname
			index2+=1
		while(1)
		index+=2+numdat
		index1+=numdat
	while(1)
	g_swavenames=S_wavenames
End Macro

Macro CalcHall0(vdp0,vhp0,vdm0,vhm0,vhpb,vhmb,sigma,ns,mue)
	String vdp0,vhp0,vdm0,vhm0,vhpb,vhmb,sigma,ns,mue
	
	Silent 1;PauseUpdate
	Variable mag=0.3,current=1e-6,ratio=4
	duplicate/O $vdp0,$sigma,$ns,$mue
	
	$sigma = 1/(($vdp0-$vdm0)/2/ratio/current)
	$ns = mag/1.602e-19*current/abs((($vhpb-$vhp0)-($vhmb-$vhm0))/2)
	$mue = $sigma/1.602e-19/$ns
	
	display $ns
	Append/R $mue
End

Macro CalcHall(name,mag,current,ratio)
	String name
	Variable mag=0.3,current=1e-6,ratio=4
	Silent 1;PauseUpdate
	
	Silent 1;PauseUpdate
	String vdp0,vhp0,vdm0,vhm0,vdpb,vhpb,vdmb,vhmb
	String sigma,ns,mue
	String cmd
	
	vdp0="vdp0_"+name
	vhp0="vhp0_"+name
	vdm0="vdm0_"+name
	vhm0="vhm0_"+name
	vdpb="vdpb_"+name
	vhpb="vhpb_"+name
	vdmb="vdmb_"+name
	vhmb="vhmb_"+name
	sigma="sigma_"+name
	ns = "ns_"+name
	mue = "mue_"+name
	
	duplicate/O $vdp0,$sigma,$ns,$mue
	
	$sigma = 1/(($vdp0-$vdm0)/2/ratio/current)
	$ns = mag/1.602e-19*current/abs((($vhpb-$vhp0)-($vhmb-$vhm0))/2)
	$mue = $sigma/1.602e-19/$ns
	
	$ns/=1e15 // unit in 10^11 cm-2
	$mue *=1e4 //unit in cm^2/Vs
	SetScale y,0,1,"",$ns
	SetScale y,0,1,"",$mue
	display $ns
	Append/R $mue
	ModifyGraph mode=3,marker($ns)=5,marker($mue)=19,rgb($mue)=(0,0,65280)
//	cmd=
	Legend/J/N=text0/F=0/A=MC/X=-23.71/Y=35.93 "\\s("+ns+") "+ns+"\r\\s("+mue+") "+mue
	Label left "N\\BS\\M (10\\S11\\M cm\\S-2\\M)"
	Label right "µ (cm\\S2\\M/Vs)"
End

// routines for rename 
// rename for format 1:
Proc RenameForHall_config1(bwname,wavenames,numdat)
	String bwname,wavenames
	Variable numdat=2
	
	Silent 1;PauseUpdate
	
	Variable index,index1
	String vdp0,vhp0,vdm0,vhm0,vdpb,vhpb,vdmb,vhmb
	String ywname
	
	vdp0="vdp0"+"_"+bwname
	vhp0="vhp0"+"_"+bwname
	vdm0="vdm0"+"_"+bwname
	vhm0="vhm0"+"_"+bwname
	vdpb="vdpb"+"_"+bwname
	vhpb="vhpb"+"_"+bwname
	vdmb="vdmb"+"_"+bwname
	vhmb="vhmb"+"_"+bwname
	
	ywname=GetStrFromList(wavenames,2,";")
	Rename $ywname,$vdp0
	ywname=GetStrFromList(wavenames,3,";")
	Rename $ywname,$vhp0
	ywname=GetStrFromList(wavenames,2+(2+numdat),";")
	Rename $ywname,$vdm0
	ywname=GetStrFromList(wavenames,3+(2+numdat),";")
	Rename $ywname,$vhm0
	ywname=GetStrFromList(wavenames,2+(2+numdat)*2,";")
	Rename $ywname,$vdpb
	ywname=GetStrFromList(wavenames,3+(2+numdat)*2,";")
	Rename $ywname,$vhpb
	ywname=GetStrFromList(wavenames,2+(2+numdat)*3,";")
	Rename $ywname,$vdmb
	ywname=GetStrFromList(wavenames,3+(2+numdat)*3,";")
	Rename $ywname,$vhmb
	
End

// rename for configuration 2:
Proc RenameForHall_config2(bwname,wavenames,numdat)
	String bwname,wavenames
	Variable numdat=2
	
	Silent 1;PauseUpdate
	
	Variable index,index1
	String vdp0,vhp0,vdm0,vhm0,vdpb,vhpb,vdmb,vhmb
	String ywname
	
	vdp0="vdp0"+"_"+bwname
	vhp0="vhp0"+"_"+bwname
	vdm0="vdm0"+"_"+bwname
	vhm0="vhm0"+"_"+bwname
	vdpb="vdpb"+"_"+bwname
	vhpb="vhpb"+"_"+bwname
	vdmb="vdmb"+"_"+bwname
	vhmb="vhmb"+"_"+bwname
	
	ywname=GetStrFromList(wavenames,2,";")
	Rename $ywname,$vdp0
	ywname=GetStrFromList(wavenames,3,";")
	Rename $ywname,$vhp0

	ywname=GetStrFromList(wavenames,2+(2+numdat)*3,";")
	Rename $ywname,$vdm0
	ywname=GetStrFromList(wavenames,3+(2+numdat)*3,";")
	Rename $ywname,$vhm0

	ywname=GetStrFromList(wavenames,2+(2+numdat)*1,";")
	Rename $ywname,$vdpb
	ywname=GetStrFromList(wavenames,3+(2+numdat)*1,";")
	Rename $ywname,$vhpb

	ywname=GetStrFromList(wavenames,2+(2+numdat)*2,";")
	Rename $ywname,$vdmb
	ywname=GetStrFromList(wavenames,3+(2+numdat)*2,";")
	Rename $ywname,$vhmb
	
End

// rename for format 3:
Proc RenameForHallB0(bwname,wavenames,numdat)
	String bwname,wavenames
	Variable numdat=2
	
	Silent 1;PauseUpdate
	
	Variable index,index1
	String vdp0,vhp0,vdm0,vhm0,vdpb,vhpb,vdmb,vhmb
	String ywname
	
	vdp0="vdp0"+"_"+bwname
	vhp0="vhp0"+"_"+bwname
	vdm0="vdm0"+"_"+bwname
	vhm0="vhm0"+"_"+bwname
	vdpb="vdpb"+"_"+bwname
	vhpb="vhpb"+"_"+bwname
	vdmb="vdmb"+"_"+bwname
	vhmb="vhmb"+"_"+bwname
	
	ywname=GetStrFromList(wavenames,2,";")
	
	Duplicate/O $ywname,$vhp0
	ywname=GetStrFromList(wavenames,3,";")
	Duplicate/O $ywname,$vdp0
	ywname=GetStrFromList(wavenames,2+(2+numdat),";")
	Duplicate/O $ywname,$vhm0
	ywname=GetStrFromList(wavenames,3+(2+numdat),";")
	Duplicate/O $ywname,$vdm0
	
End

Proc RenameForHallBF(bwname,wavenames,numdat)
	String bwname,wavenames
	Variable numdat=2
	
	Silent 1;PauseUpdate
	
	Variable index,index1
	String vdp0,vhp0,vdm0,vhm0,vdpb,vhpb,vdmb,vhmb
	String ywname
	
	vdp0="vdp0"+"_"+bwname
	vhp0="vhp0"+"_"+bwname
	vdm0="vdm0"+"_"+bwname
	vhm0="vhm0"+"_"+bwname
	vdpb="vdpb"+"_"+bwname
	vhpb="vhpb"+"_"+bwname
	vdmb="vdmb"+"_"+bwname
	vhmb="vhmb"+"_"+bwname
	
	ywname=GetStrFromList(wavenames,2,";")
	Duplicate/O $ywname,$vhpb
	ywname=GetStrFromList(wavenames,3,";")
	Duplicate/O $ywname,$vdpb
	ywname=GetStrFromList(wavenames,2+(2+numdat),";")
	Duplicate/O $ywname,$vhmb
	ywname=GetStrFromList(wavenames,3+(2+numdat),";")
	Duplicate/O $ywname,$vdmb
	
End
