﻿#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "LoadIqvImage"

// StokesAnalysis.ipf
// 	Load/Construct/Show/Modify/Resize Images of Stokes parameters S0...S3
// 
// Data are
//		: Aqcuired with (rotatating HWP or QWP) + vertical/horizontal polarizer
//		: saved as binary format for IQV image with 480x640 image
//		: assumed to saved with names
// 		nameHWP_0_none.dat : I(0,phi)
// 		nameHWP_45_none.dat : I(0,phi)
// 		nameHWP_90_none.dat
// 		nameHWP_135_none.dat
// 		nameQWP_none_45.dat
// 		nameQWP_none_135.dat

//	revision history
//		22/03/25 ver 0.2: Some method for Mueller caclculus added
//		??/??/?? ver 0.1: first version

Menu "GraphMarquee"
	"Stokes ZoomIn all",FZoomInStokes()
End

//Menu "Stokes"
//	"Load and Show Stokes",FLoadAndDisplayStokes1(path,nameQWP,nameHWP,basename)
//	"-"
//	"Creat load wave list",	FCreateLoadWaveList(wlist,nameHWP,nameQWP)
//	"Load Stokes image data",FLoadAndDisplayStokes1(path,nameQWP,nameHWP,basename)
//	"Show Stokes image data",FShowStokesParams(basename)
//End

Macro InitStokesAnalysis(path,basename)
	String basename,path="_New Path_"
	Prompt path,"data load path",popup,PathList("*", ";", "")+"_New Path_"
	Prompt basename,"base name wave"
	PauseUpdate; Silent 1
	
	String/G g_basename
	String/G g_path
	
	FInitStokesAnalysis(path,basename)
End

Function FInitStokesAnalysis(path,basename)
	String basename,path
	
	if (CmpStr(path, "_New Path_") == 0)		// user selected new path ?
		NewPath/O StokesData			// this brings up dialog and creates or overwrites path
		path = "StokesData"
	endif
	
	SVAR g_basename
	SVAR g_path
	g_basename=basename
	g_path=path
End

Macro LoadAndDisplayStokes1(path,nameHWP,nameQWP,basename,fpol,fnorm)
	String path=g_path,nameHWP,nameQWP,basename=g_basename
	Variable fpol=1,fnorm=1
	Prompt path,"path name"
	Prompt nameHWP,"base name for lambda/2 data"
	Prompt nameQWP,"base name for lambda/4 data"
	Prompt basename,"base name for data storage"
	Prompt fpol,"polarizer",popup,"vertical;horizontal"
	Prompt fnorm,"normalize S1...S3?",popup,"yes;no"
	PauseUpdate; Silent 1
	
	FLoadAndDisplayStokes1(path,nameHWP,nameQWP,basename,fpol,fnorm)
	g_path=path
	
End

Function FLoadAndDisplayStokes1(path,nameHWP,nameQWP,basename,fpol,fnorm)
	String path,nameHWP,nameQWP,basename
	Variable fpol,fnorm
	
	String wlist="basename_list"
	Variable retval
	
	FCreateLoadWaveList(wlist,nameHWP,nameQWP)
	retval=FLoadStokesImageList(path,wlist,basename)
	if(retval!=1)
		return 0
	endif
	FCalcStokesParams(basename,fpol,fnorm)
	FShowStokesParams(basename)
	return 1
End

Function FCalcStokesParams(basename,fpol,fnorm)
	String basename
	Variable fpol // fpol=1: vertial polarizer, else: horizontal polarizer
	Variable fnorm
	
	String w1,w2,w3,w4,w5,w6
	w1="S"+basename+"_0_none"   // lambda/2 = 0 deg
	w2="S"+basename+"_45_none"  // lambda/2 = 22.5 deg
	w3="S"+basename+"_90_none"  // lambda/2 = 45 deg
	w4="S"+basename+"_135_none" // lambda/2 = 67.5 deg
	w5="S"+basename+"_none_45"  // lambda/4 = 45
	w6="S"+basename+"_none_135" // lambda/4 = 135 (-45)
	Wave ww1=$w1
	Wave ww2=$w2
	Wave ww3=$w3
	Wave ww4=$w4
	Wave ww5=$w5
	Wave ww6=$w6
	String s0,s1,s2,s3
	s0="S"+basename+"_S0"
	s1="S"+basename+"_S1"
	s2="S"+basename+"_S2"
	s3="S"+basename+"_S3"
	Duplicate/O ww1,$s0,$s1,$s2,$s3
	Wave ws0=$s0
	Wave ws1=$s1
	Wave ws2=$s2
	Wave ws3=$s3
	
	if(fpol==1)
		ws0=(ww3+ww1)
		ws1=(ww3-ww1)
		ws2=(ww4-ww2)
		ws3=(ww5-ww6)
	else
		ws0=(ww1+ww3)
		ws1=(ww1-ww3)
		ws2=(ww2-ww4)
		ws3=(ww6-ww5)
	endif
	if(fnorm==1)
		ws1 /=ws0
		ws2 /=ws0
		ws3 /=ws0
	endif
End

Function FLoadStokesImage(path,basename)
	String path,basename
	
	Variable sizex=640,sizey=480,imgsize=0.01
	String wvname,file	
	Variable ref
	String extstr=".dat"
	String file_orig,file_basename
	
//	if(strlen(basename)<=0)
	file_orig=""
	
	if (strlen(file_orig)<=0)
		Open /D/R/P=$path/T=(extstr) ref
		file_orig= S_fileName
	endif
	String path2,file2
	path2=parseFilePath(1,file_orig,":",1,0)
	file2=parseFilePath(0,file_orig,":",1,0)
	
	Print file_orig
	Variable index
	index=strsearch(file_orig,basename+"_0_none",0)
	file_basename=file_orig[0,index-1]
//	print file_basename
	
	wvname="S"+basename+"_0_none"
	file = file_basename+"_0_none.dat"
	FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)

	if(1)
	wvname="S"+basename+"_45_none"
	file = file_basename+"_45_none.dat"
	FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)

	wvname="S"+basename+"_90_none"
	file = file_basename+"_90_none.dat"
	FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)

	wvname="S"+basename+"_135_none.dat"
	file = file_basename+"_135_none"
	FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)

	wvname="S"+basename+"_none_45"
	file = file_basename+"_none_45.dat"
	FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)

	wvname="S"+basename+"_none_135"
	file = file_basename+"_none_135.dat"
	FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
	endif

End

Function FLoadStokesImageList(path,wlist,basename)
	String path,wlist,basename
	
	Variable sizex=640,sizey=480
	String wvname,file	
	String ftype=".dat"
	String dirList = IndexedFile($path, -1, ftype)

	Wave/T wwlist=$wlist
	Variable retval=1

	wvname="S"+basename+"_0_none"
	file = wwlist[0]+"_0_none.dat"
	if(FindListItem(file,dirList)>=0)
//		FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
		FLoadMatrixBinaryWave(wvname,path,file,sizex,sizey,0,16,4)
	else
		print "file ",file," not found."
		retval=0
	endif

	wvname="S"+basename+"_45_none"
	file = wwlist[1]+"_45_none.dat"
	if(FindListItem(file,dirList)>=0)
//		FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
		FLoadMatrixBinaryWave(wvname,path,file,sizex,sizey,0,16,4)
	else
		print "file ",file," not found."
		retval=0
	endif

	wvname="S"+basename+"_90_none"
	file = wwlist[2]+"_90_none.dat"
	if(FindListItem(file,dirList)>=0)
//		FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
		FLoadMatrixBinaryWave(wvname,path,file,sizex,sizey,0,16,4)
	else
		print "file ",file," not found."
		retval=0
	endif

	wvname="S"+basename+"_135_none"
	file = wwlist[3]+"_135_none.dat"
	if(FindListItem(file,dirList)>=0)
//		FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
		FLoadMatrixBinaryWave(wvname,path,file,sizex,sizey,0,16,4)
	else
		print "file ",file," not found."
		retval=0
	endif
	
	wvname="S"+basename+"_none_45"
	file = wwlist[4]+"_none_45.dat"
	if(FindListItem(file,dirList)>=0)
//		FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
		FLoadMatrixBinaryWave(wvname,path,file,sizex,sizey,0,16,4)
	else
		print "file ",file," not found."
		retval=0
	endif

	wvname="S"+basename+"_none_135"
	file = wwlist[5]+"_none_135.dat"
	if(FindListItem(file,dirList)>=0)
//		FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
		FLoadMatrixBinaryWave(wvname,path,file,sizex,sizey,0,16,4)
	else
		print "file ",file," not found."
		retval=0
	endif
	
	return retval
End

Function FCreateLoadWaveList(wlist,nameHWP,nameQWP)
	String wlist,nameHWP,nameQWP
	
	Make/N=6/O/T $wlist
	Wave/T wwlist =$wlist
	wwlist[0]=nameHWP //+"_0_none"
	wwlist[1]=nameHWP //+"_45_none"
	wwlist[2]=nameHWP //+"_90_none"
	wwlist[3]=nameHWP //+"_135_none"
	wwlist[4]=nameQWP //+"_none_45"
	wwlist[5]=nameQWP //+"_none_135"
End

Function FShowStokesParams(basename)
	String basename
	String s0,s1,s2,s3,wdwName

	String/G G_basename
	g_basename=basename
	
	s0="S"+basename+"_S0"
	s1="S"+basename+"_S1"
	s2="S"+basename+"_S2"
	s3="S"+basename+"_S3"

	FSHowIqvImage(s0,0.01)
	wdwName="S0_"+basename+"_win"
	DoWindow/C $wdwName
	ModifyImage $s0 ctab= {*,*,Rainbow,0}

	FSHowIqvImage(s1,0.01)
	wdwName="S1_"+basename+"_win"
	DoWindow/C $wdwName
	ModifyImage $s1 ctab= {-1,1,Rainbow,0}

	FSHowIqvImage(s2,0.01)
	wdwName="S2_"+basename+"_win"
	DoWindow/C $wdwName
	ModifyImage $s2 ctab= {-1,1,Rainbow,0}

	FSHowIqvImage(s3,0.01)
	wdwName="S3_"+basename+"_win"
	DoWindow/C $wdwName
	ModifyImage $s3 ctab= {-1,1,Rainbow,0}
End

Function FModifyStokesImageRange(basename,xmin,xmax,ymin,ymax)
	String basename
	Variable xmin,xmax,ymin,ymax
	
	String wdwName
	print xmin,xmax,ymin,ymax
	wdwName="S0_"+basename+"_win"
	DoWindow/F $wdwName
	SetAxis left ymin,ymax
	SetAxis bottom xmin,xmax
	
	wdwName="S1_"+basename+"_win"
	DoWindow/F $wdwName
	SetAxis left ymin,ymax
	SetAxis bottom xmin,xmax
	
	wdwName="S2_"+basename+"_win"
	DoWindow/F $wdwName
	SetAxis left ymin,ymax
	SetAxis bottom xmin,xmax
	
	wdwName="S3_"+basename+"_win"
	DoWindow/F $wdwName
	SetAxis left ymin,ymax
	SetAxis bottom xmin,xmax
	
End

Function FZoomInStokes()
	GetMarquee left, bottom
	String basename
	SVAR G_basename
	basename=G_basename
	if (V_flag == 0)
		Print "There is no marquee"
	else
		FModifyStokesImageRange(basename,V_left,V_right,V_bottom,V_top)
	endif
End

Macro ResizeStokesImageAll(basename,imgsize)
	Variable imgsize
	String basename=g_basename
	pauseUpdate; Silent 1
	
	FResizeStokesImageAll(basename,imgsize)
	g_basename=basename
End

Function FResizeStokesImageAll(basename,imgsize)
	Variable imgsize
	String basename
	
	String wdwName
	wdwName="S0_"+basename+"_win"
	DoWindow/F $wdwName
	FResizeImages(imgsize)
	
	wdwName="S1_"+basename+"_win"
	DoWindow/F $wdwName
	FResizeImages(imgsize)
	
	wdwName="S2_"+basename+"_win"
	DoWindow/F $wdwName
	FResizeImages(imgsize)
	
	wdwName="S3_"+basename+"_win"
	DoWindow/F $wdwName
	FResizeImages(imgsize)
	
End

// Stokes parameters: Stokes parameters consist of 4 waves.
//
// Convert Ex and Ey into Stokes parameters (assume lineary polarized and S3=0)
Function SfromExEy(basename,exname,eyname,fnorm)
	String basename,exname,eyname
	Variable fnorm

	Wave wEx=$exname
	Wave wEy=$eyname
	String stokename
	
	stokename="S"+basename+"_S0"
	Duplicate/O wEx,$stokename
	Wave wS0=$stokename
	stokename="S"+basename+"_S1"
	Duplicate/O wEx,$stokename
	Wave wS1=$stokename
	stokename="S"+basename+"_S2"
	Duplicate/O wEx,$stokename
	Wave wS2=$stokename
	stokename="S"+basename+"_S3"
	Duplicate/O wEx,$stokename
	Wave wS3=$stokename

// S2=2*Ex*Ey*cos(gamma), S3=2*Ex*Ey*sin(gamma), and gamma=0 (or pi) for linearly polarized light

	wS0=wEx^2+wEy^2
	wS1=wEx^2-wEy^2
	wS2=2*wEx*wEy
	wS3=0
	if(fnorm==1)
		wS1/=wS0
		wS2/=wS0
	endif
End

// Mueller matrix
// Linear polarizer (with polarization angle theta)
Function MM_MakeLinPol(dest,theta)
	String dest
	Variable theta // in degree
	Make/O/N=(4,4) $dest
	Wave wdest=$dest
	Variable th2=theta*pi/180*2
	
	wdest[0][0]=1
	wdest[1][0]=cos(th2)
	wdest[2][0]=sin(th2)
	wdest[3][0]=0
	wdest[0][1]=cos(th2)
	wdest[1][1]=cos(th2)^2
	wdest[2][1]=cos(th2)*sin(th2)
	wdest[3][1]=0
	wdest[0][2]=sin(th2)
	wdest[1][2]=cos(th2)*sin(th2)
	wdest[2][2]=sin(th2)^2
	wdest[3][2]=0
	wdest[0][3]=0
	wdest[1][3]=0
	wdest[2][3]=0
	wdest[3][3]=0
	wdest/=2
End

// Quater Waveplate (with polarization angle theta)
Function MM_MakeQWP(dest,theta)
	String dest
	Variable theta // in degree
	Make/O/N=(4,4) $dest
	Wave wdest=$dest
	Variable th2=theta*pi/180*2
	
	wdest[0][0]=1
	wdest[1][0]=0
	wdest[2][0]=0
	wdest[3][0]=0
	wdest[0][1]=0
	wdest[1][1]=cos(th2)^2
	wdest[2][1]=cos(th2)*sin(th2)
	wdest[3][1]=sin(th2)
	wdest[0][2]=0
	wdest[1][2]=cos(th2)*sin(th2)
	wdest[2][2]=sin(th2)^2
	wdest[3][2]=-cos(th2)
	wdest[0][3]=0
	wdest[1][3]=-sin(th2)
	wdest[2][3]=cos(th2)
	wdest[3][3]=0
End

// Half Waveplate (with polarization angle theta)
Function MM_MakeHWP(dest,theta)
	String dest
	Variable theta // in degree
	Make/O/N=(4,4) $dest
	Wave wdest=$dest
	Variable th4=theta*pi/180*4
	
	wdest[0][0]=1
	wdest[1][0]=0
	wdest[2][0]=0
	wdest[3][0]=0
	wdest[0][1]=0
	wdest[1][1]=cos(th4)
	wdest[2][1]=sin(th4)
	wdest[3][1]=0
	wdest[0][2]=0
	wdest[1][2]=sin(th4)
	wdest[2][2]=-cos(th4)
	wdest[3][2]=0
	wdest[0][3]=0
	wdest[1][3]=0
	wdest[2][3]=0
	wdest[3][3]=-1
End

// product of Mueller matrix and Stokes parameters (consisting of 4 waves)
// (for product of Mueller matrix, use MatrixMultiply and copy M_product to desired wave)
Function MulMMSP(dest_basename,MM,SP_basename)

	String dest_basename,MM,SP_basename

	String sname	
	sname="S"+SP_basename+"_S0";Wave wS0=$sname
	sname="S"+SP_basename+"_S1";Wave wS1=$sname
	sname="S"+SP_basename+"_S2";Wave wS2=$sname
	sname="S"+SP_basename+"_S3";Wave wS3=$sname
	
	sname="S"+dest_basename+"_S0";Duplicate/O wS0,$sname;Wave wS0_dest=$sname
	sname="S"+dest_basename+"_S1";Duplicate/O wS0,$sname;Wave wS1_dest=$sname
	sname="S"+dest_basename+"_S2";Duplicate/O wS0,$sname;Wave wS2_dest=$sname
	sname="S"+dest_basename+"_S3";Duplicate/O wS0,$sname;Wave wS3_dest=$sname

	Wave wMM=$MM
	
	wS0_dest = wMM[0][0]*wS0 + wMM[0][1]*wS1 + wMM[0][2]*wS2 + wMM[0][3]*wS3
	wS1_dest = wMM[1][0]*wS0 + wMM[1][1]*wS1 + wMM[1][2]*wS2 + wMM[1][3]*wS3
	wS2_dest = wMM[2][0]*wS0 + wMM[2][1]*wS1 + wMM[2][2]*wS2 + wMM[2][3]*wS3
	wS3_dest = wMM[3][0]*wS0 + wMM[3][1]*wS1 + wMM[3][2]*wS2 + wMM[3][3]*wS3
End
