#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "LoadIQVimage"

// Create Movie based on the graph/image in "twindow"
// "twave" is displayed in "twindow" and updated following in the waves
// in "twave_list"

Macro InitMakeMovie0(path,twindow,twave,twave_list)
	String path,twindow,twave,twave_list
	Prompt path,"data load path",popup,PathList("*", ";", "")+"_New Path_"
	Prompt twindow,"target window name"
	Prompt twave,"target wave"
	Prompt twave_list,"wave list"
	PauseUpdate; Silent 1
	
	if (CmpStr(path, "_New Path_") == 0)		// user selected new path ?
		NewPath/O imgData			// this brings up dialog and creates or overwrites path
		path = "imgData"
	endif

	String/G g_twindow=twindow
	String/G g_twave=twave
	String/G g_twave_list=twave_list
End

Function FMakeMovie0(twindow,twave,twave_list,frameRate)
	String twindow,twave,twave_list
	Variable frameRate
	
	Variable nframe=DimSize($twave_list,0)
	Variable i
	Wave/T wtwave_list=$twave_list

	DoWindow/F $twindow
	String ttwave
	for(i=0;i<nframe;i+=1)
		if(i==0)
			newmovie/O/F=(frameRate)
		endif
//		ModifyGizmo ModifyObject=surface0,objectType=surface,property={ plane,i}
		ttwave=wtwave_list[i]
		Duplicate/O $ttwave,$twave
		DoUpdate
		AddMovieFrame
	endfor
	
	closemovie
End

// Create Movie based on the graph/image in "twindow" of Gizmo window
// "twave" is a 3D wave containg 
// Setup of "twindow" should be finished before calling MakeGizmoMovie0
// surface

Function MakeGizmoMovie0(twindow,twave,frameRate)
	String twindow,twave
	Variable frameRate // 20

	Variable nframe
	Wave ttwave=$twave
	nframe=DimSize(ttwave,2)
	DoWindow/F $twindow

	Variable i
	for(i=0;i<nframe;i+=1)
		if(i==0)
			newmovie/O/F=(framerate)
		endif
		execute("ModifyGizmo ModifyObject=surface0,objectType=surface,property={plane,i}")
		DoUpdate
		addmovieframe
	endfor
	
	closemovie
End

Function MakeGizmoMovie00(frameRate)
	Variable frameRate // 20

	Variable nframe
//	nframe=DimSize(Ex_t,2)
	nframe=40
	// NewGizmo
	// add 3D wave as surface0 
	// ModifyGizmo opName=ortho0, operation=ortho,data={-1.1,1.1,-1.1,1.1,-2,2}

	Variable i
	for(i=0;i<nframe;i+=1)
		if(i==0)
			newmovie/O/F=(framerate)
		endif
		execute("ModifyGizmo ModifyObject=surface0,objectType=surface,property={ plane,i}")
		DoUpdate
		addmovieframe
	endfor
	
	closemovie
End

// example of movieGraph

Window ex0_MovieGraph(twindow,twave,twave_list,imgSize) : Graph
	String twave,twave_list,twindow
	Variable imgSize
	
	String orig=$twave_list[0]
	Duplicate/O $orig,$twave
	DoWindow $twindow
	if(V_flag==1) // window exists
		DoWindow/F $twindow		
	else
		FShowIqvImage(twave,imgSize)
		DoWindow/C $twindow
	endif
EndMacro

Window ex1_MovieGraph(twindow,twave) : Graph
	String twindow,twave
	Variable imgSize

//	Wave wmBase=$mBase
	PauseUpdate; Silent 1		// building window...
	Display /W=(432,45,901,454)
	AppendImage $twave
	ModifyImage $twave ctab= {*,*,Grays,0}
	ModifyGraph width={perUnit,2.83465,bottom},height={perUnit,2.83465,left}
	ModifyGraph mirror=0
	SetAxis left 90,220
	SetAxis bottom 190,320
	DoWindow/C $twindow
EndMacro

// Find min/max and set
Function FFindMinMaxInWaveList(twindow,twave_list)
    String twave_list,twindow
    
    Wave/T wtarget=$twave_list
    Variable i=0,n=DimSize(wtarget,0)
    String wv
    Variable zmin=1e30,zmax=-1e30

    do
		wv=wtarget[i]
		WaveStats/Q $wv
		if(V_min<zmin)
			zmin=V_min
		endif
		if(V_max>zmax)
			zmax=V_max
		endif
		i+=1
	while(i<n)
	print "min=",zmin,"max=",zmax
	
	DoWindow/F $twindow
	String imgName=StringFromList(0,ImageNameList("",";"))
	ModifyImage $imgName ctab= {zmin,zmax,Grays,0}
End

// Make Wave List for movie
Function FMakeWaveList(twave_list,prefix,start,stop)
	String twave_list,prefix
    Variable start,stop

    Variable i=0,n
    n=stop-start+1
    Make/O/N=(n)/T $twave_list
    Wave/T wtarget=$twave_list
    do
        wtarget[i]=prefix+num2istr(i+start)
        i+=1
    while(i<n)
End

// loader
Function FLoadWaveInList(twave_list,path)
	String twave_list,path

	String wvname,file,fileName,ftype=".dat"
	String dirList = IndexedFile($path, -1, ftype)

	Variable i=0,n=DimSize($twave_list,0)
	Variable sizex=640,sizey=480,imgsize=0.01

	Wave/T wtarget=$twave_list
	do
		wvname=wtarget[i]
		filename=wtarget[i]+".dat"
		if(FindListItem(filename, dirList)>0)
			FLoadMatrixBinaryWave(wvname,path,filename,sizex,sizey,0,16,4)
		endif
//		fileName = IndexedFile($path,i,ftype)			// get name of next file in path
//		gotFile = CmpStr(fileName, "")
//		file=basename+"_"+num2str(i)
		i+=1
	while(i<n)
End
