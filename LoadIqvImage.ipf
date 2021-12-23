#pragma rtGlobals=1		// Use modern global access method.
#include "MatrixOperations2"

// LoadIqvImage.ipf by J. Motohisa
// Load binary image file saved with Iqvsampl4 (LV7 program)
//
// ver 0.1	2006/06/22 : first version
// ver 0.1b 2021/12/23 : ResizeImage functionized

Macro LoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
	Variable sizex=640,sizey=480,imgsize=0.02
	String wvname,path,file
	PauseUpdate;Silent 1
	
	FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
End

Function FLoadIQVImage(wvname,path,file,sizex,sizey,imgsize)
	Variable sizex,sizey,imgsize
	String wvname,path,file
	
	Variable ref
	String extstr=".dat"
	
	if (strlen(file)<=0)
		Open /D/R/P=$path/T=(extstr) ref
		file= S_fileName
	endif
//	print file

	if (strlen(wvname)<1)
		wvname="M"+wname(file)
		print wvname
	endif

	FLoadMatrixBinaryWave(wvname,path,file,sizex,sizey,0,16,4)
	FShowIQVimage(wvname,imgsize)
End Macro

Function FShowIQVimage(wvname,imgsize)
	String wvname
	Variable imgsize
	
	Variable imgsize2
	Display; AppendImage $wvname
	imgsize2=imgsize*28.3465
	ModifyGraph width={perUnit,(imgsize2),bottom},height={perUnit,(imgsize2),left}
End

Macro ShowIQVimage(wvname,imgsize)
	String wvname
	Variable imgsize=0.02
	Prompt wvname,"wave name",popup,WaveList("*",";","DIMS:2")
	PauseUpdate;Silent 1
	FShowIQVimage(wvname,imgsize)
	Execute("JEG_AddColorLegend(wvname)")
End

Function FResizeImages(imgsize)
	Variable imgsize
	
	Variable imgsize2
	imgsize2=imgsize*28.3465
	ModifyGraph width={perUnit,(imgsize2),bottom},height={perUnit,(imgsize2),left}
End

Macro ResizeImages(imgsize)
	Variable imgsize
	PauseUpdate;Silent 1
	
	FResizeImages(imgsize)
End

Macro RemoveAxes()
	PauseUpdate;Silent 1
	ModifyGraph tick(left)=3,noLabel(left)=2,axOffset(left)=-10,standoff(left)=0
	ModifyGraph axThick(left)=0
	ModifyGraph tick(bottom)=3,noLabel(bottom)=2,axOffset(bottom)=-10,standoff(bottom)=0
	ModifyGraph axThick(bottom)=0
End	
