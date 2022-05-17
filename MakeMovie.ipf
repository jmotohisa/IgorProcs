#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "LoadIQVimage"

// Create Movie based on the graph/image in "twindow"
// "twave" is displayed in "twindow" and updated following in the waves
// in "twave_list"

Macro InitMakeMovie0(path,twindow,twave,twave_list)
	String path="_New Path_",twindow,twave,twave_list
	Prompt path,"data load path",popup,PathList("*", ";", "")+"_New Path_"
	Prompt twindow,"target window name"
	Prompt twave,"target wave"
	Prompt twave_list,"wave list"
	PauseUpdate; Silent 1
	
	if (CmpStr(path, "_New Path_") == 0)		// user selected new path ?
		NewPath/O imgData			// this brings up dialog and creates or overwrites path
		path = "imgData"
	endif

	String/G g_path=path
	String/G g_twindow=twindow
	String/G g_twave=twave
	String/G g_twave_list=twave_list
End

Macro MakeWaveList(twave_list,prefix,start,stop)
	String twave_list=g_twave_list,prefix
	Variable start,stop
	Prompt twave_list,"wave list"
	Prompt prefix, "prefix of file name"
	Prompt start,"starting index"
	Prompt stop, "ending index"
	PauseUpdate; Silent 1
	
	FMakeWaveList(twave_list,prefix,start,stop)

	g_twave_list=twave_list
End

Macro LoadWaveInList(twave_list,path)
	String twave_list=g_twave_list,path=g_path
	Prompt twave_list,"wave list"
	Prompt path,"data load path",popup,PathList("*", ";", "")+"_New Path_"
	PauseUpdate; Silent 1

	FLoadWaveInList(twave_list,path)
	g_twave_list=twave_list
	g_path=path
End

Macro MakeMovie0(twindow,twave,twave_list,frameRate)
	String twindow=g_twindow,twave=g_twave,twave_list=g_twave_list
	Variable framerate=0.2
	Prompt twindow,"target window name"
	Prompt twave,"target wave"
	Prompt twave_list,"wave list"
	Prompt framerate,"frame rate"
	
	FMakeMovie0(twindow,twave,twave_list,frameRate)

	g_twindow=twindow
	g_twave_list=twave_list
	g_twave=twave
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

Macro ex0_MovieGraph(twindow,twave,twave_list,imgSize)
	String twave=g_twave,twave_list=g_twave_list,twindow=g_twindow
	Variable imgSize=0.1
	Prompt twindow,"target window name"
	Prompt twave,"target wave"
	Prompt twave_list,"wave list"
	Prompt imgSize,"image size"
	PauseUpdate silent 1;
	
	String orig=$twave_list[0]
	Duplicate/O $orig,$twave
	DoWindow $twindow
	if(V_flag==1) // window exists
		DoWindow/F $twindow		
	else
		FShowIqvImage(twave,imgSize)
		DoWindow/C $twindow
	endif

	g_twindow=twindow
	g_twave_list=twave_list
	g_twave=twave
EndMacro

Macro FindMinMaxInWaveList(twindow,twave_list)
	String twave_list=g_twave_list,twindow=g_twindow
 	PauseUpdate; Silent 1
 	
	FFindMinMaxInWaveList(twindow,twave_list)
	g_twindow=twindow
	g_twave_list=twave_list
End

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
		Variable item=FindListItem(filename, dirList)
		if(item>=0)
			FLoadMatrixBinaryWave(wvname,path,filename,sizex,sizey,0,16,4)
		endif
//		fileName = IndexedFile($path,i,ftype)			// get name of next file in path
//		gotFile = CmpStr(fileName, "")
//		file=basename+"_"+num2str(i)
		i+=1
	while(i<n)
End

Macro MakePlotMovie0(twindow,twave_list,frameRate,start,stop,step)
	String twindow=g_twindow,twave_list=g_twave_list
	Variable framerate=0.2,start,stop,step
	Prompt twindow,"target window name"
	Prompt twave,"target wave"
	Prompt twave_list,"wave list"
	Prompt framerate,"frame rate"
	
	
End

Function FMakePlotMovie0(twindow,twave_list,frameRate,start,stop,step,fcreate)
	String twindow,twave_list
	Variable framerate,start,stop,step,fcreate

	Variable nframe=(stop-start)/step
	Variable i
	Wave/T wtwave_list=$twave_list
	Variable n=DimSize(wtwave_list,0)

	DoWindow/F $twindow
	String ttwave
	String worig,wdest
	Variable nn,ii
	for(i=0;i<nframe;i+=1)
		if(i==0 && fcreate==1)
			newmovie/O/F=(frameRate)
		endif
		nn=start+step*i
		for(ii=0;ii<n;ii+=1)
			worig=wtwave_list[ii]
			wdest=worig+"_dup"
			Wave orig=$worig,dest=$wdest
			Duplicate/O/R=[0,nn] orig,dest
//			dest[]=orig[0,nn]
		
//		ModifyGizmo ModifyObject=surface0,objectType=surface,property={ plane,i}
//			ttwave=wtwave_list[i]
//		Duplicate/O $ttwave,$twave
		endfor
//		print start,nn
		DoUpdate
		if(fcreate==1)
			AddMovieFrame
		endif
	endfor
	
	if(fcreate==1)
		closemovie
	endif

End

Function FMakeDupWaves(twave_list)
	String twave_list

	Wave/T wtwave_list=$twave_list
	String worig,wdest
	Variable i,n=DimSize(wtwave_list,0)
	for(i=0;i<n;i+=1)
		worig=wtwave_list[i]
		wdest=worig+"_dup"
		Duplicate/O $worig,$wdest
		wave dest
//		dest=NaN
	endfor	
End