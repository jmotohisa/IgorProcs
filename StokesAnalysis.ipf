#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// StokesAnalysis.ipf

//
#include "LoadIqvImage"

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

Function FDisplayStokes(basename)
	String basename
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
	file = file_basename+"_40_none.dat"
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
	
	Variable sizex=640,sizey=480,imgsize=0.01
	String wvname,file	
	Variable ref
	String extstr=".dat"
	String file_orig="",file_basename

	Wave/T wwlist=$wlist

	if (strlen(file_orig)<=0)
		Open /D/R/P=$path/T=(extstr) ref
		file_orig= S_fileName
	endif
	String path2,file2,pathstr
	path2=parseFilePath(1,file_orig,":",1,0)
//	file2=parseFilePath(0,file_orig,":",1,0)

//	pathstr="imgPath"
//	NewPath pathstr,path2

	wvname="S"+basename+"_0_none"
	file = path2+wwlist[0]+"_0_none.dat"
//	FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
	FLoadMatrixBinaryWave(wvname,path,file,sizex,sizey,0,16,4)

	wvname="S"+basename+"_45_none"
	file = path2+wwlist[1]+"_45_none.dat"
//	FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
	FLoadMatrixBinaryWave(wvname,path,file,sizex,sizey,0,16,4)

	wvname="S"+basename+"_90_none"
	file = path2+wwlist[2]+"_90_none.dat"
//	FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
	FLoadMatrixBinaryWave(wvname,path,file,sizex,sizey,0,16,4)

	wvname="S"+basename+"_135_none"
	file = path2+wwlist[3]+"_135_none.dat"
//	FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
	FLoadMatrixBinaryWave(wvname,path,file,sizex,sizey,0,16,4)

	wvname="S"+basename+"_none_45"
	file = path2+wwlist[4]+"_none_45.dat"
//	FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
	FLoadMatrixBinaryWave(wvname,path,file,sizex,sizey,0,16,4)

	wvname="S"+basename+"_none_135"
	file = path2+wwlist[5]+"_none_135.dat"
//	FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
	FLoadMatrixBinaryWave(wvname,path,file,sizex,sizey,0,16,4)
End

Function FCreateLoadWaveList(target,name1,name2)
	String target,name1,name2
	
	Make/N=6/O/T $target
	Wave/T wtarget =$target
	wtarget[0]=name1 //+"_0_none"
	wtarget[1]=name1 //+"_45_none"
	wtarget[2]=name1 //+"_90_none"
	wtarget[3]=name1 //+"_135_none"
	wtarget[4]=name2 //+"_none_45"
	wtarget[5]=name2 //+"_none_135"
End